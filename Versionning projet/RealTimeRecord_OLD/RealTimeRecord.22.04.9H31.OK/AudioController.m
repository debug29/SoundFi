//
//  AudioController.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AudioController.h"

void fixedPointToSInt16( SInt32 * source, SInt16 * target, int length ) {
    
    int i;
    
    for(i = 0;i < length; i++ ) {
        target[i] =  (SInt16) (source[i] >> 9);
        
    }
    
}



OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers) {
    
    AudioController *THIS=(__bridge AudioController*)userData;
    AudioUnit audioUnit=(THIS->audioUnit);
    float *convertedSampleBuffer=THIS->convertedSampleBuffer;
    
    OSStatus status = AudioUnitRender(audioUnit, actionFlags, audioTimeStamp,
                                      1, numFrames, buffers);
    
    if(status != noErr) {
        NSLog(@"Arror AudioUnitRender %d",(int)status);
        return status;
    }
    
    AudioUnitSampleType *echantillonAudio;
    SInt16 buffer[1024];
    echantillonAudio=(AudioUnitSampleType*) buffers->mBuffers[0].mData;
    fixedPointToSInt16(echantillonAudio, buffer, numFrames);
    
    
    
    for (int i=0; i<numFrames; i++) {
        printf("%7d ",buffer[i]);
        if(i%16==0 && i!=0)
            printf("\n");
    }
    printf("\n");
    printf("\n");
    
    
    return noErr;
}

@implementation AudioController

-(int)initAudioSession
{
        NSLog(@"Initialisation de la session audio");
    
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
    
    float rate = 44100.f;
    
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
    streamDescription.mSampleRate        = rate;
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
    
    
    float sampleRate= 44100.f;
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
    
    NSLog(@"Démarrage du graph");
    OSStatus status = AUGraphStart(myGraph);
    if (status)
        NSLog(@"AUGraphStart Error");
    
    return 0;
}


-(int)stopProcessingAudio
{
    NSLog(@"Arret de l'écoute");
    
    
    Boolean isRunning = false;
    NSLog(@"Arret du graph");
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
