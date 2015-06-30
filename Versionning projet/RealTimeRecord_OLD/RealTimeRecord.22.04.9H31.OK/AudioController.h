//
//  AudioController.h
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>




@interface AudioController : NSObject
{
    @public
    AudioUnit audioUnit;
    AudioUnit mixerUnit;
    
    float *convertedSampleBuffer;
    
    AUNode ioNode;
    AUNode mixerNode;
    
    AUGraph myGraph;
    
}


-(int)startAudioUnit;
-(int)stopProcessingAudio;
-(int)initAudioStreams;
-(int)initAudioSession;

@end
