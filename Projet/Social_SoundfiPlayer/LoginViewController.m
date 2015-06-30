//
//  LoginViewController.m
//  Social_SoundfiPlayer
//
//  Created by Evernet on 06/08/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBG.png"]];
    bg.size = CGSizeMake(350, 621);
    bg.contentMode = UIViewContentModeScaleToFill;
    bg.center = self.view.center;
    bg.iOS6ParallaxIntensity = -15.;
    [self.view addSubview:bg];
    
    
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSError *error;
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
    
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.waveformView = [[Wave alloc] initWithFrame:CGRectMake(0, self.view.height - 180, 320, 250)];
    //    self.waveformView.frame = self.view.bounds;
    self.waveformView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.waveformView];
    
    [self.waveformView setWaveColor:[UIColor whiteColor]];
    [self.waveformView setNumberOfWaves:4];
    [self.waveformView setPrimaryWaveLineWidth:3.0f];
    [self.waveformView setSecondaryWaveLineWidth:1.0f];
    self.waveformView.alpha = 0.60;
    
    UIView *blurView = [[UIView alloc] initWithFrame:CGRectMake((320 - 250) / 2., 100, 250, 50)];
    blurView.iOS6ParallaxIntensity = 5.;
    UIBlurEffect *visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:visualEffect];
    
    // Setting frame of our new view using superview bounds
    visualEffectView.frame = blurView.bounds;
    
    // Sending blurred view to back because we want to use it as background of our view
    [blurView addSubview:visualEffectView];
    [blurView sendSubviewToBack:visualEffectView];
    
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = blurView.bounds;
    
    maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"logoSoundfi.png"] CGImage];
    
    // Apply the mask to your uiview layer
    blurView.layer.mask = maskLayer;
    [self.view addSubview:blurView];
    
    UIView *soundCloudLogo = [[UIView alloc] initWithFrame:CGRectMake((320 - 230) / 2., 260, 230, 145)];
    soundCloudLogo.iOS6ParallaxIntensity = 5.;
    UIBlurEffect *visualEffectLogo = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *visualEffectViewLogo = [[UIVisualEffectView alloc] initWithEffect:visualEffectLogo];
    
    // Setting frame of our new view using superview bounds
    visualEffectViewLogo.frame = soundCloudLogo.bounds;
    
    // Sending blurred view to back because we want to use it as background of our view
    [soundCloudLogo addSubview:visualEffectViewLogo];
    [soundCloudLogo sendSubviewToBack:visualEffectViewLogo];
    
    CALayer* maskLayerLogo = [CALayer layer];
    maskLayerLogo.frame = soundCloudLogo.bounds;
    
    maskLayerLogo.contents = (__bridge id)[[UIImage imageNamed:@"SCLogo.png"] CGImage];
    
    // Apply the mask to your uiview layer
    soundCloudLogo.layer.mask = maskLayerLogo;
    [self.view addSubview:soundCloudLogo];
    
    CALayer* maskLayerLogoBut = [CALayer layer];
    maskLayerLogoBut.frame = soundCloudLogo.bounds;
    
    maskLayerLogoBut.contents = (__bridge id)[[UIImage imageNamed:@"SCLogo.png"] CGImage];
    
    // Apply the mask to your uiview layer
    
    BFPaperButton *bfFlatSmart = [[BFPaperButton alloc] initFlatWithFrame:soundCloudLogo.frame];
    bfFlatSmart.backgroundColor = [UIColor clearColor];
    [bfFlatSmart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bfFlatSmart setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    bfFlatSmart.layer.mask = maskLayerLogoBut;
    [bfFlatSmart addTarget:self action:@selector(switchToLoginVC:) forControlEvents:UIControlEventTouchUpInside];
    bfFlatSmart.tapCircleColor = [UIColor lightTextColor];
    bfFlatSmart.backgroundFadeColor = [UIColor clearColor];
    
    [self.view addSubview:bfFlatSmart];
    
}

- (void) switchToLoginVC:(id)sender {
//    [self.recorder ]
    InitViewController *init = [[InitViewController alloc] init];
    init.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:init animated:YES completion:^{
        [self removeFromParentViewController];
    }];
}

- (void)updateMeters
{
    [self.recorder updateMeters];
    
    CGFloat normalizedValue = pow (10, [self.recorder averagePowerForChannel:0] / 20);
    
    [self.waveformView updateWithLevel:normalizedValue];
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
