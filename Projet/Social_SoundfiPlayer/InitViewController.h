//
//  InitViewController.h
//  Social_SoundfiPlayer
//
//  Created by Evernet on 06/08/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SoundCloud.h"
#import "SoundFiAudioSession.h"
#import "AppDelegate.h"

@interface InitViewController : UIViewController <SoundFiEngineDelegate>

@property (nonatomic, retain) SoundCloud *soundCloud;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end
