//
//  SoundFiAudioSession.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "SoundFiAudioSession.h"
#include <pthread.h>


/**---------------------------------------------------------------------------------------
 * Smb2PitchShift
 *  ---------------------------------------------------------------------------------------
 */
/** FFT alorithme for hight accurancy analysis
 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
 NSDictionary *parameters = @{@"48.4040428": @"-4.5003953"};
 [manager POST:@"http://188.165.251.201:8064/checkin?sessiontoken=33a74563448b479d229e0ad82084414948e1a9098f5a3c2fcbe030fefea66dda" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
 NSLog(@"JSON: %@", responseObject);
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 NSLog(@"Error Cacahuète: %@", error);
 }];
 This was take from http://www.dspdimension.com/ and modify to apply a hight pass filter, and some modification.
 
 @see fftGetFrequencyHighAccuracy
 */
void smb2PitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize,
                    long osamp, float sampleRate, float *indata, float *outdata,
                    FFTSetup fftSetup, float * frequency,void* userData);



/**---------------------------------------------------------------------------------------
 * MagnitudeSquared
 *  ---------------------------------------------------------------------------------------
 */
float MagnitudeSquared(float x, float y) {
    return ((x*x) + (y*y));
}



/**---------------------------------------------------------------------------------------
 * Int16ToFloat32
 *  ---------------------------------------------------------------------------------------
 */
/** Convert an Int16 to Int32
 
 */
void Int16ToFloat32(SInt16* source,Float32* dest,int numFrames)
{
    for (int i = 0; i < numFrames; i++) {
        dest[i] = source[i] / 32768.0f;
    }
}


/**---------------------------------------------------------------------------------------
 * FixedPointToSInt16
 *  ---------------------------------------------------------------------------------------
 */
/** Convert fixed point 8.24 to Int16
 
 */
void fixedPointToSInt16( SInt32 * source, SInt16 * target, int length ) {
    
    for(int i = 0;i < length; i++ ) {
        target[i] =  (SInt16) (source[i] >> 9);
    }
}


/**---------------------------------------------------------------------------------------
 * FftGetFrequencyHighAccuracy
 *  ---------------------------------------------------------------------------------------
 */
/** FFT function to get frequency of an audio sample
 
 This function is use for foreground processing or ponctual background processing. It can give the frequency close to 1Hz but use pretty much CPU, do not use this all the time or it will use to much battery.
 
 @param inRefCon Typically allow to pass parameters to this function (to make the function working pass a SoundFiAudioSession instance)
 @param inNumberFrames The number of frame use to process audio
 @param sampleBuffer the buffer that contain the audio sample
 @see smb2PitchShift
 */
OSStatus fftGetFrequencyHighAccuracy (
                                      void *inRefCon,
                                      UInt32 inNumberFrames,
                                      SInt16 *sampleBuffer) {
    
    SoundFiAudioSession *THIS = (__bridge SoundFiAudioSession *)inRefCon;
    
    float *outputBuffer = THIS->outputBuffer;
    float *analysisBuffer = THIS->analysisBuffer;
    int nbrEchantillon = THIS-> nbrEchantillon;
    
    FFTSetup fftSetup = THIS->fftSetup;      // fft setup structures need to support vdsp functions
    
    
    uint32_t stride = 1;                    // interleaving factor for vdsp functions
    int bufferCapacity = nbrEchantillon;               // maximum size of fft buffers
    
    float pitchShift = 1.0;                 // pitch shift factor 1=normal, range is .5->2.0
    long osamp = 4;                         // oversampling factor
    long fftSize = nbrEchantillon;                     // fft size
    
    
    float frequency;                        // analysis frequency result
    
    
    //	ConvertInt16ToFloat
    vDSP_vflt16((SInt16 *) sampleBuffer, stride, (float *) analysisBuffer, stride, bufferCapacity );

    pitchShift = (0.5 * 1.5) + .5;
    
    // osamp should be at least 4
    
    osamp = 4;
    fftSize = nbrEchantillon;
    
    smb2PitchShift( pitchShift , (long) inNumberFrames,
                   fftSize,  osamp, (float) THIS->sampleRate,
                   (float *) analysisBuffer , (float *) outputBuffer,
                   fftSetup, &frequency,inRefCon);
    
    
    THIS->sampleFrequency = (int) frequency;
    
    
    // now convert from float to Sint16
    vDSP_vfixr16((float *) outputBuffer, stride, (SInt16 *) sampleBuffer, stride, bufferCapacity );
    
    
    return noErr;
    
    
}


/**---------------------------------------------------------------------------------------
 * FftGetFrequencyLowAccuracy
 *  ---------------------------------------------------------------------------------------
 */
/** FFT function to get frequency of an audio sample
 
 This function is use for background processing. It can give the frequency close to 50Hz but use very few CPU. (Carrafull not enought acurrate for message processing).
 
 @param inRefCon Typically allow to pass parameters to this function (to make the function working pass a SoundFiAudioSession instance)
 @param inNumberFrames The number of frame use to process audio
 @param sampleBuffer the buffer that contain the audio sample
 */
