//
//  SoundFiASSession.h
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
- (void) messageReceived:(NSString*) theMessage;
- (void) startingReception;
- (void) finishEmission;
@end

@interface SoundFiASSession : NSObject
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
    
    Float32 *emptySample;
    
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
    
    //Reception mode variables
    NSMutableString *messageReceive;
    
    // Emission mode variables
    double theta;
    NSString *myMessage;
    pthread_mutex_t emissionMutex;
    int nbCaracRepeat;
    BOOL initSequence;
    BOOL isSafeForWork;
    
    // Share mode's variable
    int compteur;
    
    // Delegate to respond back
    id <SampleProtocolDelegate> _delegate;
    
    
    
    
    
    //Transaction information
    BOOL receptionMode;
    BOOL emissionMode;
    BOOL firstLaunch;
    
    //Etat de l'échange du message (Receveur)
    BOOL transactionIsInit; //Etat global de début de transaction
    BOOL startingMessageSize;
    
    BOOL acquitementCaracIsOk;
    BOOL acquitementsendingIsOk;
    
    int nbrAquitInit;
    int nbrRepeat;
    int sentFrequency;
    
    NSString* messageSize;
    int currentDigitIndex;
    
    BOOL pingPong;
    
    
    
    
    AudioBuffer recordBuffer;
    AudioBufferList recordBufferList;
    
    //Information about the message
    int size;
    
    //TEST
    int testVal;
    
    
    
}
//Delegate property
@property (nonatomic,strong) id delegate;

-(void)fftSetup;
-(void)setupCallback;

//Démarage de l'écoute ou de l'envoie
-(int)startAudioUnit:(int)mode : (NSString*)message;

-(int)stopProcessingAudio;
-(int)initAudioSession;
-(void)startAnalysis;


-(int)getASCIIFrequency;
-(void)emissionSampleCalcul:(int)frequence : (int)numFrames : (Float32 *)buffer;
-(void)attenuateSampleCalcul:(int)frequence : (int)numFrames : (Float32 *)buffer;

-(void)checkTimeOut;
-(void)sampleTreatment:(int)numFrames;

-(void)acceptableTimeOut;
-(void)rebootSending;

@end
