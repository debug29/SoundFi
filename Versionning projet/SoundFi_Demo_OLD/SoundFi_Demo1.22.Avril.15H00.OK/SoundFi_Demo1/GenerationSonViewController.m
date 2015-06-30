//
//  GenerationSonViewController.m
//  SoundFi_Demo1
//
//  Created by François Le Brun on 04/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "GenerationSonViewController.h"
#import <AudioToolbox/AudioToolbox.h>


//////////          getfrequency2
//
//  This switch permit to asign for each caracter of the ASCII table
//  a frequency. Caracter are separate by 21.27Hz
//
//////////
#pragma mark - getfrequency2
float getfrequency2(char c)
{
    int base=18000;
    
    switch (c) {
        case ' ': return base+(((int)c-32)*21.27); break;
        case '!': return base+(((int)c-32)*21.27); break;
        case '"': return base+(((int)c-32)*21.27); break;
        case '#': return base+(((int)c-32)*21.27); break;
        //case '§': return base+(((int)c-32)*21.27); break;         //    § not a caracter :/
        case '%': return base+(((int)c-32)*21.27); break;
        case '&': return base+(((int)c-32)*21.27); break;
        case '\'': return base+(((int)c-32)*21.27); break;
        case '(': return base+(((int)c-32)*21.27); break;
        case ')': return base+(((int)c-32)*21.27); break;
        case '*': return base+(((int)c-32)*21.27); break;
        case '+': return base+(((int)c-32)*21.27); break;
        case ',': return base+(((int)c-32)*21.27); break;
        case '-': return base+(((int)c-32)*21.27); break;
        case '.': return base+(((int)c-32)*21.27); break;
        case '/': return base+(((int)c-32)*21.27); break;
        case '0': return base+(((int)c-32)*21.27); break;
        case '1': return base+(((int)c-32)*21.27); break;
        case '2': return base+(((int)c-32)*21.27); break;
        case '3': return base+(((int)c-32)*21.27); break;
        case '4': return base+(((int)c-32)*21.27); break;
        case '5': return base+(((int)c-32)*21.27); break;
        case '6': return base+(((int)c-32)*21.27); break;
        case '7': return base+(((int)c-32)*21.27); break;
        case '8': return base+(((int)c-32)*21.27); break;
        case '9': return base+(((int)c-32)*21.27); break;
        case ':': return base+(((int)c-32)*21.27); break;
        case ';': return base+(((int)c-32)*21.27); break;
        case '<': return base+(((int)c-32)*21.27); break;
        case '=': return base+(((int)c-32)*21.27); break;
        case '>': return base+(((int)c-32)*21.27); break;
        case '?': return base+(((int)c-32)*21.27); break;
        case '@': return base+(((int)c-32)*21.27); break;
        case 'A': return base+(((int)c-32)*21.27); break;
        case 'B': return base+(((int)c-32)*21.27); break;
        case 'C': return base+(((int)c-32)*21.27); break;
        case 'D': return base+(((int)c-32)*21.27); break;
        case 'E': return base+(((int)c-32)*21.27); break;
        case 'F': return base+(((int)c-32)*21.27); break;
        case 'G': return base+(((int)c-32)*21.27); break;
        case 'H': return base+(((int)c-32)*21.27); break;
        case 'I': return base+(((int)c-32)*21.27); break;
        case 'J': return base+(((int)c-32)*21.27); break;
        case 'K': return base+(((int)c-32)*21.27); break;
        case 'L': return base+(((int)c-32)*21.27); break;
        case 'M': return base+(((int)c-32)*21.27); break;
        case 'N': return base+(((int)c-32)*21.27); break;
        case 'O': return base+(((int)c-32)*21.27); break;
        case 'P': return base+(((int)c-32)*21.27); break;
        case 'Q': return base+(((int)c-32)*21.27); break;
        case 'R': return base+(((int)c-32)*21.27); break;
        case 'S': return base+(((int)c-32)*21.27); break;
        case 'T': return base+(((int)c-32)*21.27); break;
        case 'U': return base+(((int)c-32)*21.27); break;
        case 'V': return base+(((int)c-32)*21.27); break;
        case 'W': return base+(((int)c-32)*21.27); break;
        case 'X': return base+(((int)c-32)*21.27); break;
        case 'Y': return base+(((int)c-32)*21.27); break;
        case 'Z': return base+(((int)c-32)*21.27); break;
        case '[': return base+(((int)c-32)*21.27); break;
        case '\\': return base+(((int)c-32)*21.27); break;
        case ']': return base+(((int)c-32)*21.27); break;
        case '^': return base+(((int)c-32)*21.27); break;
        case '_': return base+(((int)c-32)*21.27); break;
        case '`': return base+(((int)c-32)*21.27); break;
        case 'a': return base+(((int)c-32)*21.27); break;
        case 'b': return base+(((int)c-32)*21.27); break;
        case 'c': return base+(((int)c-32)*21.27); break;
        case 'd': return base+(((int)c-32)*21.27); break;
        case 'e': return base+(((int)c-32)*21.27); break;
        case 'f': return base+(((int)c-32)*21.27); break;
        case 'g': return base+(((int)c-32)*21.27); break;
        case 'h': return base+(((int)c-32)*21.27); break;
        case 'i': return base+(((int)c-32)*21.27); break;
        case 'j': return base+(((int)c-32)*21.27); break;
        case 'k': return base+(((int)c-32)*21.27); break;
        case 'l': return base+(((int)c-32)*21.27); break;
        case 'm': return base+(((int)c-32)*21.27); break;
        case 'n': return base+(((int)c-32)*21.27); break;
        case 'o': return base+(((int)c-32)*21.27); break;
        case 'p': return base+(((int)c-32)*21.27); break;
        case 'q': return base+(((int)c-32)*21.27); break;
        case 'r': return base+(((int)c-32)*21.27); break;
        case 's': return base+(((int)c-32)*21.27); break;
        case 't': return base+(((int)c-32)*21.27); break;
        case 'u': return base+(((int)c-32)*21.27); break;
        case 'v': return base+(((int)c-32)*21.27); break;
        case 'w': return base+(((int)c-32)*21.27); break;
        case 'x': return base+(((int)c-32)*21.27); break;
        case 'y': return base+(((int)c-32)*21.27); break;
        case 'z': return base+(((int)c-32)*21.27); break;
        case '{': return base+(((int)c-32)*21.27); break;
        case '|': return base+(((int)c-32)*21.27); break;
        case '}': return base+(((int)c-32)*21.27); break;
        case '~': return base+(((int)c-32)*21.27); break;
        default: return 0.0; break;
    }
}


