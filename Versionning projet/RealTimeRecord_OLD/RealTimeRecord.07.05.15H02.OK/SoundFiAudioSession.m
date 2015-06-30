//
//  SoundFiAudioSession.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "SoundFiAudioSession.h"
#include <pthread.h>

void smb2PitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize,
					long osamp, float sampleRate, float *indata, float *outdata,
					FFTSetup fftSetup, float * frequency);


// for some calculation in the fft callback
// check to see if there is a vDsp library version
float MagnitudeSquared(float x, float y) {
	return ((x*x) + (y*y));
}


//Convert Int16 to Float32
void Int16ToFloat32(SInt16* source,Float32* dest,int numFrames)
{
    for (int i = 0; i < numFrames; i++) {
        dest[i] = source[i] / 32768.0f;
    }
}

//Convert fixed point 8.24 to Int16
void fixedPointToSInt16( SInt32 * source, SInt16 * target, int length ) {
    
    int i;
    
    for(i = 0;i < length; i++ ) {
        target[i] =  (SInt16) (source[i] >> 9);
        
    }
    
}


// Use to get the frequency with an high accuracy
// during a message transfer
OSStatus fftGetFrequencyHighAccuracy (
                        void *inRefCon,                 // scope (MixerHostAudio)
                        UInt32 inNumberFrames,          // number of frames in this slice
                        SInt16 *sampleBuffer) {         // frames (sample data)
    
    // scope reference that allows access to everything in MixerHostAudio class
    
	SoundFiAudioSession *THIS = (__bridge SoundFiAudioSession *)inRefCon;
    
  	float *outputBuffer = THIS->outputBuffer;
	float *analysisBuffer = THIS->analysisBuffer;
    
    FFTSetup fftSetup = THIS->fftSetup;      // fft setup structures need to support vdsp functions
	
    
	uint32_t stride = 1;                    // interleaving factor for vdsp functions
	int bufferCapacity = 256;               // maximum size of fft buffers
    
    float pitchShift = 1.0;                 // pitch shift factor 1=normal, range is .5->2.0
    long osamp = 4;                         // oversampling factor
    long fftSize = 256;                     // fft size
    
	
	float frequency;                        // analysis frequency result
    
    
    //	ConvertInt16ToFloat
    
    vDSP_vflt16((SInt16 *) sampleBuffer, stride, (float *) analysisBuffer, stride, bufferCapacity );
    
    // run the pitch shift
    
    // scale the fx control 0->1 to range of pitchShift .5->2.0
    
    pitchShift = (0.5 * 1.5) + .5;
    
    // osamp should be at least 4, but at this time my ipod touch gets very unhappy with
    // anything greater than 2
    
    osamp = 4;
    fftSize = 256;		// this seems to work in real time since we are actually doing the fft on smaller windows
    
    smb2PitchShift( pitchShift , (long) inNumberFrames,
                   fftSize,  osamp, (float) THIS->sampleRate,
                   (float *) analysisBuffer , (float *) outputBuffer,
                   fftSetup, &frequency);
    
    
    // display detected pitch
    
    
    THIS->sampleFrequency = (int) frequency;
    
    // now convert from float to Sint16
    
    vDSP_vfixr16((float *) outputBuffer, stride, (SInt16 *) sampleBuffer, stride, bufferCapacity );
    
    
    return noErr;
    
    
}

