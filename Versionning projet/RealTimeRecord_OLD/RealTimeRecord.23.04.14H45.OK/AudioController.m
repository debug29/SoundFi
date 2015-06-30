//
//  AudioController.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "AudioController.h"


NSString* decode32(){return @" ";}
NSString* decode33(){return @"!";}
NSString* decode34(){return @"\"";}
NSString* decode35(){return @"#";}
NSString* decode36(){return @"§";}
NSString* decode37(){return @"%";}
NSString* decode38(){return @"&";}
NSString* decode39(){return @"'";}
NSString* decode40(){return @"(";}
NSString* decode41(){return @")";}
NSString* decode42(){return @"*";}
NSString* decode43(){return @"+";}
NSString* decode44(){return @",";}
NSString* decode45(){return @"-";}
NSString* decode46(){return @".";}
NSString* decode47(){return @"/";}
NSString* decode48(){return @"0";}
NSString* decode49(){return @"1";}
NSString* decode50(){return @"2";}
NSString* decode51(){return @"3";}
NSString* decode52(){return @"4";}
NSString* decode53(){return @"5";}
NSString* decode54(){return @"6";}
NSString* decode55(){return @"7";}
NSString* decode56(){return @"8";}
NSString* decode57(){return @"9";}
NSString* decode58(){return @":";}
NSString* decode59(){return @";";}
NSString* decode60(){return @"<";}
NSString* decode61(){return @"=";}
NSString* decode62(){return @">";}
NSString* decode63(){return @"?";}
NSString* decode64(){return @"@";}
NSString* decode65(){return @"A";}
NSString* decode66(){return @"B";}
NSString* decode67(){return @"C";}
NSString* decode68(){return @"D";}
NSString* decode69(){return @"E";}
NSString* decode70(){return @"F";}
NSString* decode71(){return @"G";}
NSString* decode72(){return @"H";}
NSString* decode73(){return @"I";}
NSString* decode74(){return @"J";}
NSString* decode75(){return @"K";}
NSString* decode76(){return @"L";}
NSString* decode77(){return @"M";}
NSString* decode78(){return @"N";}
NSString* decode79(){return @"O";}
NSString* decode80(){return @"P";}
NSString* decode81(){return @"Q";}
NSString* decode82(){return @"R";}
NSString* decode83(){return @"S";}
NSString* decode84(){return @"T";}
NSString* decode85(){return @"U";}
NSString* decode86(){return @"V";}
NSString* decode87(){return @"W";}
NSString* decode88(){return @"X";}
NSString* decode89(){return @"Y";}
NSString* decode90(){return @"Z";}
NSString* decode91(){return @"[";}
NSString* decode92(){return @"\\";}
NSString* decode93(){return @"]";}
NSString* decode94(){return @"^";}
NSString* decode95(){return @"_";}
NSString* decode96(){return @"`";}
NSString* decode97(){return @"a";}
NSString* decode98(){return @"b";}
NSString* decode99(){return @"c";}
NSString* decode100(){return @"d";}
NSString* decode101(){return @"e";}
NSString* decode102(){return @"f";}
NSString* decode103(){return @"g";}
NSString* decode104(){return @"h";}
NSString* decode105(){return @"i";}
NSString* decode106(){return @"j";}
NSString* decode107(){return @"k";}
NSString* decode108(){return @"l";}
NSString* decode109(){return @"m";}
NSString* decode110(){return @"n";}
NSString* decode111(){return @"o";}
NSString* decode112(){return @"p";}
NSString* decode113(){return @"q";}
NSString* decode114(){return @"r";}
NSString* decode115(){return @"s";}
NSString* decode116(){return @"t";}
NSString* decode117(){return @"u";}
NSString* decode118(){return @"v";}
NSString* decode119(){return @"w";}
NSString* decode120(){return @"x";}
NSString* decode121(){return @"y";}
NSString* decode122(){return @"z";}
NSString* decode123(){return @"{";}
NSString* decode124(){return @"|";}
NSString* decode125(){return @"}";}
NSString* decode126(){return @"~";}

void smb2PitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize,
					long osamp, float sampleRate, float *indata, float *outdata,
					FFTSetup fftSetup, float * frequency);

void fixedPointToSInt16( SInt32 * source, SInt16 * target, int length ) {
    
    int i;
    
    for(i = 0;i < length; i++ ) {
        target[i] =  (SInt16) (source[i] >> 9);
        
    }
    
}

