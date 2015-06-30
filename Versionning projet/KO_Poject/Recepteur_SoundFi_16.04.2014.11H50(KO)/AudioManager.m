//
//  AudioManager.m
//  Recepteur_SoundFi
//
//  Created by François Le Brun on 16/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager


-(id)init
{
    self = [super init];
    
    [self startAudioSession];
    
    [self setupStereoStreamFormat];
    [self setupMonoStreamFormat];
    [self setupSInt16StreamFormat];
    [self initAudioGraph];
    
    return self;
}




////////////////////////////
//
// setup asbd stream formats
//
//
- (void) setupStereoStreamFormat {
    
    // The AudioUnitSampleType data type is the recommended type for sample data in audio
    //    units. This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    //     NSLog (@"size of AudioUnitSampleType: %lu", bytesPerSample);
    
    // Fill the application audio format struct's fields to define a linear PCM,
    //        stereo, noninterleaved stream at the hardware sample rate.
    stereoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    stereoStreamFormat.mBytesPerPacket    = bytesPerSample;
    stereoStreamFormat.mFramesPerPacket   = 1;
    stereoStreamFormat.mBytesPerFrame     = bytesPerSample;
    stereoStreamFormat.mChannelsPerFrame  = 2;                    // 2 indicates stereo
    stereoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    stereoStreamFormat.mSampleRate        = sampleRate;
    
    NSLog (@"The stereo stream format:");
    //[self printASBD: stereoStreamFormat];
}

//////////////////////////////
- (void) setupMonoStreamFormat {
    
    // The AudioUnitSampleType data type is the recommended type for sample data in audio
    //    units. This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    
    // Fill the application audio format struct's fields to define a linear PCM,
    //        stereo, noninterleaved stream at the hardware sample rate.
    monoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    monoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    monoStreamFormat.mBytesPerPacket    = bytesPerSample;
    monoStreamFormat.mFramesPerPacket   = 1;
    monoStreamFormat.mBytesPerFrame     = bytesPerSample;
    monoStreamFormat.mChannelsPerFrame  = 1;                  // 1 indicates mono
    monoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    monoStreamFormat.mSampleRate        = sampleRate;
    
    NSLog (@"The mono stream format:");
    //[self printASBD: monoStreamFormat];
    
}

// this will be the stream format for anything that gets seriously processed by a render callback function
// it users 16bit signed int for sample data, assuming that this callback is probably on the input bus of a mixer
// or the input scope of the rio Output bus, in either case, we're assumeing that the AU will do the necessary format
// conversion to satisfy the output hardware - tz
//
// important distinction here with asbd's:
//
// note the difference between AudioUnitSampleType and AudioSampleType
//
// the former is an 8.24 (32 bit) fixed point sample format
// the latter is signed 16 bit (SInt16) integer sample format
//
// a subtle name differnce for a huge programming differece


- (void) setupSInt16StreamFormat {
    
    // Stream format for Signed 16 bit integers
    //
    // note: as of ios5 this works for signal channel mic/line input (not stereo)
    // and for mono audio generators (like synths) which pull no device data
    
    //    This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioSampleType);	// Sint16
    //    NSLog (@"size of AudioSampleType: %lu", bytesPerSample);
	
    // Fill the application audio format struct's fields to define a linear PCM,
    //        stereo, noninterleaved stream at the hardware sample rate.
    SInt16StreamFormat.mFormatID          = kAudioFormatLinearPCM;
    SInt16StreamFormat.mFormatFlags       = kAudioFormatFlagsCanonical;
    SInt16StreamFormat.mBytesPerPacket    = bytesPerSample;
    SInt16StreamFormat.mFramesPerPacket   = 1;
    SInt16StreamFormat.mBytesPerFrame     = bytesPerSample;
    SInt16StreamFormat.mChannelsPerFrame  = 1;                  // 1 indicates mono
    SInt16StreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    SInt16StreamFormat.mSampleRate        = sampleRate;
	
    NSLog (@"The SInt16 (mono) stream format:");
    //[self printASBD: SInt16StreamFormat];
    
    
    
}


// this is a test of using a float stream for the output scope of rio input bus
// and the input bus of a mixer channel
// the reason for this is that it would allow float algorithms to run without extra conversion
// that is, if it actually works
//
// so - apparently this doesn't work - at least in the context just described - there was no error in setting it
//
- (void) setupFloatStreamFormat {
	
    
    //    This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof(float);
	
    // Fill the application audio format struct's fields to define a linear PCM,
    //        stereo, noninterleaved stream at the hardware sample rate.
    floatStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    floatStreamFormat.mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
    floatStreamFormat.mBytesPerPacket    = bytesPerSample;
    floatStreamFormat.mFramesPerPacket   = 1;
    floatStreamFormat.mBytesPerFrame     = bytesPerSample;
    floatStreamFormat.mChannelsPerFrame  = 1;                  // 1 indicates mono
    floatStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    floatStreamFormat.mSampleRate        = sampleRate;
	
    NSLog (@"The float stream format:");
    //[self printASBD: floatStreamFormat];
	
}