// Use to get the frequency with a low accuracy
// during the application background
OSStatus fftGetFrequencyLowAccuracy (   void                        *inRefCon,          // scope referece for external data
                                        UInt32 						inNumberFrames,     // number of frames to process
                                        SInt16                      *sampleBuffer)      // frame buffer
{
	
    // note: the fx control slider does nothing during fft passthrough
    
    // set all the params
    
    // scope reference that allows access to everything in MixerHostAudio class
    
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
	int bufferCapacity = THIS->fftBufferCapacity;
	SInt16 index = THIS->fftIndex;
	
    
	// Fill the buffer with our sampled data. If we fill our buffer, run the
	// fft.
    
	// NSLog(@"index: %d", index);
	int read = bufferCapacity - index;
	if (read > inNumberFrames) {
		// NSLog(@"filling");
        
		memcpy((SInt16 *)dataBuffer + index, sampleBuffer, inNumberFrames * sizeof(SInt16));
		THIS->fftIndex += inNumberFrames;
	} else {
		// NSLog(@"processing");
		// If we enter this conditional, our buffer will be filled and we should
		// perform the FFT.
        
		memcpy((SInt16 *)dataBuffer + index, sampleBuffer, read * sizeof(SInt16));
        
		
		// Reset the index.
		THIS->fftIndex = 0;
        
        
        // *************** FFT ***************
        // convert Sint16 to floating point
        
        vDSP_vflt16((SInt16 *) dataBuffer, stride, (float *) outputBuffer, stride, bufferCapacity );
        
        
		//
		// Look at the real signal as an interleaved complex vector by casting it.
		// Then call the transformation function vDSP_ctoz to get a split complex
		// vector, which for a real signal, divides into an even-odd configuration.
		//
        
        vDSP_ctoz((COMPLEX*)outputBuffer, 2, &A, 1, nOver2);
		
		// Carry out a Forward FFT transform.
        
        vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_FORWARD);
		
        
		// The output signal is now in a split real form. Use the vDSP_ztoc to get
		// an interleaved complex vector.
        
        vDSP_ztoc(&A, 1, (COMPLEX *)analysisBuffer, 2, nOver2);
        
		// for display purposes...
        //
        // Determine the dominant frequency by taking the magnitude squared and
		// saving the bin which it resides in. This isn't precise and doesn't
        // necessary get the "fundamental" frequency, but its quick and sort of works...
        
        // note there are vdsp functions to do the amplitude calcs
        
        float dominantFrequency = 0;
        int bin = -1;
        for (int i=0; i<n; i+=2) {
			float curFreq = MagnitudeSquared(analysisBuffer[i], analysisBuffer[i+1]);
			if (curFreq > dominantFrequency) {
				dominantFrequency = curFreq;
				bin = (i+1)/2;
			}
		}
        
        dominantFrequency = bin*(THIS->sampleRate/bufferCapacity);
        
        // printf("Dominant frequency: %f   \n" , dominantFrequency);
        THIS->sampleFrequency = (int) dominantFrequency;   // set instance variable with detected frequency
		
        
 
        //Don't need to do the inverse FFT transorm
 
        // Carry out an inverse FFT transform.
		
        vDSP_fft_zrip(fftSetup, &A, stride, log2n, FFT_INVERSE );
        
        // scale it
		
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



/////
//
//  Callback for emission
//
/////////////////
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


/////////////
//
//  CallBack For message Reception
//
//////////////
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

@implementation SoundFiAudioSession


///////////
//
// Custom init method to set AudioSession and params
//
///////////
-(SoundFiAudioSession*)init
{
    self=[super init];
    
    [self initAudioSession];
    [self setupCallback];
    [self fftSetup];
    [self initAudioStreams];
    
    pthread_mutex_init(&emissionMutex, NULL);
    nbCaracRepeat=0;
    
    [self startAudioUnit:0:NULL];
    
    return self;
}


///////////
//
// Créate the audio wave with the required frequency
//
///////////
-(void)emissionSampleCalcul:(int)frequence : (int)numFrames : (Float32 *)buffer
{
    double theta_increment = 2.0 * M_PI * frequence / sampleRate;     // θ(n) = 2πƒ n / r
    const double amplitude = 1.0;
    
    // Loop génération for the samples
    // f(n) = a sin ( θ(n) )
    
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

///////////
//
// This fonction coordinate the state of the emission
// and asign a frequency to a caracter
//
///////////
-(int)getASCIIFrequency
{
    int frequence;
    
    if (initSequence) {
        if (nbrRepeatInit>=9) {
            initSequence=FALSE;
        }
        //NSLog(@"InitInit");
        nbrRepeatInit++;
        return 19390;
    }
    
    if (compteur < [myMessage length]) {
        frequence=20000 +(((int)[myMessage characterAtIndex:compteur]-32)*10);
        //printf("Freq : %d carac: %c \n",frequence,[myMessage characterAtIndex:compteur]);
    }
    else
    {
        if (isSafeForWork) {
            isSafeForWork=FALSE;
            [self.delegate finishEmission];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,1), dispatch_get_main_queue(), ^{
                [self relaunchReception];
            });
            //NSTimer *timer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(relaunchReception) userInfo:nil repeats:NO];
            NSLog(@"STOP");
        }
        //NSLog(@"heyho");
        return 20960;
    }
    
    if (nbCaracRepeat==4)
    {
        compteur = compteur+1;
        nbCaracRepeat = 0;
    }
    else
        nbCaracRepeat=nbCaracRepeat+1;
    
    return frequence;
}

