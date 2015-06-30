//
//  MyDisKSlideController.m
//  mydistriKt
//
//  Created by Evernet on 12/05/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import "MyDisKSlideController.h"
#import "SoundFiViewController.h"
#import "PaperButton.h"

typedef NS_ENUM(NSUInteger, MyDisKSlideControllerState) {
    MyDisKSlideControllerStateNormal = 0,
    MyDisKSlideControllerStateMinimized,
    MyDisKSlideControllerStateMaximized
};

typedef NS_ENUM(NSUInteger, MyDisKMenuAnimateType) {
    MyDisKMenuAnimateSimple = 0,
    MyDisKMenuAnimateSpringy,
    MyDisKMenuAnimateCustom
};

@interface MyDisKSlideController () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, getter = isDragging) BOOL dragging;
@property (nonatomic, readwrite, getter = isMenuOpen) BOOL menuOpen;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIButton *closeOverlayButton;

@property (nonatomic, readwrite) UIViewController *menuViewController;
@property (nonatomic, readwrite) UIViewController *prevContentViewController;
@property (nonatomic, readwrite) UIViewController *contentViewController;

@end

@implementation MyDisKSlideController

- (id)initWithMenuController:(UIViewController *)menuViewController contentController:(UIViewController *)contentViewController {
    self = [super init];
    if (self) {
        self.scale = 0.6784f;
        self.animationType = MyDisKMenuAnimateCustom;
        self.menuOpen = NO;
        
        self.backgoundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.backgoundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.menuViewController = menuViewController;
        self.contentViewController = contentViewController;
        
        // Do View Controller child/parent relationship stuff
        
        [self.menuViewController willMoveToParentViewController:self];
        [self.contentViewController willMoveToParentViewController:self];
        [self addChildViewController:self.menuViewController];
        [self addChildViewController:self.contentViewController];
        [self.menuViewController didMoveToParentViewController:self];
        [self.contentViewController didMoveToParentViewController:self];
        
        // Prepeare
        
        if ([menuViewController.view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *) menuViewController.view;
            scrollView.scrollsToTop = NO;
        }
        
        menuViewController.view.clipsToBounds = NO;
        [self applyGestureRecognizerToViewController:self.contentViewController];
        [self applyShadowToViewController:self.contentViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgoundImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:self.backgoundImageView];
    [self.view addSubview:self.menuViewController.view];
    [self.view addSubview:self.contentViewController.view];
}

- (void)openMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    [self openMenuWithDuration:animated ? 0.3 : 0 completion:completion];
}

- (void)openMenuWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    self.menuOpen = YES;
    
    [self animateMenuOpenWithDuration:duration completion:^(BOOL finished) {
        [self applyOverlayButtonToMainViewController];
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)closeMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    [self closeMenuWithDuration:animated ? 0.3 : 0 completion:completion];
}

- (void)closeMenuWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    self.menuOpen = NO;
    [self.closeOverlayButton removeFromSuperview];
    self.closeOverlayButton = nil;
    [self animateMenuCloseWithDuration:duration completion:completion];
}

