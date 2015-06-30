//
//  AuGraphController.h
//  TestGraph
//
//  Created by François Le Brun on 16/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

@interface AuGraphController : NSObject
{
    @public
    AUGraph monGraph;
    
    AudioUnit mixer;
    AudioUnit ioUnit;
    
    AUNode inputNode;
    AUNode mixerNode;
    
    AudioStreamBasicDescription inputASBD;
    
    Float64 sampleRate; //Ratio, init  à 44100.0

}

@property        AudioUnit       mixer;
@property        AudioUnit       ioUnit;

@property        AUNode          inputNode;
@property        AUNode          mixerNode;

- (void)initializeAUGraph;
- (void)startAUGraph;
- (void)stopAUGraph;

@end
