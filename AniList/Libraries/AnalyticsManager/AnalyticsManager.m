//
//  AnalyticsManager.m
//  iMapMy3
//
//  Created by Corey Roberts on 7/18/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnalyticsManager.h"
#import "GAI.h"

static NSString *const kTrackingId = @"UA-42547259-1";

static NSArray *eventCategories = nil;
static NSArray *timingCategories = nil;
static NSArray *socialNetworks = nil;

@interface AnalyticsManager()
@property (nonatomic, strong) id<GAITracker> tracker;

@end

@implementation AnalyticsManager

static AnalyticsManager *sharedInstance = nil;

+ (AnalyticsManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AnalyticsManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        [self initGoogleAnalytics];
    }
    return self;
}

- (void)initGoogleAnalytics {
    [GAI sharedInstance].debug = NO;
    [GAI sharedInstance].dispatchInterval = 30;
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    eventCategories = @[
                          @"Feature",
                          @"Action",
                          @"Ads"
                        ];
    
    timingCategories = @[
                           @"Feature"
                         ];
    
    socialNetworks = @[
                         @"Facebook",
                         @"Twitter"
                       ];
}

- (void)trackView:(NSString *)view {
    [self.tracker sendView:view];
}

- (void)trackEvent:(NSString *)event forCategory:(EventCategory)category {
    [self trackEvent:event forCategory:category withValue:nil];
}

- (void)trackEvent:(NSString *)event forCategory:(EventCategory)category withValue:(NSNumber *)value {
    [self.tracker sendEventWithCategory:eventCategories[category] withAction:event withLabel:nil withValue:value];
}

- (void)trackTiming:(NSString *)timingEvent forCategory:(TimingCategory)category withTimeInterval:(NSTimeInterval)timeInterval {
    [self.tracker sendTimingWithCategory:timingCategories[category] withValue:timeInterval withName:timingEvent withLabel:nil];
}

- (void)trackSocial:(NSString *)socialEvent forNetwork:(SocialNetwork)socialNetwork {
    [self.tracker sendSocial:socialNetworks[socialNetwork] withAction:socialEvent withTarget:nil];
}



@end
