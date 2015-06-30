//
//  AppDelegate.m
//  SoundFi DemoApp
//
//  Created by Florian Coulon on 29/05/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    soundEngine = [[SoundFiAudioSession alloc]init];
    soundEngine.delegate = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[HomeViewController alloc] init];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)messageReceived:(NSString *)theMessage :(int)quality {
    if (theMessage.length > 6) {
        if ([theMessage hasPrefix:@"Note:"]) {
            theMessage = [theMessage substringFromIndex:5];
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            localNotification.alertBody = theMessage;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}

- (void)progressStatut:(float)percent { }
- (void)finishEmission { }
- (void)startingReception { NSLog(@"In app delegate !!!"); }
- (void)soundToLow { }
- (void)applicationWillResignActive:(UIApplication *)application { }
- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (!soundEngine->enableBackground) {
        NSLog(@"Backgound disable");
        [soundEngine stopProcessingAudio];
    }
    soundEngine.delegate = self;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (!soundEngine->enableBackground) {
        NSLog(@"Reprise de l'écoute");
        [soundEngine startAudioUnit:0:NULL];
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application { }
- (void)applicationWillTerminate:(UIApplication *)application { }

@end