// Reception conversion method
///////////
//
// This function deal with the recepetion state, for background and foreground
// it perform the FFT method : fftGetfrequency
// NOTE: The FFT for background is less accurate than the other but use only 2%CPU
//
///////////
-(void)sampleTreatment:(int)numFrames
{
    if(isInitiate)
    {
        fftGetFrequencyHighAccuracy( (__bridge void*)self, numFrames, samplesBuffer);
        //NSLog(@" Freq : %d  ASCII: %3d Carac : %@",sampleFrequency,(sampleFrequency-18490)/20+32,[NSString stringWithFormat:@"%c",(char)((sampleFrequency-19995)/10+32)]);
        
        if (sampleFrequency>=19995 && sampleFrequency<=20945)
        {
            NSString *res = [NSString stringWithFormat:@"%c",(char)((sampleFrequency-19995)/10+32)];
            [messageReceive appendString:res];
            compteur=0;
        }
        else if(sampleFrequency>=20955 && sampleFrequency<=20965)
        {
            NSLog(@"Stop");
            [self startAnalysis];
            isInitiate=FALSE;
            //[self stopProcessingAudio];
        }

    }
    else
    {
        fftGetFrequencyLowAccuracy( (__bridge void*)self, numFrames, samplesBuffer);    //Background
        if (sampleFrequency>=19300 && sampleFrequency<19490 && !isInitiate)
        {
            NSLog(@"Gogo");
            [self.delegate startingReception];
            compteur=0;
            isInitiate=TRUE;
            
        }
    }

}


//////
//
//    Check if the comunication time out
//
/////
-(void)checkTimeOut
{
    if (isInitiate &&compteur>500) {
        NSLog(@"TimeOut");
        isInitiate=FALSE;
        [self startAnalysis];
        //[self stopProcessingAudio];
    }
}


///////////
//
// Set up some variable for the renderCallback
//
///////////
-(void)setupCallback
{
    isInitiate=FALSE;
    isTimeOut=FALSE;
    
    receptionMode=FALSE;
    emissionMode=FALSE;
    
    emptySample=malloc(256*sizeof(AudioUnitSampleType));
    for (int i=0; i<256; i++) {
        emptySample[i]=0;
    }
    
    samplesBuffer=(SInt16*)malloc(256 *sizeof(float));
}

///////////
//
// Set up variable and tabs for the fft
//
///////////
-(void)fftSetup
{
    UInt32 maxFrames = 256;    // fft size
	
	
	// setup input and output buffers to equal max frame size
	
	dataBuffer = (void*)malloc(maxFrames * sizeof(SInt16));
	outputBuffer = (float*)malloc(maxFrames *sizeof(float));
	analysisBuffer = (float*)malloc(maxFrames *sizeof(float));
	
	// set the init stuff for fft based on number of frames
	
	fftLog2n = log2f(maxFrames);		// log base2 of max number of frames, eg., 10 for 256
	fftN = 1 << fftLog2n;					// actual max number of frames, eg., 256 - what a silly way to compute it
    
    
	fftNOver2 = maxFrames/2;                // half fft size
	fftBufferCapacity = maxFrames;          // yet another way of expressing fft size
	fftIndex = 0;                           // index for reading frame data in callback
	
	// split complex number buffer
	fftA.realp = (float *)malloc(fftNOver2 * sizeof(float));		//
	fftA.imagp = (float *)malloc(fftNOver2 * sizeof(float));		//
	
	
	// zero return indicates an error setting up internal buffers
	
	fftSetup = vDSP_create_fftsetup(fftLog2n, FFT_RADIX2);
    if( fftSetup == (FFTSetup) 0) {
        NSLog(@"Error - unable to allocate FFT setup buffers" );
	}
    
}

///////////
//
// Set up the audioDescription and AudioUnit for emission
//
///////////
-(void)emissionSetup
{
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
    AudioUnitSetProperty(emissionUnit,kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Input,0,&input,sizeof(input)); //Def des propriétés
    
    
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


///////////
//
// Init AudioSession's parameters like rate,duration,category
//
///////////
-(int)initAudioSession
{
    NSLog(@"Initialisation de la session audio");
    sampleRate=44100.0;
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord error: &audioSessionError];
    
    
    [mySession setPreferredSampleRate: 44100.0 error: &audioSessionError];
    
    [mySession setPreferredIOBufferDuration: (256.0/sampleRate) error: &audioSessionError];
    
    [mySession setActive:YES error:nil];
    
    return 0;
}




