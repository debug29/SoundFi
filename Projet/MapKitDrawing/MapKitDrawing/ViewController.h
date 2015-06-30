//
//  ViewController.h
//  MapKitDrawing
//
//  Created by Evernet on 20/05/14.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WildcardGestureRecognizer.h"
#import "Zone.h"
#import "MyPoint.h"
#import <HTAutocompleteTextField.h>
#import "HTAutocompleteManager.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface ViewController : UIViewController <WildCardDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

- (void)touchesBegan:(UITouch*)touch;
- (void)touchesMoved:(UITouch*)touch;
- (void)touchesEnded:(UITouch*)touch;

@end
