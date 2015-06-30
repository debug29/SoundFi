//
//  AppDelegate.h
//  SoundFi
//
//  Created by Evernet on 29/04/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiViewController.h"
#import "SoundFiAudioSession.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    @public
    SoundFiAudioSession *myAudioEngine;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SoundFiViewController *viewController;

@end
