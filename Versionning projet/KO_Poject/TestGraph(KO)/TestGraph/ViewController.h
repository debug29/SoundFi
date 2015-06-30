//
//  ViewController.h
//  TestGraph
//
//  Created by François Le Brun on 16/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuGraphController.h"


@interface ViewController : UIViewController
{
    @public
    AuGraphController *monControlleur;
    
    UIButton *B_start;
    UIButton *B_stop;
}

@property (nonatomic,retain) IBOutlet UIButton *B_start;
@property (nonatomic,retain) IBOutlet UIButton *B_stop;
@property (nonatomic, nonatomic) AuGraphController *monControlleur;

-(IBAction)start:(UIButton*)bouton;
-(IBAction)stop:(UIButton*)bouton;


@end
