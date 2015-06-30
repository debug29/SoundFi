//
//  AudioController.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AudioController.h"



void frequencyDecoder(int f)
{
    if (f>19992 || f<20008) {
        (f>19379 && f<19387) ? printf("a") : 0;
        (f>19400 && f<19008) ? printf("b") : 0;
        (f>19421 && f<19429) ? printf("c") : 0;
        (f>19442 && f<19450) ? printf("d") : 0;
        (f>19464 && f<19472) ? printf("e") : 0;
        (f>19485 && f<19493) ? printf("f") : 0;
        (f>19506 && f<19514) ? printf("g") : 0;
        (f>19527 && f<19535) ? printf("h") : 0;
        (f>19549 && f<19557) ? printf("i") : 0;
        (f>19570 && f<19578) ? printf("j") : 0;
        (f>19591 && f<19599) ? printf("k") : 0;
        (f>19613 && f<19621) ? printf("l") : 0;
        (f>19634 && f<19642) ? printf("m") : 0;
        (f>19655 && f<19663) ? printf("n") : 0;
        (f>19676 && f<19684) ? printf("o") : 0;
        (f>19698 && f<19706) ? printf("p") : 0;
        (f>19719 && f<19727) ? printf("q") : 0;
        (f>19740 && f<19748) ? printf("r") : 0;
        (f>19761 && f<19769) ? printf("s") : 0;
        (f>19783 && f<19791) ? printf("t") : 0;
        (f>19804 && f<19812) ? printf("u") : 0;
        (f>19825 && f<19833) ? printf("v") : 0;
        (f>19846 && f<19854) ? printf("w") : 0;
        (f>19868 && f<19876) ? printf("x") : 0;
        (f>19889 && f<19897) ? printf("y") : 0;
        (f>19910 && f<19918) ? printf("z") : 0;
    }
}


void smb2PitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize,
					long osamp, float sampleRate, float *indata, float *outdata,
					FFTSetup fftSetup, float * frequency);

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
	int bufferCapacity = 1024;    // maximum size of fft buffers
    
    float pitchShift = 1.0;                 // pitch shift factor 1=normal, range is .5->2.0
    long osamp = 4;                         // oversampling factor
    long fftSize = 1024;                    // fft size
    
	
	float frequency;                        // analysis frequency result
    
    
    //	ConvertInt16ToFloat
    
    vDSP_vflt16((SInt16 *) sampleBuffer, stride, (float *) analysisBuffer, stride, bufferCapacity );
    
    // run the pitch shift
    
    // scale the fx control 0->1 to range of pitchShift .5->2.0
    
    pitchShift = (THIS->micFxControl * 1.5) + .5;
    
    // osamp should be at least 4, but at this time my ipod touch gets very unhappy with
    // anything greater than 2
    
    osamp = 4;
    fftSize = 1024;		// this seems to work in real time since we are actually doing the fft on smaller windows
    
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


OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers) {
    
    AudioController *THIS=(__bridge AudioController*)userData;
    AudioUnit audioUnit=(THIS->audioUnit);
    int compteur = THIS->compteur;
    
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
    
    
    status=fftGetFrequency ( userData, numFrames, buffer);
    
    //Affichage de la fréquence
    //NSLog(@"Frequency : %d",THIS->sampleFrequency);
    frequencyDecoder(THIS->sampleFrequency);
    
    /*
    for (int i=0; i<numFrames; i++) {
        printf("%7d ",buffer[i]);
        if(i%16==0 && i!=0)
            printf("\n");
    }
    printf("\n");
    printf("\n");
    */

    
    
    buffers->mBuffers[0].mData=THIS->emptySample;
    
    THIS->compteur=compteur+1;
    
    return noErr;
}

@implementation AudioController

-(void)setupCallback
{
    emptySample=malloc(1024*sizeof(AudioUnitSampleType));
    for (int i=0; i<1024; i++) {
        emptySample[i]=0;
    }
    
    samplesBuffer=(SInt16*)malloc(1024 *sizeof(float));
}

-(void)fftSetup
{
    outputBuffer = (float*)malloc(1024 *sizeof(float));
	analysisBuffer = (float*)malloc(1024 *sizeof(float));
    
    fftLog2n = log2f(1024);
	micFxControl = 0.5f;
    
    fftSetup = vDSP_create_fftsetup(fftLog2n, FFT_RADIX2);
    
}


