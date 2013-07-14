//
//  Settings.m
//  AniList
//
//  Created by Corey Roberts on 7/14/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "Settings.h"

#define kVerboseLogging @"kVerboseLogging"
#define kDebugUI        @"kDebugUI"

@implementation Settings

#pragma mark - Singleton Methods

+ (Settings *)sharedSettings {
    static dispatch_once_t pred;
    static Settings *sharedSettings = nil;
    
    dispatch_once(&pred, ^{
        sharedSettings = [[Settings alloc] init];
    });
    
    return sharedSettings;
}

- (id)init {
    self = [super init];
    
    if(self) {
        self.verboseLogging = [[NSUserDefaults standardUserDefaults] boolForKey:kVerboseLogging];
        self.debugUI = [[NSUserDefaults standardUserDefaults] boolForKey:kDebugUI];
    }
    
    return self;
}

- (void)setVerboseLogging:(BOOL)verboseLogging {
    _verboseLogging = verboseLogging;
    
    [[NSUserDefaults standardUserDefaults] setBool:verboseLogging forKey:kVerboseLogging];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDebugUI:(BOOL)debugUI {
    _debugUI = debugUI;
    
    [[NSUserDefaults standardUserDefaults] setBool:debugUI forKey:kDebugUI];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
