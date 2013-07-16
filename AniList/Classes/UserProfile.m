//
//  UserProfile.m
//  AniList
//
//  Created by Corey Roberts on 6/13/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UserProfile.h"
#import "MALHTTPClient.h"

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

#pragma mark - Public Methods

- (void)logout {
    self.username = @"";
    self.password = @"";
}

+ (BOOL)userIsLoggedIn {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kUsernameKey] && [[NSUserDefaults standardUserDefaults] valueForKey:kPasswordKey];
}


- (NSURLRequest *)getUserImageURL:(NSDictionary *)data {
    NSString *profileImageURL = data[@"avatar_url"];
    return [NSURLRequest requestWithURL:[NSURL URLWithString:profileImageURL]];
}

- (void)createAnimeStats:(NSDictionary *)data {
    self.animeStats = @{
                        kStatsTotalTimeInDays   : data[kStatsTotalTimeInDays],
                        kStatsWatching          : data[kStatsWatching],
                        kStatsCompleted         : data[kStatsCompleted],
                        kStatsOnHold            : data[kStatsOnHold],
                        kStatsDropped           : data[kStatsDropped],
                        kStatsPlanToWatch       : data[kStatsPlanToWatch],
                        kStatsTotalEntries      : data[kStatsTotalEntries]
                        };
}

- (void)createMangaStats:(NSDictionary *)data {
    self.mangaStats = @{
                        kStatsTotalTimeInDays   : data[kStatsTotalTimeInDays],
                        kStatsReading           : data[kStatsReading],
                        kStatsCompleted         : data[kStatsCompleted],
                        kStatsOnHold            : data[kStatsOnHold],
                        kStatsDropped           : data[kStatsDropped],
                        kStatsPlanToRead        : data[kStatsPlanToRead],
                        kStatsTotalEntries      : data[kStatsTotalEntries]
                        };
}

@end