- (void)pushContentController:(UIViewController *)contentViewController animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (self.contentViewController != contentViewController) {
        self.prevContentViewController = self.contentViewController;
        self.contentViewController = contentViewController;
        
        [self.contentViewController willMoveToParentViewController:self];
        
        [self.prevContentViewController.view removeGestureRecognizer:self.panGestureRecognizer];
        [self applyGestureRecognizerToViewController:self.contentViewController];
        [self applyShadowToViewController:self.contentViewController];
        
        [self addChildViewController:self.contentViewController];
        
        // Do it always animated
        [self transitionFromViewController:self.prevContentViewController toViewController:self.contentViewController duration:0 options:UIViewAnimationOptionCurveEaseInOut animations:nil completion:^(BOOL finished) {
            [self.contentViewController didMoveToParentViewController:self];
            [self.prevContentViewController removeFromParentViewController];
            self.prevContentViewController = nil;
        }];
        
        if (self.menuOpen) {
            self.contentViewController.view.transform = self.prevContentViewController.view.transform;
            [self closeMenuAnimated:animated completion:completion];
        } else {
            self.contentViewController.view.transform = self.prevContentViewController.view.transform;
        }
    } else {
        [self closeMenuAnimated:animated completion:completion];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Animate transitions
CGFloat AirDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat AirRadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

- (void)animateMenuOpenWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    switch (self.animationType) {
        case 0: { // Simple
            [UIView animateWithDuration:0.80 delay:0. usingSpringWithDamping:1. initialSpringVelocity:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.contentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateNormal toState:MyDisKSlideControllerStateMinimized progress:1];
            }                completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
            break;
        }
        case 1: { // Springy
            [UIView animateWithDuration:1.00 delay:0. usingSpringWithDamping:0.20 initialSpringVelocity:11. options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.contentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateNormal toState:MyDisKSlideControllerStateMinimized progress:1];
            }                completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
            break;
        }
        case 2: { // Customise
            CATransform3D transform = CATransform3DIdentity;
            CATransform3D tmp = CATransform3DIdentity;
            transform = CATransform3DRotate(transform, -0.6591f, 0, 1, 0);
            transform = CATransform3DTranslate(transform, 170.0000f, 0.0000f, 0.0000f);
            transform = CATransform3DScale(transform, 1.0000f, 1.0000f, 1.0000f);
            transform = CATransform3DScale(transform, 1.0000f, 0.5084f, 1.0000f);
            transform = CATransform3DScale(transform, 0.5084f, 1.0000f, 1.0000f);
            tmp = CATransform3DIdentity;
            tmp.m34 = -0.0026f;
            transform = CATransform3DConcat(transform, tmp);
            
            self.menuViewController.view.layer.zPosition = -2500;
            UINavigationController *nav = (UINavigationController*)self.contentViewController;
            for (UIView *view in [nav.navigationBar subviews]) {
                NSLog(@"Class : %@", [view class]);
                NSLog(@"Tag :  %ld", (long)[view tag]);
                if ([view tag] == 24) {
                    [(PaperButton*)view animateToClose];
                    [(PaperButton*)view changeShowMenu];
                }
            }
            [UIView animateWithDuration:0.80 delay:0. usingSpringWithDamping:1. initialSpringVelocity:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.contentViewController.view.layer.transform = transform;
            }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion(finished);
                                 }
                             }];
            break;        }
        default:
            break;
    }
}

- (void)animateMenuCloseWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    switch (self.animationType) {
        case 0: { // Simple
            [UIView animateWithDuration:0.80 delay:0. usingSpringWithDamping:1. initialSpringVelocity:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.contentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateMinimized toState:MyDisKSlideControllerStateNormal progress:1];
                self.prevContentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateMinimized toState:MyDisKSlideControllerStateNormal progress:1];
            }                completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
            break;
        }
        case 1: { // Springy
            [UIView animateWithDuration:0.90 delay:0. usingSpringWithDamping:0.40 initialSpringVelocity:30. options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.contentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateMinimized toState:MyDisKSlideControllerStateNormal progress:1];
                self.prevContentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateMinimized toState:MyDisKSlideControllerStateNormal progress:1];
            }                completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
            break;
        }
        case 2: { // Customise
            NSLog(@"yolo");
            UINavigationController *nav = (UINavigationController*)self.contentViewController;
            for (UIView *view in [nav.navigationBar subviews]) {
                NSLog(@"Class : %@", [view class]);
                NSLog(@"Tag :  %ld", (long)[view tag]);
                if ([view tag] == 42 || [view tag] == 24) {
                    [(PaperButton*)view animateToMenu];
                    [(PaperButton*)view changeShowMenu];
                    view.tag = 24;
                }
            }
            [UIView animateWithDuration:0.80 delay:0. usingSpringWithDamping:1. initialSpringVelocity:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.contentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateMinimized toState:MyDisKSlideControllerStateNormal progress:1];
                self.prevContentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateMinimized toState:MyDisKSlideControllerStateNormal progress:1];
            }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion(finished);
                                 }
                             }];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Transform animations