///////////                 Render Tone
//
//      This function will be call every time the output needs a new audio sample
//      So we are going to generate a new sample base on the frequency desired
//      to match with the caracter to send
//
///////////
#pragma mark - RenderTone
OSStatus RenderTone(
                    void *inRefCon,                                 // user's data here the GenerationSonViewController
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)            // the buffer for the samples

{
    GenerationSonViewController *viewController =(__bridge GenerationSonViewController *)inRefCon;
    
    if (viewController->compteur<10) {
        viewController->frequence=getfrequency2([viewController->lemessage characterAtIndex:0]);
    }
    else
        viewController->frequence=19900;
    
    
	double theta = viewController->theta;
	double theta_increment = 2.0 * M_PI * viewController->frequence / viewController->ratioEchantillon;     // θ(n) = 2πƒ n / r
    const double amplitude = viewController->amplitude;
    
	Float32 *buffer = (Float32 *)ioData->mBuffers[0].mData;  //Get the buffer (0->mono, 1->stereo)
	
    // Loop génération for the samples
    // f(n) = a sin ( θ(n) )
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
    //Get the new value of theta
	viewController->theta = theta;
    viewController->compteur = viewController->compteur+1;
    
	return noErr;
}

///////////     ToneInterruptionListener
//
//     This function will be call when the audio session is interrupt
//
///////////
#pragma mark - ToneInterruptionListener
void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
    GenerationSonViewController *viewController = (__bridge GenerationSonViewController *)inClientData;
    
    [viewController stop];
}


@implementation GenerationSonViewController
@synthesize Sli_frequence;
@synthesize But_lecture;
@synthesize Lab_frequence;
@synthesize Sli_amplitude;
@synthesize Lab_amplitude;
@synthesize But_send_img;
@synthesize message;
@synthesize But_send_msg;


