//
//  DialViewController.h
//  SoundFi DemoApp
//
//  Created by Evernet on 06/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOMessagingViewController.h"
#import <FDStatusBarNotifierView.h>
#import "Wave.h"
#import "AppDelegate.h"

@interface DialViewController : SOMessagingViewController <SoundFiEngineDelegate> {
    AppDelegate *appDelegate;
    FDStatusBarNotifierView *notifierView;
}

@end
