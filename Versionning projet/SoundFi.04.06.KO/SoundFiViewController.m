//
//  SoundFiViewController.m
//  SoundFi
//
//  Created by Evernet on 29/04/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import "SoundFiViewController.h"
#import "THPinViewController.h"
#import "AppDelegate.h"

@interface SoundFiViewController ()

@end

@implementation SoundFiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        device = [deviceColor new];
        color = [device getIntegerForDeviceColor];
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    if (barStyle)
        return UIStatusBarStyleLightContent;
    else
        return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    messageList = [[NSMutableArray alloc]init];
    self.correctPin = @"1234";
    self.remainingPinEntries = NUMBER_OF_PIN_ENTRIES;

    
    self.view.backgroundColor = [UIColor whiteColor];
    [device logDeviceColor];
    [self loadBackground];
    
    
    self.waveformView = [[Wave alloc] initWithFrame:self.view.bounds];
    self.waveformView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.waveformView];
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    if ([device getIntegerForDeviceColor] == 1)
        [self.waveformView setWaveColor:[UIColor blackColor]];
    else if ([device getIntegerForDeviceColor] == 2)
        [self.waveformView setWaveColor:[UIColor whiteColor]];
    else
        [self.waveformView setWaveColor:[UIColor whiteColor]];
    
    
    [self.waveformView setNumberOfWaves:4];
    [self.waveformView setPrimaryWaveLineWidth:5.0f];
    [self.waveformView setSecondaryWaveLineWidth:2.5];
    
    tryItButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tryItButton setBackgroundImage:[UIImage imageNamed:@"tryitNormal.png"] forState:UIControlStateNormal];
    if (IS_IPHONE_5)
        tryItButton.frame = CGRectMake((320-158) / 2., 420, 158, 47.5);
    else
        tryItButton.frame = CGRectMake((320-158) / 2., 400, 158, 47.5);
    [tryItButton addTarget:self action:@selector(launchPinCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tryItButton];
    
    // Do any additional setup after loading the view.
}


/////////////
//
//  TODO : check position on iphone 5
//
//////////////
-(void)initUI
{
    UIColor *firstColor=[[UIColor alloc] init];  //Main UI Color
    UIColor *secondColor=[[UIColor alloc] init]; //Use for progressBar Color
    //UI Color Management
    switch (color) {
        case 1:     //Silver
            firstColor = [UIColor blackColor];
            secondColor = [UIColor whiteColor];
            break;
        case 2:     //Gold
            firstColor = [UIColor whiteColor];
            secondColor = [UIColor grayColor];
            break;
        case 3:     //Black
            firstColor = [UIColor whiteColor];
            secondColor = [UIColor blackColor];
            break;
        default:    //White
            firstColor = [UIColor blackColor];
            secondColor = [UIColor whiteColor];
            break;
        
    }
    
    
    //TextView **Dialogue stuff**
    msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 70, 320, 100)];
    msgTextView.layer.borderWidth = 1.0f;
    msgTextView.layer.borderColor = [firstColor CGColor];
    msgTextView.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.0];
    msgTextView.textColor=firstColor;
    msgTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    msgTextView.editable=FALSE;
    msgTextView.alpha=0.;
    [self.view addSubview:msgTextView];
    
    //Bouton envoie message **Dialogue stuff**
    sendBut = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBut.frame = CGRectMake(260,msgTextView.y + 99, 60, 30);
    sendBut.layer.borderWidth=1.0f;
    sendBut.layer.borderColor= [firstColor CGColor];
    [sendBut setTitleColor:firstColor forState:UIControlStateNormal];
    [sendBut setTitle:@"Envoyer" forState:UIControlStateNormal];
    [sendBut addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    sendBut.enabled=FALSE;
    sendBut.alpha=0.;
    [self.view addSubview:sendBut];
    
    //Bouton retour menu **Dialogue stuff**
    returnMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    returnMenu.frame = CGRectMake(0,20, 320,40);
    returnMenu.layer.borderWidth=1.0f;
    returnMenu.layer.borderColor= [firstColor CGColor];
    [returnMenu setTitleColor:firstColor forState:UIControlStateNormal];
    [returnMenu setTitle:@"Menu" forState:UIControlStateNormal];
    [returnMenu addTarget:self action:@selector(dismissDialogueView) forControlEvents:UIControlEventTouchUpInside];
    returnMenu.enabled=FALSE;
    returnMenu.alpha=0.;
    [self.view addSubview:returnMenu];
    
    //Progress bar for sending message
    sendingProgress =[[UIProgressView alloc] init];
    sendingProgress.frame = CGRectMake(10,sendBut.y +sendBut.height/2,240,20);
    sendingProgress.alpha=0.;
    sendingProgress.layer.borderWidth=0.3f;
    sendingProgress.layer.borderColor= [firstColor CGColor];
    sendingProgress.trackTintColor=secondColor;
    sendingProgress.progressTintColor=firstColor;
    [self.view addSubview:sendingProgress];
    
    
    //Table view liste des notifications **Notification stuff**
    if (IS_IPHONE_5)
        messageTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,65, 320,1071) style:UITableViewStylePlain];
    else
        messageTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,65, 320,480) style:UITableViewStylePlain];
    messageTableView.dataSource = self;
    messageTableView.delegate=self;
    messageTableView.editing=FALSE;
    messageTableView.alpha=0.;
    messageTableView.backgroundColor=firstColor;
    [self.view addSubview:messageTableView];
    
    //Return to menu button for Notification **Notification stuff**
    backMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backMenu.frame = CGRectMake(0,20, 320,40);
    backMenu.layer.borderWidth=1.0f;
    backMenu.layer.borderColor= [firstColor CGColor];
    [backMenu setTitleColor:firstColor forState:UIControlStateNormal];
    [backMenu setTitle:@"Menu" forState:UIControlStateNormal];
    [backMenu addTarget:self action:@selector(dismissNotificationView) forControlEvents:UIControlEventTouchUpInside];
    backMenu.alpha=0.;
    backMenu.enabled=FALSE;
    [self.view addSubview:backMenu];
    
    
    
}

