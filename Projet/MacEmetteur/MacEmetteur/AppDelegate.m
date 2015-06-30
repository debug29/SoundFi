//
//  AppDelegate.m
//  MacEmetteur
//
//  Created by François Le Brun on 29/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AppDelegate.h"

@interface  AppDelegate()
@property (nonatomic,strong) IBOutlet emetteurViewController *emetteurViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.emetteurViewController=[[emetteurViewController alloc] initWithNibName:@"emetteurViewController" bundle:nil];
    
    
    [self.window.contentView addSubview:self.emetteurViewController.view];
    self.emetteurViewController.view.frame = ((NSView*)self.window.contentView).bounds;
}

@end
