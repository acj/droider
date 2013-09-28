//
//  AndroidTools.m
//  Droider
//
//  Created by Adam Jensen on 9/16/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "AndroidTools.h"

@implementation AndroidTools

+ (NSArray*) getListOfConnectedDevices
{
    NSString *path = @"/Users/acj/android-sdk-macosx/platform-tools/adb";
    NSString *devicesArg = @"devices";
    NSArray *args = [NSArray arrayWithObjects:devicesArg, nil];
    
    NSTask *t = [[NSTask alloc] init];
    NSPipe *outputPipe = [NSPipe pipe];
    [t setStandardInput:[NSPipe pipe]];
    [t setStandardOutput:outputPipe];
    [t setStandardError:outputPipe];
    [t setLaunchPath:path];
    [t setArguments:args];
    [t launch];
    [t waitUntilExit];
    
    NSFileHandle *handle = [outputPipe fileHandleForReading];
    NSData *taskOutput = [handle readDataToEndOfFile];
    NSString *outputText = [[NSString alloc] initWithData:taskOutput encoding:NSUTF8StringEncoding];
    
    NSArray *deviceList = [self removePreambleAndWhitespace:outputText];
    
    NSMutableArray *devices = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i=0; i < deviceList.count; i++) {
        [devices addObject:[deviceList[i] componentsSeparatedByString:@"\t"]];
    }
    
    return devices;
}

+ (NSArray*) removePreambleAndWhitespace: (NSString*)adbOutput
{
    NSArray *lines = [adbOutput componentsSeparatedByString:@"\n"];
    
    NSRange arrayRange;
    arrayRange.location = 1;
    arrayRange.length = lines.count - arrayRange.location - 2;
    
    return [[NSArray alloc] initWithArray:[lines subarrayWithRange:arrayRange]];
}

@end
