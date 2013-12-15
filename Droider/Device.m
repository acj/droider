//
//  Device.m
//  Droider
//
//  Created by Adam Jensen on 12/12/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "AndroidTools.h"
#import "Device.h"

@implementation Device

@synthesize installedPackages;

- (id)initWithDeviceId:(NSArray *)deviceId_
{
    self = [super init];
    
    if (self)
    {
        self.deviceId = [deviceId_ objectAtIndex:0];
        self.deviceType = [deviceId_ objectAtIndex:1];
    }
    
    return self;
}

- (void)refresh
{
    self.deviceModel = [AndroidTools getModelNumberForDevice:self.deviceId];
    self.installedPackages = [[AndroidTools getListOfInstalledPackagesForDevice:self.deviceId] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

@end
