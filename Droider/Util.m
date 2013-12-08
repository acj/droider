//
//  Util.m
//  Droider
//
//  Created by Adam Jensen on 12/7/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString *) getTemporaryDirectory
{
    NSString *tempDir = NSTemporaryDirectory();
    if (tempDir == nil)
    {
        tempDir = @"/tmp";
    }
    
    return tempDir;
}

@end
