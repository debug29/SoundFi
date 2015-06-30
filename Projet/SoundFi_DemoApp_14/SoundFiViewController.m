//
//  SoundFiViewController.m
//  SoundFi DemoApp
//
//  Created by Evernet on 02/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "SoundFiViewController.h"
#import <POP/POP.h>
#import "MyDisKSlideController.h"
#import "UIColor+CustomColors.h"
#import "JCRBlurView.h"
#import "NotifViewController.h"
#import "FlatButton.h"

@interface SoundFiViewController ()
@property(nonatomic) UIControl *dragView;
@property (nonatomic) FlatButton *param;
@end

@implementation SoundFiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate->soundEngine.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        notif = [NSMutableArray arrayWithArray:[prefs objectForKey:@"NotifArray"]];
        NSLog(@"%@", notif);
        if (![notif count])
            [notif addObject:@"0x0001"];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.view.tag = 0;
    appDelegate->soundEngine.delegate = self;
    today = [NSDate date];
    if (self.dragView == nil)
        [self addDragView];
    [UIView animateWithDuration:1.4 animations:^{
        self.waveformView.alpha = 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.dragView.alpha = 1.;
        } completion:nil];
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIImageView *logoNav = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_nav.png"]];
    self.navigationItem.titleView = logoNav;
    menuButton = [PaperButton button];
    menuButton.tag = 24;
    [menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    menuButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.param = [FlatButton button];
    self.param.backgroundColor = [UIColor clearColor];
    self.param.frame = CGRectMake(0, 0, 20, 20);
    [self.param setBackgroundImage:[UIImage imageNamed:@"paramBut.png"] forState:UIControlStateNormal];
    [self.param setBackgroundImage:[UIImage imageNamed:@"paramBut.png"] forState:UIControlStateHighlighted];
    [self.param addTarget:self action:@selector(pushParam:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *paramBut = [[UIBarButtonItem alloc] initWithCustomView:self.param];
    
    [paramBut.customView addConstraint:[NSLayoutConstraint constraintWithItem:self.param attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:paramBut.customView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [paramBut.customView addConstraint:[NSLayoutConstraint constraintWithItem:self.param attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:paramBut.customView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    
    self.navigationItem.rightBarButtonItem = paramBut;
    
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
    
    // Do any additional setup after loading the view.
}

// Load Parameters

- (void)pushParam:(id)sender {
    [self.navigationController pushViewController:[[ParamViewController alloc] init] animated:YES];
}

// Open Left Menu

- (void)openMenu:(id)sender {
    menuButton.tag = 42;
    [(MyDisKSlideController*)self.navigationController.parentViewController openMenuAnimated:YES completion:nil];
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
    if (theMessage.length > 6) {
        if ([theMessage hasPrefix:@"Note:"]) {
            theMessage = [theMessage substringFromIndex:5];
            notifIncomming = theMessage;
            [notif addObject:theMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.4 animations:^{ self.dragView.alpha = 0; } completion:^(BOOL finished) {
                    [self addDragView];
                    [UIView animateWithDuration:0.4 animations:^{
                        self.dragView.alpha = 1.;
                    } completion:nil];
                }];    });
    }
}
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

// Test POP

- (void)pop_animationDidApply:(POPDecayAnimation *)anim {
    CGPoint currentVelocity = [[anim valueForKeyPath:@"velocity"] CGPointValue];
    CGPoint velocity = CGPointMake(currentVelocity.x, -currentVelocity.y);
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
    positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.centerX, self.view.centerY + 180)];
    [self.dragView.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
}

#pragma mark - Private Instance methods

- (void)addDragView
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];
    
    self.dragView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 292.5, 177.5)];
    self.dragView.centerY = self.view.centerY + 180;
    self.dragView.centerX = self.view.centerX;
    if ([notif count] == 1 && [[notif objectAtIndex:0] isEqualToString:@"0x0001"]) {
        UIImageView *noNotifIcone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noNotifIcone.png"]];
        noNotifIcone.x = 8;
        noNotifIcone.y = 8;
        [self.dragView addSubview:noNotifIcone];
        UILabel *noNotifLabel = [[UILabel alloc] initWithFrame:CGRectMake(13 + 36.5, 0, 292.5 - 49.5, 40)];
        noNotifLabel.text = @"Rien de nouveau";
        noNotifLabel.centerY = noNotifIcone.centerY - 10;
        noNotifLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        noNotifLabel.textColor = [UIColor colorWithRed:(234./255.) green:(115./255.) blue:(17./255.) alpha:1.];
        [self.dragView addSubview:noNotifLabel];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        NSDateFormatter *hoursFormat = [[NSDateFormatter alloc]init];
        NSDateFormatter *minutesFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        [hoursFormat setDateFormat:@"HH"];
        [minutesFormat setDateFormat:@"mm"];
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(13 + 37.5, 0, 292.5 - 49.5, 40)];
        dateLabel.text = [NSString stringWithFormat:@"le %@ à %@h%@",[dateFormat stringFromDate:today], [hoursFormat stringFromDate:today], [minutesFormat stringFromDate:today]];
        dateLabel.centerY = noNotifIcone.centerY + 7;
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        [self.dragView addSubview:dateLabel];
        
        UIImageView *sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
        sep.centerX = 292.5 / 2.;
        sep.y = noNotifIcone.y + noNotifIcone.height + 5;
        [self.dragView addSubview:sep];
        
        UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(5, sep.y + 10, 292.5 - 10, 177.5 - (sep.y + 10))];
        content.textColor = [UIColor whiteColor];
        content.textAlignment = NSTextAlignmentCenter;
        content.font = [UIFont fontWithName:@"HelveticaNeue" size:(36. / 2.)];
        content.editable = NO;
        content.userInteractionEnabled = NO;
        content.text = @"Il semblerait que vous n’ayez pas de notifications";
        content.backgroundColor = [UIColor clearColor];
        [self.dragView addSubview:content];
        
        self.dragView.alpha = 0.;
        
    }
    else if (![notifIncomming isEqualToString:@""])
    {
        UIImageView *noNotifIcone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noNotifIcone.png"]];
        noNotifIcone.x = 8;
        noNotifIcone.y = 8;
        [self.dragView addSubview:noNotifIcone];
        UILabel *noNotifLabel = [[UILabel alloc] initWithFrame:CGRectMake(13 + 36.5, 0, 292.5 - 49.5, 40)];
        noNotifLabel.text = @"New notification !";
        noNotifLabel.centerY = noNotifIcone.centerY - 10;
        noNotifLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        noNotifLabel.textColor = [UIColor colorWithRed:(234./255.) green:(115./255.) blue:(17./255.) alpha:1.];
        [self.dragView addSubview:noNotifLabel];
        today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        NSDateFormatter *hoursFormat = [[NSDateFormatter alloc]init];
        NSDateFormatter *minutesFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        [hoursFormat setDateFormat:@"HH"];
        [minutesFormat setDateFormat:@"mm"];
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(13 + 37.5, 0, 292.5 - 49.5, 40)];
        dateLabel.text = [NSString stringWithFormat:@"le %@ à %@h%@",[dateFormat stringFromDate:today], [hoursFormat stringFromDate:today], [minutesFormat stringFromDate:today]];
        dateLabel.centerY = noNotifIcone.centerY + 7;
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        [self.dragView addSubview:dateLabel];
        
        UIImageView *sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
        sep.centerX = 292.5 / 2.;
        sep.y = noNotifIcone.y + noNotifIcone.height + 5;
        [self.dragView addSubview:sep];
        
        UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(5, sep.y + 10, 292.5 - 10, 177.5 - (sep.y + 10))];
        content.textColor = [UIColor whiteColor];
        content.textAlignment = NSTextAlignmentCenter;
        content.font = [UIFont fontWithName:@"HelveticaNeue" size:(36. / 2.)];
        content.editable = NO;
        content.userInteractionEnabled = NO;
        content.text = notifIncomming;
        content.backgroundColor = [UIColor clearColor];
        [self.dragView addSubview:content];
        
        self.dragView.alpha = 0.;
    }
    self.dragView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    [self.dragView addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.dragView addGestureRecognizer:recognizer];
    
    [self.view addSubview:self.dragView];
}

- (void)touchDown:(UIControl *)sender {
    [sender.layer pop_removeAllAnimations];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    self.dragView.center = CGPointMake(recognizer.view.center.x,
                                       recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Yolo");
        CGPoint velocity = [recognizer velocityInView:self.view];
        NSLog(@"%@", NSStringFromCGPoint(velocity));
        POPDecayAnimation *positionAnimation = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation.delegate = self;
        positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
        [recognizer.view.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
    }
}


// Autorotation and other methode

- (BOOL)shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }
- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end
