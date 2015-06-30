//
//  AppDelegate.m
//  emetteur SoundFi
//
//  Created by François Le Brun on 28/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AppDelegate.h"
#include "MasterViewController.h"

@interface  AppDelegate()
@property (nonatomic,strong) IBOutlet masterViewController *masterViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.masterViewController=[[masterViewController alloc] initWithNibName:@"masterViewController" bundle:nil];
    
    
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView*)self.window.contentView).bounds;
}


@end
