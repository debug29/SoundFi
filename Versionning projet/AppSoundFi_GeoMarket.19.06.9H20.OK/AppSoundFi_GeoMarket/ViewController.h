//
//  ViewController.h
//  AppSoundFi_GeoMarket
//
//  Created by François Le Brun on 12/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <SoundFiEngineDelegate>
{
    SoundFiAudioSession *soundEngine;
    CLLocationManager *locationManager;
    int frequence;
    int nbrFreq;
    
    NSString *currentPos;
    NSString *lastPos;
    NSString *lastPosValidate;
    
}
@property (weak, nonatomic) IBOutlet UILabel *lab_trajet;
@property (weak, nonatomic) IBOutlet UILabel *lab_nbFreq;
@property (weak, nonatomic) IBOutlet UILabel *lab_freq;
@end

