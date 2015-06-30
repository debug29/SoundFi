//  Wavebackground
//
//  Created by Evernet on 05/06/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import "FlatButton.h"
#import <POP/POP.h>

@interface FlatButton()
- (void)setup;
- (void)scaleToSmall;
- (void)scaleAnimation;
- (void)scaleToDefault;
@end

@implementation FlatButton

+ (instancetype)button
{
    return [self buttonWithType:UIButtonTypeCustom];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Instance methods

- (UIEdgeInsets)titleEdgeInsets
{
    return UIEdgeInsetsMake(0.f,
                            0.f,
                            0.f,
                            0.f);
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(0.0f, 0.0f);
}

#pragma mark - Private instance methods

- (void)setup
{
    self.backgroundColor = self.tintColor;
    self.layer.cornerRadius = 0.f;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:22];

    [self addTarget:self action:@selector(scaleToSmall) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(scaleAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(scaleToDefault) forControlEvents:UIControlEventTouchDragExit];
}

- (void)scaleToSmall
{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(1, 1, 19, 19)];
    [self.layer pop_addAnimation:anim forKey:@"size"];
}

- (void)scaleAnimation
{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(-2, -2, 24, 24)];
    anim.completionBlock = ^(POPAnimation *a, BOOL finished) {
        [self scaleToDefault];
    };
    [self.layer pop_addAnimation:anim forKey:@"size"];
}

- (void)scaleToDefault
{
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)];
    [self.layer pop_addAnimation:anim forKey:@"size"];}

@end
