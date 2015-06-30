//
//  CanvasView.h
//  MapKitDrawing
//
//  Created by Evernet on 17/05/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface CanvasView : UIImageView

@property(nonatomic, weak) ViewController *delegate;

@end
