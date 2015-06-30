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

/*
static OSStatus recordingCallback(void *inRefCon,
                                   AudioUnitRenderActionFlags *ioActionFlags,
                                   const AudioTimeStamp *inTimeStamp,
                                   UInt32 inBusNumber,
                                   UInt32 inNumberFrames,
                                   AudioBufferList *ioData) {
	
	// the data gets rendered here
    AudioBuffer buffer;
    
    // a variable where we check the status
    OSStatus status;
    

    ReceptionSonViewController* viewController = (__bridge ReceptionSonViewController *)(inRefCon);

    buffer.mDataByteSize = inNumberFrames * 2; // sample size
    buffer.mNumberChannels = 1; // one channel
	buffer.mData = malloc( inNumberFrames * 2 ); // buffer size
	
    // we put our buffer into a bufferlist array for rendering
    
    // render input and check for error
    status = AudioUnitRender(viewController->uniteSon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
	
    Float32 *res= (Float32 *)ioData->mBuffers[0].mData;
    
    for (int i = 0;i<inNumberFrames;i++) {
        NSLog(@"%f ",res[i]);
    }
    NSLog(@"\n");
    
	
    return noErr;
    
}
*/

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    // TODO: Use inRefCon to access our interface object to do stuff
    // Then, use inNumberFrames to figure out how much data is available, and make
    // that much space available in buffers in an AudioBufferList.
    
    
    ReceptionSonViewController* viewController = (__bridge ReceptionSonViewController *)(inRefCon);
    
    AudioBufferList *bufferList; // <- Fill this up with buffers (you will want to malloc it, as it's a dynamic-length list)
    
    // Then:
    // Obtain recorded samples
    
    OSStatus status;
    NSLog(@"%@",viewController);
    status = AudioUnitRender(viewController->uniteSon,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             bufferList);
    
    Float32 *res= (Float32 *)bufferList->mBuffers[0].mData;
    
    for (int i = 0;i<inNumberFrames;i++) {
        NSLog(@"%f ",res[i]);
    }
    NSLog(@"\n");
    
    return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
    ReceptionSonViewController *viewController = (__bridge ReceptionSonViewController *)inClientData;
    
    [viewController stop];
}



-(void) recupAudio
{
    OSStatus status;
    
	AudioComponentDescription DescComposantEntree;  // configuration des propriété du composant de sortie audio
	DescComposantEntree.componentType = kAudioUnitType_Output;
	DescComposantEntree.componentSubType = kAudioUnitSubType_RemoteIO;
	DescComposantEntree.componentManufacturer = kAudioUnitManufacturer_Apple;
	DescComposantEntree.componentFlags = 0;
	DescComposantEntree.componentFlagsMask = 0;
	
	AudioComponent composantEntree = AudioComponentFindNext(NULL, &DescComposantEntree); // Création du composant de sortie
	
	AudioComponentInstanceNew(composantEntree, &uniteSon); //Crée une nouvelle instance de son dans le composant de sortie par défaut
	
    UInt32 flag = 1;
    status = AudioUnitSetProperty(uniteSon,
                                  kAudioOutputUnitProperty_EnableIO, // use io
                                  kAudioUnitScope_Input, // scope to input
                                  1, // select input bus (1)
                                  &flag, // set flag
                                  sizeof(flag));
    
    AudioStreamBasicDescription streamFormat;           //Description du format de sortie audio
	streamFormat.mSampleRate = ratioEchantillon;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = 4;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = 4;
	streamFormat.mChannelsPerFrame = 1;         // On a ici une emission sur un channel (le channel 0 en locurence)
	streamFormat.mBitsPerChannel = 4 * 8;
    
    status = AudioUnitSetProperty(uniteSon,
								  kAudioUnitProperty_StreamFormat,
								  kAudioUnitScope_Input,
								  1,
								  &streamFormat,
								  sizeof(streamFormat));
    
    AURenderCallbackStruct callbackStruct;
    
    // set recording callback
	callbackStruct.inputProc = recordingCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
    // set input callback to recording callback on the input bus
	status = AudioUnitSetProperty(uniteSon,
                                  kAudioOutputUnitProperty_SetInputCallback,
								  kAudioUnitScope_Global,
								  1,
								  &callbackStruct,
								  sizeof(callbackStruct));
    
    
    /*
     we need to tell the audio unit to allocate the render buffer,
     that we can directly write into it.
     */
	status = AudioUnitSetProperty(uniteSon,
								  kAudioUnitProperty_ShouldAllocateBuffer,
								  kAudioUnitScope_Output,
								  1,
								  &flag,
								  sizeof(flag));
	
    NSLog(@"walé");
    AudioUnitInitialize(uniteSon); //Init de l'unité de son
    
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
    AudioUnitUninitialize(uniteSon); // "Désactive" l'unité
    AudioComponentInstanceDispose(uniteSon); //Retire l'unité du composant audio
    uniteSon=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ratioEchantillon=44100;
    
    [self recupAudio];
    /*
    OSStatus test = AudioSessionInitialize(NULL, NULL,ToneInterruptionListener, (__bridge void *)(self)); //Démare une session audio
    
    if(test == kAudioSessionNoError)
    {
        UInt32 sessionCategory = kAudioSessionCategory_RecordAudio;  // Met le type lecture media pour la session courante
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    }
    AudioSessionSetActive(true);
    */
    
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
