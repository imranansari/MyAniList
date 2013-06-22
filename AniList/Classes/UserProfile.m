//
//  UserProfile.m
//  AniList
//
//  Created by Corey Roberts on 6/13/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile

static UserProfile *profile = nil;

+ (UserProfile *)profile {
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        profile = [[UserProfile alloc] init];
    });
    
    return profile;
}

- (void)setUsername:(NSString *)username andPassword:(NSString *)password {
    profile.username = username;
    profile.password = password;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedIn object:nil];
}

- (NSString *)username {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUsernameKey];
}

- (NSString *)password {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPasswordKey];
}

- (void)setUsername:(NSString *)username {
    [[NSUserDefaults standardUserDefaults] setValue:username forKey:kUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setValue:password forKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL)userIsLoggedIn {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kUsernameKey] && [[NSUserDefaults standardUserDefaults] valueForKey:kPasswordKey];
}

@end
