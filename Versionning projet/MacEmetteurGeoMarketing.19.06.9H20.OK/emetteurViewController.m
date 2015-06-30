//
//  emetteurViewController.m
//  MacEmetteurGeoMarketing
//
//  Created by François Le Brun on 29/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "emetteurViewController.h"

@interface emetteurViewController ()

@end

@implementation emetteurViewController
@synthesize textfield;
@synthesize texfield2;
@synthesize textfield3;
@synthesize bouton;
@synthesize bouton2;
@synthesize bouton3;
@synthesize tf_freq;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        AudioController *newControlleur=[[AudioController alloc]init];
        myController=newControlleur;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
}

- (IBAction)EnvoieMessage:(id)sender {
    
    if (sender==bouton) {
        myController->frequency=(int)[[tf_freq stringValue] integerValue];
    }
    else if (sender==bouton2){
        myController->frequency=(int)[[texfield2 stringValue] integerValue];
    }else if (sender==bouton3){
        myController->frequency=(int)[[textfield3 stringValue] integerValue];
    }
    
    if(isSending){
        isSending=FALSE;
        [myController stopProcessingAudio];
        bouton.title=@"Emmetre";
        bouton2.title=@"Emmetre";
        bouton3.title=@"Emmetre";
    }
    else {
        isSending=TRUE;
        bouton.title=@"Stop";
        bouton2.title=@"Stop";
        bouton3.title=@"Stop";
        [myController startAudioUnit:1];
    }
}
@end
