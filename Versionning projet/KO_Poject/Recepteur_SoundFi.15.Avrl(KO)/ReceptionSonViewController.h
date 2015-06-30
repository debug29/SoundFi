//
//  ReceptionSonViewController.h
//  Recepteur_SoundFi
//
//  Created by François Le Brun on 15/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

@interface ReceptionSonViewController : UIViewController
{
    
    UIButton *But_ecoute;
    UIButton *But_stop;
@public
    AudioComponentInstance uniteSon;
    double frequence;
    double amplitude;
    double ratioEchantillon;
    double theta;
}


@property (nonatomic,retain) IBOutlet UIButton *But_ecoute;
@property (nonatomic,retain) IBOutlet UIButton *But_stop;

-(IBAction)lancerEcoute:(UIButton *)bouton;
-(IBAction)stopEcoute:(UIButton *)bouton;
-(void)stop;
static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData);

@end
