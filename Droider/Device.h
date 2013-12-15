//
//  Device.h
//  Droider
//
//  Created by Adam Jensen on 12/12/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject


- (id)initWithDeviceId:(NSArray *)deviceId_;
- (void)refresh;

@property NSString *deviceId;
@property NSString *deviceType;
@property NSString *deviceModel;
@property NSArray  *installedPackages;

@end
