//
//  ViewController.m
//  New Engine ObjC
//
//  Created by François Le Brun on 04/06/2014.
//  Copyright (c) 2014 LeBrun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
            

@end

@implementation ViewController
@synthesize inputNode;
@synthesize outputNode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    myEngine = [[AVAudioEngine alloc]init];
    
    inputNode = [[AVAudioInputNode alloc]init];
    
    [myEngine attachNode:inputNode];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
