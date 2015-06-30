//
//  ViewController.m
//  SoundPayCaisse
//
//  Created by François Le Brun on 27/05/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize tf_prix;
@synthesize b_demandePaiement;
@synthesize sw_bankData;
@synthesize sw_prix;
@synthesize sw_statut;

- (void)viewDidLoad
{
    [super viewDidLoad];
    soundEngine = [[SoundFiAudioSession alloc] init];
    soundEngine.delegate=self;
    tf_prix.delegate=self;
    [tf_prix setReturnKeyType:UIReturnKeyDone];
    
    soundEngine->transactionState=0;
    
    statutPaiement=@"{valid:\"1\"}";
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)demandePaiement:(id)sender {
    [soundEngine relaunchReception];
    soundEngine->transactionState=0;
    [sw_prix setOn:FALSE];
    [sw_statut setOn:FALSE];
    [sw_bankData setOn:FALSE];
    
    NSLog(@"Début du paiement");
    
    prix=[NSString stringWithFormat:@"{price:\"%@\",id:\"8F3896FBE7674C56A1DF12B3B55AFB1E\"}",[tf_prix text]];
    soundEngine->prix=prix;                                         //Init à la main
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"J'envoie le prix");
        [soundEngine startAudioUnit:1:prix];
        soundEngine->transactionState++;
        soundEngine->timeOutProcess=516;                            //Time out de 3 sec
    });
}

- (void) transactionStatutChange:(int)statut                       // Call at any changement of the paiement statut
{
    switch (statut) {
        case 2:
            [sw_prix setOn:TRUE];
            break;
        case 6:
            [sw_statut setOn:TRUE];
            break;
        default:
            break;
    }
}
- (void) clientData:(NSString*)clientData                          // Call to send paiement data to UI
{
    [sw_bankData setOn:TRUE];
    idClient=clientData;
}
- (void) transactionFinalState:(NSString*)transactionFinalState    // Call to send paiement final statut to UI
{
    statutPaiement=transactionFinalState;
}

- (void) messageReceived:(NSString*) theMessage : (int)quality{}
- (void) startingReception{}
- (void) finishEmission{}
- (void) soundToLow{}
- (void) progressStatut:(float) percent{}

////////
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
