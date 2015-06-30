//
//  LoginViewController.h
//  Social_SoundfiPlayer
//
//  Created by Evernet on 06/08/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "InitViewController.h"

@interface LoginViewController : UIViewController

@property (nonatomic, retain) Wave *waveformView;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@end