OSStatus fftGetFrequencyLowAccuracy (   void                        *inRefCon,
                                     UInt32 						inNumberFrames,
                                     SInt16                      *sampleBuffer)
{
    
    SoundFiAudioSession *THIS = (__bridge SoundFiAudioSession*)inRefCon;
    
    COMPLEX_SPLIT A = THIS->fftA;                // complex buffers
    
    void *dataBuffer = THIS->dataBuffer;         // working sample buffers
    float *outputBuffer = THIS->outputBuffer;
    float *analysisBuffer = THIS->analysisBuffer;
    
    FFTSetup fftSetup = THIS->fftSetup;          // fft structure to support vdsp functions
    
    // fft params
    
    uint32_t log2n = THIS->fftLog2n;
    uint32_t n = THIS->fftN;
    uint32_t nOver2 = THIS->fftNOver2;
    uint32_t stride = 1;
    int bufferCapacity = (int)THIS->fftBufferCapacity;
    SInt16 index = THIS->fftIndex;
    
    
    // Fill the buffer with our sampled data. If we fill our buffer, run the fft
    
    // NSLog(@"index: %d", index);
    int read = bufferCapacity - index;
    if (read > inNumberFrames) {
        memcpy((SInt16 *)dataBuffer + index, sampleBuffer, inNumberFrames * sizeof(SInt16));
        THIS->fftIndex += inNumberFrames;
    } else {
        memcpy((SInt16 *)dataBuffer + index, sampleBuffer, read * sizeof(SInt16));
        // Reset the index.
        THIS->fftIndex = 0;
        
        // *************** FFT ***************
        // convert Sint16 to floating point
        
        vDSP_vflt16((SInt16 *) dataBuffer, stride, (float *) outputBuffer, stride, bufferCapacity );
        
        // Look at the real signal as an interleaved complex vector by casting it.
        // Then call the transformation function vDSP_ctoz to get a split complex
        // vector, which for a real signal, divides into an even-odd configuration.
        
        vDSP_ctoz((COMPLEX*)outputBuffer, 2, &A, 1, nOver2);
        
        // Carry out a Forward FFT transform.
        
        vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_FORWARD);
        
        // The output signal is now in a split real form. Use the vDSP_ztoc to get
        // an interleaved complex vector.
        
        vDSP_ztoc(&A, 1, (COMPLEX *)analysisBuffer, 2, nOver2);
        
        // Determine the dominant frequency by taking the magnitude squared and
        // saving the bin which it resides in. This isn't precise and doesn't
        // necessary get the "fundamental" frequency, but its quick and sort of works...
        
        // note there are vdsp functions to do the amplitude calcs
        
        float dominantFrequency = 0;
        int bin = -1;
        for (int i=100; i<n; i+=2) {
            float curFreq = MagnitudeSquared(analysisBuffer[i], analysisBuffer[i+1]);
            if ((curFreq > dominantFrequency) && (curFreq >5000000000)) { //1000000000 is the minimal "amplitude" to accept the pic
                dominantFrequency = curFreq;                              // This value may be changed in function of mode
                bin = (i+1)/2;
            }
        }
        
        dominantFrequency = bin*(THIS->sampleRate/bufferCapacity);
        
        THIS->sampleFrequency = (int) dominantFrequency;
        
        
        // Carry out an inverse FFT transform.
        // I think that it can be removed ^^
        
        vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_INVERSE );
        
        float scale = (float) 1.0 / (2 * n);
        vDSP_vsmul(A.realp, 1, &scale, A.realp, 1, nOver2 );
        vDSP_vsmul(A.imagp, 1, &scale, A.imagp, 1, nOver2 );
        
        // convert from split complex to interleaved complex form
        
        vDSP_ztoc(&A, 1, (COMPLEX *) outputBuffer, 2, nOver2);
        
        // now convert from float to Sint16
        
        vDSP_vfixr16((float *) outputBuffer, stride, (SInt16 *) sampleBuffer, stride, bufferCapacity );
        
    }
    
    return noErr;
    
}



/**---------------------------------------------------------------------------------------
 * RenderToneCallback
 *  ---------------------------------------------------------------------------------------
 */
/** A callBack function use in audio processing (emission)
 
 This function is call during the emission mode. It will request an audio sample from hardware, that we fill with our desired sample (at our given frequency) and then put in the mircrophone to create the sound.
 
 @param userData Typically allow to pass parameters to this function (to make the function working pass a SoundFiAudioSession instance)
 @param actionFlags Don't really know what is this but not usefull
 @param audioTimeStamp Don't really know what is this but not usefull
 @param busNumber The number of the bus the function have to use (automatic)
 @param numFrames The number of frame use to process audio
 @param buffers The buffer that contain the audio sample
 
 */
OSStatus renderToneCallback(void *userData,
                            AudioUnitRenderActionFlags *actionFlags,
                            const AudioTimeStamp *audioTimeStamp,
                            UInt32 busNumber,
                            UInt32 numFrames,
                            AudioBufferList *buffers) {
    
    SoundFiAudioSession *THIS=(__bridge SoundFiAudioSession*)userData;
    
    pthread_mutex_lock(&THIS->emissionMutex);
    
    //If emissionMode = TRUE then start sending stuff
    if (THIS->emissionMode) {
        int frequence;
        
        frequence = [THIS getASCIIFrequency];
        [THIS emissionSampleCalcul:frequence :numFrames :(Float32 *)buffers->mBuffers[0].mData];
    }
    pthread_mutex_unlock(&THIS->emissionMutex);
    
    return noErr;
}



/**---------------------------------------------------------------------------------------
 * RenderCallback
 *  ---------------------------------------------------------------------------------------
 */
/** A callBack function use in audio processing (reception)
 
 This function is call during the reception mode. It will request an audio sample from hardware, that we analyse. Before ending the function, you had to set the sample to an empty sample to avoid echo.
 
 @param userData Typically allow to pass parameters to this function (to make the function working pass a SoundFiAudioSession instance)
 @param actionFlags Don't really know what is this but not usefull
 @param audioTimeStamp Don't really know what is this but not usefull
 @param busNumber The number of the bus the function have to use (automatic)
 @param numFrames The number of frame use to process audio
 @param buffers The buffer that contain the audio sample
 
 */
OSStatus renderCallback(void *userData,
                        AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp,
                        UInt32 busNumber,
                        UInt32 numFrames,
                        AudioBufferList *buffers) {
    
    SoundFiAudioSession *THIS=(__bridge SoundFiAudioSession*)userData;
    AudioUnit audioUnit=(THIS->audioUnit);
    int compteur = THIS->compteur;
    
    //If recepetionMode = TRUE then start recording and analysis stuff
    if(THIS->receptionMode)
    {
        AudioUnitSampleType *echantillonAudio;
        OSStatus status = AudioUnitRender(audioUnit, actionFlags, audioTimeStamp,1, numFrames, buffers);
        
        if(status != noErr) {
            NSLog(@"Arror AudioUnitRender %d",(int)status);
            return status;
        }
        
        echantillonAudio=(AudioUnitSampleType*) buffers->mBuffers[0].mData;
        
        fixedPointToSInt16(echantillonAudio, THIS->samplesBuffer, numFrames);
        
        [THIS sampleTreatment:numFrames];
        
        compteur=THIS->compteur;
        buffers->mBuffers[0].mData=THIS->emptySample;
        if(THIS->isInitiate)
        {
            THIS->compteur=compteur+1;
        }
        
        [THIS checkTimeOut];
        
        
    }
    
    return noErr;
}