OSStatus fftGetFrequency (
                        void *inRefCon,                // scope (MixerHostAudio)
                        UInt32 inNumberFrames,        // number of frames in this slice
                        SInt16 *sampleBuffer) {      // frames (sample data)
    
    // scope reference that allows access to everything in MixerHostAudio class
    
	AudioController *THIS = (__bridge AudioController *)inRefCon;
    
  	float *outputBuffer = THIS->outputBuffer;
	float *analysisBuffer = THIS->analysisBuffer;
    
    FFTSetup fftSetup = THIS->fftSetup;      // fft setup structures need to support vdsp functions
	
    
	uint32_t stride = 1;                    // interleaving factor for vdsp functions
	int bufferCapacity = 512;    // maximum size of fft buffers
    
    float pitchShift = 1.0;                 // pitch shift factor 1=normal, range is .5->2.0
    long osamp = 4;                         // oversampling factor
    long fftSize = 512;                    // fft size
    
	
	float frequency;                        // analysis frequency result
    
    
    //	ConvertInt16ToFloat
    
    vDSP_vflt16((SInt16 *) sampleBuffer, stride, (float *) analysisBuffer, stride, bufferCapacity );
    
    // run the pitch shift
    
    // scale the fx control 0->1 to range of pitchShift .5->2.0
    
    pitchShift = (THIS->micFxControl * 1.5) + .5;
    
    // osamp should be at least 4, but at this time my ipod touch gets very unhappy with
    // anything greater than 2
    
    osamp = 4;
    fftSize = 512;		// this seems to work in real time since we are actually doing the fft on smaller windows
    
    smb2PitchShift( pitchShift , (long) inNumberFrames,
                   fftSize,  osamp, (float) THIS->sampleRate,
                   (float *) analysisBuffer , (float *) outputBuffer,
                   fftSetup, &frequency);
    
    
    // display detected pitch
    
    
    THIS->sampleFrequency = (int) frequency;
    
    // now convert from float to Sint16
    
    vDSP_vfixr16((float *) outputBuffer, stride, (SInt16 *) sampleBuffer, stride, bufferCapacity );
    
    
    
    return noErr;
    
    
}


OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers) {
    
    AudioController *THIS=(__bridge AudioController*)userData;
    AudioUnit audioUnit=(THIS->audioUnit);
    int compteur = THIS->compteur;
    
    OSStatus status = AudioUnitRender(audioUnit, actionFlags, audioTimeStamp,
                                      1, numFrames, buffers);
    
    if(status != noErr) {
        NSLog(@"Arror AudioUnitRender %d",(int)status);
        return status;
    }
    
    AudioUnitSampleType *echantillonAudio;
    SInt16 *buffer=THIS->samplesBuffer;
    echantillonAudio=(AudioUnitSampleType*) buffers->mBuffers[0].mData;
    
    fixedPointToSInt16(echantillonAudio, buffer, numFrames);
    
    
    status=fftGetFrequency ( userData, numFrames, buffer);

    
    if (THIS->sampleFrequency>18012 && THIS->sampleFrequency<20005) {
        NSString *test=THIS->tableauDecodage[(THIS->sampleFrequency-18013)]();
        NSLog(@"\n Freq : %d  diff: %d  val : %@",THIS->sampleFrequency,(THIS->sampleFrequency-18013),test);
        //NSLog(@"\n%@\n",test);
    }
    
    
    buffers->mBuffers[0].mData=THIS->emptySample;
    
    THIS->compteur=compteur+1;
    
    return noErr;
}

@implementation AudioController


