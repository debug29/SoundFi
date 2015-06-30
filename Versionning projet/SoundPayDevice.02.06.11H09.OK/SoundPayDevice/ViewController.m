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

- (void)viewDidLoad
{
    [super viewDidLoad];
    soundEngine = [[SoundFiAudioSession alloc] init];
    soundEngine.delegate=self;
    
    acquitPrice=FALSE;
    sendingID=FALSE;
    statutReception=FALSE;
    codeOk=FALSE;
    acquitStatut=FALSE;
    endReception=FALSE;
    
    myID=@"{\"id_user\" : \"134513455\",\"pass\" : \"sd>ACKpl2Rmy{{tg\"}";
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

- (void) messageReceived:(NSString*) theMessage : (int)quality{
    
    if ([theMessage isEqualToString:@"GP"] && !acquitPrice) {                   //Si je reçoit ce message j'ai le bon prix et je continue
        NSLog(@"Le prix reçu est le bon");
        lab_payInfo.text=paiementInformation;
        [sw_prix setOn:TRUE];
        acquitPrice=TRUE;
        sendingID=TRUE;

        dispatch_sync(dispatch_get_main_queue(), ^{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"CODE" message:@"Entrer votre code secret" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.delegate=self;
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortraitUpsideDown;
            [alert show];
        });
        
    }
    
    //J'acquite le prix reçu
    if (!acquitPrice) {
        NSLog(@"J'acquite le prix reçu");
        paiementInformation=theMessage;
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [soundEngine startAudioUnit:1:theMessage];
        });
    }
    
    if (codeOk) {
        
        //Si id aquité est ok je dit Qu'il peut continuer
        if (!sendingID && !statutReception) {
            if ([theMessage isEqualToString:myID]) {
                NSLog(@"Il a reçu le bon ID");
                soundEngine->timeOutProcess=20000;   //Remet le timeOut à l'infini (si déclenché gros problème)
                [sw_id setOn:TRUE];
                statutReception=TRUE;
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [soundEngine startAudioUnit:1:@"GID"];
                });
            }
            else {
                sendingID=TRUE;
                [self messageReceived:myID :0];
            }

        }
        
        // J'envoie mon ID
        if (sendingID) {
            sendingID=FALSE;
            soundEngine->timeOutProcess=516;   // Set du timeOut à 3 sec soit 516 frames
            NSLog(@"J'envoie mon id");
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [soundEngine startAudioUnit:1:myID];
            });
        }
        
        //Je vérifie que le statut acquité est bon
        if (acquitStatut && !endReception) {
            if ([theMessage isEqualToString:@"GF"]) {
                acquitStatut=TRUE;
                endReception=TRUE;
                NSLog(@"GG Sa marche genre parfait biatch");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sw_finalisation setOn:TRUE];
                    img_good.alpha=1.;
                });
            }
            else {
                acquitStatut=FALSE;
            }
        }
        
        //Je renvoie le statut reçu comme aquitement
        if (statutReception && !acquitStatut && ![theMessage isEqualToString:myID]) {
            NSLog(@"Je renvoie le statut reçu");
            paiementStatut=theMessage;
            acquitStatut=TRUE;
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [soundEngine startAudioUnit:1:paiementStatut];
            });
        }
        
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    codeOk=TRUE;
    [self messageReceived:nil :0];
}

- (BOOL)shouldAutorotate {return YES;}
- (NSUInteger)supportedInterfaceOrientations {return UIInterfaceOrientationMaskAll;}

- (void) startingReception{}
- (void) finishEmission{}
- (void) soundToLow{}
- (void) progressStatut:(float) percent{}

- (IBAction)restart:(id)sender {
    acquitPrice=FALSE;
    sendingID=FALSE;
    statutReception=FALSE;
    codeOk=FALSE;
    acquitStatut=FALSE;
    endReception=FALSE;
    [soundEngine relaunchReception];
    
    [sw_finalisation setOn:FALSE];
    [sw_id setOn:FALSE];
    [sw_prix setOn:FALSE];
    img_good.alpha=0.;
    lab_payInfo.text=@"Info Paiement :";
}
@end
