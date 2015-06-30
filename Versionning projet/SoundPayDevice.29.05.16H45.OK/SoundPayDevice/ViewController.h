//
//  ViewController.h
//  SoundPayDevice
//
//  Created by François Le Brun on 27/05/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"

@interface ViewController : UIViewController <UIAlertViewDelegate>
{
    SoundFiAudioSession *soundEngine;
    
    NSString *myID;
    NSString *paiementStatut;
    NSString *paiementInformation;
    BOOL acquitPrice;
    BOOL sendingID;
    BOOL statutReception;
    BOOL acquitStatut;
    BOOL codeOk;
}
@property (weak, nonatomic) IBOutlet UISwitch *sw_prix;
@property (weak, nonatomic) IBOutlet UISwitch *sw_id;
@property (weak, nonatomic) IBOutlet UISwitch *sw_finalisation;
@property (weak, nonatomic) IBOutlet UILabel *lab_payInfo;
@property (weak, nonatomic) IBOutlet UIImageView *img_good;
@property (weak, nonatomic) IBOutlet UIButton *b_restart;

- (IBAction)restart:(id)sender;


@end
