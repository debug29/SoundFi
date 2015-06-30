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

#define dec97(f)= (f>19379 && f<19387) ? 1 : 0;
#define dec98(f)= (f>19400 && f<19008) ? 1 : 0;
#define dec99(f)= (f>19421 && f<19429) ? 1 : 0;
#define dec100(f)= (f>19442 && f<19450) ? 1 : 0;
#define dec101(f)= (f>19464 && f<19472) ? 1 : 0;
#define dec102(f)= (f>19485 && f<19493) ? 1 : 0;
#define dec103(f)= (f>19506 && f<19514) ? 1 : 0;
#define dec104(f)= (f>19527 && f<19535) ? 1 : 0;
#define dec105(f)= (f>19549 && f<19557) ? 1 : 0;
#define dec106(f)= (f>19570 && f<19578) ? 1 : 0;
#define dec107(f)= (f>19591 && f<19599) ? 1 : 0;
#define dec108(f)= (f>19613 && f<19621) ? 1 : 0;
#define dec109(f)= (f>19634 && f<19642) ? 1 : 0;
#define dec110(f)= (f>19655 && f<19663) ? 1 : 0;
#define dec111(f)= (f>19676 && f<19684) ? 1 : 0;
#define dec112(f)= (f>19698 && f<19706) ? 1 : 0;
#define dec113(f)= (f>19719 && f<19727) ? 1 : 0;
#define dec114(f)= (f>19740 && f<19748) ? 1 : 0;
#define dec115(f)= (f>19761 && f<19769) ? 1 : 0;
#define dec116(f)= (f>19783 && f<19791) ? 1 : 0;
#define dec117(f)= (f>19804 && f<19812) ? 1 : 0;
#define dec118(f)= (f>19825 && f<19833) ? 1 : 0;
#define dec119(f)= (f>19846 && f<19854) ? 1 : 0;
#define dec120(f)= (f>19868 && f<19876) ? 1 : 0;
#define dec121(f)= (f>19889 && f<19897) ? 1 : 0;
#define dec122(f)= (f>19910 && f<19918) ? 1 : 0;

@interface AudioController : NSObject
{
    @public
    AudioUnit audioUnit;
    AudioUnit mixerUnit;
    
    
    AUNode ioNode;
    AUNode mixerNode;
    
    AUGraph myGraph;
    
    int sampleFrequency;
    float sampleRate;
    
    AudioUnitSampleType *emptySample;
    
    //Callback Setup
    
    SInt16 *samplesBuffer;
    
    
    //FFT use
    FFTSetup fftSetup;
    
    float *outputBuffer;
	float *analysisBuffer;
    
    float fftLog2n;
	float micFxControl;
    
    
    // Test
    int compteur;
}

-(void)fftSetup;
-(void)setupCallback;

-(int)startAudioUnit;
-(int)stopProcessingAudio;
-(int)initAudioStreams;
-(int)initAudioSession;

@end
