//
//  AudioController.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AudioController.h"
#include <pthread.h>

void smb2PitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize,
					long osamp, float sampleRate, float *indata, float *outdata,
					FFTSetup fftSetup, float * frequency);


// for some calculation in the fft callback
// check to see if there is a vDsp library version
float MagnitudeSquared(float x, float y) {
	return ((x*x) + (y*y));
}

void fixedPointToSInt16( SInt32 * source, SInt16 * target, int length ) {
    
    int i;
    
    for(i = 0;i < length; i++ ) {
        target[i] =  (SInt16) (source[i] >> 9);
        
    }
    
}

OSStatus fftGetFrequency (
                        void *inRefCon,                // scope (MixerHostAudio)
                        UInt32 inNumberFrames,        // number of frames in this slice
                        SInt16 *sampleBuffer) {      // frames (sample data)
    
    // scope reference that allows access to everything in MixerHostAudio class
    
	AudioController *THIS = (__bridge AudioController *)inRefCon;
    
  	float *outputBuffer = THIS->outputBuffer;
	float *analysisBuffer = THIS->analysisBuffer;
    
    FFTSetup fftSetup = THIS->fftSetup;      // fft setup structures need to support vdsp functions
	
    
	uint32_t stride = 1;                    // interleaving factor for vdsp functions
	int bufferCapacity = 512;    // maximum size of fft buffers
    
    float pitchShift = 1.0;                 // pitch shift factor 1=normal, range is .5->2.0
    long osamp = 4;                         // oversampling factor
    long fftSize = 512;                    // fft size
    
	
	float frequency;                        // analysis frequency result
    
    
    //	ConvertInt16ToFloat
    
    vDSP_vflt16((SInt16 *) sampleBuffer, stride, (float *) analysisBuffer, stride, bufferCapacity );
    
    // run the pitch shift
    
    // scale the fx control 0->1 to range of pitchShift .5->2.0
    
    pitchShift = (0.5 * 1.5) + .5;
    
    // osamp should be at least 4, but at this time my ipod touch gets very unhappy with
    // anything greater than 2
    
    osamp = 3;
    fftSize = 512;		// this seems to work in real time since we are actually doing the fft on smaller windows
    
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


/*
OSStatus fftGetFrequency (   void                        *inRefCon,          // scope referece for external data
                         UInt32 						inNumberFrames,     // number of frames to process
                         SInt16 *sampleBuffer)                           // frame buffer
{
	
    // note: the fx control slider does nothing during fft passthrough
    
    // set all the params
    
    // scope reference that allows access to everything in MixerHostAudio class
    
    AudioController *THIS = (__bridge AudioController*)inRefCon;
    
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
	
    
    
	// this next logic assumes that the bufferCapacity determined by maxFrames in the fft-setup is less than or equal to
	// the inNumberFrames (which should be determined by the av session IO buffer size (ie duration)
	//
	// If we can guarantee the fft buffer size is equal to the inNumberFrames, then this buffer filling step is unecessary
	//
	// at this point i think its essential to make the two buffers equal size in order to do the fft passthrough without doing
	// the overlapping buffer thing
	//
	
    
	// Fill the buffer with our sampled data. If we fill our buffer, run the
	// fft.
	
	// so I have a question - the fft buffer  needs to be an even multiple of the frame (packet size?) or what?
    
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
            printf("%f\n",curFreq);
			if (curFreq > dominantFrequency) {
				dominantFrequency = curFreq;
				bin = (i+1)/2;
			}
		}
        printf("\n\n");
        
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
*/

OSStatus renderToneCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers) {
 
    AudioController *THIS=(__bridge AudioController*)userData;
    int compteur = THIS->compteur;

    //If emissionMode = TRUE then start sending stuff
    if (THIS->emissionMode) {
        double theta = THIS->theta;
        int frequence;
        
        pthread_mutex_lock(&THIS->emissionMutex);
        
        if (compteur < [THIS->myMessage length]) {
            frequence=18500 +(((int)[THIS->myMessage characterAtIndex:compteur]-32)*20);
            printf("Freq : %d carac: %c \n",frequence,[THIS->myMessage characterAtIndex:compteur]);
        }
        else
            frequence=20550;
        
        if (THIS->nbCaracRepeat==2)
        {
            THIS->compteur = compteur+1;
            THIS->nbCaracRepeat = 0;
        }
        else
            THIS->nbCaracRepeat=THIS->nbCaracRepeat+1;
        
        pthread_mutex_unlock(&THIS->emissionMutex);
        
        
        double theta_increment = 2.0 * M_PI * frequence / THIS->sampleRate;     // θ(n) = 2πƒ n / r
        const double amplitude = 1.0;
        
        
        Float32 *buffer = (Float32 *)buffers->mBuffers[0].mData;  //Get the buffer (0->mono, 1->stereo)
        
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
        
        //Get the new value of theta
        THIS->theta = theta;
        
        
    }
    
    return noErr;
}


