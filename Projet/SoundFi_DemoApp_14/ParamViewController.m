//
//  ParamViewController.m
//  SoundFi DemoApp
//
//  Created by Evernet on 06/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ParamViewController.h"
#import <SevenSwitch.h>

@interface ParamViewController ()

@end

@implementation ParamViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate->soundEngine.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.view.tag = 1;
    appDelegate->soundEngine.delegate = self;
    [UIView animateWithDuration:1.4 animations:^{
        self.waveformView.alpha = 0.6;
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.title = @"Paramètres";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fond.png"]];
    bg.contentMode = UIViewContentModeScaleToFill;
    bg.frame = CGRectMake(-1, -1, self.view.width + 2, self.view.height + 2);
    [self.view addSubview:bg];
    
    // Wave view
    
    self.waveformView = [[Wave alloc] initWithFrame:self.view.bounds];
    self.waveformView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.waveformView];
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.waveformView setWaveColor:[UIColor whiteColor]];
    [self.waveformView setNumberOfWaves:4];
    [self.waveformView setPrimaryWaveLineWidth:5.0f];
    [self.waveformView setSecondaryWaveLineWidth:2.5];
    self.waveformView.alpha = 0.0;
    
    // Items View
    SevenSwitch *listenOnOff = [[SevenSwitch alloc] initWithFrame:CGRectMake(self.view.width - 65, 100, 50, 30)];
    listenOnOff.activeColor = [UIColor colorWithRed:(234./255.) green:(115./255.) blue:(17./255.) alpha:1.];
    listenOnOff.onTintColor = [UIColor colorWithRed:(234./255.) green:(115./255.) blue:(17./255.) alpha:1.];
    [listenOnOff addTarget:appDelegate->soundEngine action:@selector(switchBackgroundChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:listenOnOff];
    
    UILabel *bglistenLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 65, 30)];
    bglistenLabel.x = 15;
    bglistenLabel.centerY = listenOnOff.centerY;
    bglistenLabel.text = @"Listen in background";
    bglistenLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:bglistenLabel];
    
    // Do any additional setup after loading the view.
}

// SoundEngine Delegate

- (void)appWillEnterForegroundNotification { appDelegate->soundEngine.delegate = self; }

- (void)updateMeters
{
    CGFloat normalizedValue = pow (10, [self.recorder averagePowerForChannel:0] / 30);
    if(appDelegate->soundEngine == nil)
        normalizedValue=0.1;
    else {
        if (appDelegate->soundEngine->sampleFrequency<17000)
            normalizedValue=0.1;
        else
            normalizedValue=appDelegate->soundEngine->sampleFrequency*0.00002;
    }
    [self.waveformView updateWithLevel:normalizedValue];
}

- (void)messageReceived:(NSString *)theMessage :(int)quality {
    NSLog(@"Received Message : %@", theMessage);
}

- (void)progressStatut:(float)percent { NSLog(@"yoplai"); }
- (void)finishEmission { }
- (void)soundToLow { }
- (void)startingReception {
    dispatch_async(dispatch_get_main_queue(), ^{
        notifierView = [[FDStatusBarNotifierView alloc] initWithMessage:@"Receiving Message..."];
        notifierView.timeOnScreen = 3.0; // by default it's 2 seconds
        [notifierView showInWindow:self.view.window];
    });
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
