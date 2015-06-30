//
//  SoundFiAudioSession.h
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

@protocol SampleProtocolDelegate <NSObject>
@required
- (void) messageReceived:(NSString*) theMessage : (int)quality;
- (void) startingReception;
- (void) finishEmission;
- (void) soundToLow;
- (void) progressStatut:(float) percent;
@end

@interface SoundFiAudioSession : NSObject
{
    @public
    AudioUnit           audioUnit;
    AudioUnit           mixerUnit;
    AudioUnit           emissionUnit;
    
    AUNode              ioNode;
    AUNode              mixerNode;
    
    AUGraph             myGraph;
    
    int                 sampleFrequency;
    float               sampleRate;
    
    AudioUnitSampleType *emptySample;

    int                 receptionQuality; //Reception's quality : <20            omg so bad
                                          //                      >20 && <40     not so bad
                                          //                      >40 && <70     nice but some error
                                          //                      >70 or more    so perfect
    
    //Callback Setup
    
    SInt16              *samplesBuffer;

    
    
    // fft
	FFTSetup            fftSetup;			// fft predefined structure required by vdsp fft functions
	COMPLEX_SPLIT       fftA;               // complex variable for fft
	int                 fftLog2n;           // base 2 log of fft size
    int                 fftN;               // fft size
    int                 fftNOver2;          // half fft size
	size_t              fftBufferCapacity;	// fft buffer size (in samples)
	size_t              fftIndex;           // read index pointer in fft buffer
    
    void                *dataBuffer;        //  input buffer from mic/line
	float               *outputBuffer;      //  fft conversion buffer
	float               *analysisBuffer;    //  fft analysis buffer
    
    //Transaction information
    BOOL                isInitiate;
    BOOL                isTimeOut;
    BOOL                receptionMode;
    BOOL                emissionMode;
    
    //Reception mode variables
    NSMutableString     *messageReceive;
    
    // Emission mode variables
    double              theta;
    NSString            *myMessage;
    pthread_mutex_t     emissionMutex;
    int                 nbCaracRepeat;
    BOOL                initSequence;
    int                 nbrRepeatInit;
    BOOL                isSafeForWork;
    
    // Share mode's variable
    int                 compteur;
    
    // Delegate to respond back
    id <SampleProtocolDelegate> _delegate;
    
    //Test
    int                 *tabTstFreq;
    int                 tabIndex;
    
}
//Delegate property
@property (nonatomic,strong) id delegate;

-(void)fftSetup;
-(void)setupCallback;

//Démarage de l'écoute ou de l'envoie
-(int)startAudioUnit:(int)mode : (NSString*)message;

-(int)stopProcessingAudio;
-(int)initAudioStreams;
-(int)initAudioSession;
-(void)startAnalysis;


-(int)getASCIIFrequency;
-(void)emissionSampleCalcul:(int)frequence : (int)numFrames : (Float32 *)buffer;

-(void)checkTimeOut;
-(void)sampleTreatment:(int)numFrames;

-(void)routeChanged;

@end
