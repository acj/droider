//
//  AndroidTools.h
//  Droider
//
//  Created by Adam Jensen on 9/16/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AndroidTools : NSObject


+ (NSArray*) getListOfConnectedDevices;

+ (NSString *) getModelNumberForDevice:(NSString *)deviceId;

+ (NSArray *) getListOfRunningProcessesForDevice:(NSString *)deviceId;

+ (NSArray *) getListOfInstalledPackagesForDevice:(NSString *)deviceId;

+ (int) runAdbCommand:(NSString *)command
           withDevice:(NSString *)deviceId;

+ (NSData *) getOutputOfAdbCommand:(NSString *)command
                        withDevice:(NSString *)deviceId;

+ (NSArray *) parseOutputOfAdbCommand:(NSString *)command
                           withDevice:(NSString *)deviceId
                            withRegex:(NSString *)regexMatch;

@end
