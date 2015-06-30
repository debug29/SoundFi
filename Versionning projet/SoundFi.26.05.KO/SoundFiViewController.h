//
//  SoundFiViewController.h
//  SoundFi
//
//  Created by Evernet on 29/04/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <FrameAccessor.h>

#import "AMBlurView.h"
#import "THPinViewController.h"
#import "deviceColor.h"
#import "Wave.h"

#import "SoundFiAudioSession.h"

@interface SoundFiViewController : UIViewController <THPinViewControllerDelegate,SampleProtocolDelegate,UITableViewDelegate> {
    deviceColor *device;
    int color;
    BOOL barStyle;
    BOOL firstLaunch;
    int nbrBadgeNotif;
    
    //Dialogue UI
    UITextView *msgTextView;
    UIButton *sendBut;
    UIButton *returnMenu;
    UIProgressView *sendingProgress;
    
    //Menu UI
    UIImageView *background;
    UIButton *tryItButton;
    
    UIImageView *menu;
    UIButton *dialBut;
    UIButton *notifBut;
    UIButton *paramBut;
    
    //Notification UI
    UITableView *messageTableView;
    UIButton *backMenu;
    
    //SoundFiAudioSession stuff
    SoundFiAudioSession *soundFiSession;
    NSString *messageReceived;
    NSString *messageToSend;
    NSMutableArray *messageList;
}

@property (nonatomic, strong) UIButton *contentButton;
@property (nonatomic, copy) NSString *correctPin;
@property (nonatomic, assign) NSUInteger remainingPinEntries;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, retain) Wave *waveformView;

@end
