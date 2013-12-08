//
//  AppDelegate.m
//  Droider
//
//  Created by Adam Jensen on 9/25/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "AppDelegate.h"
#import "AndroidTools.h"
#import "Util.h"

@implementation AppDelegate

@synthesize statusMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:[NSImage imageNamed:@"android-statusbar-icon"]];
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
            NSString *deviceId = [device objectAtIndex:0];
            NSString *deviceModel = [AndroidTools getModelNumberForDevice:deviceId];
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:deviceModel
                                                          action:nil
                                                   keyEquivalent:@""];
            [item setTarget:self];
            [item setSubmenu:[self getSubmenuForDeviceId:deviceId]];
            [statusMenu addItem:item];
        }
    }
    
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                                      action:@selector(quitItemClicked:)
                                               keyEquivalent:@"Q"];
    [statusMenu addItem:quitItem];
}

- (NSMenu *)getSubmenuForDeviceId:(NSString *)deviceId
{
    NSMenu *submenu = [NSMenu alloc];
    
    NSMenuItem *clearDataMenu = [[NSMenuItem alloc] initWithTitle:@"Clear Data"
                                                           action:nil
                                                    keyEquivalent:@"C"];
    [clearDataMenu setRepresentedObject:deviceId];
    [clearDataMenu setSubmenu:[self getSubmenuWithInstalledPackages:deviceId]];
    
    [submenu addItem:clearDataMenu];
    
    [[submenu addItemWithTitle:@"Reboot" action:@selector(rebootMenuItemClicked:) keyEquivalent:@"R"] setRepresentedObject:deviceId];
    [[submenu addItemWithTitle:@"Take Screenshot" action:@selector(takeScreenshotMenuItemClicked:) keyEquivalent:@"S"] setRepresentedObject:deviceId];
    return submenu;
}

- (NSMenu *)getSubmenuWithInstalledPackages:(NSString *)deviceId
{
    NSMenu *submenu = [NSMenu alloc];
    
    NSArray *packageList = [[AndroidTools getListOfInstalledPackagesForDevice:deviceId] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *pkgName in packageList)
    {
        [[submenu addItemWithTitle:pkgName
                            action:@selector(clearDataMenuItemClicked:)
                     keyEquivalent:@""] setRepresentedObject:pkgName];
    }
    
    return submenu;
}

- (void)clearDataMenuItemClicked:(NSMenuItem *)item
{
    NSString *deviceId = [[item parentItem] representedObject];
    NSString *pkgName  = [item representedObject];
    NSString *clearCmd = [NSString stringWithFormat:@"shell pm clear %@", pkgName];
    
    [AndroidTools runAdbCommand:clearCmd withDevice:deviceId];
}

- (void)takeScreenshotMenuItemClicked:(NSMenuItem *)item
{
    NSString *localImagePath = [[Util getTemporaryDirectory] stringByAppendingPathComponent:@".droider.jpg"];
    NSString *sdCardImagePath = @"/sdcard/.droider.jpg";
    
    NSString *screenCapCmd = [NSString stringWithFormat:@"shell screencap -p %@", sdCardImagePath];
    NSString *pullImageCmd = [NSString stringWithFormat:@"pull %@ %@", sdCardImagePath, localImagePath];
    NSString *removeImageCmd = [NSString stringWithFormat:@"shell rm %@", sdCardImagePath];
    
    [AndroidTools runAdbCommand:screenCapCmd withDevice:[item representedObject]];
    [AndroidTools runAdbCommand:pullImageCmd withDevice:[item representedObject]];
    [AndroidTools runAdbCommand:removeImageCmd withDevice:[item representedObject]];
    
    [[NSWorkspace sharedWorkspace] openFile:localImagePath];
}

- (void)rebootMenuItemClicked:(NSMenuItem *)item
{
    [AndroidTools runAdbCommand:@"reboot" withDevice:[item representedObject]];
}

- (void)quitItemClicked:(NSMenuItem *)item
{
    [NSApp terminate:self];
}

@end
