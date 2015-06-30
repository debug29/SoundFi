//
//  ViewController.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize myController;

@synthesize lab_waitingMessage;
@synthesize iv_waitingMessage;
@synthesize sw_emissionMode;
@synthesize sw_receptionMode;
@synthesize tv_receivedMessage;



-(IBAction)receptionModeOnOff:(id)sw
{
    if ([sw_receptionMode isOn])
    {
        [lab_waitingMessage setHidden:NO];
        [iv_waitingMessage startAnimating];
        [iv_waitingMessage setHidden:NO];
        [myController startAudioUnit];
    }
    else
        [myController stopProcessingAudio];
}

-(IBAction)emissionModeOnOff:(id)sw
{
    NSLog(@"Niet, pas encore disponible");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    AudioController *newControlleur=[[AudioController alloc]init];
    myController=newControlleur;

    [lab_waitingMessage setHidden:YES];
    [iv_waitingMessage setHidden:YES];
    
    [myController initAudioSession];
    [myController setupCallback];
    [myController fftSetup];
    [myController initAudioStreams];
    
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
