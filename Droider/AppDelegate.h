//
//  AppDelegate.h
//  Droider
//
//  Created by Adam Jensen on 9/25/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    NSOperationQueue *queue;
    NSStatusItem     *statusItem;
}

- (void)deviceListRefreshed:(NSArray *)deviceList;

- (void)menuWillOpen:(NSMenu *)menu;

+ (id)shared;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;

@end