//Get sample here
OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers) {
    
    AudioController *THIS=(__bridge AudioController*)userData;
    AudioUnit audioUnit=(THIS->audioUnit);
    int compteur = THIS->compteur;
    
    
    //If recepetionMode = TRUE then start recording and analysis stuff
    if(THIS->receptionMode)
    {
        OSStatus status = AudioUnitRender(audioUnit, actionFlags, audioTimeStamp,
                                          1, numFrames, buffers);
        
        if(status != noErr) {
            NSLog(@"Arror AudioUnitRender %d",(int)status);
            return status;
        }
        
        AudioUnitSampleType *echantillonAudio;
        SInt16 *buffer=THIS->samplesBuffer;
        echantillonAudio=(AudioUnitSampleType*) buffers->mBuffers[0].mData;
        
        fixedPointToSInt16(echantillonAudio, buffer, numFrames);
        
        //Get the frequency from the sample
        status=fftGetFrequency ( userData, numFrames, buffer);
        
        //Test the frequency and start the transaction if init signal
        //is receive, end with a stop signal
        if (THIS->sampleFrequency>=18490 && THIS->sampleFrequency<=20420) {
            
            NSString *res = [NSString stringWithFormat:@"%c",(char)((THIS->sampleFrequency-18490)/20+32)];
            NSLog(@" Freq : %d  ASCII: %3d Carac : %@",THIS->sampleFrequency,(THIS->sampleFrequency-18490)/20+32,res);
            [THIS->messageReceive appendString:res];
            
            /*
            compteur=0;
            
            //Stop the transaction
            if ([res isEqualToString:@":stop"])
            {
                NSLog(@"Ending transaction");
                THIS->isInitiate=FALSE;
                THIS->isTimeOut=FALSE;
                [THIS startAnalysis];
            }
            
            //If init add the char to the string message
            if (THIS->isInitiate)
            {
                [THIS->messageReceive appendString:res];
            }
            
            //Init the transaction
            if ([res isEqualToString:@"init:"])
            {
                NSLog(@"Starting Transaction");
                THIS->isInitiate=TRUE;
                THIS->isTimeOut=TRUE;
            }
            */
        }
        
        
        buffers->mBuffers[0].mData=THIS->emptySample;
        
        //Deal with timeout, if transaction is init, if nothing is coming, stop the process
        if (THIS->isTimeOut && compteur>1000) {
            NSLog(@"TimeOut");
            THIS->isInitiate=FALSE;
            [THIS startAnalysis];
            [THIS stopProcessingAudio];
        }
        
        THIS->compteur=compteur+1;
         
    }
    
    return noErr;
}

@implementation AudioController



-(AudioController*)init
{
    self=[super init];
    
    [self initAudioSession];
    [self setupCallback];
    [self fftSetup];
    [self initAudioStreams];
    
    pthread_mutex_init(&emissionMutex, NULL);
    nbCaracRepeat=0;
    
    return self;
}

//Set up some variable for the renderCallback
-(void)setupCallback
{
    isInitiate=FALSE;
    isTimeOut=FALSE;
    
    receptionMode=FALSE;
    emissionMode=FALSE;
    
    emptySample=malloc(512*sizeof(AudioUnitSampleType));
    for (int i=0; i<512; i++) {
        emptySample[i]=0;
    }
    
    samplesBuffer=(SInt16*)malloc(512 *sizeof(float));
}

