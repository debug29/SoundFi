//
//  ViewController.m
//  RealTimeRecord
//
//  Created by François Le Brun on 17/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize myController;

@synthesize lab_waitingMessage;
@synthesize iv_waitingMessage;
@synthesize sw_emissionMode;
@synthesize sw_receptionMode;
@synthesize tv_receivedMessage;
@synthesize tf_myMessage;
@synthesize but_sendMessage;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)receptionModeOnOff
{
    //ON
    if ([sw_receptionMode isOn])
    {
        [sw_emissionMode setOn:NO];
        [self emissionModeOnOff];
        [lab_waitingMessage setHidden:NO];
        [iv_waitingMessage startAnimating];
        [iv_waitingMessage setHidden:NO];
        [myController startAudioUnit:0:NULL];
    }
    else //OFF
    {
        [lab_waitingMessage setHidden:YES];
        [iv_waitingMessage stopAnimating];
        [iv_waitingMessage setHidden:YES];
        [myController stopProcessingAudio];
    }
}

-(IBAction)emissionModeOnOff
{
    //ON
    if ([sw_emissionMode isOn]) {
        [sw_receptionMode setOn:NO];
        [self receptionModeOnOff];
        [but_sendMessage setHidden:NO];
        [tf_myMessage setHidden:NO];
    }
    else //OFF
    {
        [but_sendMessage setHidden:YES];
        tf_myMessage.text=@"";
        [tf_myMessage setHidden:YES];
        [myController stopProcessingAudio];
    }
}

-(IBAction)sendMessage
{
    //myMessage = [tf_myMessage text];
    myMessage=@"{type : 1 image_uti : \"http://soudfi.com/images/67531686.jpg\", text : \"Bonjour, bienvenue sur SoundFi. Ceci est une message de test pour une taille standart en nombre de caracteres. L'objectif est que ce message passe sans erreurs et avec tous les caracteres.\"}";
    [self textFieldShouldReturn:tf_myMessage];
    
    NSLog(@"Envoie du message : %@",myMessage);
    
    [myController startAudioUnit:1:myMessage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AudioController *newControlleur=[[AudioController alloc]init];
    myController=newControlleur;
    myController.delegate=self;
    
    [tf_myMessage setReturnKeyType:UIReturnKeyDone];
    tf_myMessage.delegate=self;
    
    
    [lab_waitingMessage setHidden:YES];
    [iv_waitingMessage setHidden:YES];
    [but_sendMessage setHidden:YES];
    [tf_myMessage setHidden:YES];
    
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)messageReceived{
    NSLog(@"Un message à été reçu");
    [sw_receptionMode setOn:FALSE];
    [iv_waitingMessage stopAnimating];
    [iv_waitingMessage setHidden:YES];
    
    message=myController->messageReceive;
    lab_waitingMessage.text=message;
}

@end
