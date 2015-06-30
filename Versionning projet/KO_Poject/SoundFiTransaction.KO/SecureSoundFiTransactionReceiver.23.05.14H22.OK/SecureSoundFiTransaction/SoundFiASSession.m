//
//  SoundFiASSession.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "SoundFiASSession.h"
#include <pthread.h>

#define kOutputBus 0
#define kInputBus 1

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
    
	SoundFiASSession *THIS = (__bridge SoundFiASSession *)inRefCon;
    
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
    
    SoundFiASSession *THIS = (__bridge SoundFiASSession*)inRefCon;
    
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
//  Callback for send and receive message for a secure transaction
//
/////////////////
OSStatus RecordCallback(void *userData,
                        AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp,
                        UInt32 busNumber,
                        UInt32 numFrames,
                        AudioBufferList *buffers) {
    
    SoundFiASSession *THIS=(__bridge SoundFiASSession*)userData;
    pthread_mutex_lock(&THIS->emissionMutex);
    
    AudioUnit audioUnit=(THIS->audioUnit);
    AudioUnitSampleType *echantillonAudio;
    AudioBuffer buffer=THIS->recordBuffer;
    AudioBufferList bufferList=THIS->recordBufferList;
    bufferList.mBuffers[0] = buffer;
    
    
    AudioUnitRender(audioUnit, actionFlags, audioTimeStamp,1, numFrames, &bufferList);
    echantillonAudio=(AudioUnitSampleType*) bufferList.mBuffers[0].mData;
    fixedPointToSInt16(echantillonAudio, THIS->samplesBuffer, numFrames);
    fftGetFrequencyHighAccuracy( (__bridge void*)THIS, numFrames,THIS->samplesBuffer); //Foreground
    //printf("%d\n",THIS->sampleFrequency);
    
    
    //Attente de la fréquence d'init
    if (!THIS->transactionIsInit) {
        if (THIS->sampleFrequency>=19707 && THIS->sampleFrequency<=19713) {
            //Fréquence de démarage reçu
            THIS->frequenceInitReceive=TRUE;
            THIS->nbrAquitInit=0;
        }
        else if (THIS->sampleFrequency>=18280 && THIS->sampleFrequency<=18455) {
            if (THIS->frequenceInitReceive) {
                THIS->startingMessageSize=TRUE;
                THIS->transactionIsInit=TRUE;
                THIS->nbrAquitInit=0;
                NSLog(@"RECEPTEUR : Fin de l'init");
            }
        }
    }
    
    // Réception de la validation de la lettre
    if (THIS->startingMessageSize) {
        if (THIS->nbrAquitInit==0 && THIS->sampleFrequency<19748 && THIS->sampleFrequency >18000) {
            THIS->currentCaracFrequency=THIS->sampleFrequency;
            printf("Sending : %d\n",THIS->sampleFrequency);
        }
        if(THIS->sampleFrequency>19748 && THIS->sampleFrequency <19752 && !THIS->isAGoogLetter) {
            NSLog(@"C'est GOOD %d",THIS->sampleFrequency);
            THIS->isAGoogLetter=TRUE;
        }
        else if (THIS->isAGoogLetter) {      //Est ce que une nouvelle lettre est envoyé ?
            if(THIS->sampleFrequency>=19707 && THIS->sampleFrequency<=19713) {
                NSLog(@"On reppart %D",THIS->sampleFrequency);
                [THIS rebootReceiving];
            }
        }
    }
    

    
    pthread_mutex_unlock(&THIS->emissionMutex);
    
    return noErr;
}

/////
//
//  Callback for send and receive message for a secure transaction
//  On envoie les messages avec un décalage de -300 pour le récepteur
/////////////////
OSStatus PlayBackCallback(void *userData,
                          AudioUnitRenderActionFlags *actionFlags,
                          const AudioTimeStamp *audioTimeStamp,
                          UInt32 busNumber,
                          UInt32 numFrames,
                          AudioBufferList *buffers) {
    
    SoundFiASSession *THIS=(__bridge SoundFiASSession*)userData;
    pthread_mutex_lock(&THIS->emissionMutex);
    int frequence;
    
    
    //Acquittement de l'initialisation
    if (THIS->frequenceInitReceive && !THIS->transactionIsInit) {
        frequence=19410;
    }
    
    
    //Acquittement du chiffre reçu
    if (THIS->startingMessageSize) {
        //NSLog(@"J'acquite le chiffre reçu");
        frequence=THIS->currentCaracFrequency-300;
        //printf("Sending : %d\n",frequence);
        THIS->nbrAquitInit++;
    }
    
    if (THIS->isAGoogLetter) {
            frequence = 19410;
    }
    
    
    
    buffers->mBuffers[0].mData=THIS->emptySample;
    [THIS emissionSampleCalcul:frequence :numFrames :(Float32 *)buffers->mBuffers[0].mData];
    
    THIS->compteur++;
    [THIS initAcceptableTimeOut];
    
    pthread_mutex_unlock(&THIS->emissionMutex);
    
    return noErr;
}


@implementation SoundFiASSession

-(void)rebootReceiving
{
    startingMessageSize=FALSE;
    transactionIsInit=FALSE;
    frequenceInitReceive=TRUE;
    isAGoogLetter=FALSE;
    nbrAquitInit=0;
    
}

-(void)initAcceptableTimeOut
{
    if (compteur>3) {
        compteur=0;
        nbrAquitInit=0;
    }
}

