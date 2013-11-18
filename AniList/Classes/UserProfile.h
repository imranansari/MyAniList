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
#define kEmailKey @"kEmailKey"

#define kUserAnimeStats @"kUserAnimeStats"
#define kUserMangaStats @"kUserMangaStats"
#define kNotificationTimestampKey @"kNotificationTimestampKey"
#define kProTipNotification @"kProTipNotification"

// Stats
#define kStatsTotalTimeInDays @"time_days"
#define kStatsWatching @"watching"
#define kStatsCompleted @"completed"
#define kStatsOnHold @"on_hold"
#define kStatsDropped @"dropped"
#define kStatsPlanToWatch @"plan_to_watch"
#define kStatsTotalEntries @"total_entries"
#define kStatsReading @"reading"
#define kStatsPlanToRead @"plan_to_read"

// Notification Names
#define kUserLoggedIn @"kUserLoggedIn"

// Preference Keys
#define kDisplayWatching @"kDisplayWatching"
#define kDisplayCompleted @"kDisplayCompleted"
#define kDisplayOnHold @"kDisplayOnHold"
#define kDisplayDropped @"kDisplayDropped"
#define kDisplayPlanToWatch @"kDisplayPlanToWatch"

@interface UserProfile : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, strong) NSDictionary *animeStats;
@property (nonatomic, strong) NSDictionary *mangaStats;
@property (nonatomic, strong) NSURLRequest *profileImageURL;
@property (nonatomic, strong) UIImage *profileImage;

// Preferences
@property (nonatomic, assign) BOOL displayWatching;
@property (nonatomic, assign) BOOL displayCompleted;
@property (nonatomic, assign) BOOL displayOnHold;
@property (nonatomic, assign) BOOL displayDropped;
@property (nonatomic, assign) BOOL displayPlanToWatch;

+ (UserProfile *)profile;
- (void)setUsername:(NSString *)username andPassword:(NSString *)password;
- (void)logout;
+ (BOOL)userIsLoggedIn;
- (void)fetchProfileWithSuccess:(void (^)(void))success failure:(void (^)(void))failure;

- (NSURLRequest *)getUserImageURL:(NSDictionary *)data;

- (NSString *)animeCellStats;
- (NSString *)mangaCellStats;

- (void)createAnimeStats:(NSDictionary *)data;
- (void)createMangaStats:(NSDictionary *)data;

- (NSTimeInterval)lastFetchedNotificationTimestamp;
- (void)setNotificationTimestamp:(NSTimeInterval)timestamp;

- (BOOL)shouldShowProTip;
- (void)setProTip;

@end
