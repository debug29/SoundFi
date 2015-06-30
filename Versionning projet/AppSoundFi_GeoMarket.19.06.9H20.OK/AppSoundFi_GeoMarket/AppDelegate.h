//
//  AppDelegate.h
//  AppSoundFi_GeoMarket
//
//  Created by François Le Brun on 12/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SoundFiAudioSession.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    @public
    SoundFiAudioSession *soundEngine;
    CLLocationManager *locationManager;
    NSTimer *timer;
    UIBackgroundTaskIdentifier bgTask;
    
    
    BOOL test;
    //GPS localisation
    float lastLat;
    float lastLong;
    BOOL isHightAccuracy;
}
@property (strong, nonatomic) UIWindow *window;


@end

