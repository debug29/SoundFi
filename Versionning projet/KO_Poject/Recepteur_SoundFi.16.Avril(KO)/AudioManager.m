//
//  AudioManager.m
//  Recepteur_SoundFi
//
//  Created by François Le Brun on 16/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AudioManager.h"



#pragma mark -
#pragma mark mic, line in Audio Rendering

////////////////////////////////
// callback for mic/lineIn input
//
//
// this callback is now the clearinghouse for
// DSP fx processing
//
//


////////////////////////////////////////////////////////
// convert sample vector from fixed point 8.24 to SInt16
void fixedPointToSInt16( SInt32 * source, SInt16 * target, int length ) {
    
    int i;
    
    for(i = 0;i < length; i++ ) {
        target[i] =  (SInt16) (source[i] >> 9);
        
    }
    
}

////////////////////////////////////////////////////////
// convert sample vector from SInt16 to fixed point 8.24
void SInt16ToFixedPoint( SInt16 * source, SInt32 * target, int length ) {
    
    int i;
    
    for(i = 0;i < length; i++ ) {
        target[i] =  (SInt32) (source[i] << 9);
        if(source[i] < 0) {
            target[i] |= 0xFF000000;
        }
        else {
            target[i] &= 0x00FFFFFF;
        }
        
    }
    
}

float getMeanVolumeSint16( SInt16 * vector , int length ) {
    
    
    // get average input volume level for meter display
    // by calculating log of mean volume of the buffer
    // and displaying it to the screen
    // (note: there's a vdsp function to do this but it works on float samples
    
    int sum;
    int i;
    int averageVolume;
    float logVolume;
    
    
    sum = 0;
    for ( i = 0; i < length ; i++ ) {
        sum += abs((int) vector[i]);
    }
    
    averageVolume = sum / length;
    
    //    printf("\naverageVolume before scale = %lu", averageVolume );
    
    // now convert to logarithm and scale log10(0->32768) into 0->1 for display
    
    
    logVolume = log10f( (float) averageVolume );
    logVolume = logVolume / log10(32768);
    
    return (logVolume);
    
}


