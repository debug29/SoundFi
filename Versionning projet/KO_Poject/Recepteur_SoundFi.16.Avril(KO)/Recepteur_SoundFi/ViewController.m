//
//  ViewController.m
//  Recepteur_SoundFi
//
//  Created by François Le Brun on 15/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) initializeMixerSettingsToUI {

    //  initialize all the MixerHostAudio methods which respond to UI objects
	
    
    [myManager enableMixerInput: 0 isOn: mixerBus0Switch.isOn];
    //    [myManager enableMixerInput: 1 isOn: mixerBus1Switch.isOn];
	[myManager enableMixerInput: 2 isOn: mixerBus2Switch.isOn];
	[myManager enableMixerInput: 3 isOn: mixerBus3Switch.isOn];
    [myManager enableMixerInput: 4 isOn: mixerBus3Switch.isOn];
    
    [myManager enableMixerInput: 5 isOn: mixerBus3Switch.isOn];
    [myManager setMixerBus5Fx: mixerBus5FxSwitch.isOn];
    
    [myManager setMixerOutputGain: mixerOutputLevelFader.value];
    [myManager setMixerFx: mixerFxSwitch.isOn];
    
    [myManager setMixerInput: 0 gain: mixerBus0LevelFader.value];
    [myManager setMixerInput: 1 gain: mixerBus1LevelFader.value];
    [myManager setMixerInput: 2 gain: mixerBus2LevelFader.value];
	[myManager setMixerInput: 3 gain: mixerBus3LevelFader.value];
    [myManager setMixerInput: 4 gain: mixerBus4LevelFader.value];
	[myManager setMixerInput: 5 gain: mixerBus5LevelFader.value];
    
    
	myManager.micFxOn = NO;
    myManager.micFxControl = .5;
    myManager.micFxType = 0;
    
	
	micFreqDisplay.text = @"go";
	
	// this updated the pitch field at regular intervals
	
	[NSTimer scheduledTimerWithTimeInterval:0.1
									 target:self
								   selector:@selector(myMethod:)
								   userInfo:myManager
									repeats: YES];
	
	
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AudioManager *myManager_=[[AudioManager alloc] init];
    self->myManager=myManager_;
    AUGraphStart(myManager->audioGraph);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
