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
NSString* decodeInit(){return @"init:";}
NSString* decodeStop(){return @":stop";}

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

//Get sample here
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
    
    //Get the frequency from the sample
    status=fftGetFrequency ( userData, numFrames, buffer);
    
    //Test the frequency and start the transaction if init signal
    //is receive, end with a stop signal
    if (THIS->sampleFrequency>17990 && THIS->sampleFrequency<20026) {
        NSString *res=THIS->tableauDecodage[(THIS->sampleFrequency-17990)/21]();
        NSLog(@" Freq : %d  diff: %d value:%@ ",THIS->sampleFrequency,(THIS->sampleFrequency-17990),res);
        
        compteur=0;
        
        //Stop the transaction
        if ([res isEqualToString:@":stop"])
        {
            NSLog(@"Ending transaction");
            THIS->isInitiate=FALSE;
            THIS->isTimeOut=FALSE;
            [THIS stopProcessingAudio];
        }
        
        //If init add the char to the string message
        if (THIS->isInitiate)
        {
            [THIS->messageReceive appendString:res];
        }
        
        //Init the transaction
        if ([res isEqualToString:@"init:"])
        {
            NSLog(@"Starting Transaction");
            THIS->isInitiate=TRUE;
            THIS->isTimeOut=TRUE;
        }
    }
    
    
    buffers->mBuffers[0].mData=THIS->emptySample;
    
    //Deal with timeout, if transaction is init
    //it nothing is coming, stop the process
    if (THIS->isTimeOut && compteur>1000) {
        THIS->isInitiate=FALSE;
        [THIS stopProcessingAudio];
    }
    
    THIS->compteur=compteur+1;
    
    return noErr;
}

@implementation AudioController


//Init the pointer function tab
//each index represent à function for a char
-(void)initDecodeur
{
    tableauDecodage=malloc(97*sizeof(void*));
    
    tableauDecodage[0]=decode32;
    tableauDecodage[1]=decode33;
    tableauDecodage[2]=decode34;
    tableauDecodage[3]=decode35;
    tableauDecodage[4]=decode36;
    tableauDecodage[5]=decode37;
    tableauDecodage[6]=decode38;
    tableauDecodage[7]=decode39;
    tableauDecodage[8]=decode40;
    tableauDecodage[9]=decode41;
    tableauDecodage[10]=decode42;
    tableauDecodage[11]=decode43;
    tableauDecodage[12]=decode44;
    tableauDecodage[13]=decode45;
    tableauDecodage[14]=decode46;
    tableauDecodage[15]=decode47;
    tableauDecodage[16]=decode48;
    tableauDecodage[17]=decode49;
    tableauDecodage[18]=decode50;
    tableauDecodage[19]=decode51;
    tableauDecodage[20]=decode52;
    tableauDecodage[21]=decode53;
    tableauDecodage[22]=decode54;
    tableauDecodage[23]=decode55;
    tableauDecodage[24]=decode56;
    tableauDecodage[25]=decode57;
    tableauDecodage[26]=decode58;
    tableauDecodage[27]=decode59;
    tableauDecodage[28]=decode60;
    tableauDecodage[29]=decode61;
    tableauDecodage[30]=decode62;
    tableauDecodage[31]=decode63;
    tableauDecodage[32]=decode64;
    tableauDecodage[33]=decode65;
    tableauDecodage[34]=decode66;
    tableauDecodage[35]=decode67;
    tableauDecodage[36]=decode68;
    tableauDecodage[37]=decode69;
    tableauDecodage[38]=decode70;
    tableauDecodage[39]=decode71;
    tableauDecodage[40]=decode72;
    tableauDecodage[41]=decode73;
    tableauDecodage[42]=decode74;
    tableauDecodage[43]=decode75;
    tableauDecodage[44]=decode76;
    tableauDecodage[45]=decode77;
    tableauDecodage[46]=decode78;
    tableauDecodage[47]=decode79;
    tableauDecodage[48]=decode80;
    tableauDecodage[49]=decode81;
    tableauDecodage[50]=decode82;
    tableauDecodage[51]=decode83;
    tableauDecodage[52]=decode84;
    tableauDecodage[53]=decode85;
    tableauDecodage[54]=decode86;
    tableauDecodage[55]=decode87;
    tableauDecodage[56]=decode88;
    tableauDecodage[57]=decode89;
    tableauDecodage[58]=decode90;
    tableauDecodage[59]=decode91;
    tableauDecodage[60]=decode92;
    tableauDecodage[61]=decode93;
    tableauDecodage[62]=decode94;
    tableauDecodage[63]=decode95;
    tableauDecodage[64]=decode96;
    tableauDecodage[65]=decode97;
    tableauDecodage[66]=decode98;
    tableauDecodage[67]=decode99;
    tableauDecodage[68]=decode100;
    tableauDecodage[69]=decode101;
    tableauDecodage[70]=decode102;
    tableauDecodage[71]=decode103;
    tableauDecodage[72]=decode104;
    tableauDecodage[73]=decode105;
    tableauDecodage[74]=decode106;
    tableauDecodage[75]=decode107;
    tableauDecodage[76]=decode108;
    tableauDecodage[77]=decode109;
    tableauDecodage[78]=decode110;
    tableauDecodage[79]=decode111;
    tableauDecodage[80]=decode112;
    tableauDecodage[81]=decode113;
    tableauDecodage[82]=decode114;
    tableauDecodage[83]=decode115;
    tableauDecodage[84]=decode116;
    tableauDecodage[85]=decode117;
    tableauDecodage[86]=decode118;
    tableauDecodage[87]=decode119;
    tableauDecodage[88]=decode120;
    tableauDecodage[89]=decode121;
    tableauDecodage[90]=decode122;
    tableauDecodage[91]=decode123;
    tableauDecodage[92]=decode124;
    tableauDecodage[93]=decode125;
    tableauDecodage[94]=decode126;
    tableauDecodage[95]=decodeInit;
    tableauDecodage[96]=decodeStop;

}

