//
//  DialViewController.m
//  SoundFi DemoApp
//
//  Created by Evernet on 06/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "DialViewController.h"
#import "ContentManager.h"

@interface DialViewController ()
@property (strong, nonatomic) NSMutableArray *dataSource;
@end

@implementation DialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate->soundEngine.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.title = @"Dialogue";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self loadMessages];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.view.tag = 1;
    appDelegate->soundEngine.delegate = self;
}

- (void)loadMessages
{
    self.dataSource = [[[ContentManager sharedManager] generateConversation] mutableCopy];
}

// SoundEngine Delegate

- (void)appWillEnterForegroundNotification { appDelegate->soundEngine.delegate = self; }

- (void)messageReceived:(NSString *)theMessage {
    NSLog(@"Yolo : %@", theMessage);
    if (theMessage.length > 6) {
        if ([theMessage hasPrefix:@"Note:"]) {
            theMessage = [theMessage substringFromIndex:5];
            SOMessage *msg = [[SOMessage alloc] init];
            msg.text = theMessage;
            msg.fromMe = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self receiveMessage:msg];
            });
        }
    }
    
    
    
}

- (void)localisationData:(NSString*)imgPromo :(NSString*)txtPromo{}
- (void)progressStatut:(float)percent { //NSLog(@"yoplai");
}
- (void)finishEmission { }
- (void)soundToLow { }
- (void)startingReception { }


#pragma mark - SOMessaging data source
- (NSMutableArray *)messages
{
    return self.dataSource;
}

- (NSTimeInterval)intervalForMessagesGrouping
{
    // Return 0 for disableing grouping
    return 0;
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    SOMessage *message = self.dataSource[index];
    
    // Adjusting content for 3pt. (In this demo the width of bubble's tail is 6pt)
    if (!message.fromMe) {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
        cell.textView.textColor = [UIColor colorWithRed:(234./255.) green:(115./255.) blue:(17./255.) alpha:1.];
    }
}

#pragma mark - SOMessaging delegate
- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell
{
    // Show selected media in fullscreen
    [super didSelectMedia:media inMessageCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message
{
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
    
    SOMessage *msg = [[SOMessage alloc] init];
    msg.text = message;
    msg.fromMe = YES;
    NSString *forSend = [NSString stringWithFormat:@"Note:%@", msg.text];
    [appDelegate->soundEngine startAudioUnit:SFSendingMode :forSend];
    [self sendMessage:msg];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    // Take a photo/video or choose from gallery
}

@end