/**
 
 */

//Private methods
@interface SoundFiAudioSession()

-(void)fftSetup;                                                                    //Setup the fft stuff
-(void)setupCallback;                                                               //Setup the callback variable
-(int)initAudioStreams;                                                             //Setup the Audio route and audio units
-(int)initAudioSession;                                                             //Setup the audioSession spec

-(int)stopProcessingAudio;                                                          //Stop audio processing

-(void)startAnalysis;                                                               //Analysis of the received message

-(void)interruptionDetected:(NSNotification *)notification;                         //Call when the audioEngine is stop by ther process

-(void)activateSoundFiMessaging;                                                    //Activate the messaging function

-(void)desactivateSoundFiMessaging;                                                 //Desactivate the messaging function
@end

@implementation SoundFiAudioSession




#pragma mark - Initialisation method

/**---------------------------------------------------------------------------------------
 * @name Initialisation methods
 * Init
 *  ---------------------------------------------------------------------------------------
 */
/** This is the SoundFiAudioSession init method, this method init every mode (messaging,paiemement and localisation).
 
 This function init all the variables of the engine. By default, the messaging and localisation mode are enable, the engine is configure to allow background tasking by default (that can be change later by the user). This fonction will call every sub init methods.
 
 - initGeoloc
 - initAudioSession
 - setupCallback
 - fftSetup
 - initAudioStreams
 
 Note that every sub function (initGeoloc,initAudioSession ...), would be in the init method, but to simplify the code they have been spitted.
 
 @return Return an instance of SoundFiAudioSession.
 @see initGeoloc
 
 initAudioSession
 
 setupCallback
 
 fftSetup
 
 initAudioStreams
 */
-(SoundFiAudioSession*)init
{
    self=[super init];
    
    mySession = [AVAudioSession sharedInstance];
    
    simpleMessagingMode=TRUE;
    enableBackground=TRUE;
    
    nbrEchantillon=256; //1024
    
    //Notification listening for background and foreground
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(enteredBackground)
                                                 name: @"didEnterBackground"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(enteredForeground)
                                                 name: @"willEnterForeground"
                                               object: nil];
    
    
    
    minimumVolume=0.7;
    engineIsRunning=TRUE;
    
    sampleFrequency=1000;
    
    [self initAudioSession];
    [self setupCallback];
    [self fftSetup];
    [self initAudioStreams];
    
    pthread_mutex_init(&emissionMutex, NULL);
    nbCaracRepeat=0;
    
    [self startAudioUnit:SFReceivingMode:NULL];
    
    return self;
}

/**---------------------------------------------------------------------------------------
 * InitAudioStream
 *  ---------------------------------------------------------------------------------------
 */

/** This method deal with the initilisation of the audioStream, mainly the AudioGraph
 
 This method represent mainly the initialisation of the reception.
 It set all the parameters of stream including IO and mixer and the graph. This function proceed in 6 step :
 
 - Define the ASBD (Audio Stream Basic Description)
 - Define the component description (IO and Mixer)
 - Create graph's node
 - Associate AudioUnit with node
 - Configure AudioUnit (including callback setup)
 - Initialize graph
 
 NOTE : The mixer is not really use here but implement for futur feature.
 
 @see init
 @return 1 un case of error, else 0
 @warning Here some error that can be raised by the function
 
 - NewAUGraph error
 - AUGraphAddNode error
 - AUGraphOpen error
 - AUGraphNodeInfo error
 - AUGraphSetNodeInputCallback error
 - AUGraphInitialize error
 
 */
-(int)initAudioStreams
{
    OSStatus err;
    err=NewAUGraph(&myGraph);
    if (err!=noErr) {NSLog(@"Erreur NewAUGraph");}
    
    //Put the session in play/record mode
#if DEBUG
    NSLog(@"Initialisation des streams audios");
#endif
    /*
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &audioCategory) != noErr) {
        return 1;
    }
    
    UInt32 overrideCategory = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(UInt32), &overrideCategory);
    */
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                                  ASBD configuration                                          */
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    AudioComponentDescription ioComponentDescription;
    ioComponentDescription.componentType = kAudioUnitType_Output;
    ioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    ioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioComponentDescription.componentFlags = 0;
    ioComponentDescription.componentFlagsMask = 0;
    
    //ASBD for mono record
    AudioStreamBasicDescription streamDescription;
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    streamDescription.mFormatID          = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    streamDescription.mBytesPerPacket    = (int)bytesPerSample;
    streamDescription.mFramesPerPacket   = 1;
    streamDescription.mBytesPerFrame     = (int)bytesPerSample;
    streamDescription.mChannelsPerFrame  = 1;                                   // 1 indicates mono
    streamDescription.mBitsPerChannel    = (int)(8 * bytesPerSample);
    streamDescription.mSampleRate        = sampleRate;
    
    //Mixer component description configuration
    AudioComponentDescription mixerComponentDescription;
    mixerComponentDescription.componentType = kAudioUnitType_Mixer;
    mixerComponentDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixerComponentDescription.componentFlags = 0;
    mixerComponentDescription.componentFlagsMask = 0;
    
    
    //Add node to the graph
    err=AUGraphAddNode(myGraph, &ioComponentDescription, &ioNode);
    if (err!=noErr) {NSLog(@"Error AUGraphAddNode1");}
    err=AUGraphAddNode(myGraph, &mixerComponentDescription, &mixerNode);
    if (err!=noErr) {NSLog(@"Error AUGraphAddNode2");}
    
    
    //Open Graph
    err=AUGraphOpen (myGraph);
    if (err!=noErr) {NSLog(@"Error AUGraphOpen");}
    
    //Get the AudioUnit from node
    AUGraphNodeInfo (myGraph,ioNode,NULL,&audioUnit);
    if (err!=noErr) {NSLog(@"Error AUGraphNodeInfo1");}
    AUGraphNodeInfo (myGraph,mixerNode,NULL,&mixerUnit);
    if (err!=noErr) {NSLog(@"Error AUGraphNodeInfo2");}
    
    /////////////////////////////////
    //  Audio unit configuration   //
    /////////////////////////////////
    // Enable input for the I/O unit, which is disabled by default.
    //Bus 1 = input , Bus 0 = output générally speaking
    AudioUnitElement ioUnitInputBus = 1;
    UInt32 enableInput = 1;
    
    AudioUnitSetProperty (
                          audioUnit,
                          kAudioOutputUnitProperty_EnableIO,
                          kAudioUnitScope_Input,
                          ioUnitInputBus,
                          &enableInput,
                          sizeof (enableInput)
                          );
    
    //Set the monoStream format for output
    AudioUnitSetProperty (
                          audioUnit,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Output,
                          ioUnitInputBus,
                          &streamDescription,
                          sizeof (streamDescription)
                          );
    
    
    //////////////////////////////////
    //  Mixer configuration         //
    //////////////////////////////////
    UInt32 busCount   = 2;    // bus count for mixer unit input
#if DEBUG
    NSLog (@"Setting mixer unit input bus count to: %u", (unsigned int)busCount);
#endif
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_ElementCount,
                          kAudioUnitScope_Input,
                          0,
                          &busCount,
                          sizeof (busCount)
                          );
    
    UInt32 maximumFramesPerSlice = 4096;
    
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_MaximumFramesPerSlice,
                          kAudioUnitScope_Global,
                          0,
                          &maximumFramesPerSlice,
                          sizeof (maximumFramesPerSlice)
                          );
    
    //Activitate input bus 1, done here but if we increase the number
    // of output, this must be done with the UI
    AudioUnitParameterValue isOn;
    isOn=kMultiChannelMixerParam_Enable;
    AudioUnitSetParameter (
                           mixerUnit,
                           kMultiChannelMixerParam_Enable,
                           kAudioUnitScope_Input,
                           1,
                           isOn,
                           0
                           );
    //Set the monoStream format
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Input,
                          1,
                          &streamDescription,
                          sizeof (streamDescription)
                          );
    
    //Set the sample rate
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_SampleRate,
                          kAudioUnitScope_Output,
                          0,
                          &sampleRate,
                          sizeof (sampleRate)
                          );
    
    
    //Use a call back in the input bus 1 of the mixer to get the mic
    AURenderCallbackStruct inputCallbackStruct;
    
    inputCallbackStruct.inputProc        = renderCallback;
    inputCallbackStruct.inputProcRefCon  = (__bridge void *)(self);
    
    err = AUGraphSetNodeInputCallback (myGraph,mixerNode,1,&inputCallbackStruct); //1 => input du mixer  0 => sortie
    if(err!=noErr){NSLog(@"Error NodeInputCallBack");}
    
    //  connect the output of the mixer with the output of the IOunit
    // This is mandatory, else the mixer won't need any sample
    // and your callback won't be call.
    AUGraphConnectNodeInput(myGraph, mixerNode, 0, ioNode, 0);
    
    // For display information of the graph (very usefull to debug)
