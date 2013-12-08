//
//  ShellTools.m
//  Droider
//
//  Created by Adam Jensen on 10/6/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "ShellTools.h"

@implementation ShellTools

+ (BOOL) userShellIsValid
{
    NSString *userShell = [[[NSProcessInfo processInfo] environment] objectForKey:@"SHELL"];
    NSLog(@"User's shell is %@", userShell);
    
    BOOL isValidShell = NO;
    for (NSString *validShell in [[NSString stringWithContentsOfFile:@"/etc/shells" encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        if ([[validShell stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:userShell]) {
            isValidShell = YES;
            break;
        }
    }
    
    if (!isValidShell) {
        NSLog(@"Shell %@ is not in /etc/shells", userShell);
    }
    
    return isValidShell;
}

+ (NSString *) getOutputFromShellCommand:(NSString *)command
{
    if ([self userShellIsValid])
    {
        NSMutableArray *combinedArgs = [NSMutableArray arrayWithObjects:@"-l", @"-c", command, nil];
        return [self getOutputFromCommand:[self getPathToUserShell] withArguments:combinedArgs];
    }
    else
    {
        NSLog(@"User shell is not listed in /etc/shells; refusing to run command");
        return nil;
    }
    
}

+ (NSData *) getRawOutputFromCommand:(NSString *)commandPath withArguments:(NSArray *)args
{
    NSLog(@"Launch path will be '%@'", commandPath);
    NSLog(@"Arguments: %@", args);
    NSPipe *outputPipe = [NSPipe pipe];
    NSTask *t = [[NSTask alloc] init];
    [t setStandardInput:[NSPipe pipe]];
    [t setStandardOutput:outputPipe];
    [t setStandardError:outputPipe];
    [t setLaunchPath:commandPath];
    [t setArguments:args];
    [t launch];
    [t waitUntilExit];
    
    NSFileHandle *handle = [outputPipe fileHandleForReading];
    return [handle readDataToEndOfFile];
}

+ (NSString *) getOutputFromCommand:(NSString *)commandPath withArguments:(NSArray *)args
{
    return [[NSString alloc] initWithData:[self getRawOutputFromCommand:commandPath withArguments:args]
                                 encoding:NSUTF8StringEncoding];
}

+ (NSString *) getPathToUserShell
{
    NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
    return [environmentDict objectForKey:@"SHELL"];
}

+ (int) runCommand:(NSString *)commandPath withArguments:(NSArray *)args
{
    NSTask *t = [[NSTask alloc] init];
    [t setLaunchPath:commandPath];
    [t setArguments:args];
    [t launch];
    [t waitUntilExit];
    
    return [t terminationStatus];
}

@end
