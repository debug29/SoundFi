//
//  AppDelegate.h
//  TestUnification
//
//  Created by François Le Brun on 23/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SoundFiAudioSession.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    @public
    SoundFiAudioSession         *soundEngine;

}
@property (strong, nonatomic) UIWindow *window;


@end

