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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AudioManager *myManager=[[AudioManager alloc] init];
    self->myManager=myManager;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
