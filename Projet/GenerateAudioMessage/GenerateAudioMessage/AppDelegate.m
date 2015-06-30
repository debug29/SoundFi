//
//  AppDelegate.m
//  GenerateAudioMessage
//
//  Created by François Le Brun on 13/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate ()
            
@property (weak) IBOutlet NSWindow *window;


@end

@implementation AppDelegate

-(void)emissionSampleCalcul:(int)frequence : (int)numFrames : (Float32 *)buffer
{
    double theta_increment = 2.0 * M_PI * frequence / sampleRate;     // θ(n) = 2πƒ n / r
    double amplitude = .25;
    // Loop génération for the samples
    // f(n) = a sin ( θ(n) )
    
    for (UInt32 frame = 0; frame < numFrames; frame++)
    {
        buffer[frame] = 0;
        buffer[frame] = sin(theta) * amplitude;
        
        //printf("%f\n", buffer[frame]);
        theta += theta_increment;
        if (theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    AudioBufferList *bufferList;
    
    ExtAudioFileRef outputFile;
    
    ExtAudioFileWriteAsync(outputFile,512,bufferList);
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}








@end












