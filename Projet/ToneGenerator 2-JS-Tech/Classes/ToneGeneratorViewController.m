//
//  ToneGeneratorViewController.m
//  ToneGenerator
//
//  Created by Matt Gallagher on 2010/10/20.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "ToneGeneratorViewController.h"
#import <AudioToolbox/AudioToolbox.h>

OSStatus RenderTone(
	void *inRefCon, 
	AudioUnitRenderActionFlags 	*ioActionFlags, 
	const AudioTimeStamp 		*inTimeStamp, 
	UInt32 						inBusNumber, 
	UInt32 						inNumberFrames, 
	AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 0.6;

	// Get the tone parameters out of the view controller
	ToneGeneratorViewController *viewController =
		(ToneGeneratorViewController *)inRefCon;
	double theta = viewController->theta;
	double theta_increment = 2.0 * M_PI * viewController->frequency / viewController->sampleRate;

	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	viewController->theta = theta;

	return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	ToneGeneratorViewController *viewController =
		(ToneGeneratorViewController *)inClientData;
	
	[viewController stop];
}

@implementation ToneGeneratorViewController

@synthesize frequencySlider;
@synthesize playButton;
@synthesize frequencyLabel;

- (IBAction)aInit:(id)sender {
    frequency=20026;
    [self togglePlay:nil];
    [self performSelector:@selector(togglePlay:) withObject:nil afterDelay:0.5];
    NSLog(@"France");
}
- (IBAction)aStop:(id)sender {
    frequency=20069;
    [self togglePlay:nil];
    [self performSelector:@selector(togglePlay:) withObject:nil afterDelay:0.5];
    NSLog(@"Allemagne");
}
- (IBAction)a1:(id)sender {
    frequency=20112;
    [self togglePlay:nil];
    [self performSelector:@selector(togglePlay:) withObject:nil afterDelay:0.5];
    NSLog(@"Italie");
}
- (IBAction)a2:(id)sender {
    frequency=20155;
    [self togglePlay:nil];
    [self performSelector:@selector(togglePlay:) withObject:nil afterDelay:0.5];
    NSLog(@"Espagne");
}
- (IBAction)a3:(id)sender {
    frequency=20198;
    [self togglePlay:nil];
    [self performSelector:@selector(togglePlay:) withObject:nil afterDelay:0.5];
    NSLog(@"Angleterre");
}
- (IBAction)a4:(id)sender {
    frequency=20241;//Salle de bain
    [self togglePlay:nil];
    [self performSelector:@selector(togglePlay:) withObject:nil afterDelay:0.5];
    NSLog(@"YOLOOOOOOOO");
}
- (IBAction)a5:(id)sender {
    frequency=20284;//Cuisine
}
- (IBAction)a6:(id)sender {
    frequency=20327;
}
- (IBAction)a7:(id)sender {
    frequency=20600;
}
- (IBAction)a8:(id)sender {
    frequency=20700;
}
- (IBAction)a9:(id)sender {
    frequency=20800;
}
- (IBAction)aA:(id)sender {
    frequency=18294;
}
- (IBAction)aB:(id)sender {
    frequency=18312;
}
- (IBAction)aR:(id)sender {
    //frequency=18600;
    //frequency=19420;
}
- (IBAction)aT:(id)sender {
    frequency=18736;
}
- (IBAction)aU:(id)sender {
    frequency=18754;
}
- (IBAction)aL:(id)sender {
    frequency=18150;   // recetpeur simu
    //frequency=18450;
}
- (IBAction)aN:(id)sender {
    frequency=18528;
}

- (IBAction)sliderChanged:(UISlider *)slider
{
	frequency = slider.value;
	frequencyLabel.text = [NSString stringWithFormat:@"%4.1f Hz", frequency];
}

- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert1(toneUnit, @"Error creating unit: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = self;
	err = AudioUnitSetProperty(toneUnit, 
		kAudioUnitProperty_SetRenderCallback, 
		kAudioUnitScope_Input,
		0, 
		&input, 
		sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
		kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;	
	streamFormat.mBytesPerFrame = four_bytes_per_float;		
	streamFormat.mChannelsPerFrame = 1;	
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
		kAudioUnitProperty_StreamFormat,
		kAudioUnitScope_Input,
		0,
		&streamFormat,
		sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %ld", err);
}

- (IBAction)togglePlay:(UIButton *)selectedButton
{
	if (toneUnit)
	{
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
		
		[selectedButton setTitle:NSLocalizedString(@"Play", nil) forState:0];
	}
	else
	{
		[self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(toneUnit);
		NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
		
		// Start playback
		err = AudioOutputUnitStart(toneUnit);
		NSAssert1(err == noErr, @"Error starting unit: %ld", err);
		
		[selectedButton setTitle:NSLocalizedString(@"Stop", nil) forState:0];
	}
}

- (void)stop
{
	if (toneUnit)
	{
		[self togglePlay:playButton];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self sliderChanged:frequencySlider];
	sampleRate = 44100;

	OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, self);
	if (result == kAudioSessionNoError)
	{
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	}
    //[[AVAudioSession sharedInstance] setPreferredIOBufferDuration: ((float)1024/sampleRate) error: nil]; //Number of sample must depend of the mode WALE 1024

	AudioSessionSetActive(true);
}

- (void)viewDidUnload {
	self.frequencyLabel = nil;
	self.playButton = nil;
	self.frequencySlider = nil;

	AudioSessionSetActive(false);
}


- (void)dealloc {
    [_init release];
    [_bStop release];
    [_b1 release];
    [_b2 release];
    [_b3 release];
    [_b4 release];
    [_b5 release];
    [_b6 release];
    [_b7 release];
    [_b8 release];
    [_b9 release];
    [_bA release];
    [_bB release];
    [_bR release];
    [_bT release];
    [_bU release];
    [_bL release];
    [_bN release];
    [_bStop release];
    [super dealloc];
}
@end