//Set up some variable for the renderCallback
-(void)setupCallback
{
    [self initDecodeur];
    
    isInitiate=FALSE;
    isTimeOut=FALSE;
    
    emptySample=malloc(512*sizeof(AudioUnitSampleType));
    for (int i=0; i<512; i++) {
        emptySample[i]=0;
    }
    
    samplesBuffer=(SInt16*)malloc(512 *sizeof(float));
}

//Set up variable and tabs for the fft
-(void)fftSetup
{
    
    outputBuffer = (float*)malloc(512 *sizeof(float));
	analysisBuffer = (float*)malloc(512 *sizeof(float));
    
    fftLog2n = log2f(512);
	micFxControl = 0.5f;
    
    fftSetup = vDSP_create_fftsetup(fftLog2n, FFT_RADIX2);
    
}


//Init the parameters of the audioSession
-(int)initAudioSession
{
    NSLog(@"Initialisation de la session audio");
    sampleRate=44100.0;
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord error: &audioSessionError];
    
    
    [mySession setPreferredSampleRate: 44100.0 error: &audioSessionError];
    
    [mySession setPreferredIOBufferDuration: (512.0/sampleRate) error: &audioSessionError];
    
    [mySession setActive:YES error:nil];
    
    return 0;
}



//Set all the parameters of stream
//including IO and mixer
//Set the graph
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
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(UInt32), &overrideCategory);
    
    ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    /*                                  ASBD configuration                                          */
     ///////////// ///////////// ///////////// ///////////// ///////////// ///////////// /////////////
    AudioComponentDescription ioComponentDescription;
    ioComponentDescription.componentType = kAudioUnitType_Output;
    ioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    ioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioComponentDescription.componentFlags = 0;
    ioComponentDescription.componentFlagsMask = 0;
    
    //ASBD for mono record
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
    
    //Mixer component description configuration
    AudioComponentDescription mixerComponentDescription;
    mixerComponentDescription.componentType = kAudioUnitType_Mixer;
    mixerComponentDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixerComponentDescription.componentFlags = 0;
    mixerComponentDescription.componentFlagsMask = 0;
    

    //Add node to the graph
    err=AUGraphAddNode(myGraph, &ioComponentDescription, &ioNode);
    if (err!=noErr) {NSLog(@"Error AUGraphAddNode1");}
    err=AUGraphAddNode(myGraph, &mixerComponentDescription, &mixerNode);
    if (err!=noErr) {NSLog(@"Error AUGraphAddNode2");}
    
    
    //Open Graph
    err=AUGraphOpen (myGraph);
    if (err!=noErr) {NSLog(@"Error AUGraphOpen");}
    
    //Get the AudioUnit from node
    AUGraphNodeInfo (myGraph,ioNode,NULL,&audioUnit);
    if (err!=noErr) {NSLog(@"Error AUGraphNodeInfo1");}
    AUGraphNodeInfo (myGraph,mixerNode,NULL,&mixerUnit);
    if (err!=noErr) {NSLog(@"Error AUGraphNodeInfo2");}
    
    /////////////////////////////////
    //  Audio unit configuration   //
	/////////////////////////////////
    // Enable input for the I/O unit, which is disabled by default.
    //Bus 1 = input , Bus 0 = output générally speaking
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
    //  Mixer configuration         //
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
    
    //Activitate input bus 1, done here but if we increase the number
    // of output, this must be done with the UI
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
    //Set the monoStream format
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_StreamFormat,
                          kAudioUnitScope_Input,
                          1,
                          &streamDescription,
                          sizeof (streamDescription)
                          );
    
    //Set the sample rate
    AudioUnitSetProperty (
                          mixerUnit,
                          kAudioUnitProperty_SampleRate,
                          kAudioUnitScope_Output,
                          0,
                          &sampleRate,
                          sizeof (sampleRate)
                          );
    
    
    //Use a call back in the input bus 1 of the mixer to get the mic
    AURenderCallbackStruct inputCallbackStruct;
	
    inputCallbackStruct.inputProc        = renderCallback;
    inputCallbackStruct.inputProcRefCon  = (__bridge void *)(self);
	
    err = AUGraphSetNodeInputCallback (myGraph,mixerNode,1,&inputCallbackStruct); //1 => input du mixer  0 => sortie
    if(err!=noErr){NSLog(@"Error NodeInputCallBack");}
    
    //  connect the output of the mixer with the output of the IOunit
    // This is mandatory, else the mixer won't need any sample
    // and your callback won't be call.
    AUGraphConnectNodeInput(myGraph, mixerNode, 0, ioNode, 0);
    
    // For display information of the graph (very usefull to debug)
    CAShow (myGraph);
    
    //When everything is configurate you can initialize the graph
    err = AUGraphInitialize (myGraph);
    if(err!=noErr){NSLog(@"Error AUGraphInitialize");}
    
    return 0;
}

