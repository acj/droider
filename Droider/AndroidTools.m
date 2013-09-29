//
//  AndroidTools.m
//  Droider
//
//  Created by Adam Jensen on 9/16/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "AndroidTools.h"

@implementation AndroidTools

+ (NSString *) getOutputFromShellCommand:(NSString *)commandPath withArguments:(NSArray *)args
{
    NSTask *t = [[NSTask alloc] init];
    NSPipe *outputPipe = [NSPipe pipe];
    [t setStandardInput:[NSPipe pipe]];
    [t setStandardOutput:outputPipe];
    [t setStandardError:outputPipe];
    [t setLaunchPath:commandPath];
    [t setArguments:args];
    [t launch];
    [t waitUntilExit];
    
    NSFileHandle *handle = [outputPipe fileHandleForReading];
    NSData *taskOutput = [handle readDataToEndOfFile];
    return [[NSString alloc] initWithData:taskOutput encoding:NSUTF8StringEncoding];
}

+ (NSArray*) getListOfConnectedDevices
{
    NSString *path = @"/Users/acj/android-sdk-macosx/platform-tools/adb";
    NSString *devicesArg = @"devices";
    NSArray *args = [NSArray arrayWithObjects:devicesArg, nil];
    
    NSString *outputText = [self getOutputFromShellCommand:path withArguments:args];
    
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

@end
