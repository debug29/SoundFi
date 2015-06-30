//
//  LeftMenuViewController.m
//  SoundFi DemoApp
//
//  Created by Evernet on 02/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController

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
    
    // BG View
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BGLeftMenu.png"]];
    bg.contentMode = UIViewContentModeScaleToFill;
    bg.frame = CGRectMake(-1, -1, self.view.width + 2, self.view.height + 2);
    [self.view addSubview:bg];
    
    userThumbnail = [[AsyncImageView alloc] initWithFrame:CGRectMake((240 / 2.) - 50., 60, 100, 100)];
    userThumbnail.imageURL = [[NSURL alloc] initWithString:@"https://media.licdn.com/mpr/mpr/shrink_200_200/p/4/005/062/0d9/000d8b1.jpg"];
    userThumbnail.layer.cornerRadius = 50;
    userThumbnail.clipsToBounds = YES;
    [self.view addSubview:userThumbnail];
    // Do any additional setup after loading the view.
    
    UITextView *username = [[UITextView alloc] initWithFrame:CGRectMake(0, 170, 240, 60)];
    username.backgroundColor = [UIColor clearColor];
    username.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    username.textColor = [UIColor whiteColor];
    username.textAlignment = NSTextAlignmentCenter;
    username.editable = NO;
    username.userInteractionEnabled = NO;
    username.text = @"Florian COULON";
    [username addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [self.view addSubview:username];
    
    dialBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [dialBut setBackgroundImage:[UIImage imageNamed:@"dialBut.png"] forState:UIControlStateNormal];
    [dialBut addTarget:self action:@selector(goDialogue:) forControlEvents:UIControlEventTouchUpInside];
    dialBut.size = CGSizeMake(243.5, 41);
    dialBut.x = (240 / 2.) - (243.5 / 2.);
    dialBut.y = 240;
    [self.view addSubview:dialBut];
    
    notifBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [notifBut setBackgroundImage:[UIImage imageNamed:@"notifBut.png"] forState:UIControlStateNormal];
    [notifBut addTarget:self action:@selector(goNotif:) forControlEvents:UIControlEventTouchUpInside];
    notifBut.size = CGSizeMake(243.5, 41);
    notifBut.x = (240 / 2.) - (243.5 / 2.);
    notifBut.y = 301;
    [self.view addSubview:notifBut];
    
    accountBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [accountBut setBackgroundImage:[UIImage imageNamed:@"accountBut.png"] forState:UIControlStateNormal];
    //    [dialBut addTarget:self action:@selector(cancelPress:) forControlEvents:UIControlEventTouchUpInside];
    accountBut.size = CGSizeMake(243.5, 41);
    accountBut.x = (240 / 2.) - (243.5 / 2.);
    accountBut.y = self.view.height - 82 - 60;
    [self.view addSubview:accountBut];
    
    logoutBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBut setBackgroundImage:[UIImage imageNamed:@"logoutBut.png"] forState:UIControlStateNormal];
    [logoutBut addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
    logoutBut.size = CGSizeMake(243.5, 41);
    logoutBut.x = (240 / 2.) - (243.5 / 2.);
    logoutBut.y = self.view.height - 41 - 40;
    [self.view addSubview:logoutBut];
}

- (void) logOut:(id)sender {
    [(MyDisKSlideController*)self.parentViewController closeMenuAnimated:YES completion:^(BOOL finished) {
        HomeViewController *home = [[HomeViewController alloc] init];
        
        home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.parentViewController presentViewController:home animated:YES completion:^{
            [self.parentViewController removeFromParentViewController];
        }];
    }];
}

- (void) goNotif:(id)sender {
    [(MyDisKSlideController*)self.parentViewController closeMenuAnimated:YES completion:^(BOOL finished) {
        NotifViewController *notif = [[NotifViewController alloc] init];
        MyDisKSlideController *slide = (MyDisKSlideController*)self.parentViewController;
        NSLog(@"%@", [slide.contentViewController class]);
        NSLog(@"%ld", (long)slide.contentViewController.view.tag);
        
        if (slide.contentViewController.view.tag == 0)
            [(UINavigationController*)slide.contentViewController pushViewController:notif animated:YES];
    }];
}

- (void) goDialogue:(id)sender {
    [(MyDisKSlideController*)self.parentViewController closeMenuAnimated:YES completion:^(BOOL finished) {
        DialViewController *dial = [[DialViewController alloc] init];
        MyDisKSlideController *slide = (MyDisKSlideController*)self.parentViewController;
        NSLog(@"%@", [slide.contentViewController class]);
        NSLog(@"%ld", (long)slide.contentViewController.view.tag);
        
        if (slide.contentViewController.view.tag == 0)
            [(UINavigationController*)slide.contentViewController pushViewController:dial animated:YES];
    }];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *txtview = object;
    CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
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
