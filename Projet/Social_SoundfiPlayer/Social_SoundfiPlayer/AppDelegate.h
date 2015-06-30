//
//  AppDelegate.h
//  Social_SoundfiPlayer
//
//  Created by Evernet on 06/08/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    @public
    SoundFiAudioSession     *sFAudioSession;
}
@property (strong, nonatomic) UIWindow *window;

@end
