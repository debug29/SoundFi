//
//  ViewController.h
//  soundCloud
//
//  Created by François Le Brun on 06/08/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"

@interface ViewController : UIViewController
{
    SoundFiAudioSession *audioSession;
}
@property (weak, nonatomic) IBOutlet UIButton *b_go;
@property (weak, nonatomic) IBOutlet UIButton *b_stop;
- (IBAction)a_go:(id)sender;
- (IBAction)a_stop:(id)sender;

@end

