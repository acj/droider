//
//  GetDeviceInfoOperation.h
//  Droider
//
//  Created by Adam Jensen on 12/12/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "Device.h"
#import <Foundation/Foundation.h>

@interface GetDeviceInfoOperation : NSOperation

@property Device *device;

- (id)initWithDevice:(Device *)device_;

@end
