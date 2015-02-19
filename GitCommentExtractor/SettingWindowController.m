//
//  SettingWindowController.m
//  GitCommentExtracter
//
//  Created by Cheung Chun Wai on 18/2/15.
//  Copyright (c) 2015 sakiwei. All rights reserved.
//

#import "SettingWindowController.h"

@interface SettingWindowController ()
@property (unsafe_unretained) IBOutlet NSTextView *gitTagTextView;
@property (unsafe_unretained) IBOutlet NSTextView *commentOutputTextView;

@property (weak) IBOutlet NSTextField *workspaceLabel;
@property (weak) IBOutlet NSTextField *fromTagField;
@property (weak) IBOutlet NSTextField *toTagField;

@property (strong, nonatomic) NSArray *tags;
@end

@implementation SettingWindowController

- (IBAction)useLatestTags:(id)sender {
    
    // use latest tags
    if (self.tags.count < 2) {
        self.toTagField.enabled = NO;
        self.fromTagField.enabled = NO;
        self.toTagField.stringValue = @"";
        self.fromTagField.stringValue = @"";
    } else {
        self.toTagField.enabled = YES;
        self.fromTagField.enabled = YES;
        self.fromTagField.stringValue = self.tags[1];
        self.toTagField.stringValue = self.tags[0];
    }
}

- (IBAction)showComments:(id)sender {
    NSLog(@"self.workspacePath = %@",self.workspacePath);
    
    // extract content from git log
    NSString *runCmd;
    if (self.tags.count < 2) {
        runCmd = @"git log --pretty=format:%s --no-merges";
    } else {
        runCmd = [NSString stringWithFormat:@"git log --pretty=format:%%s %@..%@ --no-merges", self.fromTagField.stringValue, self.toTagField.stringValue];
    }
    
    NSString *result = [self runShellCommand:runCmd];
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *lines = [result componentsSeparatedByString:@"\n"];
    lines = [lines sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    self.commentOutputTextView.string = [lines componentsJoinedByString:@"\n"];
    
    
    [self.commentOutputTextView setSelectedRange:NSMakeRange(0, self.commentOutputTextView.string.length)];
    
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:@[self.commentOutputTextView.string]];
    
}

- (NSString *)runShellCommand:(NSString *)commands {
    
    // run shell command
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSMutableDictionary * environment = [[[NSProcessInfo processInfo] environment] mutableCopy];
    environment[@"LC_ALL"]=@"en_US.UTF-8";
    
    NSTask *task = [[NSTask alloc] init];
    [task setEnvironment:environment];
    
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-c", commands];
    task.standardOutput = pipe;
    task.currentDirectoryPath = self.workspacePath;
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return output;
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    
    [self.workspaceLabel setStringValue:self.workspacePath];
    
    // get tag list
    NSString *gitTags = [self runShellCommand:@"git tag -l | sort -r"];
    
    if (gitTags.length == 0) {
        [self.gitTagTextView setString:@"No Tags"];
    } else {
        [self.gitTagTextView setString:gitTags];
    }
    
    // split in to array
    self.tags = [gitTags componentsSeparatedByString:@"\n"];
    
    if (self.tags.count < 2) {
        self.toTagField.enabled = NO;
        self.fromTagField.enabled = NO;
    } else {
        self.toTagField.enabled = YES;
        self.fromTagField.enabled = YES;
    }
}

- (void)setWorkspacePath:(NSString *)workspacePath {
    
    if (![_workspacePath isEqualToString:workspacePath]) {
        self.tags = nil;
        self.commentOutputTextView.string = @"";
        [self useLatestTags:nil];
        _workspacePath = workspacePath;
    }
    
}


@end