-(void)initDecodeur
{
    tableauDecodage=malloc(1994*sizeof(void*));
    
    for (int i=0; i<=19; i++) tableauDecodage[i]=decode32;
    
    for (int i=20; i<=40; i++) tableauDecodage[i]=decode33;
    for (int i=41; i<=61; i++) tableauDecodage[i]=decode34;
    for (int i=62; i<=82; i++) tableauDecodage[i]=decode35;
    for (int i=83; i<=103; i++) tableauDecodage[i]=decode36;
    for (int i=104; i<=124; i++) tableauDecodage[i]=decode37;
    for (int i=125; i<=145; i++) tableauDecodage[i]=decode38;
    for (int i=146; i<=166; i++) tableauDecodage[i]=decode39;
    for (int i=167; i<=187; i++) tableauDecodage[i]=decode40;
    for (int i=188; i<=208; i++) tableauDecodage[i]=decode41;
    for (int i=209; i<=229; i++) tableauDecodage[i]=decode42;
    for (int i=230; i<=250; i++) tableauDecodage[i]=decode43;
    for (int i=251; i<=271; i++) tableauDecodage[i]=decode44;
    for (int i=272; i<=292; i++) tableauDecodage[i]=decode45;
    for (int i=293; i<=313; i++) tableauDecodage[i]=decode46;
    for (int i=314; i<=334; i++) tableauDecodage[i]=decode47;
    
    //0-9
    for (int i=335; i<=355; i++) tableauDecodage[i]=decode48;
    for (int i=356; i<=376; i++) tableauDecodage[i]=decode49;
    for (int i=377; i<=397; i++) tableauDecodage[i]=decode50;
    for (int i=398; i<=418; i++) tableauDecodage[i]=decode51;
    for (int i=419; i<=439; i++) tableauDecodage[i]=decode52;
    for (int i=440; i<=460; i++) tableauDecodage[i]=decode53;
    for (int i=461; i<=481; i++) tableauDecodage[i]=decode54;
    for (int i=482; i<=502; i++) tableauDecodage[i]=decode55;
    for (int i=503; i<=523; i++) tableauDecodage[i]=decode56;
    for (int i=524; i<=544; i++) tableauDecodage[i]=decode57;
    
    for (int i=545; i<=565; i++) tableauDecodage[i]=decode58;
    for (int i=566; i<=586; i++) tableauDecodage[i]=decode59;
    for (int i=587; i<=607; i++) tableauDecodage[i]=decode60;
    for (int i=608; i<=628; i++) tableauDecodage[i]=decode61;
    for (int i=629; i<=649; i++) tableauDecodage[i]=decode62;
    for (int i=650; i<=670; i++) tableauDecodage[i]=decode63;
    for (int i=671; i<691; i++) tableauDecodage[i]=decode64;
    // A-Z
    for (int i=692; i<712; i++) tableauDecodage[i]=decode65;
    for (int i=713; i<733; i++) tableauDecodage[i]=decode66;
    for (int i=734; i<754; i++) tableauDecodage[i]=decode67;
    for (int i=755; i<775; i++) tableauDecodage[i]=decode68;
    for (int i=776; i<796; i++) tableauDecodage[i]=decode69;
    for (int i=797; i<817; i++) tableauDecodage[i]=decode70;
    for (int i=818; i<838; i++) tableauDecodage[i]=decode71;
    for (int i=839; i<859; i++) tableauDecodage[i]=decode72;
    for (int i=860; i<880; i++) tableauDecodage[i]=decode73;
    for (int i=881; i<901; i++) tableauDecodage[i]=decode74;
    for (int i=902; i<922; i++) tableauDecodage[i]=decode75;
    for (int i=923; i<943; i++) tableauDecodage[i]=decode76;
    for (int i=944; i<964; i++) tableauDecodage[i]=decode77;
    for (int i=965; i<=985; i++) tableauDecodage[i]=decode78;
    for (int i=986; i<=1006; i++) tableauDecodage[i]=decode79;
    for (int i=1007; i<=1027; i++) tableauDecodage[i]=decode80;
    for (int i=1028; i<=1048; i++) tableauDecodage[i]=decode81;
    for (int i=1049; i<=1069; i++) tableauDecodage[i]=decode82;
    for (int i=1070; i<=1090; i++) tableauDecodage[i]=decode83;
    for (int i=1091; i<=1111; i++) tableauDecodage[i]=decode84;
    for (int i=1112; i<=1132; i++) tableauDecodage[i]=decode85;
    for (int i=1133; i<=1153; i++) tableauDecodage[i]=decode86;
    for (int i=1154; i<=1174; i++) tableauDecodage[i]=decode87;
    for (int i=1175; i<=1195; i++) tableauDecodage[i]=decode88;
    for (int i=1196; i<=1216; i++) tableauDecodage[i]=decode89;
    for (int i=1217; i<=1237; i++) tableauDecodage[i]=decode90;
    
    for (int i=1238; i<=1258; i++) tableauDecodage[i]=decode91;
    for (int i=1259; i<=1279; i++) tableauDecodage[i]=decode92;
    for (int i=1280; i<=1300; i++) tableauDecodage[i]=decode93;
    for (int i=1301; i<=1321; i++) tableauDecodage[i]=decode94;
    for (int i=1322; i<=1342; i++) tableauDecodage[i]=decode95;
    for (int i=1343; i<=1363; i++) tableauDecodage[i]=decode96;
    //  a-z
    for (int i=1364; i<=1394;i++) tableauDecodage[i]=decode97; //a
    for (int i=1385; i<=1405;i++) tableauDecodage[i]=decode98;
    for (int i=1406; i<=1426;i++) tableauDecodage[i]=decode99;
    for (int i=1427; i<=1447;i++) tableauDecodage[i]=decode100;
    for (int i=1448; i<=1468;i++) tableauDecodage[i]=decode101;
    for (int i=1469; i<=1489;i++) tableauDecodage[i]=decode102;
    for (int i=1490; i<=1510;i++) tableauDecodage[i]=decode103;
    for (int i=1511; i<=1531;i++) tableauDecodage[i]=decode104;
    for (int i=1532; i<=1552;i++) tableauDecodage[i]=decode105;
    for (int i=1553; i<=1573;i++) tableauDecodage[i]=decode106;
    for (int i=1574; i<=1594;i++) tableauDecodage[i]=decode107;
    for (int i=1585; i<=1615;i++) tableauDecodage[i]=decode108;
    for (int i=1616; i<=1636;i++) tableauDecodage[i]=decode109; //m
    for (int i=1637; i<=1657;i++) tableauDecodage[i]=decode110;
    for (int i=1658; i<=1678;i++) tableauDecodage[i]=decode111;
    for (int i=1679; i<=1699;i++) tableauDecodage[i]=decode112;
    for (int i=1700; i<=1720;i++) tableauDecodage[i]=decode113;
    for (int i=1721; i<=1741;i++) tableauDecodage[i]=decode114;
    for (int i=1742; i<=1762;i++) tableauDecodage[i]=decode115; //s
    for (int i=1763; i<=1783;i++) tableauDecodage[i]=decode116;
    for (int i=1784; i<=1804;i++) tableauDecodage[i]=decode117;
    for (int i=1805; i<=1825;i++) tableauDecodage[i]=decode118;
    for (int i=1826; i<=1846;i++) tableauDecodage[i]=decode119;
    for (int i=1847; i<=1867;i++) tableauDecodage[i]=decode120;
    for (int i=1868; i<=1888;i++) tableauDecodage[i]=decode121;
    for (int i=1989; i<=1909;i++) tableauDecodage[i]=decode122; //z
    
    for (int i=1910; i<=1930; i++) tableauDecodage[i]=decode123;
    for (int i=1931; i<=1951; i++) tableauDecodage[i]=decode124;
    for (int i=1952; i<=1972; i++) tableauDecodage[i]=decode125;
    for (int i=1973; i<=1993; i++) tableauDecodage[i]=decode126;
}

