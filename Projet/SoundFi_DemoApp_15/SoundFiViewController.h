//
//  SoundFiViewController.h
//  SoundFi DemoApp
//
//  Created by Evernet on 02/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RQShineLabel.h>
#import <FDStatusBarNotifierView.h>
#import "Wave.h"
#import "AppDelegate.h"
#import "PaperButton.h"
#import "ParamViewController.h"


@interface SoundFiViewController : UIViewController <SoundFiEngineDelegate> {
    AppDelegate *appDelegate;
    FDStatusBarNotifierView *notifierView;
    NSMutableArray *notif;
    @public
    PaperButton *menuButton;
    NSDate *today;
    NSString *notifIncomming;
    
    NSString *promoIncomming;
    NSString *promoImgIncomming;
    NSMutableArray *promo;
}

@property (nonatomic, retain) Wave *waveformView;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@end
