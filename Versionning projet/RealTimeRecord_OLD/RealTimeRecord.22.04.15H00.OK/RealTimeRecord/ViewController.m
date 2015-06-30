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
@synthesize B_start;
@synthesize B_stop;
@synthesize myController;


- (void)viewDidLoad
{
    [super viewDidLoad];
    AudioController *newControlleur=[[AudioController alloc]init];
    myController=newControlleur;

    
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


-(IBAction)start:(UIButton*)bouton
{
    [myController startAudioUnit];
}


-(IBAction)stop:(UIButton*)bouton
{
    [myController stopProcessingAudio];
}

@end
