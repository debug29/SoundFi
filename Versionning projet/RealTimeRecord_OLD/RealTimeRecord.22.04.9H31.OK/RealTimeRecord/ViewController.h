//
//  ViewController.h
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"

@interface ViewController : UIViewController
{
    AudioController *myController;
    UIButton *B_start;
    UIButton *B_stop;
}

@property (nonatomic,retain) IBOutlet UIButton *B_start;
@property (nonatomic,retain) IBOutlet UIButton *B_stop;
@property (nonatomic, nonatomic) AudioController *myController;

-(IBAction)start:(UIButton*)bouton;
-(IBAction)stop:(UIButton*)bouton;


@end
