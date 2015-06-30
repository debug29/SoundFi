//
//  emetteurViewController.m
//  MacEmetteur
//
//  Created by François Le Brun on 29/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "emetteurViewController.h"

@interface emetteurViewController ()

@end

@implementation emetteurViewController
@synthesize textfield;
@synthesize bouton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        AudioController *newControlleur=[[AudioController alloc]init];
        myController=newControlleur;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
}

- (IBAction)EnvoieMessage:(id)sender {
    myController->isSafeForWork=TRUE;
    
    //myMessage = [textfield stringValue];
    myMessage=@"{type : 1 image_uti : \"http://soudfi.com/images/67531686.jpg\", text : \"Bonjour, bienvenue sur SoundFi. Ceci est une message de test pour une taille standart en nombre de caracteres. L'objectif est que ce message passe sans erreurs et avec tous les caracteres.\"}";
    
    
    NSLog(@"Envoie du message : %@",myMessage);
    
    myController->myMessage=myMessage;
    [myController startAudioUnit:1];
}
@end