OSStatus micLineInCallback (void					*inRefCon,
                            AudioUnitRenderActionFlags 	*ioActionFlags,
                            const AudioTimeStamp			*inTimeStamp,
                            UInt32 						inBusNumber,
                            UInt32 						inNumberFrames,
                            AudioBufferList				*ioData)
{
	
	// set params & local variables
    
    // scope reference that allows access to everything in MixerHostAudio class
    
	AudioManager *THIS = (__bridge AudioManager *)inRefCon;
    
    AudioUnit rioUnit = THIS->ioUnit;    // io unit which has the input data from mic/lineIn
    int i;                              // loop counter
    
	OSStatus err;                       // error returns
	OSStatus renderErr;
	
    UInt32 bus1 = 1;                    // input bus
	
    
    AudioUnitSampleType *inSamplesLeft = NULL;         // convenience pointers to sample data
    AudioUnitSampleType *inSamplesRight = NULL;
    
    int isStereo;               // c boolean - for deciding how many channels to process.
    int numberOfChannels;       // 1 = mono, 2= stereo
    
    // Sint16 buffers to hold sample data after conversion
    
    SInt16 *sampleBufferLeft = THIS->conversionBufferLeft;
    SInt16 *sampleBufferRight = THIS->conversionBufferRight;
    SInt16 *sampleBuffer;
    
	
    // start the actual processing
    
    numberOfChannels = THIS->deviceInputChannel;
    isStereo = numberOfChannels > 1 ? 1 : 0;  // decide stereo or mono
	
	// copy all the input samples to the callback buffer - after this point we could bail and have a pass through
	
    renderErr = AudioUnitRender(rioUnit, ioActionFlags,
								inTimeStamp, bus1, inNumberFrames, ioData);
	if (renderErr < 0) {
		return renderErr;
	}
    
    // this comment is open to debate:
    // it seems that you can process single channel audio input as SInt16 just fine
    // In fact thats what this program had previously done with mono audio input.
    
    // but you get format errors if you set Sint16 samples in an ASBD with 2 channels
    // So... now to simplify things, we're going to get all input as 8.24 and just
    // convert it to SInt16 or float for processing
    //
    // There may be some 3 stage conversions here, ie., 8.24->Sint16->float
    // that could probably obviously be replaced by direct 8.24->float conversion
    //
    
    // convert to SInt16
    
    
    inSamplesLeft = (AudioUnitSampleType *) ioData->mBuffers[0].mData; // left channel
    fixedPointToSInt16(inSamplesLeft, sampleBufferLeft, inNumberFrames);
    
    if(isStereo) {
        inSamplesRight = (AudioUnitSampleType *) ioData->mBuffers[1].mData; // right channel
        fixedPointToSInt16(inSamplesRight, sampleBufferRight, inNumberFrames);
    }
    
    
    
    
    // get average input volume level for meter display
    //
    // (note: there's a vdsp function to do this but it works on float samples
    
    
    
    THIS->displayInputLevelLeft = getMeanVolumeSint16( sampleBufferLeft, inNumberFrames); // assign to instance variable for display
    if(isStereo) {
        THIS->displayInputLevelRight = getMeanVolumeSint16(sampleBufferRight, inNumberFrames); // assign to instance variable for display
    }
    
    
    //
    //  get user mic/line FX selection
    //
    //  so... none of these effects except fftPassthrough and delay (echo) are fast enough to
    //  render in stereo at the default sample rate and buffer sizes - on the ipad2
    //  This is kind of sad but I didn't really do any optimization
    //  and there's a lot of wasteful conversion and duplication going on... so there is hope
    
    // for now, run the effects in mono
    
    
    if(THIS->micFxOn == YES) {       // if user toggled on mic fx
        
        if(isStereo) {              // if stereo, combine left and right channels into left
            for( i = 0; i < inNumberFrames; i++ ) {
                sampleBufferLeft[i] = (SInt16) ((.5 * (float) sampleBufferLeft[i]) + (.5 * (float) sampleBufferRight[i]));
            }
        }
        sampleBuffer = sampleBufferLeft;
        
        // Effet appliqué à l'échantillon audio
        /*
        switch (THIS->micFxType) {
            case 0:
                ringMod( inRefCon, inNumberFrames, sampleBuffer );
                break;
            case 1:
                err = fftPassThrough ( inRefCon, inNumberFrames, sampleBuffer);
                break;
            case 2:
                err = fftPitchShift ( inRefCon, inNumberFrames, sampleBuffer);
                break;
            case 3:
                err = simpleDelay ( inRefCon, inNumberFrames, sampleBuffer);
                break;
            case 4:
                err = movingAverageFilterFloat ( inRefCon, inNumberFrames, sampleBuffer);
                break;
            case 5:
                err = convolutionFilter ( inRefCon, inNumberFrames, sampleBuffer);
                break;
                
            default:
                break;
        }
         */
        
        
        // If stereo, copy left channel (mono) results to right channel
        if(isStereo) {
            for(i = 0; i < inNumberFrames; i++ ) {
                sampleBufferRight[i] = sampleBufferLeft[i];
            }
        }
    }
    
    
    // convert back to 8.24 fixed point
    
    SInt16ToFixedPoint(sampleBufferLeft, inSamplesLeft, inNumberFrames);
    if(isStereo) {
        SInt16ToFixedPoint(sampleBufferRight, inSamplesRight, inNumberFrames);
    }
    
    NSLog(@"Test");
    return noErr;	// return with samples in iOdata
    
    
	
}



@implementation AudioManager


