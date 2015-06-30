//
//  ViewController.h
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"

@interface ViewController : UIViewController
{
    AudioController *myController;
    //UIButton *B_start;
    //UIButton *B_stop;
    
    
    // UI
    UILabel *lab_waitingMessage;
    
    UIActivityIndicatorView *iv_waitingMessage;
    
    UISwitch *sw_receptionMode;
    UISwitch *sw_emissionMode;
    
    UITableView *tv_receivedMessage;
}


@property (nonatomic, nonatomic) AudioController *myController;


@property (nonatomic,retain) IBOutlet UISwitch *sw_receptionMode;
@property (nonatomic,retain) IBOutlet UISwitch *sw_emissionMode;
@property (nonatomic,retain) IBOutlet UITableView *tv_receivedMessage;
@property (nonatomic,retain) IBOutlet UILabel * lab_waitingMessage;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *iv_waitingMessage;

-(IBAction)receptionModeOnOff:(id)sw;
-(IBAction)emissionModeOnOff:(id)sw;


@end
