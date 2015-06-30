//
//  ViewController.m
//  SpellCheck
//
//  Created by François Le Brun on 14/05/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *word=@"image_uti";
    
    UITextChecker *checker = [[UITextChecker alloc] init];
    
    NSRange checkRange = NSMakeRange(0, [word length]);
    
    NSRange misspelledRange = [checker rangeOfMisspelledWordInString:word
                                                               range:checkRange
                                                          startingAt:checkRange.location
                                                                wrap:NO
                                                            language:@"fr_FR"];
    
    NSArray *arrGuessed = [checker guessesForWordRange:misspelledRange inString:word language:@"fr_FR"];
    
    if ([arrGuessed count]>0) {
        for (int i=0; i<[arrGuessed count]; i++) {
            NSLog(@"%@",arrGuessed[i]);
        }
    }
    if ([arrGuessed count]>0)
        word = [word stringByReplacingCharactersInRange:misspelledRange withString:[arrGuessed objectAtIndex:0]];
    NSLog(@"%@",word);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