#if DEBUG
    CAShow (myGraph);
#endif
    
    //When everything is configurate you can initialize the graph
    err = AUGraphInitialize (myGraph);
    if(err!=noErr){NSLog(@"Error AUGraphInitialize");}
    
    return 0;
}

/**---------------------------------------------------------------------------------------
 * InitFFT
 *  ---------------------------------------------------------------------------------------
 */

/** Set up variable and array for the fft.
 
 This method simply init a lot of stuff to allow FFT process later.
 
 @see init
 */
-(void)fftSetup {
    UInt32 maxFrames = nbrEchantillon;    // fft size
    
    
    // setup input and output buffers to equal max frame size
    
    dataBuffer = (void*)malloc(maxFrames * sizeof(SInt16));
    outputBuffer = (float*)malloc(maxFrames *sizeof(float));
    analysisBuffer = (float*)malloc(maxFrames *sizeof(float));
    
    // set the init stuff for fft based on number of frames
    
    fftLog2n = log2f(maxFrames);            // log base2 of max number of frames, eg., 10 for 256
    fftN = 1 << fftLog2n;					// actual max number of frames, eg., 256 - what a silly way to compute it
    
    
    fftNOver2 = maxFrames/2;                // half fft size
    fftBufferCapacity = maxFrames;          // yet another way of expressing fft size
    fftIndex = 0;                           // index for reading frame data in callback
    
    // split complex number buffer
    fftA.realp = (float *)malloc(fftNOver2 * sizeof(float));
    fftA.imagp = (float *)malloc(fftNOver2 * sizeof(float));
    
    // zero return indicates an error setting up internal buffers
    
    fftSetup = vDSP_create_fftsetup(fftLog2n, FFT_RADIX2);
    if( fftSetup == (FFTSetup) 0) {
        NSLog(@"Error - unable to allocate FFT setup buffers" );
    }
    
    //Call this two function to do a little trick
    fftGetFrequencyLowAccuracy( (__bridge void*)self, maxFrames, samplesBuffer);
    fftGetFrequencyHighAccuracy( (__bridge void*)self, maxFrames, samplesBuffer);
}


/**---------------------------------------------------------------------------------------
 * EmissionSetup
 *  ---------------------------------------------------------------------------------------
 */

/** Like an emissionInit, this function setup the audioUnit for emission
 
 This method perform the initialisation in 4 steps :
 
 - Create the component description
 - Find the output component
 - Create the ASBD (Audio Stream Basic Description)
 - Assign the component to the AudioUnit
 
 @see init
 */
-(void)emissionSetup {
    //Configure the description for the output component
    AudioComponentDescription DescComposantSortie;
    DescComposantSortie.componentType = kAudioUnitType_Output;
    DescComposantSortie.componentSubType = kAudioUnitSubType_RemoteIO;
    DescComposantSortie.componentManufacturer = kAudioUnitManufacturer_Apple;
    DescComposantSortie.componentFlags = 0;
    DescComposantSortie.componentFlagsMask = 0;
    
    //Find a component matching with the description
    AudioComponent composantSortie = AudioComponentFindNext(NULL, &DescComposantSortie);
    
    //Assign the instance to the uniteSon
    AudioComponentInstanceNew(composantSortie, &emissionUnit);
    
    //Create the callbackStruct and assign it to the RenderTone function
    //inputProcRefCon=self allow us to acces information in the RenderTone function
    AURenderCallbackStruct input;
    input.inputProc = renderToneCallback;
    input.inputProcRefCon = (__bridge void *)(self);
    AudioUnitSetProperty(emissionUnit,kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Input,0,&input,sizeof(input));
    
    
    //ASBD configuration
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = sampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = 4;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = 4;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = 4 * 8;
    
    //Put the ASBD to the uniteSon
    AudioUnitSetProperty(emissionUnit,kAudioUnitProperty_StreamFormat,kAudioUnitScope_Input,0,&streamFormat,sizeof(AudioStreamBasicDescription));
}


