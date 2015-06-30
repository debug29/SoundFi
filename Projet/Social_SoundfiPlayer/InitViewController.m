//
//  InitViewController.m
//  Social_SoundfiPlayer
//
//  Created by Evernet on 06/08/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import "InitViewController.h"

@interface InitViewController ()
{
    SoundFiAudioSession     *sFAudioSession;
    NSString                *urlString;
}
@end

@implementation InitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"yolo");
        self.soundCloud = [[SoundCloud alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get SoundFi app instance
    AppDelegate *appD = [[UIApplication sharedApplication] delegate];
    sFAudioSession=appD->sFAudioSession;
    sFAudioSession.delegate=self;
    
    //////////Bouton de Test////////////
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 addTarget:self
               action:@selector(listen)
     forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"QuoiQestCeQueTuEcoute" forState:UIControlStateNormal];
    button1.frame = CGRectMake(30.0, 30.0, 250.0, 60.0);
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 addTarget:self
                action:@selector(playSong)
      forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"PlayMySong" forState:UIControlStateNormal];
    button2.frame = CGRectMake(30.0, 90.0, 250.0, 60.0);
    [self.view addSubview:button2];
    ///////////////////////////////////
    
    [self.soundCloud loadUserInfo:^(NSDictionary *userInfo) {
        NSURL *url = [NSURL URLWithString:[userInfo objectForKey:@"avatar_url"]];
        AsyncImageView *avatar = [[AsyncImageView alloc] initWithFrame:CGRectMake(100, 150, 120, 120)];
        avatar.imageURL = url;
        avatar.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:avatar];

    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    [self.soundCloud loadUserFavTracks:^(NSArray *userFavTracks) {
        NSLog(@"%@", [[userFavTracks objectAtIndex:0] objectForKey:@"stream_url"]);
        urlString =[[userFavTracks objectAtIndex:0] objectForKey:@"stream_url"];
        //[self playTrack:[[userFavTracks objectAtIndex:0] objectForKey:@"stream_url"]];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    // Do any additional setup after loading the view.
}

- (void) playTrack:(NSString *)_urlString {
    NSData *data =[self.soundCloud downloadTrackData:_urlString];
    self.audioPlayer = [[AVAudioPlayer alloc]initWithData:data error:nil];
    
    // Set the shared instance
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    //[mySession setCategory:AVAudioSessionCategoryPlayback error:nil];

    [mySession setCategory:AVAudioSessionCategoryMultiRoute withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [mySession setActive:YES error:nil];
    
    AVAudioSessionRouteDescription *route = [mySession currentRoute];
    NSArray *outputs = [route outputs];
    AVAudioSessionChannelDescription *desiredChannel = [[[outputs objectAtIndex:0] channels] objectAtIndex:0];
    // Create an array of desired channels
    NSArray *channelDescriptions = [NSArray arrayWithObject:desiredChannel];
    // Assign the channels
    self.audioPlayer.channelAssignments = channelDescriptions;
    
    [self.audioPlayer play];
    [sFAudioSession startEmitUniqueFrequency:18000];
}

-(void)listen{
    if([self.audioPlayer isPlaying])
        [self.audioPlayer stop];
    if([sFAudioSession isSendingMonoFrequency])
       [sFAudioSession stopEmitUniqueFrequency];
}

-(void)playSong{
    [self playTrack:urlString];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SoundFi delegate
-(void) findUserWithFreq:(NSNumber*)frequency{
    NSLog(@"Trouvé : %d",[frequency intValue]);
}
- (void) messageReceived:(NSString*) theMessage{}
- (void) startingReception{}
- (void) progressStatut:(float) percent{}
- (void) finishEmission{}
- (void) soundToLow{}









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
