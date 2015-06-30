//
//  LeftMenuViewController.h
//  SoundFi DemoApp
//
//  Created by Evernet on 02/06/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

#import "HomeViewController.h"
#import "NotifViewController.h"
#import "DialViewController.h"

@interface LeftMenuViewController : UIViewController {
    AsyncImageView *userThumbnail;
    UIButton *dialBut, *notifBut, *accountBut, *logoutBut;
}

@end
