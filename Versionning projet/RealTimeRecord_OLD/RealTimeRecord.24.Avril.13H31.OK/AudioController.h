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
    
    
    AUNode ioNode;
    AUNode mixerNode;
    
    AUGraph myGraph;
    
    int sampleFrequency;
    float sampleRate;
    
    AudioUnitSampleType *emptySample;
    
    NSString * (**tableauDecodage)(void);
    
    //Callback Setup
    
    SInt16 *samplesBuffer;
    
    
    //FFT use
    FFTSetup fftSetup;
    
    float *outputBuffer;
	float *analysisBuffer;
    
    float fftLog2n;
	float micFxControl;
    
    //Transaction information
    BOOL isInitiate;
    BOOL isTimeOut;
    
    //Message
    NSMutableString *messageReceive;
    
    // Test
    int compteur;
}

-(void)fftSetup;
-(void)setupCallback;

-(int)startAudioUnit;
-(int)stopProcessingAudio;
-(int)initAudioStreams;
-(int)initAudioSession;
-(void)startAnalysis;
-(NSString*)analysisCompare:(NSString*)un : (NSString*)deux : (NSString*)trois;


@end