///////////
//
// Custom init method to set AudioSession and params
//
///////////
-(SoundFiASSession*)init
{
    self=[super init];
    
    [self initAudioSession];
    [self setupCallback];
    [self fftSetup];
    
    pthread_mutex_init(&emissionMutex, NULL);
    nbCaracRepeat=0;
    
    
    transactionIsInit=FALSE;
    frequenceInitReceive=FALSE;
    startingMessageSize=FALSE;
    messageSizeString=[[NSMutableString alloc] init];
    
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
    double amplitude = 0.3;
    
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
    
    if (compteur < [myMessage length]) {
        frequence=18000 +(((int)[myMessage characterAtIndex:compteur]-32)*18);
        //printf("Freq : %d carac: %c \n",frequence,[myMessage characterAtIndex:compteur]);
    }
    
    return frequence;
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
    
    emptySample=malloc(256*sizeof(Float32));
    for (int i=0; i<256; i++) {
        emptySample[i]=0.;
    }
    
    samplesBuffer=(SInt16*)malloc(256 *sizeof(float));
    
    recordBuffer.mNumberChannels = 1;
    recordBuffer.mDataByteSize = 256 * 4;
    recordBuffer.mData = malloc( 256 * 4 );
    
    recordBufferList.mNumberBuffers = 1;
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
    /*
     UInt32 overrideCategory = 1;
     if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
     sizeof(UInt32), &overrideCategory) != noErr) {
     // Less serious error, but you may want to handle it and bail here
     }
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
     
     UInt32 enable = 1;
     AudioUnitSetProperty(emissionUnit, kAudioOutputUnitProperty_EnableIO,kAudioUnitScope_Input, 1, &enable, sizeof(UInt32));
     
     AudioUnitSetProperty(audioUnit,kAudioOutputUnitProperty_EnableIO,kAudioUnitScope_Output,0,&enable,sizeof(enable));
     
     //Create the callbackStruct and assign it to the RenderTone function
     //inputProcRefCon=self allow us to acces information in the RenderTone function
     AURenderCallbackStruct input;
     input.inputProc = RecordCallback;
     input.inputProcRefCon = (__bridge void *)(self);
     AudioUnitSetProperty(emissionUnit,kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Global,1,&input,sizeof(input)); //Def des propriétés
     
     AURenderCallbackStruct output;
     output.inputProc = PlayBackCallback;
     output.inputProcRefCon = (__bridge void *)(self);
     AudioUnitSetProperty(emissionUnit,kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Global,0,&output,sizeof(output)); //Def des propriétés
     
     
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
     
     AudioStreamBasicDescription OutputStreamFormat;
     OutputStreamFormat.mSampleRate = sampleRate;
     OutputStreamFormat.mFormatID = kAudioFormatLinearPCM;
     OutputStreamFormat.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
     OutputStreamFormat.mBytesPerPacket = 4;
     OutputStreamFormat.mFramesPerPacket = 1;
     OutputStreamFormat.mBytesPerFrame = 4;
     OutputStreamFormat.mChannelsPerFrame = 1;
     OutputStreamFormat.mBitsPerChannel = 4 * 8;
     
     // Ditto for the output stream, which we will be sending the processed audio to
     AudioUnitSetProperty(emissionUnit, kAudioUnitProperty_StreamFormat,kAudioUnitScope_Output, 1, &OutputStreamFormat, sizeof(AudioStreamBasicDescription));
     */
    // Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units
	AudioComponentInstanceNew(inputComponent, &audioUnit);
	
	// Enable IO for recording
	UInt32 flag = 1;
	AudioUnitSetProperty(audioUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         kInputBus,
                         &flag,
                         sizeof(flag));
	
	// Enable IO for playback
	AudioUnitSetProperty(audioUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Output,
                         kOutputBus,
                         &flag,
                         sizeof(flag));
	
    // Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = sampleRate;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
    audioFormat.mBytesPerPacket = 4;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mBytesPerFrame = 4;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 4 * 8;
	
	// Apply format
	AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         kInputBus,
                         &audioFormat,
                         sizeof(audioFormat));
    
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
    
	AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         kOutputBus,
                         &streamFormat,
                         sizeof(streamFormat));
	
	
	// Set input callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = RecordCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
	AudioUnitSetProperty(audioUnit,
                         kAudioOutputUnitProperty_SetInputCallback,
                         kAudioUnitScope_Global,
                         kInputBus,
                         &callbackStruct,
                         sizeof(callbackStruct));
	
	// Set output callback
	callbackStruct.inputProc = PlayBackCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
	AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Global,
                         kOutputBus,
                         &callbackStruct,
                         sizeof(callbackStruct));
    
    AudioUnitInitialize(audioUnit);
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
    [mySession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&audioSessionError];
    
    
    [mySession setPreferredSampleRate: 44100.0 error: &audioSessionError];
    
    [mySession setPreferredIOBufferDuration: (256.0/sampleRate) error: &audioSessionError];
    
    [mySession setActive:YES error:nil];
    
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
    
    /*
     for (int i=0;i<200000; i++) {
     printf("%d\n",tabTstFreq[i]);
     }
     */
    
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
    [self emissionSetup];
    AudioOutputUnitStart(audioUnit);
    
    return 0;
    
}


///////////
//
// Stop the Graph
//
///////////
-(int)stopProcessingAudio
{
    NSLog(@"Stop Emission");
    AudioOutputUnitStop(audioUnit);
    
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
