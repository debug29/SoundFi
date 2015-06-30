//
//  ViewController.h
//  soundFiMessaging_v2
//
//  Created by François Le Brun on 04/08/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"

@interface ViewController : UIViewController
{
    SoundFiAudioSession     *audioSession;
}
@property (weak, nonatomic) IBOutlet UIButton *bouton;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
- (IBAction)action_bouton:(id)sender;

@end

