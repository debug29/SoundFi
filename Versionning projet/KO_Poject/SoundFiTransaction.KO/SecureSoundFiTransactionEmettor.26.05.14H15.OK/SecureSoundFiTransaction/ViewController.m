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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    SoundFiASSession *newControlleur=[[SoundFiASSession alloc]init];
    myController=newControlleur;
    myController.delegate=self;

    myMessage=@"{type : 1 image_uti : \"http://soudfi.com/images/67531686.jpg\", text : \"Bonjour, bienvenue sur SoundFi. Ceci est une message de test pour une taille standart en nombre de caracteres. L'objectif est que ce message passe sans erreurs et avec tous les caracteres.\"}";
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
    NSLog(@"EMETTEUR : Lancement de l'emetteur");
    [myController startAudioUnit:0 :nil];
}

- (void) messageReceived:(NSString*) theMessage{}
- (void) startingReception{}
- (void) finishEmission{}
@end
