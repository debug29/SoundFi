//
//  ReceptionSonViewController.m
//  Recepteur_SoundFi
//
//  Created by François Le Brun on 15/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ReceptionSonViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ReceptionSonViewController ()

@end

@implementation ReceptionSonViewController
@synthesize But_ecoute;
@synthesize But_stop;



static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32
                                  inNumberFrames,
                                  AudioBufferList *ioData) {
	
	// the data gets rendered here
    AudioBuffer buffer;
    
    // a variable where we check the status
    OSStatus status;
    
    /**
     This is the reference to the object who owns the callback.
     */
    ReceptionSonViewController *viewController = (__bridge ReceptionSonViewController*) inRefCon;
    
    /**
     on this point we define the number of channels, which is mono
     for the iphone. the number of frames is usally 512 or 1024.
     */
    buffer.mDataByteSize = inNumberFrames * 2; // sample size
    buffer.mNumberChannels = 1; // one channel
	buffer.mData = malloc( inNumberFrames * 2 ); // buffer size
	
    // we put our buffer into a bufferlist array for rendering
	AudioBufferList bufferList;
	bufferList.mNumberBuffers = 1;
	bufferList.mBuffers[0] = buffer;
    
    // render input and check for error
    status = AudioUnitRender(viewController->uniteSon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    
	// process the bufferlist in the audio processor
	[viewController processBuffer:&bufferList];
    // clean up the buffer
	free(bufferList.mBuffers[0].mData);
	
    return noErr;
}


#pragma mark objective-c class


-(void)initializeAudio
{
    OSStatus status;
	
	// We define the audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output; // we want to ouput
	desc.componentSubType = kAudioUnitSubType_RemoteIO; // we want in and ouput
	desc.componentFlags = 0; // must be zero
	desc.componentFlagsMask = 0; // must be zero
	desc.componentManufacturer = kAudioUnitManufacturer_Apple; // select provider
	
	// find the AU component by description
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// create audio unit by component
	status = AudioComponentInstanceNew(inputComponent, &(uniteSon));
    
	
    // define that we want record io on the input bus
    UInt32 flag = 1;
	status = AudioUnitSetProperty(uniteSon,
								  kAudioOutputUnitProperty_EnableIO, // use io
								  kAudioUnitScope_Input, // scope to input
								  kInputBus, // select input bus (1)
								  &flag, // set flag
								  sizeof(flag));
    /*
     We need to specifie our format on which we want to work.
     We use Linear PCM cause its uncompressed and we work on raw data.
     for more informations check.
     
     We want 16 bits, 2 bytes per packet/frames at 44khz
     */
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate			= ratioEchantillon;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 1;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 2;
	audioFormat.mBytesPerFrame		= 2;
    
    
    
    
    // set the format on the input stream
	status = AudioUnitSetProperty(uniteSon,
								  kAudioUnitProperty_StreamFormat,
								  kAudioUnitScope_Input,
								  kInputBus,
								  &audioFormat,
								  sizeof(audioFormat));
	
	
	
    /**
     We need to define a callback structure which holds
     a pointer to the recordingCallback and a reference to
     the audio processor object
     */
    
	AURenderCallbackStruct callbackStruct;
    
    // set recording callback
	callbackStruct.inputProc = recordingCallback; // recordingCallback pointer
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
    // set input callback to recording callback on the input bus
	status = AudioUnitSetProperty(uniteSon,
                                  kAudioOutputUnitProperty_SetInputCallback,
								  kAudioUnitScope_Global,
								  kInputBus,
								  &callbackStruct,
								  sizeof(callbackStruct));
    
	
    // reset flag to 0
	flag = 0;
    
    /*
     we need to tell the audio unit to allocate the render buffer,
     that we can directly write into it.
     */
	status = AudioUnitSetProperty(uniteSon,
								  kAudioUnitProperty_ShouldAllocateBuffer,
								  kAudioUnitScope_Output,
								  kInputBus,
								  &flag,
								  sizeof(flag));
	
    
    /*
     we set the number of channels to mono and allocate our block size to
     1024 bytes.
     */
	audioBuffer.mNumberChannels = 1;
	audioBuffer.mDataByteSize = 512 * 2;
	audioBuffer.mData = malloc( 512 * 2 );
	
	// Initialize the Audio Unit and cross fingers =)
	status = AudioUnitInitialize(uniteSon);
    
    NSLog(@"Started");
    
}


void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
    ReceptionSonViewController *viewController = (__bridge ReceptionSonViewController *)inClientData;
    
    [viewController stop];
}


-(void)processBuffer: (AudioBufferList*) audioBufferList
{
    AudioBuffer sourceBuffer = audioBufferList->mBuffers[0];
    
    // we check here if the input data byte size has changed
	if (audioBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
        // clear old buffer
		free(audioBuffer.mData);
        // assing new byte size and allocate them on mData
		audioBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
		audioBuffer.mData = malloc(sourceBuffer.mDataByteSize);
	}
    
	// copy incoming audio data to the audio buffer
	memcpy(audioBuffer.mData, audioBufferList->mBuffers[0].mData, audioBufferList->mBuffers[0].mDataByteSize);
    
    Float32 *res = audioBufferList->mBuffers[0].mData;
    
    for (int nb = 0; nb < (audioBufferList->mBuffers[0].mDataByteSize / 2); nb++) {
        NSLog(@"%f",res[nb]);
    }
    NSLog(@"\n\n");
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)stop
{
    
}


-(IBAction)lancerEcoute:(UIButton *)bouton
{
        AudioOutputUnitStart(uniteSon); //Démare la lecture
}


-(IBAction)stopEcoute:(UIButton *)bouton
{
    AudioOutputUnitStop(uniteSon);
    uniteSon=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ratioEchantillon=44100;
    [self initializeAudio];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
