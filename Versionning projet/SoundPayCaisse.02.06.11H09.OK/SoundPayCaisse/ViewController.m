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

- (void)viewDidLoad
{
    [super viewDidLoad];
    soundEngine = [[SoundFiAudioSession alloc] init];
    soundEngine.delegate=self;
    
    priceSending=FALSE;
    idAquit=FALSE;
    sendPaiementStatut=FALSE;
    
    statutPaiement=@"{\"valid\":\"1\"}";
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)demandePaiement:(id)sender {
    priceSending=FALSE;
    idAquit=FALSE;
    sendPaiementStatut=FALSE;
    [soundEngine relaunchReception];
    
    NSLog(@"Début du paiement");
    prix=[NSString stringWithFormat:@"{price:\"%@\",id:\"8F3896FBE7674C56A1DF12B3B55AFB1E\"}",[tf_prix text]];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"J'envoie le prix");
        [soundEngine startAudioUnit:1:prix];
        soundEngine->timeOutProcess=516;        //Time out de 3 sec
    });
}

- (void) messageReceived:(NSString*) theMessage : (int)quality
{
    
    if ([theMessage isEqualToString:@"GID"]) {
        NSLog(@"J'ai bien reçu les ID");
        idAquit=TRUE;
    }
    
    //On attends la réception de l'ID
    if (priceSending && !idAquit) {
        idClient=theMessage;
        NSLog(@"Je receptionne l'ID");
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [soundEngine startAudioUnit:1:theMessage];
        });
    }
    
    //Après récepetion de l'acquitement du prix, on vérifie qu'il est bon et on dit OK
    if (!priceSending) {
        if ([theMessage isEqualToString:prix]) {
            NSLog(@"Good price");
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [soundEngine startAudioUnit:1:@"GP"];
            });
            soundEngine->timeOutProcess=20000;  // Remet le timeout à l'infini
            priceSending=TRUE;
        }
        else
        {
            [soundEngine startAudioUnit:1:prix];
        }

    }
    
    //Validation de l'aquitement
    if (sendPaiementStatut) {
        if ([theMessage isEqualToString:statutPaiement]) {
            NSLog(@"GG Biatch c'est terminé");
            soundEngine->timeOutProcess=20000;  // Remet le timeout à l'infini
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [soundEngine startAudioUnit:1:@"GF"];
            });
        }
        else {
            sendPaiementStatut=TRUE;
            [self messageReceived:statutPaiement :0];
        }
    }
    
    //Envoie du statut final du paiement
    if (idAquit && !sendPaiementStatut) {
        sendPaiementStatut=TRUE;
        NSLog(@"Statut du paiement");
        soundEngine->timeOutProcess=344;        //Time out de 2 sec
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [soundEngine startAudioUnit:1:statutPaiement];
        });
    }
    
}
- (void) startingReception{}
- (void) finishEmission{}
- (void) soundToLow{}
- (void) progressStatut:(float) percent{}


@end
