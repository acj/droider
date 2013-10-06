//
//  ShellTools.h
//  Droider
//
//  Created by Adam Jensen on 10/6/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShellTools : NSObject
+ (BOOL) userShellIsValid;

+ (NSString *) getPathToUserShell;

+ (NSString *) getOutputFromShellCommand:(NSString *)command;

+ (NSString *) getOutputFromCommand:(NSString *)commandPath withArguments:(NSArray *)args;

@end