//Comparison for the analysis of the message
-(NSString*)analysisCompare:(NSString*)un : (NSString*)deux : (NSString*)trois
{
    if ([un isEqualToString:deux])
    {
        return un;
    }
    else if ([un isEqualToString:trois])
    {
        return un;
    }
    else if ([deux isEqualToString:trois])
    {
        return deux;
    }
    
    return @"";
}


//Analysis of the message receive during the transaction
//including errors treatment and some other things soon .....
-(void)startAnalysis
{
    NSArray *component;
    NSMutableString *chaineFinale=[[NSMutableString alloc]init];
    
    NSLog(@"%@",messageReceive);
    
    
    //Remove the init and stop message
    component=[messageReceive componentsSeparatedByString:@"init:"];
    component=[component[[component count]-1] componentsSeparatedByString:@":stop"];
    messageReceive=component[0];
    
    
    //Deals with the repeatition of caractère using a FEC like
    for (int i=0; i<[messageReceive length]-2; i=i+3) {
        NSString *un=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i]];
        NSString *deux=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i+1]];
        NSString *trois=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:i+2]];
        
        NSLog(@"%@ %@ %@",un,deux,trois);

        [chaineFinale appendString: [self analysisCompare:un:deux:trois]];
        
    }
    
    //FEC like end in case where the message is not a x3
    if ([messageReceive length]%2==1) {
        NSString *un=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:[messageReceive length]-2]];
        NSString *deux=[NSString stringWithFormat:@"%c",[messageReceive characterAtIndex:[messageReceive length]-1]];
        if ([un isEqualToString:deux])
            [chaineFinale appendString:un];
    }
    
    
    NSLog(@"Resultat : %@",chaineFinale);
}

// Start the Graph
-(int)startAudioUnit
{
    compteur=0;
    messageReceive = [[NSMutableString alloc]init];
    
    NSLog(@"Démarrage du graph, compteur : %d",compteur);
    OSStatus status = AUGraphStart(myGraph);
    if (status)
        NSLog(@"AUGraphStart Error");
    
    return 0;
}

// Stop the Graph
-(int)stopProcessingAudio
{
    Boolean isRunning = false;
    NSLog(@"Arret du graph, compteur : %d",compteur);
    OSStatus status = AUGraphIsRunning(myGraph, &isRunning);
    if (isRunning)
        status = AUGraphStop(myGraph);
    if (status)
        NSLog(@"AUGraphStop Error");
    
    
    if ([messageReceive length]!=0) {
        [self startAnalysis];
    }

    return 0;
    
    

}


@end