-(int)initAudioSession
{
    NSLog(@"Initialisation de la session audio");
    sampleRate=44100.0;
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord error: &audioSessionError];
    
    
    [mySession setPreferredSampleRate: 44100.0 error: &audioSessionError];
    
    Float32 currentBufferDuration =  (Float32) (1024.0 / 44100.0);
	UInt32 sss = sizeof(currentBufferDuration);
	
	AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, sizeof(currentBufferDuration), &currentBufferDuration);
	NSLog(@"setting buffer duration to: %f", currentBufferDuration);
    
    [mySession setActive:YES error:nil];
    
    
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &sss, &currentBufferDuration);
	NSLog(@"Actual current hardware io buffer duration: %f ", currentBufferDuration );
    
    return 0;
}




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
    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                               sizeof(UInt32), &overrideCategory) != noErr) {
        // Less serious error, but you may want to handle it and bail here
    }
    
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                          Initialisation de l'unité son io audioUnit                          */
     ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    AudioComponentDescription ioComponentDescription;
    ioComponentDescription.componentType = kAudioUnitType_Output;
    ioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    ioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioComponentDescription.componentFlags = 0;
    ioComponentDescription.componentFlagsMask = 0;
    
    /* Configuration de la ioUnit Hors node
     
    AudioComponent component = AudioComponentFindNext(NULL, &ioComponentDescription);
    if(AudioComponentInstanceNew(component, &audioUnit) != noErr) {
        return 1;
    }
    
    UInt32 enable = 1;
    if(AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO,
                            kAudioUnitScope_Input, 1, &enable, sizeof(UInt32)) != noErr) {
        return 1;
    }
    */
    
    /* CallBack sur la ioUnit hors node
     
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; // Render function
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    if(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback,
                            kAudioUnitScope_Input, 0, &callbackStruct,
                            sizeof(AURenderCallbackStruct)) != noErr) {
        return 1;
    }
    */
    
    //ASBD for mono record  PEUT ETRE A REMPLACER AVEC LA DEF DE audiograph ????????
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
    /*
    streamDescription.mSampleRate = 44100;
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    streamDescription.mBitsPerChannel = 16;
    streamDescription.mBytesPerFrame = 2;
    streamDescription.mChannelsPerFrame = 1;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * streamDescription.mChannelsPerFrame;
    streamDescription.mFramesPerPacket = 1;
    streamDescription.mReserved = 0;
    */
    
    /*   Set Ptoperty pour iounit hors node
     
    // Set up input stream with above properties
    if(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    
    
    // Ditto for the output stream, which we will be sending the processed audio to
    if(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
     */
    
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                     Fin de l'initialisation de l'unité son io audioUnit                     */
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    
    
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                          Initialisation de l'unité son du mixeur                             */
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
        AudioComponentDescription mixerComponentDescription;
        mixerComponentDescription.componentType = kAudioUnitType_Mixer;
        mixerComponentDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        mixerComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        mixerComponentDescription.componentFlags = 0;
        mixerComponentDescription.componentFlagsMask = 0;
        

    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                     Fin de l'initialisation de l'unité son du mixeur                         */
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    
    err=AUGraphAddNode(myGraph, &ioComponentDescription, &ioNode);
    if (err!=noErr) {NSLog(@"Error AUGraphAddNode1");}
    err=AUGraphAddNode(myGraph, &mixerComponentDescription, &mixerNode);
    if (err!=noErr) {NSLog(@"Error AUGraphAddNode2");}
    
    
    
    err=AUGraphOpen (myGraph);
    if (err!=noErr) {NSLog(@"Error AUGraphOpen");}
    
    AUGraphNodeInfo (myGraph,ioNode,NULL,&audioUnit);       //Va écraser les config précédente de l'audioUnit   BAD   ? ? ? ? ? ?
    if (err!=noErr) {NSLog(@"Error AUGraphNodeInfo1");}
    AUGraphNodeInfo (myGraph,mixerNode,NULL,&mixerUnit);    //Pareil pour le mixer, mettre config après  ? ? ? ? ? ? ? ? ?
    if (err!=noErr) {NSLog(@"Error AUGraphNodeInfo2");}
    
    //////////////////////////////////
    
	
    // Enable input for the I/O unit, which is disabled by default. (Output is
    //	enabled by default, so there's no need to explicitly enable it.)
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
    
    /*
    // Set up input stream with above properties
    if(AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    */
    
    //Active l'entrée du bus 1 pour le mixer
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
    
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Input,
                          1,
                          &streamDescription,
                          sizeof (streamDescription)
                          );
    
    
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_SampleRate,
                          kAudioUnitScope_Output,
                          0,
                          &sampleRate,
                          sizeof (sampleRate)
                          );
    ////////////////////////////////////
    
    
    // Attache un callback sur l'entrée du mixer, il va ainsi demander des infos
    AURenderCallbackStruct inputCallbackStruct;
	
    inputCallbackStruct.inputProc        = renderCallback;	// callback à complété, a quoi va t'il servir?????
    inputCallbackStruct.inputProcRefCon  = (__bridge void *)(self);
	
	//  une seule entrée sur le mixer 0 ou 1  ? ?? ?
    err = AUGraphSetNodeInputCallback (myGraph,mixerNode,1,&inputCallbackStruct); //1 => input du mixer  0 => sortie
    if(err!=noErr){NSLog(@"Error NodeInputCallBack");}
    
    AUGraphConnectNodeInput(myGraph, mixerNode, 0, ioNode, 0);
    
    //Permet l'affichage du graph dans la console pour check son état
    CAShow (myGraph);
    
    err = AUGraphInitialize (myGraph);
    if(err!=noErr){NSLog(@"Error AUGraphInitialize");}
    
    return 0;
}

-(int)startAudioUnit
{
    /*
    NSLog(@"Démarrage de l'écoute");
    if(AudioUnitInitialize(audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioOutputUnitStart(audioUnit) != noErr) {
        return 1;
    }
    */
    
    compteur=0;
    NSLog(@"Démarrage du graph, compteur : %d",compteur);
    OSStatus status = AUGraphStart(myGraph);
    if (status)
        NSLog(@"AUGraphStart Error");
    
    return 0;
}


-(int)stopProcessingAudio
{
    NSLog(@"Arret de l'écoute");
    
    
    Boolean isRunning = false;
    NSLog(@"Arret du graph, compteur : %d",compteur);
    OSStatus status = AUGraphIsRunning(myGraph, &isRunning);
    if (isRunning)
        status = AUGraphStop(myGraph);
    if (status)
        NSLog(@"AUGraphStop Error");
    
    
    
    /*
    if(AudioOutputUnitStop(audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioUnitUninitialize(audioUnit) != noErr) {
        return 1;
    }
    
    audioUnit = NULL;
    */
     return 0;
}


@end
