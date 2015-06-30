//
//  HomeViewController.h
//  SoundFi DemoApp
//
//  Created by Florian Coulon on 29/05/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RQShineLabel.h>
#import <FDStatusBarNotifierView.h>
#import "Wave.h"
#import "AppDelegate.h"

#import "SoundFiViewController.h"
#import "MyDisKSlideController.h"
#import "LeftMenuViewController.h"


@interface HomeViewController : UIViewController <SoundFiEngineDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    AppDelegate *appDelegate;
    FDStatusBarNotifierView *notifierView;
    BOOL isHide, isReceivable;
    UIButton *signinBut, *registerBut, *cancelBut, *confirmBut;
    UIImageView *logo, *welcomText, *suscribText;
    
    UITextField *emailField, *passwordField;
}

@property (nonatomic, retain) Wave *waveformView;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (strong, nonatomic) RQShineLabel *shineLabel;

@end
