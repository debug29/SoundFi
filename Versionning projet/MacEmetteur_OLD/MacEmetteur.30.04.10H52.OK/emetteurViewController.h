//
//  emetteurViewController.h
//  MacEmetteur
//
//  Created by François Le Brun on 29/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AudioController.h"

@interface emetteurViewController : NSViewController
{
    AudioController *myController;
    NSString *myMessage;
}
@property (weak) IBOutlet NSTextField *textfield;
@property (weak) IBOutlet NSButton *bouton;

- (IBAction)EnvoieMessage:(id)sender;

@end
