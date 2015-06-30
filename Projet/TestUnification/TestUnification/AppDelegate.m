//
//  AppDelegate.m
//  TestUnification
//
//  Created by François Le Brun on 23/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
            

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    soundEngine = [[SoundFiAudioSession alloc] init];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"didEnterBackground"
                                                        object: nil
                                                      userInfo: nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"willEnterForeground"
                                                        object: nil
                                                      userInfo: nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
