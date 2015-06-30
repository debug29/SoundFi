//
//  ViewController.h
//  AudioQueueTest
//
//  Created by François Le Brun on 29/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

static const int kNumberBuffers = 3;                              // 1

typedef struct {
    AudioStreamBasicDescription   mDataFormat;                    // 2
    AudioQueueRef                 mQueue;                         // 3
    AudioQueueBufferRef           mBuffers[kNumberBuffers];       // 4
    UInt32                        bufferByteSize;                 // 6
    UInt32                        mNumPacketsToRead;              // 8
    AudioStreamPacketDescription  *mPacketDescs;                  // 9
    bool                          mIsRunning;                     // 10
    float                         theta;
    float                         sampleRate;
    
} Playstate;

@interface ViewController : UIViewController
{
    @public
    
}


- (void)setupAudioFormat:(AudioStreamBasicDescription*)format;
@end
