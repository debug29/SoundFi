//
//  SCLoginViewController.h
//  Social_SoundfiPlayer
//
//  Created by Evernet on 06/08/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCLoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic)  NSString *scToken;
@property (strong, nonatomic)  NSString *scCode;
@property id soundCloudDelegate;
@end