- (void)launchPinCode:(id)sender {
    THPinViewController *pinViewController = [[THPinViewController alloc] initWithDelegate:self andImage:background.image];
    pinViewController.promptTitle = @"Enter PIN";
    pinViewController.backgroundColor = [UIColor clearColor];
    pinViewController.promptColor = [UIColor clearColor];
    pinViewController.view.tintColor = [UIColor whiteColor];
    pinViewController.hideLetters = YES;
    pinViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:pinViewController animated:YES completion:nil];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)sendMessage
{
    sendingProgress.progress=0;
    messageToSend = [msgTextView text];
    //messageToSend=@"{type : 1 image_uti : \"http://soudfi.com/images/67531686.jpg\", texte : \"Bonjour, bienvenue sur SoundFi. Ceci est un message de test pour une taille standards en nombre de caracteres. L'objectif est que ce message passe sans erreurs et avec tous les caracteres.\"}";
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [soundFiSession startAudioUnit:1:messageToSend];
    });
}

#pragma mark - UI management

-(void)dismissDialogueView
{
    //Display menu
    menu.alpha=1.;
    dialBut.enabled=TRUE;
    paramBut.enabled=TRUE;
    notifBut.enabled=TRUE;
    
    //Hide and disable Dial view
    msgTextView.editable=FALSE;
    msgTextView.alpha=0.;
    sendBut.enabled=false;
    sendBut.alpha=0.;
    returnMenu.enabled=FALSE;
    returnMenu.alpha=0.;
    sendingProgress.alpha=0.;
}

-(void)dismissNotificationView
{
    //Display menu
    menu.alpha=1.;
    dialBut.enabled=TRUE;
    paramBut.enabled=TRUE;
    notifBut.enabled=TRUE;
    
    //Hide and Disable Notif view
    messageTableView.editing=FALSE;
    messageTableView.alpha=0.;
    backMenu.enabled=FALSE;
    backMenu.alpha=0.;
}

-(void)dismissParamView
{
    
}

-(void)dismissMenuView
{
    menu.alpha=0.;
    dialBut.enabled=FALSE;
    paramBut.enabled=FALSE;
    notifBut.enabled=FALSE;
}

-(void)startDialView
{
    NSLog(@"Ouverture de la view pour envoyer message");
    //Dismiss menu
    [self dismissMenuView];
    
    //TextView
    msgTextView.editable=TRUE;
    msgTextView.alpha=1.;

    //Bouton envoie message
    sendBut.enabled=TRUE;
    sendBut.alpha=1.;
    
    //Bouton retour menu
    returnMenu.enabled=TRUE;
    returnMenu.alpha=1.;
    
    //Progress bar
    sendingProgress.alpha=1.;
    sendingProgress.progress=0.;
}

