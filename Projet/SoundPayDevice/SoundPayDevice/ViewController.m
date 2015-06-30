//
//  ViewController.m
//  SoundPayDevice
//
//  Created by François Le Brun on 27/05/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize sw_finalisation;
@synthesize sw_id;
@synthesize sw_prix;
@synthesize lab_payInfo;
@synthesize img_good;

// Mot de pass crypté tRbVQ9KjTWqcOQ9r7pyCUI7hkMdg8f13lISsT0H6y9s=

- (void)viewDidLoad
{
    [super viewDidLoad];
    soundEngine = [[SoundFiAudioSession alloc] init];
    soundEngine.delegate=self;
    transactionState=0;
    nbEssai=3;
    
    soundEngine->myID=@"{id_user:\"134513455\"";                                    //Init à la main
    soundEngine->cryptedPassAES=@"tRbVQ9KjTWqcOQ9r7pyCUI7hkMdg8f13lISsT0H6y9s=";    //Init à la main
    
    
    //[AESCrypt encrypt:@"gjt:;=PLght54dcgxXDS" password:@"24021992"];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:1.];
    alertView.transform = CGAffineTransformRotate(alertView.transform, M_PI);
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotate {return YES;}
- (NSUInteger)supportedInterfaceOrientations {return UIInterfaceOrientationMaskAll;}

- (void) transactionStatutChange:(int)statut{
    switch (statut) {
        case 3: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sw_prix setOn:TRUE];
            });
        }
            break;
        case 4: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sw_id setOn:TRUE];
            });
        }
            break;
        case 6: {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([paiementStatut isEqualToString:@"{valid:\"1\"}"]) {
                    img_good.backgroundColor=[UIColor greenColor];
                }
                else if ([paiementStatut isEqualToString:@"{valid:\"0\"}"]) {
                    img_good.backgroundColor=[UIColor redColor];
                }
                
                [sw_finalisation setOn:TRUE];
                img_good.alpha=1.;
            });
        }
            break;
        default:
            break;
            
    }
}

- (void) transactionData:(NSString*)transactionData{lab_payInfo.text=transactionData;}
- (void) transactionFinalState:(NSString*)transactionFinalState{}
- (void) messageReceived:(NSString*) theMessage : (int)quality {}
- (void) startingReception{}
- (void) finishEmission{}
- (void) soundToLow{}
- (void) progressStatut:(float) percent{}

- (IBAction)restart:(id)sender {
    [soundEngine relaunchReception];
    transactionState=0;
    soundEngine->timeOutProcess=20000;
    
    [sw_finalisation setOn:FALSE];
    [sw_id setOn:FALSE];
    [sw_prix setOn:FALSE];
    img_good.alpha=0.;
    lab_payInfo.text=@"Info Paiement :";
}

@end

