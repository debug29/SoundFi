//
//  Zone.h
//  MapKitDrawing
//
//  Created by François Le Brun on 29/07/2014.
//  Copyright (c) 2014 tazi.hosni.omar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyPoint.h"
@interface Zone : NSObject
{
    @public
    NSString            *identifiant;
    NSString            *name;
    NSMutableArray      *polyPoint;
}
@end
