//
//  ViewController.m
//  AppSoundFi_GeoMarket
//
//  Created by François Le Brun on 12/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
            

@end

@implementation ViewController
@synthesize lab_freq;
@synthesize lab_nbFreq;
@synthesize lab_trajet;

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *myAppDelegate =(AppDelegate *)[[UIApplication sharedApplication]delegate];
    soundEngine = myAppDelegate->soundEngine;
    soundEngine.delegate=self;
    nbrFreq=0;
    
    locationManager=myAppDelegate->locationManager;
    
    
    currentPos=@"Aucune";
    lastPos=@"Aucune";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) messageReceived:(NSString*) theMessage : (int)quality{}
- (void) startingReception{}
- (void) finishEmission{}
- (void) soundToLow{}
- (void) progressStatut:(float) percent{}
- (void) localisationData:(NSString*)lieu :(NSString*)promotion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        /////////////// TEST /////////////////
        if ([lastPosValidate isEqualToString:lieu]) {
            nbrFreq++;
            lab_nbFreq.text=[NSString stringWithFormat:@"%d",nbrFreq];
            return;
        }
        lastPosValidate=lieu;
        //////////////////////////////////////
        
        lab_freq.text=promotion;
        lab_trajet.text=[NSString stringWithFormat:@"%@\n%@",lab_trajet.text,lieu];
        nbrFreq++;
        lab_nbFreq.text=[NSString stringWithFormat:@"%d",nbrFreq];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotification.alertBody = promotion;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    });
}

@end
