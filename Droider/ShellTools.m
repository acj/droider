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

+ (NSString *) getPathToUserShell
{
    NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
    return [environmentDict objectForKey:@"SHELL"];
}

@end
