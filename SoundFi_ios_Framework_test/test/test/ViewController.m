//
//  ViewController.m
//  test
//
//  Created by François Le Brun on 21/07/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
            

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    audioSession = [[SoundFiAudioSession alloc]init];
    [audioSession printASCIItoFrequencyTable];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) messageReceived:(NSString*) theMessage{}
- (void) startingReception{}
- (void) progressStatut:(float) percent{}
- (void) finishEmission{}
- (void) soundToLow{}
@end
