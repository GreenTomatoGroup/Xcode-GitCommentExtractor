//
//  GitCommentExtractor.m
//  GitCommentExtractor
//
//  Created by Cheung Chun Wai on 19/2/15.
//  Copyright (c) 2015 Sakiwei. All rights reserved.
//

#import "GitCommentExtractor.h"

static GitCommentExtractor *sharedPlugin;

@interface GitCommentExtractor()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (strong, nonatomic) NSMutableDictionary *windowDictionary;

@end

@implementation GitCommentExtractor

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        
        self.windowDictionary = [NSMutableDictionary dictionary];
        // Create menu items, initialize UI, etc.
        
        // set up menu item
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
        
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Git Comment Extractor" action:@selector(showSettingWindow) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
    }
    return self;
}

// Sample Action, for menu item:

- (id)workspaceForWindow:(NSWindow *)window
{
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
    
    for (id controller in workspaceWindowControllers) {
        if ([[controller valueForKey:@"window"] isEqual:window]) {
            return [controller valueForKey:@"_workspace"];
        }
    }
    return nil;
}

- (void)showSettingWindow {
    
    // extract workspace path
    NSString *workspacePath = [[[[self workspaceForWindow:[NSApp keyWindow]] valueForKey:@"representingFilePath"] valueForKey:@"_pathString"] stringByDeletingLastPathComponent];
    
    if (self.settingWindow == nil) {
        // load setting window
        self.settingWindow = [[SettingWindowController alloc] initWithWindowNibName:@"SettingWindowController"];
    }
    
    self.settingWindow.workspacePath = workspacePath;
    
    [self.settingWindow showWindow:self.settingWindow];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

