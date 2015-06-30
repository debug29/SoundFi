//
//  emetteurViewController.h
//  MacEmetteurGeoMarketing
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
    
    BOOL isSending;
}
@property (weak) IBOutlet NSTextField *textfield;
@property (weak) IBOutlet NSTextField *texfield2;
@property (weak) IBOutlet NSTextField *textfield3;
@property (weak) IBOutlet NSButton *bouton;
@property (weak) IBOutlet NSButton *bouton2;
@property (weak) IBOutlet NSButton *bouton3;
@property (weak) IBOutlet NSTextFieldCell *tf_freq;

- (IBAction)EnvoieMessage:(id)sender;

@end
