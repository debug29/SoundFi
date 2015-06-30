//
//  ViewController.m
//  CryptMyWord
//
//  Created by François Le Brun on 03/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *message = @"Bonjour Florian, je suis codee en AES 256.Je suis fiable.";
    NSString *password = @"p4ssw0rd";
    
    NSString *encryptedData = [AESCrypt encrypt:message password:password];
    
    NSString *messageDecrypted = [AESCrypt decrypt:encryptedData password:password];

    NSLog(@" \n Message init :%@ \n Message Codé : %@ \n Message décodé : %@",message,encryptedData,messageDecrypted);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