-(id)init
{
    self = [super init];
    
    [self startAudioSession];
    
    [self setupStereoStreamFormat];
    [self setupMonoStreamFormat];
    [self setupSInt16StreamFormat];
    [self initAudioGraph];
    AUGraphStart (audioGraph);
    
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
    
    
    /////////////////////////////
    // I/O Unit Setup (input bus)
	
    if(inputDeviceAvailable) {            // if no input device, skip this step
        NSLog(@"Autorisation démarage micro");
        AudioUnitElement ioUnitInputBus = 1;
        
        // Enable input for the I/O unit, which is disabled by default. (Output is
        //	enabled by default, so there's no need to explicitly enable it.)
        UInt32 enableInput = 1;
        
        AudioUnitSetProperty (
                              ioUnit,
                              kAudioOutputUnitProperty_EnableIO,
                              kAudioUnitScope_Input,
                              ioUnitInputBus,
                              &enableInput,
                              sizeof (enableInput)
                              );
        
       
        //Applique un absd en fonction du nombre de channel disponible
        
        if( deviceInputChannel == 1) {
            NSLog (@"Utilisation d'un absd mono");
                        AudioUnitSetProperty (
                                              ioUnit,
                                              kAudioUnitProperty_StreamFormat,
                                              kAudioUnitScope_Output,
                                              ioUnitInputBus,
                                              &monoStreamFormat,
                                              sizeof (monoStreamFormat)
                                              );
        }
        else {
            NSLog (@"Utilisation d'un adsb stereo");
                        AudioUnitSetProperty (
                                              ioUnit,
                                              kAudioUnitProperty_StreamFormat,
                                              kAudioUnitScope_Output,
                                              ioUnitInputBus,
                                              &stereoStreamFormat,
                                              sizeof (stereoStreamFormat)
                                              );
        }
    }    
	
    // Fin de la configuration du RIO
    
    
    
    
    //////////////////////////////////TEST/////////////////////////////////////////////
    
    
    
    
    
    
    //////////////////////////////////TEST/////////////////////////////////////////////
    
    
    /////////////////////////////////////////////////////////////////////
    // now attach the separate render callback for the mic/lineIn channel
	
    
	if(inputDeviceAvailable) {
        
        UInt16 busNumber = 2;		// mic channel on mixer
        
        // Setup the structure that contains the input render callback
        AURenderCallbackStruct inputCallbackStruct;
        
        inputCallbackStruct.inputProc        = micLineInCallback;	// 8.24 version
        inputCallbackStruct.inputProcRefCon  = (__bridge void *)(self);
        
        
        NSLog (@"Registering the render callback - mic/lineIn - with mixer unit input bus %u", busNumber);
        // Set a callback for the specified node's specified input
                 AUGraphSetNodeInputCallback (
                                              audioGraph,
                                              mixerNode,
                                              busNumber,
                                              &inputCallbackStruct
                                              );
    }
    
    [self connectNodes];
    
    //............................................................................
    // Initialize audio processing graph
    
    // Diagnostic code
    // Call CAShow if you want to look at the state of the audio processing
    //    graph.
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (audioGraph);
    
    NSLog (@"Initializing the audio processing graph");
    // Initialize the audio processing graph, configure audio data stream formats for
    //    each input and output, and validate the connections between audio units.
    
    AUGraphInitialize (audioGraph);
    

}

-(void)connectNodes
{
    OSStatus result = noErr;
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    
    // note: you only need to connect nodes which don't have assigned callbacks.
    // So for example, the mic/lineIn channel doesn't need to be connected.
    
	
	NSLog (@"Connecting nodes in audio processing graph");
    
    
    /*
     // this call should only be used if you don't need to process the mic input with a callback
     
     // Connect the output of the input bus of the I/O unit to the Multichannel Mixer unit input.
     result =	AUGraphConnectNodeInput (
     audioGraph,
     iONode,				// source node
     1,					// source node bus number
     mixerNode,			// destination node
     micBus					// destintaion node bus number
     );
     
     if (result) {[self printErrorMessage: @"AUGraphConnectNodeInput - I/O unit to Multichannel Mixer unit" withStatus: result]; return;}
     
     
     */
    
    
    NSLog (@"Connecting the sampler output to the mixer input node 4");
    
	// connect file player bus 0 (sampler output) to mixer bus 2 (third input)
	AUGraphConnectNodeInput(audioGraph, samplerNode, 0, mixerNode, 4);
    
    
    
    NSLog (@"Connecting the filePlayer output to input effect 1");
    
	// connect file player bus 0  to input effect1
	AUGraphConnectNodeInput(audioGraph, filePlayerNode, 0, inputEffect1Node, 0);
    
    
    NSLog (@"Connecting the input effect 1 output to the mixer input node 5");
    
	// connect file player bus 0 (input effect 1 output) to mixer bus 5
	AUGraphConnectNodeInput(audioGraph, inputEffect1Node, 0, mixerNode, 5);
    
    
    
    
    NSLog (@"Connecting the mixer output to the input of mixer effect element");
    
    
    
    result = AUGraphConnectNodeInput (
                                      audioGraph,
                                      mixerNode,         // source node
                                      0,                 // source node output bus number
                                      auEffectNode,            // destination node
                                      0                  // desintation node input bus number
                                      );
    
    
    
    
    NSLog (@"Connecting the effect output to the input of the I/O unit output element");
    
    
    
    result = AUGraphConnectNodeInput (
                                      audioGraph,
                                      auEffectNode,         // source node
                                      0,                 // source node output bus number
                                      iONode,            // destination node
                                      0                  // desintation node input bus number
                                      );

}


@end