/**---------------------------------------------------------------------------------------
 * CallBack setup
 *  ---------------------------------------------------------------------------------------
 */

/** This function init some variables use in the callback methods
 
 @see init
 */
-(void)setupCallback
{
    isInitiate=FALSE;
    isTimeOut=FALSE;
    
    receptionMode=FALSE;
    emissionMode=FALSE;
    
    emptySample=malloc(nbrEchantillon*sizeof(AudioUnitSampleType));
    for (int i=0; i<nbrEchantillon; i++) {
        emptySample[i]=0;
    }
    
    samplesBuffer=(SInt16*)malloc(nbrEchantillon *sizeof(float));
    for (int i=0; i<nbrEchantillon; i++) {
        samplesBuffer[i]=0.;
    }
}


/**---------------------------------------------------------------------------------------
 * InitAudioSession
 *  ---------------------------------------------------------------------------------------
 */

/** Init AudioSession's parameters
 
 This function set the type of audioSession to Play&Record, and init some parameters like : rate, duration, interruptionListener.
 
 @see init
 */
-(int)initAudioSession
{
    NSLog(@"Initialisation de la session audio");
    sampleRate=44100.0;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error: &audioSessionError];
    
    [mySession setPreferredSampleRate: 44100.0 error: &audioSessionError];
    
    [mySession setPreferredIOBufferDuration: ((float)nbrEchantillon/sampleRate) error: &audioSessionError]; //Number of sample must depend of the mode WALE 1024
    // and so the fft size in the code 256 -> 1024 everywhere
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(interruptionDetected:) name:AVAudioSessionInterruptionNotification object:nil];
    
    [mySession setActive:YES error:nil];
    
    return 0;
}


#pragma mark - Emission methods


-(void)emissionSampleCalcul:(int)frequence : (int)numFrames : (Float32 *)buffer
{
    double theta_increment = 2.0 * M_PI * frequence / sampleRate;     // θ(n) = 2πƒ n / r
    
    //This portion is used for fade In and fade Out
    if (frequence == 17800 && amplitude < 0.8)
        amplitude+=0.01;
    else if (frequence == 19728 && amplitude > 0)
        amplitude-=0.01;
    
    //Sinusoïde création
    for (UInt32 frame = 0; frame < numFrames; frame++)
    {
        buffer[frame] = 0;
        buffer[frame] = sin(theta) * amplitude;
        
        theta += theta_increment;
        if (theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
    }
}



-(int)getASCIIFrequency
{
    int frequence;
    
    [self.delegate progressStatut:(((float)compteur)/[myMessage length])];
    
    if (initSequence) {
        if (nbrRepeatInit>=18) {
            initSequence=FALSE;
        }
        nbrRepeatInit++;
        return 17800;
    }
    
    if (compteur < [myMessage length]) {
        frequence=18000 +(((int)[myMessage characterAtIndex:compteur]-32)*18);
    }
    else {
        if (emissionCanBeStop) {
            emissionCanBeStop=FALSE;
            [self.delegate finishEmission];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,1), dispatch_get_main_queue(), ^{
                [self relaunchReception];
            });
#if DEBUG
            NSLog(@"STOP");
#endif
        }
        return 19728;
    }
    
    if (nbCaracRepeat==4) {
        compteur = compteur+1;
        nbCaracRepeat = 0;
    }
    else
        nbCaracRepeat=nbCaracRepeat+1;
    
    return frequence;
}


#pragma mark - Reception Methods

-(void)sampleTreatment:(int)numFrames {
    if (!(isInitiate)){
        fftGetFrequencyLowAccuracy( (__bridge void*)self, numFrames, samplesBuffer);    //Background FFT
    }
    else {
        fftGetFrequencyHighAccuracy( (__bridge void*)self, numFrames, samplesBuffer);   //Foreground FFT
    }
    
    if (simpleMessagingMode)
        [self messagingReceptionSampleTreatment];
}
/**---------------------------------------------------------------------------------------
 * @name Reception methods
 * MessagingReceptionSampleTreatment
 *  ---------------------------------------------------------------------------------------
 */
/** Treatment of simple messenging frequency
 
 @see sampleTreatment
 */
-(void)messagingReceptionSampleTreatment{
    
    if(isInitiate) {
        
        if (sampleFrequency>=17995 && sampleFrequency<=19710) {                 //Ajout d'un caractère à la chaine finale
            NSString *res = [NSString stringWithFormat:@"%c",(char)((sampleFrequency-17995)/18+32)];
            [messageReceive appendString:res];
            compteur=0;
        }
        else if(sampleFrequency>=19720 && sampleFrequency<=19736) {             //Fin du message
#if DEBUG
            NSLog(@"Stop");
#endif
            
            //Finalisation de la réception
            compteur=0;
            [self startAnalysis];
            isInitiate=FALSE;
        }
        
    }
    else {
        if (sampleFrequency>=17650 && sampleFrequency<17950 && !isInitiate) {   //Détection d'un début de message
#if DEBUG
            NSLog(@"Gogo");
#endif
            
            //Démarrage de l'écoute
            [self.delegate startingReception];
            compteur=0;
            isInitiate=TRUE;
            
        }
    }
    
    
}



#pragma mark - TimeOut methods


-(void)checkTimeOut
{
    int limite=0;
    
    //Affecte la limite en fonction du mode qui a déclenché le timeout
    if(isInitiate)
        limite=300;
    
    
    if (isInitiate && compteur>limite) {    //The time out must depend of the mode use WALE
#if DEBUG
        if (isInitiate)
            NSLog(@"TimeOut messaging");
#endif
        
        //Remise à 0 du mode géo et message
        isInitiate=FALSE;
        
        
        if (simpleMessagingMode)
            [self startAnalysis];
    }
    
}

#pragma mark - Audio Session interruption detection

/**---------------------------------------------------------------------------------------
 * @name Audio Session interruption detection methods
 * InterruptionDetected
 *  ---------------------------------------------------------------------------------------
 */
