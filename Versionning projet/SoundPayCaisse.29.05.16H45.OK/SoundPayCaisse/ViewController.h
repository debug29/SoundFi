//
//  ViewController.h
//  SoundPayCaisse
//
//  Created by François Le Brun on 27/05/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"

@interface ViewController : UIViewController
{
    SoundFiAudioSession *soundEngine;
    NSString *prix;
    NSString *idClient;
    NSString *statutPaiement;
    
    BOOL priceSending;
    BOOL idAquit;
    BOOL sendPaiementStatut;
    
}

@property (weak, nonatomic) IBOutlet UITextField *tf_prix;
@property (weak, nonatomic) IBOutlet UIButton *b_demandePaiement;
- (IBAction)demandePaiement:(id)sender;

@end
