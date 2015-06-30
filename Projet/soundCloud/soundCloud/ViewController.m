//
//  ViewController.m
//  soundCloud
//
//  Created by François Le Brun on 06/08/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize b_go;
@synthesize b_stop;

- (void)viewDidLoad {
    [super viewDidLoad];
    audioSession = [[SoundFiAudioSession alloc]init];
    audioSession.delegate=self;
    [audioSession personaliseFrequencyValue:18000 :@"123456"];
    [audioSession printASCIItoFrequencyTable];
    [audioSession startAudioUnit:SFSendingMode :@"2345634"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)a_go:(id)sender {
    [audioSession startEmitUniqueFrequency:18000];
}
- (IBAction)a_stop:(id)sender {
    [audioSession stopEmitUniqueFrequency];
}

- (void) messageReceived:(NSString*) theMessage{}
- (void) startingReception{}
- (void) progressStatut:(float) percent{}
- (void) finishEmission{}
- (void) soundToLow{}

@end
