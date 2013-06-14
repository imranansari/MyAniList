//
//  UserProfile.m
//  AniList
//
//  Created by Corey Roberts on 6/13/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile

- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password {
    self = [super init];
    if(self) {
        self.username = username;
        self.password = password;
    }
    return self;
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
    [[NSUserDefaults standardUserDefaults] setValue:password forKey:kUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL)userIsLoggedIn {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kUsernameKey] && [[NSUserDefaults standardUserDefaults] valueForKey:kPasswordKey];
}

@end
