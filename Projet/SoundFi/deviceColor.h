//
//  deviceColor.h
//  Wavebackground
//
//  Created by Evernet on 28/04/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface deviceColor : NSObject
{
    UIDevice *device;
    SEL selector;
}
- (void) logDeviceColor;
- (int) getIntegerForDeviceColor;

@end