/** Detect the interruption flag of the audioSession.
 
 This function handle any NSNotifiaction corresponding to an interruption (corresponding to a AVAudioSessionInterruptionNotification). And have the value AVAudioSessionInterruptionTypeKey.
 
 
 @param notification The NSNotification that was raised by the interruption
 
 */
-(void)interruptionDetected:(NSNotification *)notification
{
    //Check the type of notification, especially if you are sending multiple AVAudioSession events here
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
#if DEBUG
        NSLog(@"%@",[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey]);
#endif
        //Check to see if it was a Begin interruption
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
#if DEBUG
            NSLog(@"Interruption began!");
#endif
            [self stopProcessingAudio];
            
        } else {
#if DEBUG
            NSLog(@"Interruption ended!");
#endif
            dispatch_time_t restartTime = dispatch_time(DISPATCH_TIME_NOW,1.5 * NSEC_PER_SEC);
            
            dispatch_after(restartTime, dispatch_get_global_queue(0, 0), ^{
                [self startAudioUnit:SFReceivingMode:NULL];
            });
        }
    }
}


#pragma mark - Analysis methods


/**---------------------------------------------------------------------------------------
 * @name Analysis methods
 * AnalysisPhase1
 *  ---------------------------------------------------------------------------------------
 */
/** This is the first step of the analysis
 
 The purpose of this method is to remove init dans stop string that can be place in the message that is send. Actually you have to manually change it if you want. The default init and stop string are :
 
 - init:
 - :stop
 
 @see startAnalysis
 */
-(void)analysisPhase1
{
    NSArray *component;
    component=[messageReceive componentsSeparatedByString:@"init:"];
    component=[component[[component count]-1] componentsSeparatedByString:@":stop"];
    messageReceive=component[0];
}


/**---------------------------------------------------------------------------------------
 * AnalysisPhase2
 *  ---------------------------------------------------------------------------------------
 */
/** Second step of the analysis phase
 
 The purpose of the phase is analysing the string and remove some pattern. We are looking for substring like "aba", and considère that "b" is an error and should be a "a", because each caracter are repeated 4 times. The difference in the ASCII table must be less than 1 to proced to the correction. (wont work with "bkb")
 
 @see startAnalysis
 
 */
-(void)analysisPhase2
{
    NSMutableString *chainePhase2=[[NSMutableString alloc]init];
    int i=1;
    
    [chainePhase2 appendFormat:@"%c",[messageReceive characterAtIndex:0]];
    while (i<[messageReceive length]-1) {
        char previous=[messageReceive characterAtIndex:i-1];
        char current=[messageReceive characterAtIndex:i];
        char next=[messageReceive characterAtIndex:i+1];
        
        int ecart=previous-current;
        
        if (previous == next) {
            if (ecart==0)
                [chainePhase2 appendFormat:@"%c",current];
        }
        else
            [chainePhase2 appendFormat:@"%c",current];
        i++;
    }
    [chainePhase2 appendFormat:@"%c",[messageReceive characterAtIndex:[messageReceive length]-1]];
    
    messageReceive=[[NSMutableString alloc]init];
    messageReceive=chainePhase2;
}


/**---------------------------------------------------------------------------------------
 * AnalysisPhase3
 *  ---------------------------------------------------------------------------------------
 */
/** Third step of the analysis phase
 
 The purpose of the phase is analysing the string and remove some pattern. We are looking for substring like "bacb", and considère that "ac" is an error and should be "bb", because each caracter are repeated 4 times. The difference in the ASCII table must be less than 1 to proced to the correction. (wont work with "bjkb")
 
 @see startAnalysis
 
 */
-(void)analysisPhase3 {
    int i=0;
    NSMutableString *chainePhase3=[[NSMutableString alloc]init];
    
    while (i<[messageReceive length]-3) {
        char un=[messageReceive characterAtIndex:i];
        char deux=[messageReceive characterAtIndex:i+1];
        char trois=[messageReceive characterAtIndex:i+2];
        char quatre=[messageReceive characterAtIndex:i+3];
        
        if(un==quatre){
            if (un-deux!=0 && un-trois!=0) {
                [chainePhase3 appendFormat:@"%c",un];
                i=i+3;
            }
            else
            {
                [chainePhase3 appendFormat:@"%c",un];
                i++;
            }
        }
        else {
            [chainePhase3 appendFormat:@"%c",un];
            i++;
        }
        
    }
    
    while (i<[messageReceive length]) {
        char un=[messageReceive characterAtIndex:i];
        [chainePhase3 appendFormat:@"%c",un];
        i++;
    }
    
    messageReceive=[[NSMutableString alloc]init];
    messageReceive=chainePhase3;
    
}




/**---------------------------------------------------------------------------------------
 * AnalysisPhase4
 *  ---------------------------------------------------------------------------------------
 */
/** Fourth step of the analysis phase
 
 The purpose of the phase is analysing the string and remove some pattern. We are looking for substring like "fgg", and considère that "f" is an error and should be "g", because each caracter are repeated 4 times. The difference in the ASCII table must be less than 1 to proced to the correction. (wont work with "bcc")
 
 This function is similar to analysisPhase2.
 
 @see startAnalysis
 @see analysisPhase2
 */
-(void)analysisPhase4
{
    int i=0;
    NSMutableString *chainePhase4=[[NSMutableString alloc]init];
    
    while (i<[messageReceive length]-2) {
        char un=[messageReceive characterAtIndex:i];
        char deux=[messageReceive characterAtIndex:i+1];
        char trois=[messageReceive characterAtIndex:i+2];
        
        if((un==deux && trois!=deux)|| (un==trois && trois!=deux)) {
            if (fabs(trois-deux)==1) {
                [chainePhase4 appendFormat:@"%c",un];
                [chainePhase4 appendFormat:@"%c",un];
                [chainePhase4 appendFormat:@"%c",un];
                i=i+3;
            }
            else {
                [chainePhase4 appendFormat:@"%c",un];
                i++;
            }
        }
        else if(deux==trois && un!=deux) {
            if (fabs(un-deux)==1) {
                [chainePhase4 appendFormat:@"%c",deux];
                [chainePhase4 appendFormat:@"%c",deux];
                [chainePhase4 appendFormat:@"%c",deux];
                i=i+3;
            }
            else {
                [chainePhase4 appendFormat:@"%c",un];
                i++;
            }
        }
        else {
            [chainePhase4 appendFormat:@"%c",un];
            i++;
        }
        
    }
    
    while (i<[messageReceive length]) {
        char un=[messageReceive characterAtIndex:i];
        [chainePhase4 appendFormat:@"%c",un];
        i++;
    }
    
    messageReceive=[[NSMutableString alloc]init];
    messageReceive=chainePhase4;
}


