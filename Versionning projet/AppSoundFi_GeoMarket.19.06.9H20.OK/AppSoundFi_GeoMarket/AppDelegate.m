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
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    //Si on est dans de la haute précision
    if (isHightAccuracy) {
        lastLat = newLocation.coordinate.latitude;
        lastLong = newLocation.coordinate.longitude;
        NSLog(@"Analyse haute précision :Lat :%f        Long:%f",lastLat,lastLong);
        
        //On vérifie que l'on est dans la zone voulue (seras effectué par le serveur plus tard)
        //Respectivement chez François Chez Flo et la petite po
        if (((lastLat>48.4035 && lastLat<48.4080) && (lastLong<-4.500765 && lastLong>-4.511500)) || //François
            ((lastLat>48.3899928 && lastLat<48.3911928) && (lastLong<-4.483868499 && lastLong>-4.485868499))     || //Petite Po
            ((lastLat>48.4339302 && lastLat<48.4359302) && (lastLong<-4.62885 && lastLong>-4.63185))) {     //Florian
            if (!soundEngine->receptionMode && !soundEngine->emissionMode) {
                NSLog(@"Zone d'écoute activation arrière plan");                        //On démare l'arrière plan
                [soundEngine startAudioUnit:0 :nil];
            }
        }
        else {  // Si on est pas dans une zone
            if (soundEngine->receptionMode || soundEngine->emissionMode) {
                NSLog(@"Sortie de la zone, coupe arrière plan");                        //On démare l'arrière plan
                [soundEngine stopProcessingAudio];
            }
        }
        isHightAccuracy=FALSE;
        locationManager.desiredAccuracy=kCLLocationAccuracyThreeKilometers;
    }
    else
        NSLog(@"Lat :%f        Long:%f",lastLat,lastLong);
    
}

- (void)changeLocationManagerAccuracy {
    NSLog(@"Augmentation de la précision");
    isHightAccuracy=TRUE;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
    if (!(lastLat>48.4035 && lastLat<48.4080) || !(lastLong<-4.500765 && lastLong>-4.6))
        [soundEngine stopProcessingAudio];
     */
    if (((lastLat>48.4035 && lastLat<48.4080) && (lastLong<-4.500765 && lastLong>-4.511500))                  ||     //François
        ((lastLat>48.3899928 && lastLat<48.3911928) && (lastLong<-4.483868499 && lastLong>-4.485868499))     ||     //Petite Po
        ((lastLat>48.4339302 && lastLat<48.4359302) && (lastLong<-4.62885 && lastLong>-4.63185)))                   //Florian
        NSLog(@"Rien");
    else
        [soundEngine stopProcessingAudio];
}
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    NSLog(@"%@",error);
}

@end
