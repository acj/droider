//
//  AndroidTools.m
//  Droider
//
//  Created by Adam Jensen on 9/16/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "AndroidTools.h"
#import "ShellTools.h"

@implementation AndroidTools

+ (NSString *) getPathToAdbBinary
{
    return [[ShellTools getOutputFromShellCommand:@"which adb"]
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSArray*) getListOfConnectedDevices
{
    NSString *path = [self getPathToAdbBinary];
    NSString *devicesArg = @"devices";
    NSArray *args = [NSArray arrayWithObjects:devicesArg, nil];
    
    NSString *outputText = [ShellTools getOutputFromCommand:path withArguments:args];
    
    return [self getDeviceListFromAdb:outputText];
}

+ (NSArray *) getDeviceListFromAdb:(NSString *)adbOutput
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([A-Za-z0-9_-]+)\t(.+)"
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSArray *matches = [regex matchesInString:adbOutput
                                      options:0
                                        range:NSMakeRange(0, [adbOutput length])];
    
    NSMutableArray *devices = [[NSMutableArray alloc] initWithCapacity:5];
    for (NSTextCheckingResult *match in matches)
    {
        NSString *deviceId = [adbOutput substringWithRange:[match rangeAtIndex:1]];
        NSString *deviceType = [adbOutput substringWithRange:[match rangeAtIndex:2]];
        [devices addObject:[NSArray arrayWithObjects:deviceId, deviceType, nil]];
    }
    
    return devices;
}

+ (NSString *) getModelNumberForDevice:(NSString *)deviceId
{
    NSString *path = [self getPathToAdbBinary];
    NSString *args = [NSString stringWithFormat:@"-s %@ shell cat /system/build.prop | grep product.model", deviceId];
    NSArray *argArray = [args componentsSeparatedByString:@" "];
    
    NSString *outputText = [ShellTools getOutputFromCommand:path withArguments:argArray];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.+=(.+)"
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSArray *matches = [regex matchesInString:outputText
                                      options:0
                                        range:NSMakeRange(0, [outputText length])];
    
    NSString *modelNumber;
    if ([matches count] == 0)
    {
        modelNumber = @"";
    } else {
        NSTextCheckingResult *match = matches[0];
        modelNumber = [outputText substringWithRange:[match rangeAtIndex:1]];
    }
    
    return modelNumber;
}

@end
