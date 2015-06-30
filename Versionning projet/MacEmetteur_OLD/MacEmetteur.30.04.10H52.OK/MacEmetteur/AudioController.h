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
    AudioUnit emissionUnit;
    
    AUNode ioNode;
    AUNode mixerNode;
    
    AUGraph myGraph;
    
    int sampleFrequency;
    float sampleRate;
    
    AudioUnitSampleType *emptySample;
    
    NSString * (**tableauDecodage)(void);
    int (**tableauEncodage)(char c);
    
    //Callback Setup
    
    SInt16 *samplesBuffer;

    
    
    // fft
	FFTSetup fftSetup;			// fft predefined structure required by vdsp fft functions
	COMPLEX_SPLIT fftA;			// complex variable for fft
	int fftLog2n;               // base 2 log of fft size
    int fftN;                   // fft size
    int fftNOver2;              // half fft size
	size_t fftBufferCapacity;	// fft buffer size (in samples)
	size_t fftIndex;            // read index pointer in fft buffer
    
    void *dataBuffer;               //  input buffer from mic/line
	float *outputBuffer;            //  fft conversion buffer
	float *analysisBuffer;          //  fft analysis buffer
    
    //Transaction information
    BOOL isInitiate;
    BOOL isTimeOut;
    BOOL receptionMode;
    BOOL emissionMode;
    
    //Reception mode variables
    NSMutableString *messageReceive;
    
    // Emission mode variables
    double theta;
    NSString *myMessage;
    pthread_mutex_t emissionMutex;
    int nbCaracRepeat;
    
    // Test
    int compteur;
    BOOL isSafeForWork;
}

-(void)fftSetup;
-(void)setupCallback;

-(int)startAudioUnit:(int)mode;

-(int)stopProcessingAudio;
-(int)initAudioStreams;
-(int)initAudioSession;
-(void)startAnalysis;


-(int)getASCIIFrequency;
-(void)emissionSampleCalcul:(int)frequence : (int)numFrames : (Float32 *)buffer;

-(void)checkTimeOut;
-(void)sampleTreatment:(int)numFrames;


@end
