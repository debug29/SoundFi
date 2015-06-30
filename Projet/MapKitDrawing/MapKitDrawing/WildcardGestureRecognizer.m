//
//  WildcardGestureRecognizer.m
//  MapKitDrawing
//
//  Created by François Le Brun on 29/07/2014.
//  Copyright (c) 2014 tazi.hosni.omar. All rights reserved.
//

#import "WildcardGestureRecognizer.h"


@implementation WildcardGestureRecognizer
@synthesize touchesBeganCallback;

-(id) init{
    if (self = [super init])
    {
        self.cancelsTouchesInView = NO;
    }
    zoneList=[[NSMutableArray alloc]init];
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchesBeganCallback)
        touchesBeganCallback(touches, event);
    CGPoint tapPoint = [self locationInView:map];
    CLLocationCoordinate2D location = [map convertPoint:tapPoint toCoordinateFromView:map];
    NSLog(@"Start touch : %f, %f",location.latitude,location.longitude);
    
    Zone *myZone = [zoneList objectAtIndex:0];
    //NSLog(@"Id :%@, name : %@",myZone->identifiant,myZone->name);
    
    CGPoint tapPoint2;
    tapPoint2.x=location.latitude;
    tapPoint2.y=location.longitude;
    //NSLog(@"%f,%f",tapPoint2.x,tapPoint2.y);
    
    for (Zone* z in zoneList) {
        
        CGMutablePathRef mpr = CGPathCreateMutable();
        
        for (int p=0; p < [z->polyPoint count]; p++){
            MyPoint * point = [[MyPoint alloc]init];
            point = [z->polyPoint objectAtIndex:p];
            if (p == 0)
                CGPathMoveToPoint(mpr, NULL, point->latitude, point->longitude);
            else
                CGPathAddLineToPoint(mpr, NULL, point->latitude, point->longitude);
        }
        
        if(CGPathContainsPoint(mpr , NULL, tapPoint2, FALSE)){
            NSLog(@"Yeah bitch");
            MyPoint *unPoint=[[MyPoint alloc]init];
            unPoint->longitude=tapPoint.y;
            unPoint->latitude=tapPoint.x;
            self.view.userInteractionEnabled=NO;
            [self.delegate performSelector:@selector(zoneTouched::)withObject:z withObject:unPoint];
        }
        
        CGPathRelease(mpr);
        
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Cancel Touch");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"End touch");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"Move touch");
}

- (void)reset
{
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event
{
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return NO;
}

@end