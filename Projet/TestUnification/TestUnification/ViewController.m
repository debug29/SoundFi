//
//  ViewController.m
//  TestUnification
//
//  Created by François Le Brun on 23/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
            

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AppDelegate *myAppDelegate =(AppDelegate *)[[UIApplication sharedApplication]delegate];
    soundEngine =myAppDelegate->soundEngine;
    soundEngine.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)paiement:(id)sender {
    [soundEngine startpaiementProcessing];
}

- (void) messageReceived:(NSString*) theMessage{}
- (void) startingReception{}
- (void) progressStatut:(float) percent{}
- (void) finishEmission{}
- (void) soundToLow{}
- (void) localisationData:(NSString*)lieu :(NSString*)promotion{}
- (void) transactionStatutChange:(int)statut{}
- (void) transactionData:(NSString*)transactionData{}
- (void) transactionFinalState:(NSString*)transactionFinalState{}
@end
