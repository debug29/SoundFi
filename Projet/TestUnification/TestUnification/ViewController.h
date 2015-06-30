//
//  ViewController.h
//  TestUnification
//
//  Created by François Le Brun on 23/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundFiAudioSession.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController <SoundFiEngineDelegate>
{
    SoundFiAudioSession *soundEngine;
}

@property (weak, nonatomic) IBOutlet UIButton *b_paiement;

- (IBAction)paiement:(id)sender;

@end