////////////       creationUniteSon
//
//  This function contain 3 steps
//                  1- Get the audio output component
//                  2- Set the callback to the unit component
//                  3- Configure and assign the ADSB to the unit component
//
////////////
-(void) creationUniteSon
{
    //Configure the description for the output component
	AudioComponentDescription DescComposantSortie;
	DescComposantSortie.componentType = kAudioUnitType_Output;
	DescComposantSortie.componentSubType = kAudioUnitSubType_RemoteIO;
	DescComposantSortie.componentManufacturer = kAudioUnitManufacturer_Apple;
	DescComposantSortie.componentFlags = 0;
	DescComposantSortie.componentFlagsMask = 0;
	
    //Find a component matching with the description
	AudioComponent composantSortie = AudioComponentFindNext(NULL, &DescComposantSortie);
	
    //Assign the instance to the uniteSon
	AudioComponentInstanceNew(composantSortie, &uniteSon);
	
    //Create the callbackStruct and assign it to the RenderTone function
    //inputProcRefCon=self allow us to acces information in the RenderTone function
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void *)(self);
	AudioUnitSetProperty(uniteSon,kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Input,0,&input,sizeof(input)); //Def des propriétés
	

    //ASBD configuration
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = ratioEchantillon;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = 4;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = 4;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = 4 * 8;
    
    //Put the ASBD to the uniteSon
	AudioUnitSetProperty(uniteSon,kAudioUnitProperty_StreamFormat,kAudioUnitScope_Input,0,&streamFormat,sizeof(AudioStreamBasicDescription));
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/////////// lancerLecture
//
//      Launch the play state of the audio unit if inactiv
//      or stop it if it's already launch
//
///////////
-(IBAction)lancerLecture:(UIButton *)bouton
{
    if(uniteSon)
    {
        NSLog(@"Stop");
        AudioOutputUnitStop(uniteSon);
        AudioUnitUninitialize(uniteSon);
        AudioComponentInstanceDispose(uniteSon);
        uniteSon=nil;
        
        [bouton setTitle:@"Play" forState:0];
    }
    else
    {
        NSLog(@"Gogo");
        [self creationUniteSon];
        AudioUnitInitialize(uniteSon);
        AudioOutputUnitStart(uniteSon);
        
        [bouton setTitle:@"Stop" forState:0];
        
    }
}

///////////         stop
//
//  Use in the ToneInterruptionListener function
//
///////////
-(void)stop
{
    if(uniteSon)
        [self lancerLecture:But_lecture];
    
}

//Represent the slider for frequency
-(IBAction)sliderChanged:(UISlider *)slider
{
    frequence=slider.value;
    Lab_frequence.text=[NSString stringWithFormat:@"%4.f Hz",frequence];
}

//Represent the slider for amplitude
-(IBAction)sliderAmpChanged:(UISlider *)slider
{
    amplitude=slider.value;
    Lab_amplitude.text=[NSString stringWithFormat:@"%.2f",amplitude];
}


///////////    sendImage
//
//  This function send an image by transcrypting every caracter
//  to a frequency (each caracter is repeated 30 times)
//
///////////
-(IBAction)sendImage:(UIButton*)bouton
{
    NSString *lemessage;
    
    [self lancerLecture:But_lecture];
    
    UIImage * monImage=[UIImage imageNamed:@"erika_lust.jpg"];
    NSData *image=UIImageJPEGRepresentation(monImage, 0.0);
    lemessage = [NSString stringWithFormat:@"%@",image];
    
    NSLog(@"%d",lemessage.length);
    
    for (int i=0; i<lemessage.length; i++) {
        for (int j=0; j<30; j++) {                          // Repeat each caracter 30 times
            frequence=getfrequency2([lemessage characterAtIndex:i]);
        }
    }
    [self lancerLecture:But_lecture];
}

///////////     sendMessage
//
//  This function send a message by transcrypting every caracter
//  to a frequency (each caracter is repeated 1000000 times)
//
///////////
-(IBAction)sendMessage:(UIButton*)bouton
{
    
    lemessage=message.text;
    [self lancerLecture:But_lecture];
    compteur=0;
    /*
    NSLog(@"Comtpeur : %d",compteur);
        for (int i=0; i<lemessage.length; i++) {
            for (int j=0; j<1000000; j++) {
                frequence=getfrequency2([lemessage characterAtIndex:i]);
            }
        }
    NSLog(@"Comtpeur : %d",compteur);
     */
}


//////////      viewDidLoad
//
//      The important thing here is the initialization of the audio session
//
//////////
#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self sliderChanged:Sli_frequence];
    [self sliderAmpChanged:Sli_amplitude];
    ratioEchantillon=44100;
    compteur=0;
    
    //initialization of the audio session
    OSStatus test = AudioSessionInitialize(NULL, NULL,ToneInterruptionListener, (__bridge void *)(self));
    
    if(test == kAudioSessionNoError)
    {
        //Set the aussion for playback
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    }
    //Set the session active
    AudioSessionSetActive(true);
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
