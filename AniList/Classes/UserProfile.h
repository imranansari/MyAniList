//
//  UserProfile.h
//  AniList
//
//  Created by Corey Roberts on 6/13/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUsernameKey @"kUsernameKey"
#define kPasswordKey @"kPasswordKey"

// Notification Names
#define kUserLoggedIn @"kUserLoggedIn"

@interface UserProfile : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

+ (UserProfile *)profile;
- (void)setUsername:(NSString *)username andPassword:(NSString *)password;
+ (BOOL)userIsLoggedIn;

@end
