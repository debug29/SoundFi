//
//  AMBlurView.h
//  blur
//
//  Created by COULON Florian on 7/01/2014.
//  Copyright (c) 2013 Arctic Minds Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBlurView : UIView

// Use the following property to set the tintColor. Set it to nil to reset.
@property (nonatomic, strong) UIColor *blurTintColor;

- (void)setStyle:(UIBarStyle)style;

@end
