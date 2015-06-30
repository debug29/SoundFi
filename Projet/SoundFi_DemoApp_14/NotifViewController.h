//
//  NotifViewController.h
//  SoundFi DemoApp
//
//  Created by Evernet on 05/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RQShineLabel.h>
#import <FDStatusBarNotifierView.h>
#import "Wave.h"
#import "AppDelegate.h"

@interface NotifViewController : UIViewController <SoundFiEngineDelegate> {
    AppDelegate *appDelegate;
    FDStatusBarNotifierView *notifierView;
    NSMutableArray *notif;
}

@property (nonatomic, retain) Wave *waveformView;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@end
