//
//  AppDelegate.m
//  Droider
//
//  Created by Adam Jensen on 9/25/13.
//  Copyright (c) 2013 Adam Jensen. All rights reserved.
//

#import "AppDelegate.h"
#import "AndroidTools.h"
#import "Device.h"
#import "GetDeviceInfoOperation.h"
#import "RefreshDeviceListOperation.h"
#import "Util.h"

@implementation AppDelegate

@synthesize statusMenu;
@synthesize devices;

static AppDelegate *shared;

- (id)init
{
    if (![super init])
    {
        return nil;
    }
    
    devices = [[NSMutableDictionary alloc] init];
    queue = [[NSOperationQueue alloc] init];
    
    shared = self;
    return self;
}

+ (id)shared;
{
    return shared;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:[NSImage imageNamed:@"android-statusbar-icon"]];
    [statusItem setHighlightMode:YES];
    
    [statusMenu setMenuChangedMessagesEnabled:YES];
    [statusMenu setDelegate:self];
    
    [self refreshDeviceList];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self refreshDeviceList];
}

- (void)showEmptyDeviceList:(NSMenu *)menu
{
    [statusMenu removeAllItems];
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"No devices connected"
                                                  action:nil
                                           keyEquivalent:@""];
    [menu addItem:item];
}

- (void)updateMenuItems:(NSMenu *)menu
            withDevices:(NSMutableDictionary *)deviceList
{
    [menu removeAllItems];
    
    if ([deviceList count] == 0) {
        [self showEmptyDeviceList:menu];
    } else {
        for (NSString *deviceId in deviceList)
        {
            Device *device = [deviceList objectForKey:deviceId];
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[device deviceModel]
                                                          action:nil
                                                   keyEquivalent:@""];
            [item setTarget:self];
            [item setSubmenu:[self getSubmenuForDevice:device]];
            [menu addItem:item];
        }
    }
    
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                                      action:@selector(quitItemClicked:)
                                               keyEquivalent:@"Q"];
    [statusMenu addItem:quitItem];
}

- (NSMenu *)getSubmenuForDevice:(Device *)device
{
    NSMenu *submenu = [NSMenu alloc];
    
    NSMenuItem *clearDataMenu = [[NSMenuItem alloc] initWithTitle:@"Clear Data"
                                                           action:nil
                                                    keyEquivalent:@"C"];
    [clearDataMenu setRepresentedObject:device];
    [clearDataMenu setSubmenu:[self getSubmenuWithInstalledPackages:device]];
    
    [submenu addItem:clearDataMenu];
    
    [[submenu addItemWithTitle:@"Reboot" action:@selector(rebootMenuItemClicked:) keyEquivalent:@"R"] setRepresentedObject:[device deviceId]];
    [[submenu addItemWithTitle:@"Take Screenshot" action:@selector(takeScreenshotMenuItemClicked:) keyEquivalent:@"S"] setRepresentedObject:[device deviceId]];
    return submenu;
}

- (NSMenu *)getSubmenuWithInstalledPackages:(Device *)device
{
    NSMenu *submenu = [NSMenu alloc];
    
    for (NSString *pkgName in [device installedPackages])
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

- (void)refreshDeviceList
{
    [queue addOperation:[[RefreshDeviceListOperation alloc] init]];
}

- (void)deviceListRefreshed:(NSArray *)deviceList
{
    if ([deviceList count] == 0)
    {
        [self showEmptyDeviceList:statusMenu];
    }
    else
    {
        for (NSArray *deviceId in deviceList)
        {
            Device *device = [[Device alloc] initWithDeviceId:deviceId];
            [queue addOperation:[[GetDeviceInfoOperation alloc] initWithDevice:device]];
        }
    }
}

- (void)didRefreshDeviceInfo:(Device *)device
{
    [devices setObject:device forKey:[device deviceId]];
    
    [self updateMenuItems:statusMenu withDevices:devices];
}

@end
