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
    
    NSMutableArray *devices = (NSMutableArray *)[self getDeviceListFromAdb:outputText withRegex:@"^([A-Za-z0-9_-]+)\t(.+)"];
    [devices addObjectsFromArray:[self getDeviceListFromAdb:outputText withRegex:@"^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+:[0-9]+)\t(.+)"]];
    return devices;
}

+ (NSArray *) getDeviceListFromAdb:(NSString *)adbOutput
                         withRegex:(NSString *)regexString
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
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
    NSString *args = [NSString stringWithFormat:@"-s %@ shell cat /system/build.prop", deviceId];
    NSArray *argArray = [args componentsSeparatedByString:@" "];
    
    NSString *outputText = [ShellTools getOutputFromCommand:path withArguments:argArray];
    
    for (NSString *s in [NSArray arrayWithObjects:@"product.model", @"product.device", @"product.name", @"product.brand", nil])
    {
        NSString *productModel = [self getBuildPropertyFrom:outputText matchingRegex:s];
        if ( [productModel length] > 0 )
        {
            return productModel;
        }
    }
    
    return deviceId;
}

+ (NSString *) getBuildPropertyFrom:(NSString *)outputText matchingRegex:(NSString *)matchRegex
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^.+%@=(.+)", matchRegex]
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSArray *matches = [regex matchesInString:outputText
                                      options:0
                                        range:NSMakeRange(0, [outputText length])];
    
    NSString *matchingPropertyString;
    if ([matches count] == 0)
    {
        matchingPropertyString = @"";
    } else {
        NSTextCheckingResult *match = matches[0];
        matchingPropertyString = [outputText substringWithRange:[match rangeAtIndex:1]];
    }
    
    return matchingPropertyString;
}

+ (int) runAdbCommand:(NSString *)command
           withDevice:(NSString *)deviceId
{
    NSString *args       = [NSString stringWithFormat:@"-s %@ %@", deviceId, command];
    NSArray  *argArray   = [args componentsSeparatedByString:@" "];
    
    return [ShellTools runCommand:[self getPathToAdbBinary] withArguments:argArray];
}

+ (NSData *) getOutputOfAdbCommand:(NSString *)command
                        withDevice:(NSString *)deviceId
{
    NSString *args       = [NSString stringWithFormat:@"-s %@ %@", deviceId, command];
    NSArray  *argArray   = [args componentsSeparatedByString:@" "];
    
    return [ShellTools getRawOutputFromCommand:[self getPathToAdbBinary] withArguments:argArray];
}

+ (NSArray *) parseOutputOfAdbCommand:(NSString *)command
                        withDevice:(NSString *)deviceId
                         withRegex:(NSString *)regexMatch
{
    NSString *args       = [NSString stringWithFormat:@"-s %@ %@", deviceId, command];
    NSArray  *argArray   = [args componentsSeparatedByString:@" "];
    
    NSString *outputText = [ShellTools getOutputFromCommand:[self getPathToAdbBinary] withArguments:argArray];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexMatch
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSArray *matches = [regex matchesInString:outputText
                                      options:0
                                        range:NSMakeRange(0, [outputText length])];
    
    NSMutableArray *accumulator = [[NSMutableArray alloc] init];
    for (int i=0; i<[matches count]; i++)
    {
        [accumulator addObject:[outputText substringWithRange:[matches[i] rangeAtIndex:1]]];
    }
    
    return accumulator;
}

+ (NSArray *) getListOfRunningProcessesForDevice:(NSString *)deviceId
{
    return [self parseOutputOfAdbCommand:@"shell ps" withDevice:deviceId withRegex:@" ([^ ]+\\.[^ ]+)$"];
}

+ (NSArray *) getListOfInstalledPackagesForDevice:(NSString *)deviceId
{
    return [self parseOutputOfAdbCommand:@"shell pm list packages" withDevice:deviceId withRegex:@"package:(.+)$"];
}

@end
