//
//  ViewController.m
//  TestGraph
//
//  Created by François Le Brun on 16/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"
#import "AuGraphController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize B_start;
@synthesize B_stop;
@synthesize monControlleur;

-(IBAction)start:(UIButton*)bouton
{
    [monControlleur startAUGraph];
    NSLog(@"start");
}


-(IBAction)stop:(UIButton*)bouton
{
    [monControlleur stopAUGraph];
    NSLog(@"stop");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AuGraphController *controlleur=[[AuGraphController alloc]init];
    monControlleur=controlleur;
    [monControlleur initializeAUGraph];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