/**---------------------------------------------------------------------------------------
 * AnalysisPhase5
 *  ---------------------------------------------------------------------------------------
 */
/** Fifth step of the analysis phase
 
 The purpose of the phase is analysing the string and deduct the good caracter. In the string, we consider that every caracter that is repeated 2 times is a valid caracter. And if it's repeated more than 5 times, it's a double letter.
 
 Following this logic if we have this cases :
 
 - "aa" -> a
 - "abhgcc" -> c
 - "aaaaaa" -> aa
 
 @see startAnalysis
 
 */
-(void)analysisPhase5
{
    int i=0;
    int compt=0;
    NSMutableString *chaineFinale=[[NSMutableString alloc]init];
    while (i<[messageReceive length]-2) {
        NSString *un=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i]];
        NSString *deux=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i+1]];
        if ([un isEqualToString:deux]) {
            [chaineFinale appendString:un] ;
            i=i+2;
            while ([[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i]]isEqualToString:un] && (i<[messageReceive length]-1)) {
                i++;
                compt++;
                if (compt>5) {
                    [chaineFinale appendString:un];
                    compt=0;
                }
            }
        }
        else {
            i++;
        }
        
        compt=0;
    }
    messageReceive=[[NSMutableString alloc]init];
    messageReceive=chaineFinale;
    
}


/**---------------------------------------------------------------------------------------
 * AnalysisPhase6
 *  ---------------------------------------------------------------------------------------
 */
/** Sixth step of the analysis phase
 
 The purpose of the phase is analysing the string and correct the wrong word. This function proceed by analysing each word of the final text and check if it match with a word in the dictionnary.
 
 In this way, a word like "Helo" would be correct to "Hello".
 
 Note : Be carefull, this phase could lead to error, for example, it don't work on url (don"t worry it's design to ignor URL). Morevover this phase is optional and can be disable by changing the #define SPELLCHECKER to 0.
 
 @see startAnalysis
 
 */
-(void) analysisPhase6 {
    
    UITextChecker *checker = [[UITextChecker alloc] init];
    
    NSMutableString *chaineFinale=[[NSMutableString alloc]init];
    NSArray *mot=[messageReceive componentsSeparatedByString:@" "];
    
    for (int i=0; i<[mot count]; i++) {
        if ([mot[i] rangeOfString:@"http://"].location==NSNotFound) {
            NSRange checkRange = NSMakeRange(0, [mot[i] length]);
            
            NSRange misspelledRange = [checker rangeOfMisspelledWordInString:mot[i]
                                                                       range:checkRange
                                                                  startingAt:checkRange.location
                                                                        wrap:NO
                                                                    language:@"fr_FR"];
            
            NSArray *arrGuessed = [checker guessesForWordRange:misspelledRange inString:mot[i] language:@"fr_FR"];
            
            if ([arrGuessed count]>0) {
                [chaineFinale appendString:[mot[i] stringByReplacingCharactersInRange:misspelledRange withString:[arrGuessed objectAtIndex:0]]];
            }
            else
                [chaineFinale appendString:mot[i]];
        }
        else
            [chaineFinale appendString:mot[i]];
        
        [chaineFinale appendString:@" "];
    }
    
    messageReceive=[[NSMutableString alloc]init];
    messageReceive=chaineFinale;
}


/**---------------------------------------------------------------------------------------
 * StartAnalysis
 *  ---------------------------------------------------------------------------------------
 */
/** Analysis of the message receive during the transaction
 
 This function is the one you have to use if you want to analyse a string send by soundFi. It will manage all the step from 1 to 6
 
 [self analysisPhase1];
 [self analysisPhase2];
 [self analysisPhase3];
 [self analysisPhase4];
 [self analysisPhase5];
 
 #if SPELLCHECKER
 [self analysisPhase6];
 #endif
 
 @see analysisPhase1
 @see analysisPhase2
 @see analysisPhase3
 @see analysisPhase4
 @see analysisPhase5
 @see analysisPhase6
 
 */
-(void)startAnalysis
{
    if ([messageReceive length]<=0) {
        return;
    }
    
#if DEBUG
    NSLog(@"INIT /**/**/**/ : %@",messageReceive);
#endif
    
    [self analysisPhase1];
    [self analysisPhase2];
    [self analysisPhase3];
    [self analysisPhase4];
    [self analysisPhase5];
    
#if SPELLCHECKER
    [self analysisPhase6];
#endif
    
#if DEBUG
    NSLog(@"RES /**/**/**/ : %@",messageReceive);
#endif
    
    if (simpleMessagingMode)
        [self.delegate messageReceived:[NSString stringWithString:messageReceive]];
    messageReceive=[[NSMutableString alloc]init];
}


#pragma mark - Start/Stop Engine


-(int)startAudioUnit:(SFMessagingMode)mode : (NSString*)message
{
    compteur=0;
    engineIsRunning=TRUE;
    
    if (mode==SFReceivingMode) {
        receptionMode=TRUE;
        //nbrEchantillon=1024;
        //[mySession setPreferredIOBufferDuration: ((float)nbrEchantillon/sampleRate) error: nil];
        messageReceive = [[NSMutableString alloc]init];
#if DEBUG
        NSLog(@"Démarrage du graph, compteur : %d",compteur);
#endif
        OSStatus status = AUGraphStart(myGraph);
        if (status)
            NSLog(@"AUGraphStart Error");
    }
    else {
        if (![self volumeControl]) {
            [self.delegate soundToLow];
            return 0;
        }
        if (!emissionMode) {
            [self stopProcessingAudio];
            
            NSData *temp = [message dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]; // Deal with special
            myMessage = [[NSString alloc] initWithData:temp encoding:NSASCIIStringEncoding];           // caracter like è é À...
            
            emissionCanBeStop=TRUE;
            emissionMode=TRUE;
            initSequence=TRUE;
            nbrRepeatInit=0;
            amplitude=0;
#if DEBUG
            NSLog(@"Envoie du message");
#endif
            [self emissionSetup];
            nbrEchantillon=256;
            [mySession setPreferredIOBufferDuration: ((float)nbrEchantillon/sampleRate) error: nil];
            AudioUnitInitialize(emissionUnit);
            AudioOutputUnitStart(emissionUnit);
        }
    }
    
    return 1;
}


