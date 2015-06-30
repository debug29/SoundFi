//
//  ViewController.h
//  SoundPayCaisse
//
//  Created by François Le Brun on 27/05/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"
#import "AESCrypt.h"

@interface ViewController : UIViewController <UITextFieldDelegate>
{
    SoundFiAudioSession *soundEngine;
    NSString *prix;
    NSString *idClient;
    NSString *statutPaiement;
    
    BOOL priceSending;
    BOOL idAquit;
    BOOL sendPaiementStatut;
    
    int transactionState;
    BOOL timeOut;
    
}

@property (weak, nonatomic) IBOutlet UITextField *tf_prix;
@property (weak, nonatomic) IBOutlet UIButton *b_demandePaiement;
@property (weak, nonatomic) IBOutlet UISwitch *sw_prix;
@property (weak, nonatomic) IBOutlet UISwitch *sw_bankData;
@property (weak, nonatomic) IBOutlet UISwitch *sw_statut;


- (IBAction)demandePaiement:(id)sender;

@end
