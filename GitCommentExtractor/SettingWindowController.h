//
//  SettingWindowController.h
//  GitCommentExtracter
//
//  Created by Cheung Chun Wai on 18/2/15.
//  Copyright (c) 2015 sakiwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SettingWindowController;

@protocol SettingWindowControllerDelegate <NSObject>
- (void)widowsDidClose:(SettingWindowController *)controller;
@end

@interface SettingWindowController : NSWindowController<NSWindowDelegate>
@property (copy, nonatomic) NSString *workspacePath;
@end
