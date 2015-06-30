//
//  ParamViewController.h
//  SoundFi DemoApp
//
//  Created by Evernet on 06/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RQShineLabel.h>
#import <FDStatusBarNotifierView.h>
#import "Wave.h"
#import "AppDelegate.h"

@interface ParamViewController : UIViewController <SoundFiEngineDelegate> {
    AppDelegate *appDelegate;
    FDStatusBarNotifierView *notifierView;
}

@property (nonatomic, retain) Wave *waveformView;
@property (nonatomic, strong) AVAudioRecorder *recorder;


@end
