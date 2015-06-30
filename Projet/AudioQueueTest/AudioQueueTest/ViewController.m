//
//  ViewController.m
//  AudioQueueTest
//
//  Created by François Le Brun on 29/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"


static void HandleOutputBuffer (void                 *aqData,
                                AudioQueueRef        inAQ,
                                AudioQueueBufferRef  inBuffer);

void DeriveBufferSize (AudioStreamBasicDescription ASBDesc,
                       UInt32                      maxPacketSize,
                       Float64                     seconds,
                       UInt32                      *outBufferSize,
                       UInt32                      *outNumPacketsToRead) {
    
    static const int maxBufferSize = 0x50000;                        // 6
    
    static const int minBufferSize = 0x4000;                         // 7
    
    
    
    if (ASBDesc.mFramesPerPacket != 0) {                             // 8
        Float64 numPacketsForTime = ASBDesc.mSampleRate / ASBDesc.mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
        
    } else {
        
        *outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
        
    }
    
    
    
    if (*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize)
        
        *outBufferSize = maxBufferSize;
    
    else {                                                           // 11
        
        if (*outBufferSize < minBufferSize)
            
            *outBufferSize = minBufferSize;
        
    }
    
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;           // 12
    
}

@implementation ViewController


static void HandleOutputBuffer (void                 *aqData,
                                AudioQueueRef        inAQ,
                                AudioQueueBufferRef  inBuffer)
{
    Playstate *playState = (Playstate*)aqData;
    
    if (playState->mIsRunning == 0) return;
    
    SInt16 *buffer=inBuffer->mAudioData;
    int numFrames=512;
    int frequence = 100;
    double theta_increment = 2.0 * M_PI * frequence / playState->sampleRate;     // θ(n) = 2πƒ n / r
    const double amplitude = 1.0;
    
    
    // Loop génération for the samples
    // f(n) = a sin ( θ(n) )
    
    for (UInt32 frame = 0; frame < numFrames; frame++)
    {
        buffer[frame] = 0;
        buffer[frame] = sin(playState->theta) * amplitude;
        
        playState->theta += theta_increment;
        if (playState->theta > 2.0 * M_PI)
        {
            playState->theta -= 2.0 * M_PI;
        }
    }

    AudioQueueEnqueueBuffer (playState->mQueue,
                             inBuffer,
                             0,
                             playState->mPacketDescs
                             );
    
    AudioQueueStop (playState->mQueue,false);
    playState->mIsRunning = false;

}

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format
{
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    format->mFormatID          = kAudioFormatLinearPCM;
    format->mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    format->mBytesPerPacket    = bytesPerSample;
    format->mFramesPerPacket   = 1;
    format->mBytesPerFrame     = bytesPerSample;
    format->mChannelsPerFrame  = 1;                  // 1 indicates mono
    format->mBitsPerChannel    = 8 * bytesPerSample;
    format->mSampleRate        = 44100.0;
}


-(void)startPlayback
{
    AudioQueueNewOutput (&aqData.mDataFormat,                             // 2
                         HandleOutputBuffer,                              // 3
                         &aqData,                                         // 4
                         CFRunLoopGetCurrent (),                          // 5
                         kCFRunLoopCommonModes,                           // 6
                         0,                                               // 7
                         &aqData.mQueue                                   // 8
                         );

}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
