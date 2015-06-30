//
//  ToneGeneratorViewController.h
//  ToneGenerator
//
//  Created by Matt Gallagher on 2010/10/20.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ToneGeneratorViewController : UIViewController
{
	UILabel *frequencyLabel;
	UIButton *playButton;
	UISlider *frequencySlider;
	AudioComponentInstance toneUnit;

@public
	double frequency;
	double sampleRate;
	double theta;
}

@property (nonatomic, retain) IBOutlet UISlider *frequencySlider;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UILabel *frequencyLabel;


@property (retain, nonatomic) IBOutlet UIButton *init;
@property (retain, nonatomic) IBOutlet UIButton *bStop;
@property (retain, nonatomic) IBOutlet UIButton *b1;
@property (retain, nonatomic) IBOutlet UIButton *b2;
@property (retain, nonatomic) IBOutlet UIButton *b3;
@property (retain, nonatomic) IBOutlet UIButton *b4;
@property (retain, nonatomic) IBOutlet UIButton *b5;
@property (retain, nonatomic) IBOutlet UIButton *b6;
@property (retain, nonatomic) IBOutlet UIButton *b7;
@property (retain, nonatomic) IBOutlet UIButton *b8;
@property (retain, nonatomic) IBOutlet UIButton *b9;
@property (retain, nonatomic) IBOutlet UIButton *bA;
@property (retain, nonatomic) IBOutlet UIButton *bB;
@property (retain, nonatomic) IBOutlet UIButton *bR;
@property (retain, nonatomic) IBOutlet UIButton *bT;
@property (retain, nonatomic) IBOutlet UIButton *bU;
@property (retain, nonatomic) IBOutlet UIButton *bL;
@property (retain, nonatomic) IBOutlet UIButton *bN;


- (IBAction)aInit:(id)sender;
- (IBAction)aStop:(id)sender;
- (IBAction)a1:(id)sender;
- (IBAction)a2:(id)sender;
- (IBAction)a3:(id)sender;
- (IBAction)a4:(id)sender;
- (IBAction)a5:(id)sender;
- (IBAction)a6:(id)sender;
- (IBAction)a7:(id)sender;
- (IBAction)a8:(id)sender;
- (IBAction)a9:(id)sender;
- (IBAction)aA:(id)sender;
- (IBAction)aB:(id)sender;
- (IBAction)aR:(id)sender;
- (IBAction)aT:(id)sender;
- (IBAction)aU:(id)sender;
- (IBAction)aL:(id)sender;
- (IBAction)aN:(id)sender;


- (IBAction)sliderChanged:(UISlider *)frequencySlider;
- (IBAction)togglePlay:(UIButton *)selectedButton;
- (void)stop;

@end

