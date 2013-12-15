//
//  GetDeviceInfoOperation.m
//  Droider
//
//  Created by Adam Jensen on 12/12/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//


#import "AppDelegate.h"
#import "AndroidTools.h"
#import "Device.h"
#import "GetDeviceInfoOperation.h"

@implementation GetDeviceInfoOperation

@synthesize device;

- (id)initWithDevice:(Device *)device_
{
    self = [super init];
    
    if (self)
    {
        self.device = device_;
    }
    
    return self;
}

- (void)main
{
    [self.device refresh];
    [[AppDelegate shared] performSelectorOnMainThread:@selector(didRefreshDeviceInfo:)
                                           withObject:device
                                        waitUntilDone:YES];
}

@end
