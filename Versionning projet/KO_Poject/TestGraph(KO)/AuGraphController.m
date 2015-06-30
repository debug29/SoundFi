//
//  AuGraphController.m
//  TestGraph
//
//  Created by François Le Brun on 16/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AuGraphController.h"


void fixedPointToSInt16( SInt32 * source, SInt16 * target, int length ) {
    
    int i;
    
    for(i = 0;i < length; i++ ) {
        target[i] =  (SInt16) (source[i] >> 9);
        
    }
    
}

static OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{

    AudioUnitSampleType *echantillonAudio;
    AuGraphController *controlleur=(__bridge AuGraphController*) inRefCon;
    SInt16 buffer[1024];
    AudioUnit unitTemp=[controlleur ioUnit];
    
             AudioUnitRender(unitTemp,
                             ioActionFlags,
                             inTimeStamp,
                             1,
                             inNumberFrames,
                             ioData);
         
    echantillonAudio = (AudioUnitSampleType *) ioData->mBuffers[0].mData; // left channel
    
    fixedPointToSInt16(echantillonAudio, buffer, inNumberFrames);
    
    for (int i=0; i<inNumberFrames; i++) {
        printf("%d ",buffer[i]);
    }
    printf("\n");
    
    return noErr;

}

static OSStatus renderInput2(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    
    AudioUnitSampleType *echantillonAudio;
    AuGraphController *controlleur=(__bridge AuGraphController*) inRefCon;
    SInt16 buffer[1024];
    AudioUnit unitTemp=[controlleur ioUnit];
    
    AudioUnitRender(unitTemp,
                    ioActionFlags,
                    inTimeStamp,
                    1,
                    inNumberFrames,
                    ioData);
    
    echantillonAudio = (AudioUnitSampleType *) ioData->mBuffers[0].mData; // left channel
    
    //fixedPointToSInt16(echantillonAudio, buffer, inNumberFrames);
    
    for (int i=0; i<inNumberFrames; i++) {
        printf("%d ",buffer[i]);
    }
    printf("\n");
    
    return noErr;
    
}

static OSStatus inputRenderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    
    NSLog(@"fnejfbef");
    return noErr;
}


@implementation AuGraphController
@synthesize ioUnit;
@synthesize mixer;
@synthesize inputNode;