- (CGAffineTransform)scaleTransformFromState:(MyDisKSlideControllerState)from toState:(MyDisKSlideControllerState)to progress:(float)progress {
    
    // asserts
    CGAffineTransform result;
    if (from == MyDisKSlideControllerStateNormal && to == MyDisKSlideControllerStateMaximized) {
        CGFloat scaledValue = 1 / self.scale * progress;
        result = CGAffineTransformMake(scaledValue, 0, 0, scaledValue, -(progress * 233), progress * 28);
    } else if (from == MyDisKSlideControllerStateNormal && to == MyDisKSlideControllerStateMinimized) {
        if (_animationType == MyDisKMenuAnimateCustom) {
            self.menuViewController.view.layer.zPosition = -2500;
            
            for (UIView *view in [self.menuViewController.view subviews])
            {
                if (view.tag == 1)
                    view.alpha = progress;
                if (view.tag == 2) {
                    view.y = (1 - progress) * (-view.height);
                }
            }
            
            CATransform3D transform = CATransform3DIdentity;
            CATransform3D tmp = CATransform3DIdentity;
            transform = CATransform3DRotate(transform, (progress * -0.6591f), 0, 1, 0);
            transform = CATransform3DTranslate(transform, (progress * 170.0000f), 0.0000f, 0.0000f);
            transform = CATransform3DScale(transform, 1.0000f, 1.0000f, 1.0000f);
            transform = CATransform3DScale(transform, 1.0000f,1 - (1 - 0.5084f) * progress, 1.0000f);
            transform = CATransform3DScale(transform,1 - (1 - 0.5084f) * progress, 1.0000f, 1.0000f);
            tmp = CATransform3DIdentity;
            tmp.m34 = -0.0026f;
            transform = CATransform3DConcat(transform, tmp);
            
            self.contentViewController.view.layer.transform = transform;
        }
        else {
            CGFloat scaledValue = 1 - (1 - self.scale) * progress;
            result = CGAffineTransformMake(scaledValue, 0, 0, scaledValue, progress * 233, progress * 28);
        }
        return result;
        
        
    } else if (from == MyDisKSlideControllerStateMaximized && to == MyDisKSlideControllerStateNormal) {
        CGFloat scaledValue = 1 / self.scale - ((1 / self.scale) - 1) * progress;
        result = CGAffineTransformMake(scaledValue, 0, 0, scaledValue, -180 + (progress * 233), progress * 28);
    } else if (to == MyDisKSlideControllerStateNormal) {
        // Ignore progress in other cases
        result = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    } else {
        // Exception;
    }
    
    return result;
}


#pragma mark - Overlay

- (void)applyShadowToViewController:(UIViewController *)viewController {
    //    self.contentViewController.view.layer.shadowOpacity = 0.01f;
    //    self.contentViewController.view.layer.shouldRasterize = NO;
}

- (void)applyGestureRecognizerToViewController:(UIViewController *)viewController {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    self.panGestureRecognizer.cancelsTouchesInView = NO;
    [viewController.view addGestureRecognizer:self.panGestureRecognizer];
    self.panGestureRecognizer.delegate = self;
}

- (void)applyOverlayButtonToMainViewController {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.opaque = NO;
    button.frame = self.contentViewController.view.frame;
    [button addTarget:self action:@selector(closeButtonAction) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchDragOutside)];
    [button addTarget:self action:@selector(closeButtonTouchedDown) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(closeButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:button];
    self.closeOverlayButton = button;
}

- (void)closeButtonAction {
    [self closeMenuAnimated:YES completion:nil];
}

- (void)closeButtonTouchedDown {
    /*    [UIView animateWithDuration:0.1 animations:^{
     // For Custom Anim of contentView touch.
     }];*/
}

- (void)closeButtonTouchUpOutside {
    /*[UIView animateWithDuration:0.1 animations:^{
     // For Custom Anim of contentView touch.
     }];*/
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity width:(CGFloat)width {
    NSTimeInterval durationLowLimit = 0.75;
    NSTimeInterval durationHightLimit = 0.55;
    
    NSTimeInterval animationDurationDiff = durationHightLimit - durationLowLimit;
    CGFloat horizontalVelocity = velocity.x;
    
    if (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;
    
    return (durationHightLimit + durationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}


#pragma mark - Handle Gestures

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    UIView *gestureView = self.contentViewController.view;
    UIGestureRecognizerState state = gesture.state;
    CGPoint translation = [gesture translationInView:gestureView];
    CGPoint velocity = [gesture velocityInView:gestureView];
    
    CGFloat percentage = MIN(1, translation.x / (320.0f * 1.5));
    percentage = MAX(0, percentage);
    
    self.menuOpen = percentage > 0;
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        self.dragging = YES;
        if (_animationType == MyDisKMenuAnimateCustom)
            [self scaleTransformFromState:MyDisKSlideControllerStateNormal toState:MyDisKSlideControllerStateMinimized progress:percentage];
        else
            self.contentViewController.view.transform = [self scaleTransformFromState:MyDisKSlideControllerStateNormal toState:MyDisKSlideControllerStateMinimized progress:percentage];
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        self.dragging = NO;
        
        NSTimeInterval animationDuration = [self animationDurationWithVelocity:velocity width:CGRectGetWidth(gestureView.frame)];
        
        if (percentage > 0.25) {
            [self openMenuWithDuration:animationDuration completion:nil];
        } else {
            [self closeMenuWithDuration:animationDuration completion:nil];
        }
    }
}


#pragma mark - UIGestureRecognizerDelegate


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        UIPanGestureRecognizer *g = (UIPanGestureRecognizer *) gestureRecognizer;
        UIView *gestureView = self.contentViewController.view;
        CGPoint point = [g velocityInView:gestureView];
        
        if (fabsf(point.x) > fabsf(point.y)) {
            if (point.x < 0) {
                return NO;
            } else {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
