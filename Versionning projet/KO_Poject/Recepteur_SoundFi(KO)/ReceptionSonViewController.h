//
//  ReceptionSonViewController.h
//  Recepteur_SoundFi
//
//  Created by François Le Brun on 15/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

#define kInputBus 1

@interface ReceptionSonViewController : UIViewController
{
    
    UIButton *But_ecoute;
    UIButton *But_stop;
@public
    AudioComponentInstance uniteSon;
    AudioBuffer audioBuffer;
    
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
-(void)processBuffer: (AudioBufferList*) audioBufferList;

@end
