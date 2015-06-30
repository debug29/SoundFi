//
//  ViewController.h
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"


@interface ViewController : UIViewController <UITextFieldDelegate,SampleProtocolDelegate>
{
    SoundFiAudioSession *myController;
    
    NSString *myMessage;
    NSString *message;
    
    // UI
    UILabel *lab_waitingMessage;
    
    UIActivityIndicatorView *iv_waitingMessage;
    
    UISwitch *sw_receptionMode;
    UISwitch *sw_emissionMode;
    
    UITableView *tv_receivedMessage;
    
    UITextField *tf_myMessage;
    
    UIButton *but_sendMessage;
}


@property (nonatomic, nonatomic) SoundFiAudioSession *myController;


@property (nonatomic,retain) IBOutlet UISwitch *sw_receptionMode;
@property (nonatomic,retain) IBOutlet UISwitch *sw_emissionMode;
@property (nonatomic,retain) IBOutlet UITableView *tv_receivedMessage;
@property (nonatomic,retain) IBOutlet UILabel * lab_waitingMessage;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *iv_waitingMessage;
@property (nonatomic,retain) IBOutlet UITextField *tf_myMessage;
@property (nonatomic,retain) IBOutlet UIButton *but_sendMessage;

-(IBAction)receptionModeOnOff;
-(IBAction)emissionModeOnOff;
-(IBAction)sendMessage;


@end
