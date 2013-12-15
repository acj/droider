//
//  RefeshDeviceListOperation.m
//  Droider
//
//  Created by Adam Jensen on 12/8/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "AppDelegate.h"
#import "AndroidTools.h"
#import "RefreshDeviceListOperation.h"

@implementation RefreshDeviceListOperation

- (void)main
{
    NSArray *devices = [AndroidTools getListOfConnectedDevices];
    
    [[AppDelegate shared] performSelectorOnMainThread:@selector(deviceListRefreshed:)
                                           withObject:devices
                                        waitUntilDone:YES];
}

@end
