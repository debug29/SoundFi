//
//  deviceColor.m
//  SoundFi
//
//  Created by Evernet on 28/04/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import "deviceColor.h"

@implementation deviceColor

- (id)init {
    self = [super init];
    if (self) {
        device = [UIDevice currentDevice];
        selector = NSSelectorFromString([device.systemVersion hasPrefix:@"7"] ? @"_deviceInfoForKey:" :  @"deviceInfoForKey:");
    }
    return self;
}

- (void) logDeviceColor {
    //NSLog(@"DeviceColor: %@ DeviceEnclosureColor: %@", [device performSelector:selector withObject:@"DeviceColor"], [device performSelector:selector withObject:@"DeviceEnclosureColor"]);
}

- (int) getIntegerForDeviceColor {
    /*
     if ([[device performSelector:selector withObject:@"DeviceEnclosureColor"] isEqualToString:@"#d7d9d8"]) {
        NSLog(@"Argent");
        return 1;
    }
    else if ([[device performSelector:selector withObject:@"DeviceEnclosureColor"] isEqualToString:@"#faf189"]) {
        NSLog(@"Yellow");
        return 2;
    }
    else if ([[device performSelector:selector withObject:@"DeviceEnclosureColor"] isEqualToString:@"unknown"]) {
        if ([[device performSelector:selector withObject:@"DeviceColor"] isEqualToString:@"black"])
            return 3;
        else
            return 4;
    }
     */
    
    return 1;
}

@end
