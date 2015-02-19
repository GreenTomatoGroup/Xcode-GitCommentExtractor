//
//  GitCommentExtractor.h
//  GitCommentExtractor
//
//  Created by Cheung Chun Wai on 19/2/15.
//  Copyright (c) 2015 Sakiwei. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "SettingWindowController.h"

@interface GitCommentExtractor : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@property (nonatomic, strong) SettingWindowController * settingWindow;

@end