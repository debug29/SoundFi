//
//  ViewController.m
//  soundFiMessaging_v2
//
//  Created by François Le Brun on 04/08/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize imageview;

- (void)viewDidLoad {
    [super viewDidLoad];
    audioSession = [[SoundFiAudioSession alloc]init];
    audioSession.delegate=self;
    [audioSession personaliseFrequencyValue:18000 :@"123456"];
    [audioSession printASCIItoFrequencyTable];
    
    [imageview setImage:[UIImage imageNamed:@"Breaking-Bad-Heisenberg.jpg"]];
    imageview.alpha=0.;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action_bouton:(id)sender {
    [audioSession startAudioUnit:SFSendingMode :@"2345634"];
}

- (void) messageReceived:(NSString*) theMessage{
    if([theMessage isEqualToString:@"2345634"]){
        NSLog(@"Pouet + %@",theMessage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageview.alpha=1.;
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            imageview.alpha=0.;
        });
    }
}
- (void) startingReception{}
- (void) progressStatut:(float) percent{}
- (void) finishEmission{}
- (void) soundToLow{}
- (void) transactionFinalState:(NSString*)transactionFinalState{}

@end
