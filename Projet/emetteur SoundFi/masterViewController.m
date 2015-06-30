//
//  masterViewController.m
//  emetteur SoundFi
//
//  Created by François Le Brun on 28/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "masterViewController.h"
#include <pthread.h>

/////
//
//  message emission
//
/////////////////
OSStatus renderTone(void *userData, AudioUnitRenderActionFlags *actionFlags,
                    const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                    UInt32 numFrames, AudioBufferList *buffers) {
    
    masterViewController *THIS=(__bridge masterViewController*)userData;
    pthread_mutex_lock(&THIS->emissionMutex);
    
    int frequence;
    
    frequence = [THIS getASCIIFrequency];
    
    [THIS emissionSampleCalcul:frequence :numFrames :(AudioSampleType *)buffers->mBuffers[0].mData];
    
    
    pthread_mutex_unlock(&THIS->emissionMutex);
    
    return noErr;
}

@implementation masterViewController

@synthesize monBOUTON;
@synthesize monBOUTONstop;
@synthesize monTEXT;



-(void)emissionSampleCalcul:(int)frequence : (int)numFrames : (AudioSampleType *)buffer
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

-(int)getASCIIFrequency
{
    int frequence;
    
    if (compteur < [myMessage length]) {
        frequence=18500 +(((int)[myMessage characterAtIndex:compteur]-32)*20);
        printf("Freq : %d carac: %c \n",frequence,[myMessage characterAtIndex:compteur]);
    }
    else
    {
        if (isSafeForWork) {
            isSafeForWork=FALSE;
            NSLog(@"STOOOOOOOP");
        }
        return 100;
    }
    
    if (nbCaracRepeat==6)
    {
        compteur = compteur+1;
        nbCaracRepeat = 0;
    }
    else
        nbCaracRepeat=nbCaracRepeat+1;
    
    return frequence;
}

-(void) creationUniteSon
{
    NSLog(@"Configuration de l'io");
    //Configure the description for the output component
	AudioComponentDescription DescComposantSortie;
	DescComposantSortie.componentType = kAudioUnitType_Output;
	DescComposantSortie.componentSubType = kAudioUnitSubType_DefaultOutput;
	DescComposantSortie.componentManufacturer = kAudioUnitManufacturer_Apple;
	DescComposantSortie.componentFlags = 0;
	DescComposantSortie.componentFlagsMask = 0;
	
    //Find a component matching with the description
	AudioComponent composantSortie = AudioComponentFindNext(NULL, &DescComposantSortie);
	
    //Assign the instance to the uniteSon
	AudioComponentInstanceNew(composantSortie, &uniteSon);
	
    //Create the callbackStruct and assign it to the RenderTone function
    //inputProcRefCon=self allow us to acces information in the RenderTone function
	AURenderCallbackStruct input;
	input.inputProc = renderTone;
	input.inputProcRefCon = (__bridge void *)(self);
	AudioUnitSetProperty(uniteSon,kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Input,0,&input,sizeof(input)); //Def des propriétés
	
    
    //ASBD configuration
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = 44100;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = 4;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = 4;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = 4 * 8;
    
    //Put the ASBD to the uniteSon
	AudioUnitSetProperty(uniteSon,kAudioUnitProperty_StreamFormat,kAudioUnitScope_Input,0,&streamFormat,sizeof(AudioStreamBasicDescription));
    
}

-(void)loadView
{
    [super loadView];
    
}

- (IBAction)playSong:(id)sender
{
    NSLog(@"Start AudioUnit");
    myMessage = [monTEXT stringValue];
    [self creationUniteSon];
    AudioUnitInitialize(uniteSon);
    AudioOutputUnitStart(uniteSon);
}

- (IBAction)stopSong:(id)sender {
    NSLog(@"Stop AudioUnit");
    isSafeForWork=TRUE;
    compteur=0;
    AudioOutputUnitStop(uniteSon);
    AudioUnitUninitialize(uniteSon);
    AudioComponentInstanceDispose(uniteSon);
    uniteSon=nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Init des variables");
        compteur=0;
        isSafeForWork=TRUE;
        nbCaracRepeat=0;
        sampleRate=44100.0;
        isOn=FALSE;
        
    }
    return self;
}

@end