/**---------------------------------------------------------------------------------------
 * @name Start/Stop engine methods
 * StopProcessingAudio
 *  ---------------------------------------------------------------------------------------
 */
/** This function allow you to stop listenning or sending audio
 
 @return Return 1 if every thing is ok
 @warning Here some error that can be raised by the function
 
 - AUGraphStop error
 */
-(int)stopProcessingAudio
{
    if (receptionMode) {
        Boolean isRunning = false;
#if DEBUG
        NSLog(@"Arret du graph, compteur : %d",compteur);
#endif
        OSStatus status = AUGraphIsRunning(myGraph, &isRunning);
        if (isRunning)
            status = AUGraphStop(myGraph);
        if (status)
            NSLog(@"AUGraphStop Error");
    }
    else if (emissionMode) {
#if DEBUG
        NSLog(@"Stop Emission");
#endif
        AudioOutputUnitStop(emissionUnit);
    }
    
    engineIsRunning=FALSE;
    
    receptionMode=FALSE;
    emissionMode=FALSE;
    
    isInitiate=FALSE;
    return 1;
}



/**---------------------------------------------------------------------------------------
 * RelauchReception
 *  ---------------------------------------------------------------------------------------
 */
/** This function is use after finishing a message sending
 
 Permit to restart the listening and put in waiting state for a message. It will proceed to a usleep to avoid lldb due to audio still processing on sending.
 
 */
-(void)relaunchReception
{
    usleep(40000);
    [self stopProcessingAudio];
    usleep(100000);
#if DEBUG
    NSLog(@"Je relance l'écoute");
#endif
    AudioUnitUninitialize(emissionUnit);
    AudioComponentInstanceDispose(emissionUnit);
    emissionUnit=nil;
    [self startAudioUnit:SFReceivingMode:NULL];
    
}

#pragma mark - Volume control


/**---------------------------------------------------------------------------------------
 * @name Volume control methods
 * VolumeControle
 *  ---------------------------------------------------------------------------------------
 */
/** Control the app volume for sending message
 
 Limit can be configured with the changeMinimumVolume:(float) method.
 
 @return TRUE if volume is superior to the minimal require
 @see changeMinimumVolume
 */
-(BOOL)volumeControl
{
    if ([[AVAudioSession sharedInstance] outputVolume]<minimumVolume)
        return FALSE;
    else
        return TRUE;
}


-(void)changeMinimumVolume:(float)newMinVolume{
    minimumVolume=newMinVolume;
}

#pragma mark - Deprecated


-(void)switchBackgroundChanged:(id)sender
{
    //enableBackground=[sender isOn];
    if(enableBackground){
        //On active l'écoute arrière plan
#if DEBUG
        NSLog(@"Activation de l'écoute arrière plan");
#endif
    }
    else {
        //On désactive l'écoute arrière plan
#if DEBUG
        NSLog(@"Désactivation de l'écoute arrière plan");
#endif
    }
}

#pragma mark - Engine control methods



/**---------------------------------------------------------------------------------------
 * @name Engine control methods
 
 * ActivateSoundFiMessaging
 *  ---------------------------------------------------------------------------------------
 */
/** Activate the messaging mode
 
 @see desactivateSoundFiMessaging
 @see messagingModeIsEnable
 */
-(void)activateSoundFiMessaging{simpleMessagingMode=TRUE;}

/**---------------------------------------------------------------------------------------
 * DesactivateSoundFiMessaging
 *  ---------------------------------------------------------------------------------------
 */
/** Desactivate messaging mode
 
 @see desactivateSoundFiMessaging
 @see messagingModeIsEnable
 */
-(void)desactivateSoundFiMessaging{simpleMessagingMode=FALSE;}

/**---------------------------------------------------------------------------------------
 * DesableBackground
 *  ---------------------------------------------------------------------------------------
 */
/** Activate background processing
 
 @see disableBackground
 @see backgroundIsEnable
 */
-(void)enableBackground{enableBackground=TRUE;}

/**---------------------------------------------------------------------------------------
 * DesableBackground
 *  ---------------------------------------------------------------------------------------
 */
/** Desactivate background processing
 
 @see enableBackground
 @see backgroundIsEnable
 */
-(void)desableBackground{enableBackground=FALSE;}



#pragma mark - Engine information methods

/**---------------------------------------------------------------------------------------
 * @name Engine informations methods
 * BackgroundIsEnable
 *  ---------------------------------------------------------------------------------------
 */
/** Check if the background is enable
 
 @return TRUE if the background is enable
 @see enableBackground
 @see disableBackground
 */
-(BOOL)backgroundIsEnable{return enableBackground;}


-(BOOL)messagingModeIsEnable{return simpleMessagingMode;}

/**---------------------------------------------------------------------------------------
 * EngineIsRunning
 *  ---------------------------------------------------------------------------------------
 */
/** Check if the engine is running
 
 @return TRUE if the engine is running
 */
-(BOOL)engineIsRunning{return engineIsRunning;}


#pragma mark - BackGround and Foreground management



/**---------------------------------------------------------------------------------------
 * @name Background and foreground management methods
 * EnteredBackground
 *  ---------------------------------------------------------------------------------------
 */
/** Call to perform background task
 
 This function is called when the aplication is entering background. Stop audioProcessing when entering background if background processing is disable
 
 @see enteredForeground
 */
-(void)enteredBackground{
    if (!enableBackground) {
        [self stopProcessingAudio];
    }
}

/**
 *   Call to perform foreground task. This function is call when the
 *   application is going foreground
 */
/**---------------------------------------------------------------------------------------
 * EnteredForeground
 *  ---------------------------------------------------------------------------------------
 */
/** Call to perform background task
 
 This function is called when the aplication is entering foreground. Reactivate audio processing if necessary
 
 @see enteredBackground
 */
-(void)enteredForeground{
    if (![self engineIsRunning]) {
        [self startAudioUnit:SFReceivingMode :nil];
    }
}

@end
