//
//  AppDelegate.m
//  AppSoundFi_GeoMarket
//
//  Created by François Le Brun on 12/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
            

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    soundEngine = [[SoundFiAudioSession alloc] init];
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    
    //Confiduration du location manager
    if (locationManager==nil) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
        locationManager.pausesLocationUpdatesAutomatically=YES;     //Pause la localisation quand la personne ne bouge pas
        locationManager.activityType=CLActivityTypeFitness;         //Permet de stoper périodiquement la nav si la personne ne bouge pas
        [locationManager requestAlwaysAuthorization];
        [locationManager startUpdatingLocation];
        isHightAccuracy=TRUE;
    }

    //Timer qui seras déclencher toutes les X minutes pour récupérer une position précise
    if (timer==nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:30
                         target:self
                         selector:@selector(changeLocationManagerAccuracy)
                         userInfo:nil repeats:YES];
    }
    
    return YES;
}

//Delegate méthode pour l'update de la localisation de l'utilisateur
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    //Si on est dans de la haute précision
    if (isHightAccuracy) {
        lastLat = newLocation.coordinate.latitude;
        lastLong = newLocation.coordinate.longitude;
        
        //Demande au serveur si on est dans une zone
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mynetshare.fr/localisation.php?lat=%f&long=%f",lastLat,lastLong]];
        NSString* urlContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
        #if DEBUG
            NSLog(@"Analyse haute précision :Lat :%f        Long:%f",lastLat,lastLong);
            NSLog(@"Réponse serveur : %@",urlContents);
        #endif
        
        if ([urlContents isEqualToString:@"inZone"]) {
            soundEngine->isInZone=TRUE;
            if (![soundEngine isRunning])
                [soundEngine startAudioUnit:0 :nil];                                    //On démare l'arrière plan
        }
        else{
            soundEngine->isInZone=FALSE;
            if ([soundEngine isRunning])
                [soundEngine stopProcessingAudio];                                      //On stop l'arrière plan
        }
        isHightAccuracy=FALSE;
        locationManager.desiredAccuracy=kCLLocationAccuracyThreeKilometers;
    }
    
    #if DEBUG
        //NSLog(@"Lat :%f        Long:%f",lastLat,lastLong);
    #endif
    
}

// Permet d'augmenter temporairement la précision du GPS
- (void)changeLocationManagerAccuracy {
    NSLog(@"Augmentation de la précision");
    isHightAccuracy=TRUE;
    locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //Demande au serveur si on est dans une zone
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mynetshare.fr/localisation.php?lat=%f&long=%f",lastLat,lastLong]];
    NSString* urlContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];

    #if DEBUG
        NSLog(@"Réponse serveur : %@",urlContents);
    #endif
    
    if (![urlContents isEqualToString:@"inZone"]) {
        soundEngine->isInZone=FALSE;
        [soundEngine stopProcessingAudio];
    }
    else {
        soundEngine->isInZone=TRUE;
    }
    
}
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
