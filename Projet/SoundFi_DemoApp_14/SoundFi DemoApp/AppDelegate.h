//
//  AppDelegate.h
//  SoundFi DemoApp
//
//  Created by Florian Coulon on 29/05/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, SoundFiEngineDelegate> {
    @public
    SoundFiAudioSession *soundEngine;
}

@property (strong, nonatomic) UIWindow *window;

@end