//Set up variable and tabs for the fft
-(void)fftSetup
{
    /*
    outputBuffer = (float*)malloc(512 *sizeof(float));
	analysisBuffer = (float*)malloc(512 *sizeof(float));
    
    fftLog2n = log2f(512);
	micFxControl = 0.5f;
    
    fftSetup = vDSP_create_fftsetup(fftLog2n, FFT_RADIX2);
    */
    
    UInt32 maxFrames = 512;    // fft size
	
	
	// setup input and output buffers to equal max frame size
	
	dataBuffer = (void*)malloc(maxFrames * sizeof(SInt16));
	outputBuffer = (float*)malloc(maxFrames *sizeof(float));
	analysisBuffer = (float*)malloc(maxFrames *sizeof(float));
	
	// set the init stuff for fft based on number of frames
	
	fftLog2n = log2f(maxFrames);		// log base2 of max number of frames, eg., 10 for 512
	fftN = 1 << fftLog2n;					// actual max number of frames, eg., 512 - what a silly way to compute it
    
    
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

//Init the parameters of the audioSession
-(int)initAudioSession
{
    NSLog(@"Initialisation de la session audio");
    sampleRate=44100.0;
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord error: &audioSessionError];
    
    
    [mySession setPreferredSampleRate: 44100.0 error: &audioSessionError];
    
    [mySession setPreferredIOBufferDuration: (512.0/sampleRate) error: &audioSessionError];
    
    [mySession setActive:YES error:nil];
    
    return 0;
}



//Set all the parameters of stream
//including IO and mixer
//Set the graph
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

//Comparison for the analysis of the message
-(NSString*)analysisCompare:(NSString*)un : (NSString*)deux : (NSString*)trois
{
    if ([un isEqualToString:deux])
    {
        return un;
    }
    else if ([un isEqualToString:trois])
    {
        return un;
    }
    else if ([deux isEqualToString:trois])
    {
        return deux;
    }
    
    return @"";
}


//Analysis of the message receive during the transaction
//including errors treatment and some other things soon .....
-(void)startAnalysis
{
    if ([messageReceive length]<=0) {
        return;
    }
    NSArray *component;
    NSMutableString *chaineFinale=[[NSMutableString alloc]init];
    
    NSLog(@"%@",messageReceive);
    
    
    //Remove the init and stop message
    component=[messageReceive componentsSeparatedByString:@"init:"];
    component=[component[[component count]-1] componentsSeparatedByString:@":stop"];
    messageReceive=component[0];
    
    
    //Deals with the repeatition of caractère using a FEC like
    for (int i=0; i<[messageReceive length]-2; i=i+3) {
        NSString *un=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i]];
        NSString *deux=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i+1]];
        NSString *trois=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i+2]];
        
        NSLog(@"%@ %@ %@",un,deux,trois);

        [chaineFinale appendString: [self analysisCompare:un:deux:trois]];
        
    }
    
    //FEC like end in case where the message is not a x3
    if ([messageReceive length]%2==1) {
        NSString *un=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:[messageReceive length]-2]];
        NSString *deux=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:[messageReceive length]-1]];
        if ([un isEqualToString:deux])
            [chaineFinale appendString:un];
    }
    
    
    NSLog(@"Resultat : %@",chaineFinale);
}

// Start the Graph
// if mode=0  ==> reception mode
// if mode=1  ==> emission mode
-(int)startAudioUnit:(int)mode
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
            emissionMode=TRUE;
            [self emissionSetup];
            AudioUnitInitialize(emissionUnit);
            AudioOutputUnitStart(emissionUnit);
        }
    }
    
    return 0;
    
}

// Stop the Graph
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
        AudioUnitUninitialize(emissionUnit);
        AudioComponentInstanceDispose(emissionUnit);
        emissionUnit=nil;
    }
    
    [self startAnalysis];
    
    receptionMode=FALSE;
    emissionMode=FALSE;
    return 0;
    
    

}


@end
