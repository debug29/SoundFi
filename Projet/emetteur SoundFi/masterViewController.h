//
//  masterViewController.h
//  emetteur SoundFi
//
//  Created by François Le Brun on 28/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>


@interface masterViewController : NSViewController
{
@public
    NSApplication *myapp;
    AudioUnit uniteSon;
    
    NSString *myMessage;
    
    pthread_mutex_t emissionMutex;
    
    int compteur;
    BOOL isSafeForWork;
    int nbCaracRepeat;
    float theta;
    float sampleRate;
    
    BOOL isOn;
}

@property (weak) IBOutlet NSTextField *monTEXT;
@property (weak) IBOutlet NSButton *monBOUTON;
@property (weak) IBOutlet NSButton *monBOUTONstop;

- (IBAction)playSong:(id)sender;
- (IBAction)stopSong:(id)sender;

-(void)emissionSampleCalcul:(int)frequence : (int)numFrames : (AudioSampleType *)buffer;
-(int)getASCIIFrequency;

@end
