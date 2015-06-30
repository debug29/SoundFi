//
//  MyDisKSlideController.h
//  mydistriKt
//
//  Created by Evernet on 12/05/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDisKSlideController : UIViewController

@property (nonatomic, readonly, getter = isDragging) BOOL dragging;
@property (nonatomic, readonly, getter = isMenuOpen) BOOL menuOpen;

@property (nonatomic) CGFloat scale;
@property (nonatomic) NSUInteger animationType;
@property (nonatomic) UIImageView *backgoundImageView;

@property (nonatomic, readonly) UIViewController *menuViewController;
@property (nonatomic, readonly) UIViewController *contentViewController;

- (id)initWithMenuController:(UIViewController *)menuViewController contentController:(UIViewController *)contentViewController;

- (void)openMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)closeMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)pushContentController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end
