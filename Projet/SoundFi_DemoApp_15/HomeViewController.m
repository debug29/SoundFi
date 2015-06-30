//
//  HomeViewController.m
//  SoundFi DemoApp
//
//  Created by Florian Coulon on 29/05/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <FDStatusBarNotifierView.h>
#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate->soundEngine.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        isHide = NO;
        isReceivable = YES;
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    appDelegate->soundEngine.delegate = self;
    [self.shineLabel shineWithCompletion:^{
    }];
    [UIView animateWithDuration:1.4 animations:^{
        self.waveformView.alpha = 0.3;
    }];
    [UIView animateWithDuration:0.5 animations:^{ logo.alpha = 1.; cancelBut.alpha = 0.; signinBut.alpha = 0.; registerBut.alpha = 0.; welcomText.alpha = 0.; suscribText.alpha = 0.; passwordField.alpha = 0.; emailField.alpha = 0.; confirmBut.alpha = 0;} completion:^(BOOL finished) { isReceivable = YES; }];
    emailField.text = @"";
    passwordField.text = @"";
    [emailField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [passwordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    isHide = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissElem)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // BG View
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fond.png"]];
    bg.contentMode = UIViewContentModeScaleToFill;
    bg.frame = CGRectMake(-1, -1, self.view.width + 2, self.view.height + 2);
    [self.view addSubview:bg];
    
    // Wave view
    UIView *blackUnderlay = [[UIView alloc] initWithFrame:self.view.bounds];
    blackUnderlay.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.2];
    [self.view addSubview:blackUnderlay];
    
    self.waveformView = [[Wave alloc] initWithFrame:self.view.bounds];