-(void)setupCallback
{
    [self initDecodeur];
    
    emptySample=malloc(512*sizeof(AudioUnitSampleType));
    for (int i=0; i<512; i++) {
        emptySample[i]=0;
    }
    
    samplesBuffer=(SInt16*)malloc(512 *sizeof(float));
}

-(void)fftSetup
{
    
    outputBuffer = (float*)malloc(512 *sizeof(float));
	analysisBuffer = (float*)malloc(512 *sizeof(float));
    
    fftLog2n = log2f(512);
	micFxControl = 0.5f;
    
    fftSetup = vDSP_create_fftsetup(fftLog2n, FFT_RADIX2);
    
}


-(int)initAudioSession
{
    NSLog(@"Initialisation de la session audio");
    sampleRate=44100.0;
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord error: &audioSessionError];
    
    
    [mySession setPreferredSampleRate: 44100.0 error: &audioSessionError];
    
    /*
    Float32 currentBufferDuration =  (Float32) (512.0 / 44100.0);
	UInt32 sss = sizeof(currentBufferDuration);
	
	AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, sizeof(currentBufferDuration), &currentBufferDuration);
	NSLog(@"setting buffer duration to: %f", currentBufferDuration);
    */
    
    [mySession setPreferredIOBufferDuration: (512.0/sampleRate) error: &audioSessionError];
    
    [mySession setActive:YES error:nil];
    
    /*
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &sss, &currentBufferDuration);
	NSLog(@"Actual current hardware io buffer duration: %f ", currentBufferDuration );
    */

    
    return 0;
}




