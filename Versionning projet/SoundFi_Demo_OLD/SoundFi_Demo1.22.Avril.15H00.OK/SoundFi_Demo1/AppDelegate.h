//
//  AppDelegate.h
//  SoundFi_Demo1
//
//  Created by François Le Brun on 04/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenerationSonViewController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    GenerationSonViewController *viewController;

}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong,nonatomic) IBOutlet GenerationSonViewController *viewController;

@end