//Démarage de la session audio
-(void)startAudioSession{
    NSLog(@"Démarrage session audio");
    
    AVAudioSession *mySession=[AVAudioSession sharedInstance];
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
    
    //Définition du type de la session ici play et record
    [mySession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    
    inputDeviceAvailable = [mySession isInputAvailable];
    if (inputDeviceAvailable)
        NSLog(@"Micro disponible");
    else
        NSLog(@"Pas de micro disponible");
    
    
    self->sampleRate=44100.0;
    [mySession setPreferredSampleRate:sampleRate error:nil]; // Fixe la préférance du ratio de la session;
    
    Float32 bufferDuration =  (Float32) (1024.0 / self->sampleRate);
	UInt32 size = sizeof(bufferDuration);
    
	AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, sizeof(bufferDuration), &bufferDuration); //Aplique la durée à la session audio
	NSLog(@"Durée du buffer fixé à: %f pour un ratio de %f", bufferDuration,sampleRate);
    
    [mySession setActive:YES error:nil]; //Activation de la session audio
    
    //Récupération de l'échantillon réel
    self->sampleRate= [mySession sampleRate];
    NSLog(@"Ratio réel du périphérique : %f",self->sampleRate);
    
    //Récupération de la durée "réel"
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &size, &bufferDuration);
    
    
    NSInteger nbrChannel = [mySession inputNumberOfChannels];
    NSLog(@"Nombre de channel disponible %ld",(long)nbrChannel);
    self->deviceInputChannel=nbrChannel;
    
    return;
}


-(void)setupAudioGraph
{
    OSStatus resErr = noErr;
    
    resErr=NewAUGraph(&audioGraph);
    
    if (noErr != resErr) {NSLog(@"Erreur création graph");return;}
    
    //............................................................................
    // Specify the audio unit component descriptions for the audio units to be
    //    added to the graph.
    
    // remote I/O unit connects both to mic/lineIn and to speaker
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    
    
    // Multichannel mixer unit
    AudioComponentDescription MixerUnitDescription;
    MixerUnitDescription.componentType          = kAudioUnitType_Mixer;
    MixerUnitDescription.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    MixerUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    MixerUnitDescription.componentFlags         = 0;
    MixerUnitDescription.componentFlagsMask     = 0;
    
    // au unit effect for mixer output - lowPass filter
    
    AudioComponentDescription auEffectUnitDescription;
    auEffectUnitDescription.componentType = kAudioUnitType_Effect;
    auEffectUnitDescription.componentSubType = kAudioUnitSubType_LowPassFilter;
    auEffectUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    //  au mixer input channel effect
    //
    //
    //  high pass filter
    
    AudioComponentDescription auInputEffect1UnitDescription;
    auInputEffect1UnitDescription.componentType = kAudioUnitType_Effect;
    auInputEffect1UnitDescription.componentSubType = kAudioUnitSubType_HighPassFilter;
    auInputEffect1UnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // fileplayer
    
    AudioComponentDescription auFilePlayerUnitDescription;
    auFilePlayerUnitDescription.componentType = kAudioUnitType_Generator;
    auFilePlayerUnitDescription.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    auFilePlayerUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // sampler
    
    AudioComponentDescription auSamplerUnitDescription;
    auSamplerUnitDescription.componentType = kAudioUnitType_MusicDevice ;
    auSamplerUnitDescription.componentSubType = kAudioUnitSubType_Sampler;
    auSamplerUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    
    ///////////////////////////////////////////////
    // Add the nodes to the audio processing graph
    ///////////////////////////////////////////////
    
    
    NSLog (@"Adding nodes to audio processing graph");
    
    
    
    // io unit
    
    AUGraphAddNode (audioGraph,&iOUnitDescription,&iONode);
    
    // mixer unit
    
    AUGraphAddNode (audioGraph,&MixerUnitDescription,&mixerNode);
    
    // au effect unit
    
	AUGraphAddNode(audioGraph,&auEffectUnitDescription,&auEffectNode);
    
    // sampler unit
    
    AUGraphAddNode(audioGraph, &auSamplerUnitDescription, &samplerNode);
    
    // fileplayer unit
    
	AUGraphAddNode(audioGraph, &auFilePlayerUnitDescription, &filePlayerNode);
    
    // input effect1 unit
    
    AUGraphAddNode(audioGraph, &auInputEffect1UnitDescription, &inputEffect1Node);

}

-(void)initAudioGraph
{
    NSLog(@"Démarrage de la configuration du graph audio");
    
    OSStatus resErr = noErr;
    UInt16 busNumber;
    
    [self setupAudioGraph];
    
    AUGraphOpen(audioGraph);
    NSLog(@"Le graph à été ouvert");
    
    AUGraphNodeInfo (audioGraph,iONode,NULL,&ioUnit);
    
    
    return;

}

@end