- (void)initializeAUGraph;
{
    sampleRate=44100.0;
    
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord error: &audioSessionError];
    
    
    [mySession setPreferredSampleRate: sampleRate error: &audioSessionError];
    
    Float32 currentBufferDuration =  (Float32) (1024.0 / sampleRate);
	UInt32 sss = sizeof(currentBufferDuration);
	
	AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, sizeof(currentBufferDuration), &currentBufferDuration);
	NSLog(@"setting buffer duration to: %f", currentBufferDuration);
    
    [mySession setActive:YES error:nil];
    
    sampleRate = [mySession sampleRate];
    NSLog(@"SampleRate actuelle %f",sampleRate);
    
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &sss, &currentBufferDuration);
	NSLog(@"Actual current hardware io buffer duration: %f ", currentBufferDuration );
    
    
    
    
    
    
    NSLog(@"Initialisation du graph");
    
	// Error checking result
	OSStatus result = noErr;
    
	// create a new AUGraph
    
	result = NewAUGraph(&monGraph);
    
    if (result!=noErr) {NSLog(@"Error create new Graph");}
    
    // AUNodes represent AudioUnits on the AUGraph and provide an
	// easy means for connecting audioUnits together.
    
	//  intput component
	AudioComponentDescription input_desc;
	input_desc.componentType = kAudioUnitType_Output;
	input_desc.componentSubType = kAudioUnitSubType_RemoteIO;
	input_desc.componentFlags = 0;
	input_desc.componentFlagsMask = 0;
	input_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    
    // mixer component
	AudioComponentDescription mixer_desc;
	mixer_desc.componentType = kAudioUnitType_Mixer;
	mixer_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
	mixer_desc.componentFlags = 0;
	mixer_desc.componentFlagsMask = 0;
	mixer_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    
    // Add nodes to the graph to hold our AudioUnits,
	// You pass in a reference to the  AudioComponentDescription
	// and get back an  AudioUnit
	result = AUGraphAddNode(monGraph, &input_desc, &inputNode);
    result = AUGraphAddNode(monGraph, &mixer_desc, &mixerNode);
    if (result!=noErr) {NSLog(@"Error addNode1");}
    
    // open the graph AudioUnits are open but not initialized (no resource allocation occurs here)
	result = AUGraphOpen(monGraph);
    if (result!=noErr) {NSLog(@"Error oppenGraph");}
    
	// Get a link to the mixer AU so we can talk to it later
	result = AUGraphNodeInfo(monGraph, inputNode,NULL, &ioUnit);
    if (result!=noErr) {NSLog(@"Error GetNode info");}
    
    
     ////////////////////// ////////////////////// ////////////////////// ////////////////////// //////////////////////
     ////////////////////// ///// ////Configuration de l'input unit////// ////////////////////// //////////////////////
    AudioUnitElement ioUnitInputBus = 1;
    UInt32 enableInput = 1;
	
    
    result = AudioUnitSetProperty (
						  ioUnit,
						  kAudioOutputUnitProperty_EnableIO,
						  kAudioUnitScope_Input,
						  ioUnitInputBus,
						  &enableInput,
						  sizeof (enableInput)
						  );
    if (result!=noErr) {NSLog(@"Error setUnitProperty %d",(int)result);}
    
    AudioStreamBasicDescription monoStreamFormat;
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    
    monoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    monoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    monoStreamFormat.mBytesPerPacket    = bytesPerSample;
    monoStreamFormat.mFramesPerPacket   = 1;
    monoStreamFormat.mBytesPerFrame     = bytesPerSample;
    monoStreamFormat.mChannelsPerFrame  = 1;                  // 1 indicates mono
    monoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    monoStreamFormat.mSampleRate        = sampleRate;
    
    result =	AudioUnitSetProperty (
                                      ioUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      ioUnitInputBus,
                                      &monoStreamFormat,
                                      sizeof (monoStreamFormat)
                                      );
    if (result!=noErr) {NSLog(@"Error setUnitPropertyStreamFormat %d",(int)result);}
    
    
    AURenderCallbackStruct ioCallbackStruct;
	
    ioCallbackStruct.inputProc        = &renderInput2;	// 8.24 version
    ioCallbackStruct.inputProcRefCon  = (__bridge void *)(self);
    
    result = AUGraphSetNodeInputCallback (
										  monGraph,
										  inputNode,
										  0,
										  &ioCallbackStruct
										  );
    if (result!=noErr) {NSLog(@"Error setIOcallbackstruct %d",(int)noErr);}
    
    ////////////////////// /////////////////Fin config ioUnit//////////// ////////////////////// //////////////////////
     ////////////////////// ////////////////////// ////////////////////// ////////////////////// //////////////////////
    
    result = AUGraphNodeInfo(monGraph, mixerNode, NULL, &mixer);
    if (result!=noErr) {NSLog(@"Error GetmixerNode");}
    
    /////////////////////////////////
    // Multichannel Mixer unit Setup
    
    
    
    UInt32 busCount   = 3;    // bus count for mixer unit input
    UInt32 guitarBus  = 0;    // mixer unit bus 0 will be stereo and will take the guitar sound
    UInt32 beatsBus   = 1;    // mixer unit bus 1 will be mono and will take the beats sound
	UInt32 micBus	  = 2;    // mixer unit bus 2 will be mono and will take the microphone input
    //    UInt32 samplerBus   = 4;
    //    UInt32 filePlayerBus = 5;
    
    NSLog (@"Setting mixer unit input bus count to: %lu", busCount);
    result = AudioUnitSetProperty (
                                   mixer,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &busCount,
                                   sizeof (busCount)
                                   );
    
    UInt32 maximumFramesPerSlice = 4096;
    
    result = AudioUnitSetProperty (
                                   mixer,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );

    //
    //Fin de la config du mixer
    //////////////////////////////
    
    UInt16 busNumber = 2;		// mic channel on mixer
	
    // Setup the structure that contains the input render callback
    AURenderCallbackStruct inputCallbackStruct;
	
    inputCallbackStruct.inputProc        = &renderInput;	// 8.24 version
    inputCallbackStruct.inputProcRefCon  = (__bridge void *)(self);
	
	
    NSLog (@"Registering the render callback - mic/lineIn - with mixer unit input bus %u", busNumber);
    // Set a callback for the specified node's specified input
    result = AUGraphSetNodeInputCallback (
										  monGraph,
										  mixerNode,
										  busNumber,
										  &inputCallbackStruct
										  );
    if (result!=noErr) {NSLog(@"Error setCallbackmixerNode %d",(int)noErr);}
    
    NSLog (@"Setting monoStreamFormat for mixer unit bus 2 (mic/lineIn)");
    result = AudioUnitSetProperty (
								   mixer,
								   kAudioUnitProperty_StreamFormat,
								   kAudioUnitScope_Input,
								   busNumber,
								   &monoStreamFormat,
								   sizeof (monoStreamFormat)
								   );
    if (result!=noErr) {NSLog(@"Error setMixerStreamFormat %d",(int)noErr);}
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
     ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
                                    //Connection des divers node, qui que quoi connecter
    
     ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
     ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    
    
    //Initisialisation du graph
	result = AUGraphInitialize(monGraph);
    if (result!=noErr) {NSLog(@"Error Initialize graph");}
}


- (void)startAUGraph;
{
    NSLog(@"démarage du graph");
    OSStatus status = AUGraphStart(monGraph);
    if (status)
        NSLog(@"AUGraphStart Error");
}

- (void)stopAUGraph;
{
    Boolean isRunning = false;
    NSLog(@"Arret du graph");
    OSStatus status = AUGraphIsRunning(monGraph, &isRunning);
    if (isRunning)
        status = AUGraphStop(monGraph);
    if (status)
        NSLog(@"AUGraphStop Error");
}

@end