-(void)seeMyNotif
{
    NSLog(@"Ouverture de la view pour les notification");
    [self dismissMenuView];
    
    backMenu.alpha=1.;
    backMenu.enabled=TRUE;
    
    messageTableView.editing=TRUE;
    messageTableView.alpha=1.;
    
    //On retire les badges du springboard
    nbrBadgeNotif=0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
}

-(void)manageParam
{
    NSLog(@"Ouverture de la view pour les paramètres");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pas encore implémenté" message:@"Aucun paramètre à régler, revenez plus tard" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
}


#pragma mark - Mandatory delegate methods for pin view

- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController
{
    return 4;
}

- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin
{
    if ([pin isEqualToString:self.correctPin]) {
        return YES;
    } else {
        self.remainingPinEntries--;
        return NO;
    }
}

- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(THPinViewController *)pinViewController {
    tryItButton.alpha = 0.;
    
    [self initUI];
    
    // Background
    menu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu.png"]];
    menu.y = 20;
    [self.view addSubview:menu];
    
    // Buttons
    dialBut = [UIButton buttonWithType:UIButtonTypeCustom];
    dialBut.frame = CGRectMake(0, menu.y, 320, menu.height / 3);
    [self.view addSubview:dialBut];
    
    notifBut = [UIButton buttonWithType:UIButtonTypeCustom];
    notifBut.frame = CGRectMake(0, menu.y + (menu.height / 3), 320, menu.height / 3);
    [self.view addSubview:notifBut];
    
    paramBut = [UIButton buttonWithType:UIButtonTypeCustom];
    paramBut.frame = CGRectMake(0, menu.y + ((menu.height / 3) * 2.), 320, menu.height / 3);
    [self.view addSubview:paramBut];
    
    //Add action
    [dialBut addTarget:self action:@selector(startDialView) forControlEvents:UIControlEventTouchUpInside];
    [notifBut addTarget:self action:@selector(seeMyNotif) forControlEvents:UIControlEventTouchUpInside];
    [paramBut addTarget:self action:@selector(manageParam) forControlEvents:UIControlEventTouchUpInside];
    
    //Init SoundFiAudioSession
    [self initSoundFiSession];
}


- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController
{
    return (self.remainingPinEntries > 0);
}


#pragma mark - Update Wave Method

- (void)updateMeters
{
    CGFloat normalizedValue = pow (10, [self.recorder averagePowerForChannel:0] / 30);
    if(soundFiSession == nil)
        normalizedValue=0.1;
    else
    {
        if (soundFiSession->sampleFrequency<17000)
            normalizedValue=0.1;
        else
            normalizedValue=soundFiSession->sampleFrequency*0.00002;
    }
    
    [self.waveformView updateWithLevel:normalizedValue];
}


#pragma mark - loadingBackground

- (void) loadBackground {
    switch (color) {
        case 1:
            background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"silverBG.png"]];
            barStyle = NO;
            break;
        case 3: {
            background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackBG.png"]];
            barStyle = YES;
            break;
        }
        default:
            NSLog(@"Color unknow");
            break;
    }
    [self.view addSubview:background];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SoundFiSession related methods

-(void)initSoundFiSession
{
    AppDelegate *myAppDelegate =(AppDelegate *)[[UIApplication sharedApplication]delegate];
    soundFiSession=myAppDelegate->myAudioEngine;
    soundFiSession.delegate=self;
}


//Delegate SoundFi mandatory methods

-(void)messageReceived:(NSString*)theMessage :(int)quality
{
    NSLog(@"Message reçu de qualité %d",quality);
    //Background notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = theMessage;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    //Add message to the list
    [messageList addObject:theMessage];
    NSLog(@"%d",[messageList count]);
    [messageTableView reloadData];
    
    nbrBadgeNotif++;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nbrBadgeNotif];
    
    //Save the message on userData
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:theMessage forKey:[NSString stringWithFormat:@"%d",[messageList count]]];
}

-(void)startingReception
{
    NSLog(@"Je commence la réception");
}

- (void)finishEmission
{
    NSLog(@"Emmision terminée");
}

- (void)soundToLow
{
    NSLog(@"Le son est trop bas!");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Le son est trop faible" message:@"Augmenter le son au maximum pour envoyer un message" delegate:nil cancelButtonTitle:@"Ok je vais le faire" otherButtonTitles:nil];
        [alert show];
    });

}

- (void) progressStatut:(float) percent
{
    if (percent!=sendingProgress.progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [sendingProgress setProgress:percent animated:YES];
        });
    }
}



#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [messageList objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [messageList removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"LA %d",indexPath.row);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Reçu" message:[messageList objectAtIndex:indexPath.row] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
