//
//  WildcardGestureRecognizer.h
//  MapKitDrawing
//
//  Created by François Le Brun on 29/07/2014.
//  Copyright (c) 2014 tazi.hosni.omar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyPoint.h"
#import "Zone.h"
#import <SMClassicCalloutView.h>
@protocol WildCardDelegate <NSObject>
@optional
-(void)zoneTouched:(Zone*)laZone : (MyPoint*)unPoint;
@end

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface WildcardGestureRecognizer : UIGestureRecognizer {
    @public
    TouchesEventBlock touchesBeganCallback;
    MKMapView   *map;
    NSMutableArray *zoneList;
    
}
@property(copy) TouchesEventBlock touchesBeganCallback;


@end