-(int)initAudioStreams
{
    OSStatus err;
    err=NewAUGraph(&myGraph);
    if (err!=noErr) {NSLog(@"Erreur NewAUGraph");}
    
    //Put the session in play/record mode
    NSLog(@"Initialisation des streams audios");
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &audioCategory) != noErr) {
        return 1;
    }
    
    UInt32 overrideCategory = 1;
    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                               sizeof(UInt32), &overrideCategory) != noErr) {
        // Less serious error, but you may want to handle it and bail here
    }
    
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                          Initialisation de l'unité son io audioUnit                          */
     ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    AudioComponentDescription ioComponentDescription;
    ioComponentDescription.componentType = kAudioUnitType_Output;
    ioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    ioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioComponentDescription.componentFlags = 0;
    ioComponentDescription.componentFlagsMask = 0;
    
    /* Configuration de la ioUnit Hors node
     
    AudioComponent component = AudioComponentFindNext(NULL, &ioComponentDescription);
    if(AudioComponentInstanceNew(component, &audioUnit) != noErr) {
        return 1;
    }
    
    UInt32 enable = 1;
    if(AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO,
                            kAudioUnitScope_Input, 1, &enable, sizeof(UInt32)) != noErr) {
        return 1;
    }
    */
    
    /* CallBack sur la ioUnit hors node
     
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; // Render function
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    if(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback,
                            kAudioUnitScope_Input, 0, &callbackStruct,
                            sizeof(AURenderCallbackStruct)) != noErr) {
        return 1;
    }
    */
    
    //ASBD for mono record  PEUT ETRE A REMPLACER AVEC LA DEF DE audiograph ????????
    AudioStreamBasicDescription streamDescription;
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    streamDescription.mFormatID          = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    streamDescription.mBytesPerPacket    = bytesPerSample;
    streamDescription.mFramesPerPacket   = 1;
    streamDescription.mBytesPerFrame     = bytesPerSample;
    streamDescription.mChannelsPerFrame  = 1;                  // 1 indicates mono
    streamDescription.mBitsPerChannel    = 8 * bytesPerSample;
    streamDescription.mSampleRate        = sampleRate;
    /*
    streamDescription.mSampleRate = 44100;
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    streamDescription.mBitsPerChannel = 16;
    streamDescription.mBytesPerFrame = 2;
    streamDescription.mChannelsPerFrame = 1;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * streamDescription.mChannelsPerFrame;
    streamDescription.mFramesPerPacket = 1;
    streamDescription.mReserved = 0;
    */
    
    /*   Set Ptoperty pour iounit hors node
     
    // Set up input stream with above properties
    if(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    
    
    // Ditto for the output stream, which we will be sending the processed audio to
    if(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
     */
    
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                     Fin de l'initialisation de l'unité son io audioUnit                     */
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    
    
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                          Initialisation de l'unité son du mixeur                             */
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
        AudioComponentDescription mixerComponentDescription;
        mixerComponentDescription.componentType = kAudioUnitType_Mixer;
        mixerComponentDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        mixerComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        mixerComponentDescription.componentFlags = 0;
        mixerComponentDescription.componentFlagsMask = 0;
        

    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                     Fin de l'initialisation de l'unité son du mixeur                         */
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    
    err=AUGraphAddNode(myGraph, &ioComponentDescription, &ioNode);
    if (err!=noErr) {NSLog(@"Error AUGraphAddNode1");}
    err=AUGraphAddNode(myGraph, &mixerComponentDescription, &mixerNode);
    if (err!=noErr) {NSLog(@"Error AUGraphAddNode2");}
    
    
    
    err=AUGraphOpen (myGraph);
    if (err!=noErr) {NSLog(@"Error AUGraphOpen");}
    
    AUGraphNodeInfo (myGraph,ioNode,NULL,&audioUnit);       //Va écraser les config précédente de l'audioUnit   BAD   ? ? ? ? ? ?
    if (err!=noErr) {NSLog(@"Error AUGraphNodeInfo1");}
    AUGraphNodeInfo (myGraph,mixerNode,NULL,&mixerUnit);    //Pareil pour le mixer, mettre config après  ? ? ? ? ? ? ? ? ?
    if (err!=noErr) {NSLog(@"Error AUGraphNodeInfo2");}
    
    //////////////////////////////////
    
	
    // Enable input for the I/O unit, which is disabled by default. (Output is
    //	enabled by default, so there's no need to explicitly enable it.)
    AudioUnitElement ioUnitInputBus = 1;
    UInt32 enableInput = 1;
	
    AudioUnitSetProperty (
						  audioUnit,
						  kAudioOutputUnitProperty_EnableIO,
						  kAudioUnitScope_Input,
						  ioUnitInputBus,
						  &enableInput,
						  sizeof (enableInput)
						  );
    
    //Set the monoStream format for output
    AudioUnitSetProperty (
                          audioUnit,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Output,
                          ioUnitInputBus,
                          &streamDescription,
                          sizeof (streamDescription)
                          );
    
    
    //////////////////////////////////
    
    
    
    //////////////////////////////////
    UInt32 busCount   = 2;    // bus count for mixer unit input
    
    NSLog (@"Setting mixer unit input bus count to: %u", (unsigned int)busCount);
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_ElementCount,
                          kAudioUnitScope_Input,
                          0,
                          &busCount,
                          sizeof (busCount)
                          );
    
    UInt32 maximumFramesPerSlice = 4096;
    
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_MaximumFramesPerSlice,
                          kAudioUnitScope_Global,
                          0,
                          &maximumFramesPerSlice,
                          sizeof (maximumFramesPerSlice)
                          );
    
    /*
    // Set up input stream with above properties
    if(AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    */
    
    //Active l'entrée du bus 1 pour le mixer
    AudioUnitParameterValue isOn;
    isOn=kMultiChannelMixerParam_Enable;
    AudioUnitSetParameter (
                                    mixerUnit,
                                    kMultiChannelMixerParam_Enable,
                                    kAudioUnitScope_Input,
                                    1,
                                    isOn,
                                    0
                                    );
    
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Input,
                          1,
                          &streamDescription,
                          sizeof (streamDescription)
                          );
    
    
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_SampleRate,
                          kAudioUnitScope_Output,
                          0,
                          &sampleRate,
                          sizeof (sampleRate)
                          );
    ////////////////////////////////////
    
    
    // Attache un callback sur l'entrée du mixer, il va ainsi demander des infos
    AURenderCallbackStruct inputCallbackStruct;
	
    inputCallbackStruct.inputProc        = renderCallback;	// callback à complété, a quoi va t'il servir?????
    inputCallbackStruct.inputProcRefCon  = (__bridge void *)(self);
	
	//  une seule entrée sur le mixer 0 ou 1  ? ?? ?
    err = AUGraphSetNodeInputCallback (myGraph,mixerNode,1,&inputCallbackStruct); //1 => input du mixer  0 => sortie
    if(err!=noErr){NSLog(@"Error NodeInputCallBack");}
    
    AUGraphConnectNodeInput(myGraph, mixerNode, 0, ioNode, 0);
    
    //Permet l'affichage du graph dans la console pour check son état
    CAShow (myGraph);
    
    err = AUGraphInitialize (myGraph);
    if(err!=noErr){NSLog(@"Error AUGraphInitialize");}
    
    return 0;
}

-(int)startAudioUnit
{
    /*
    NSLog(@"Démarrage de l'écoute");
    if(AudioUnitInitialize(audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioOutputUnitStart(audioUnit) != noErr) {
        return 1;
    }
    */
    
    compteur=0;
    NSLog(@"Démarrage du graph, compteur : %d",compteur);
    OSStatus status = AUGraphStart(myGraph);
    if (status)
        NSLog(@"AUGraphStart Error");
    
    return 0;
}


-(int)stopProcessingAudio
{
    NSLog(@"Arret de l'écoute");
    
    
    Boolean isRunning = false;
    NSLog(@"Arret du graph, compteur : %d",compteur);
    OSStatus status = AUGraphIsRunning(myGraph, &isRunning);
    if (isRunning)
        status = AUGraphStop(myGraph);
    if (status)
        NSLog(@"AUGraphStop Error");
    
    
    
    /*
    if(AudioOutputUnitStop(audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioUnitUninitialize(audioUnit) != noErr) {
        return 1;
    }
    
    audioUnit = NULL;
    */
     return 0;
}


@end
