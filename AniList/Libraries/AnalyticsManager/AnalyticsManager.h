//
//  AnalyticsManager.h
//  iMapMy3
//
//  Created by Corey Roberts on 7/18/13.
//  Copyright (c) 2013 MapMyFitness, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    EventCategoryFeature = 0,
    EventCategoryAction,
    EventCategoryAds
} EventCategory;

typedef enum {
    TimingCategoryFeature = 0
} TimingCategory;

typedef enum {
    SocialNetworkFacebook = 0,
    SocialNetworkTwitter
} SocialNetwork;

@interface AnalyticsManager : NSObject

+ (AnalyticsManager *)sharedInstance;

- (void)trackView:(NSString *)view;
- (void)trackEvent:(NSString *)event forCategory:(EventCategory)category;
- (void)trackEvent:(NSString *)event forCategory:(EventCategory)category withValue:(NSNumber *)value;
- (void)trackTiming:(NSString *)timingEvent forCategory:(TimingCategory)category withTimeInterval:(NSTimeInterval)timeInterval;
- (void)trackSocial:(NSString *)socialEvent forNetwork:(SocialNetwork)socialNetwork;

@end
