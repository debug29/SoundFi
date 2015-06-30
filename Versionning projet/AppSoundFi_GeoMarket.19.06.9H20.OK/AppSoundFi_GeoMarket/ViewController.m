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
/*
- (void) frequencyInfo:(int*) frequency{
 
    frequency=soundEngine->curentFrequencyData;
    int avrgFreq=0;
    for (int i=0; i<100; i++) {
        avrgFreq+=frequency[i];
        frequency[i]=0;
    }
    avrgFreq/=100;
    
    printf("%d\n",avrgFreq);
    
    nbrFreq++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        lastPos=currentPos;
        if(avrgFreq>20000 && avrgFreq<20050){
            lab_freq.text=[NSString stringWithFormat:@"Chambre Florian"];
        }
        else if (avrgFreq>20050 && avrgFreq<20100){
            lab_freq.text=[NSString stringWithFormat:@"Sallon"];
        }
        else if (avrgFreq>20100 && avrgFreq<20150){
            lab_freq.text=[NSString stringWithFormat:@"Cuisine"];
        }
        lab_nbFreq.text=[NSString stringWithFormat:@"%d",nbrFreq];
        
        currentPos=lab_freq.text;
        if ([lastPos isEqualToString:currentPos] && ![lastPosValidate isEqualToString:currentPos]) {
            
        
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://mynetshare.fr/test.php?id=%d",avrgFreq]];
            NSString* urlContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            localNotification.alertBody = urlContents;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            lastPosValidate=currentPos;
            lab_trajet.text=[NSString stringWithFormat:@"%@\n%@",lab_trajet.text,currentPos];
        }
    });
}
*/

@end