//    self.waveformView.frame = self.view.bounds;
    self.waveformView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.waveformView];
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.waveformView setWaveColor:[UIColor whiteColor]];
    [self.waveformView setNumberOfWaves:4];
    [self.waveformView setPrimaryWaveLineWidth:5.0f];
    [self.waveformView setSecondaryWaveLineWidth:2.5];
    self.waveformView.alpha = 0.0;
    
    // Logo View
    
    logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logo.centerX = self.view.centerX;
    logo.y = 70;
    [self.view addSubview:logo];
    
    welcomText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welcomText.png"]];
    welcomText.centerX = self.view.centerX;
    welcomText.y = 70;
    welcomText.alpha = 0.;
    [self.view addSubview:welcomText];
    
    suscribText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suscribText.png"]];
    suscribText.centerX = self.view.centerX;
    suscribText.y = 70;
    suscribText.alpha = 0.;
    [self.view addSubview:suscribText];
    
    
    signinBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [signinBut setBackgroundImage:[UIImage imageNamed:@"signin.png"] forState:UIControlStateNormal];
    [signinBut addTarget:self action:@selector(signInPress:) forControlEvents:UIControlEventTouchUpInside];
    signinBut.size = CGSizeMake(226.5, 41);
    signinBut.centerX = self.view.centerX;
    signinBut.y = self.view.height - 117.5;
    signinBut.alpha = 0.;
    [self.view addSubview:signinBut];
    
    registerBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerBut setBackgroundImage:[UIImage imageNamed:@"register.png"] forState:UIControlStateNormal];
    [registerBut addTarget:self action:@selector(suscribPress:) forControlEvents:UIControlEventTouchUpInside];
    registerBut.size = CGSizeMake(226.5, 41);
    registerBut.centerX = self.view.centerX;
    registerBut.y = self.view.height - 67.5;
    registerBut.alpha = 0.;
    [self.view addSubview:registerBut];
    
    // Add TextFields
    
    emailField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.width - 226.5) / 2., self.view.centerY - 45, 226.5, 41)];
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.textAlignment = NSTextAlignmentCenter;
    [emailField placeholderRectForBounds:emailField.frame];
    emailField.font = [UIFont fontWithName:@"" size:14.0];
    emailField.textColor = [UIColor whiteColor];
    [emailField setValue:[UIFont fontWithName:@"" size:14.0] forKeyPath:@"_placeholderLabel.font"];
    [emailField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    emailField.leftViewMode = UITextFieldViewModeAlways;
    emailField.keyboardAppearance = UIKeyboardAppearanceDark;
    [emailField setBackground:[UIImage imageNamed:@"textfield.png"]];
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.delegate = self;
    emailField.tag = 0;
    UIColor *emailColor = [UIColor lightTextColor];
    emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName:emailColor}];
    emailField.alpha = 0.;
    [self.view addSubview:emailField];
    
    passwordField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.width - 226.5) / 2., self.view.centerY + 4, 226.5, 41)];
    passwordField.keyboardType = UIKeyboardTypeDefault;
    passwordField.secureTextEntry = YES;
    passwordField.textAlignment = NSTextAlignmentCenter;
    [passwordField placeholderRectForBounds:passwordField.frame];
    passwordField.font = [UIFont fontWithName:@"" size:14.0];
    passwordField.textColor = [UIColor whiteColor];
    [passwordField setValue:[UIFont fontWithName:@"" size:14.0] forKeyPath:@"_placeholderLabel.font"];
    [passwordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    passwordField.leftViewMode = UITextFieldViewModeAlways;
    passwordField.keyboardAppearance = UIKeyboardAppearanceDark;
    UIColor *passwordColor = [UIColor lightTextColor];
    passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:passwordColor}];
    [passwordField setBackground:[UIImage imageNamed:@"textfield.png"]];
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordField.delegate = self;
    passwordField.tag = 1;
    passwordField.alpha = 0.;
    [self.view addSubview:passwordField];
    
    // Cancel
    
    cancelBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBut setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [cancelBut addTarget:self action:@selector(cancelPress:) forControlEvents:UIControlEventTouchUpInside];
    cancelBut.size = CGSizeMake(226.5, 41);
    cancelBut.centerX = self.view.centerX;
    cancelBut.y = self.view.height - 67.5;
    cancelBut.alpha = 0.;
    [self.view addSubview:cancelBut];
    
    confirmBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBut setBackgroundImage:[UIImage imageNamed:@"confirm.png"] forState:UIControlStateNormal];
    [confirmBut addTarget:self action:@selector(confirmPress:) forControlEvents:UIControlEventTouchUpInside];
    confirmBut.size = CGSizeMake(226.5, 41);
    confirmBut.centerX = self.view.centerX;
    confirmBut.y = self.view.height - 67.5;
    confirmBut.alpha = 0.;
    [self.view addSubview:confirmBut];
    
    // Shine Text
    
    self.shineLabel = ({
        RQShineLabel *label = [[RQShineLabel alloc] initWithFrame:CGRectMake(16, 400, 320 - 32, self.view.height - 400)];
        label.numberOfLines = 0;
        label.text = @"Bienvenue sur SoundFi. Cette application est une demo technique de notre technologie.\nTouchez pour effacer ce message.";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        label;
    });
    [self.view addSubview:self.shineLabel];
}

// TextField Delegate

#pragma mark - TextFiledEntry

-(void)dismissElem {
    if (isHide == NO) {
        [self.shineLabel fadeOutWithCompletion:^{
            isHide = YES;
            [UIView animateWithDuration:0.5 animations:^{
                signinBut.alpha = 1.;
                registerBut.alpha = 1.;
            }];
        }];
    }
    [passwordField resignFirstResponder];
    [emailField resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]] && [touch.view tag] != 42) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag] == 0)
        [passwordField becomeFirstResponder];
    else
        [passwordField resignFirstResponder];
    
    return YES;
}

- (void) textFieldDidChange:(id)sender {
    if (![emailField.text isEqualToString:@""] && ![passwordField.text isEqualToString:@""])
        [UIView animateWithDuration:0.5 animations:^{ cancelBut.alpha = 0.; confirmBut.alpha = 1.;}];
    else
        [UIView animateWithDuration:0.5 animations:^{ cancelBut.alpha = 1.; confirmBut.alpha = 0.;}];
}

