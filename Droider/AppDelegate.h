//
//  AppDelegate.h
//  Droider
//
//  Created by Adam Jensen on 9/25/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem * statusItem;
}

@property (assign) IBOutlet NSWindow *window;

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;

@end
