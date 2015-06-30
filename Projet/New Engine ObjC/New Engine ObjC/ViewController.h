//
//  ViewController.h
//  New Engine ObjC
//
//  Created by François Le Brun on 04/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface ViewController : UIViewController
{
    AVAudioEngine *myEngine;
}



@property(readonly, nonatomic) AVAudioOutputNode *outputNode;
@property(readonly, nonatomic) AVAudioInputNode *inputNode;
@end