///////////
//
// Set all the parameters of stream including IO and mixer and the graph
// NOTE : The mixer is not really use here but implement for futur feature
//
///////////
-(int)initAudioStreams
{
    OSStatus err;
    err=NewAUGraph(&myGraph);
    if (err!=noErr) {NSLog(@"Erreur NewAUGraph");}
    
    //Put the session in play/record mode
    NSLog(@"Initialisation des streams audios");
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &audioCategory) != noErr) {
        return 1;
    }
    
    UInt32 overrideCategory = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(UInt32), &overrideCategory);
    
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
    streamDescription.mBytesPerPacket    = bytesPerSample;
    streamDescription.mFramesPerPacket   = 1;
    streamDescription.mBytesPerFrame     = bytesPerSample;
    streamDescription.mChannelsPerFrame  = 1;                  // 1 indicates mono
    streamDescription.mBitsPerChannel    = 8 * bytesPerSample;
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
    
    NSLog (@"Setting mixer unit input bus count to: %u", (unsigned int)busCount);
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
    CAShow (myGraph);
    
    //When everything is configurate you can initialize the graph
    err = AUGraphInitialize (myGraph);
    if(err!=noErr){NSLog(@"Error AUGraphInitialize");}
    
    return 0;
}


///////////
//
// Remove the init and stop message
//
///////////
-(void)analysisPhase1
{
    NSArray *component;
    component=[messageReceive componentsSeparatedByString:@"init:"];
    component=[component[[component count]-1] componentsSeparatedByString:@":stop"];
    messageReceive=component[0];
}


///////////
//
// Remove bad pattern like aba  (b is bad)
//
///////////
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