// Button methode

- (void)signInPress:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{ logo.alpha = 0.; cancelBut.alpha = 1.; signinBut.alpha = 0.; registerBut.alpha = 0.; welcomText.alpha = 1.; passwordField.alpha = 1.; emailField.alpha = 1.;} completion:^(BOOL finished) { isReceivable = NO; }];
}

- (void)suscribPress:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{ logo.alpha = 0.; cancelBut.alpha = 1.; signinBut.alpha = 0.; registerBut.alpha = 0.; suscribText.alpha = 1.;} completion:^(BOOL finished) { isReceivable = NO; }];
}

- (void) cancelPress:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{ logo.alpha = 1.; cancelBut.alpha = 0.; signinBut.alpha = 1.; registerBut.alpha = 1.; welcomText.alpha = 0.; suscribText.alpha = 0.; passwordField.alpha = 0.; emailField.alpha = 0.;} completion:^(BOOL finished) { isReceivable = YES; }];
}

- (void) confirmPress:(id)sender {
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[SoundFiViewController alloc] init]];
    MyDisKSlideController *slideController = [[MyDisKSlideController alloc] initWithMenuController:[[LeftMenuViewController alloc] init] contentController:nav];
    slideController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [emailField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [passwordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self presentViewController:slideController animated:YES completion:^{
        [self removeFromParentViewController];
    }];
    
    NSLog(@"Tentative de signIn with login : %@, password : %@", emailField.text, passwordField.text);
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

- (void)messageReceived:(NSString *)theMessage {
    NSLog(@"Received Message : %@", theMessage);
    if (isReceivable) {
        if (theMessage.length > 6) {
            if ([theMessage hasPrefix:@"Note:"]) {
                theMessage = [theMessage substringFromIndex:5];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.5 delay:0. options:UIViewAnimationOptionAllowAnimatedContent animations:^{ signinBut.alpha = 0.; registerBut.alpha = 0.;} completion:^(BOOL finished) {}];
                });
                if (isHide == NO) {
                    [self.shineLabel fadeOutWithCompletion:^{
                        self.shineLabel.text = theMessage;
                        [self.shineLabel shineWithCompletion:^{
                        }];
                    }];
                }
                else {
                    self.shineLabel.text = theMessage;
                    [self.shineLabel shineWithCompletion:^{ isHide = NO; }];
                }
            }
        }
    }
    else {
        if (theMessage.length > 6) {
            if ([theMessage hasPrefix:@"Note:"]) {
                theMessage = [theMessage substringFromIndex:5];
                dispatch_async(dispatch_get_main_queue(), ^{
                    notifierView = [[FDStatusBarNotifierView alloc] initWithMessage:theMessage];
                    notifierView.timeOnScreen = 3.0; // by default it's 2 seconds
                    [notifierView showInWindow:self.view.window];
                });
            }
        }
    }
}

- (void) localisationData:(NSString*)imgPromo :(NSString*)txtPromo{}
- (void)progressStatut:(float)percent { NSLog(@"yoplai"); }
- (void)finishEmission { }
- (void)soundToLow { }
- (void)startingReception {
    if (isReceivable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            notifierView = [[FDStatusBarNotifierView alloc] initWithMessage:@"Receiving Message..."];
            notifierView.timeOnScreen = 3.0; // by default it's 2 seconds
            [notifierView showInWindow:self.view.window];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            notifierView = [[FDStatusBarNotifierView alloc] initWithMessage:@"Receiving Message..."];
            notifierView.timeOnScreen = 1.0; // by default it's 2 seconds
            [notifierView showInWindow:self.view.window];
        });
    }
}

// Autorotation and other methode

- (BOOL)shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }
- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

@end
