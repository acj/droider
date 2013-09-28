//
//  AppDelegate.m
//  Droider
//
//  Created by Adam Jensen on 9/25/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "AppDelegate.h"
#import "AndroidTools.h"

@implementation AppDelegate

@synthesize statusMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Devices"];
    [statusItem setHighlightMode:YES];
    
    [self updateMenuItems:statusMenu withDevices:[AndroidTools getListOfConnectedDevices]];
}

- (void)updateMenuItems:(NSMenu *)menu
            withDevices:(NSArray *)deviceList
{
    if ([deviceList count] == 0) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No devices connected"
                                                      action:@selector(menuItemClicked:)
                                               keyEquivalent:@""];
        [statusMenu addItem:item];
    } else {
        for (NSArray *device in deviceList)
        {
            NSString *deviceName = [device objectAtIndex:0];
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:deviceName
                                                          action:@selector(menuItemClicked:)
                                                   keyEquivalent:@""];
            [item setTarget:self];
            [item setSubmenu:[self getSubmenuForDeviceId:deviceName]];
            [statusMenu addItem:item];
        }
    }
}

- (NSMenu *)getSubmenuForDeviceId:(NSString *)deviceId
{
    NSMenu *submenu = [NSMenu alloc];
    [submenu addItemWithTitle:@"Clear Data" action:nil keyEquivalent:@""];
    [submenu addItemWithTitle:@"Reboot" action:nil keyEquivalent:@""];
    [submenu addItemWithTitle:@"Take Screenshot" action:nil keyEquivalent:@""];
    return submenu;
}

- (void)menuItemClicked:(NSMenuItem *)item
{
}

@end