///////////
//
// Remove bad pattern like bacbb  (b is bad)
//
///////////
-(void)analysisPhase3
{
    int i=0;
    NSMutableString *chainePhase3=[[NSMutableString alloc]init];
    
    while (i<[messageReceive length]-3)
    {
        char un=[messageReceive characterAtIndex:i];
        char deux=[messageReceive characterAtIndex:i+1];
        char trois=[messageReceive characterAtIndex:i+2];
        char quatre=[messageReceive characterAtIndex:i+3];
        
        if(un==quatre){
            if (un-deux!=0 && un-trois!=0) {
                //NSLog(@"%d %c %c %c %c",i,un,deux,trois,quatre);
                [chainePhase3 appendFormat:@"%c",un];
                i=i+3;
            }
            else
            {
                [chainePhase3 appendFormat:@"%c",un];
                i++;
            }
        }
        else
        {
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


///////////
//
// We consider that fgg is almost ggg so we change it
// NOTE:EXPERIMENTAL
//
///////////
-(void)analysisPhase4
{
    int i=0;
    NSMutableString *chainePhase4=[[NSMutableString alloc]init];
    
    while (i<[messageReceive length]-2)
    {
        char un=[messageReceive characterAtIndex:i];
        char deux=[messageReceive characterAtIndex:i+1];
        char trois=[messageReceive characterAtIndex:i+2];
        
        if((un==deux && trois!=deux)|| (un==trois && trois!=deux))
        {
            if (fabs(trois-deux)==1) {
                [chainePhase4 appendFormat:@"%c",un];
                [chainePhase4 appendFormat:@"%c",un];
                [chainePhase4 appendFormat:@"%c",un];
                i=i+3;
            }
            else
            {
                [chainePhase4 appendFormat:@"%c",un];
                i++;
            }
        }
        else if(deux==trois && un!=deux)
        {
            if (fabs(un-deux)==1) {
                [chainePhase4 appendFormat:@"%c",deux];
                [chainePhase4 appendFormat:@"%c",deux];
                [chainePhase4 appendFormat:@"%c",deux];
                i=i+3;
            }
            else
            {
                [chainePhase4 appendFormat:@"%c",un];
                i++;
            }
        }
        else
        {
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


///////////
//
// Remove all the repetition and keep char only if
// the repetition are sufficient
//
///////////
-(void)analysisPhase5
{
    int i=0;
    int compt=0;
    NSMutableString *chaineFinale=[[NSMutableString alloc]init];
    while (i<[messageReceive length]-2)
    {
        NSString *un=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i]];
        NSString *deux=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i+1]];
        if ([un isEqualToString:deux])
        {
            [chaineFinale appendString:un] ;
            i=i+2;
            while ([[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i]]isEqualToString:un] && (i<[messageReceive length]-1)) {
                i++;
                compt++;
                if (compt>5)
                {
                    [chaineFinale appendString:un];
                    compt=0;
                }
            }
        }
        else
        {
            i++;
        }
        
        compt=0;
        //NSLog(@"i = %d sur %d",i,[messageReceive length]);
    }
    messageReceive=[[NSMutableString alloc]init];
    messageReceive=chaineFinale;
   
}

///////////
//
// Analysis of the message receive during the transaction
// including errors treatment and some other things soon .....
//
///////////
-(void)startAnalysis
{
    if ([messageReceive length]<=0) {
        return;
    }
    //NSLog(@"\n%@\n",messageReceive);
    
    NSLog(@"INIT /**/**/**/ : %@",messageReceive);
    
    NSLog(@"analysis phase 1");
    [self analysisPhase1];

    //NSLog(@"\n%@\n",messageReceive);
    
    NSLog(@"analysis phase 2");
    [self analysisPhase2];
    
    //NSLog(@"\n%@\n",messageReceive);
    
    
    NSLog(@"analysis phase 3");
    [self analysisPhase3];
    
    //NSLog(@"\n%@\n",messageReceive);
    
    //Phase 4 expérimental
    NSLog(@"analysis phase 4");
    [self analysisPhase4];
    //NSLog(@"%@",messageReceive);
    
    //NSLog(@"\n%@\n",messageReceive);
    NSLog(@"analysis phase 5");
    [self analysisPhase5];
    
    NSLog(@"End Analysis");
    
    NSLog(@"RES /**/**/**/ : %@",messageReceive);
    
    [self.delegate messageReceived:[NSString stringWithString:messageReceive]];
    messageReceive=[[NSMutableString alloc]init];
}


///////////
//
// Start the Graph
// if mode=0  ==> reception mode
// if mode=1  ==> emission mode
//
///////////
-(int)startAudioUnit:(int)mode : (NSString*)message
{
    compteur=0;
    if (mode==0)
    {
        receptionMode=TRUE;
        messageReceive = [[NSMutableString alloc]init];
        
        NSLog(@"Démarrage du graph, compteur : %d",compteur);
        OSStatus status = AUGraphStart(myGraph);
        if (status)
            NSLog(@"AUGraphStart Error");
    }
    else
    {
        if (!emissionMode)
        {
            [self stopProcessingAudio];
            myMessage=message;
            isSafeForWork=TRUE;
            emissionMode=TRUE;
            initSequence=TRUE;
            nbrRepeatInit=0;
            [self emissionSetup];
            AudioUnitInitialize(emissionUnit);
            AudioOutputUnitStart(emissionUnit);
        }
    }
    
    return 0;
    
}


///////////
//
// Stop the Graph
//
///////////
-(int)stopProcessingAudio
{
    if (receptionMode) {
        Boolean isRunning = false;
        NSLog(@"Arret du graph, compteur : %d",compteur);
        OSStatus status = AUGraphIsRunning(myGraph, &isRunning);
        if (isRunning)
            status = AUGraphStop(myGraph);
        if (status)
            NSLog(@"AUGraphStop Error");
    }
    else if (emissionMode)
    {
        NSLog(@"Stop Emission");
        AudioOutputUnitStop(emissionUnit);
    }
    
    receptionMode=FALSE;
    isInitiate=FALSE;
    emissionMode=FALSE;
    return 0;
    
    

}


///////////
//
// This fonction is use after the end of a message reception
// permit to restart the listening and put in waiting state
// for a message.
//
///////////
-(void)relaunchReception
{
    usleep(40000);
    [self stopProcessingAudio];
    usleep(100000);
    NSLog(@"Je relance l'écoute");
    AudioUnitUninitialize(emissionUnit);
    AudioComponentInstanceDispose(emissionUnit);
    emissionUnit=nil;
    [self startAudioUnit:0:NULL];

}

@end
