//
//  AnalyticsManager.m
//  iMapMy3
//
//  Created by Corey Roberts on 7/18/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnalyticsManager.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAITrackedViewController.h"


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

#pragma mark - Initializers

- (void)initGoogleAnalytics {
    
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    //To debug Google Analytics now use:
#ifdef DEBUG
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
#endif
    
    [GAI sharedInstance].dispatchInterval = 30;
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [[GAI sharedInstance].defaultTracker set:kGAIAppVersion value:[NSString stringWithFormat:@"iOS %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]]];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];

    
    eventCategories = @[
                          @"Feature",
                          @"Action",
                          @"WebService",
						  @"Error"
                        ];
    
    timingCategories = @[
                           @"Feature"
                         ];
    
    socialNetworks = @[
                         @"Facebook",
                         @"Twitter"
                       ];
}

#pragma mark - Google Analytics Methods

- (void)trackView:(NSString *)view {
    ALLog(@"Looking at %@.", view);
    
    [self.tracker set:kGAIScreenName value:view];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)trackEvent:(NSString *)event forCategory:(EventCategory)category {
    [self trackEvent:event forCategory:category withValue:nil];
}

- (void)trackEvent:(NSString *)event forCategory:(EventCategory)category withMetadata:(NSString *)metadata {
    [self trackEvent:event forCategory:category withMetadata:metadata andValue:nil];
}

- (void)trackEvent:(NSString *)event forCategory:(EventCategory)category withValue:(NSNumber *)value {
    [self trackEvent:event forCategory:category withMetadata:nil andValue:value];
}

- (void)trackEvent:(NSString *)event forCategory:(EventCategory)category withMetadata:(NSString *)metadata andValue:(NSNumber *)value {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventCategories[category] action:event label:metadata value:value] build]];
}

- (void)trackTiming:(NSString *)timingEvent forCategory:(TimingCategory)category withTimeInterval:(NSTimeInterval)timeInterval {
    [self.tracker send:[[GAIDictionaryBuilder createTimingWithCategory:timingCategories[category] interval:@(timeInterval) name:timingEvent label:nil] build]];
}

- (void)trackSocial:(NSString *)socialEvent forNetwork:(SocialNetwork)socialNetwork {
    [self trackSocial:socialEvent forNetwork:socialNetwork withTarget:nil];
}

- (void)trackSocial:(NSString *)socialEvent forNetwork:(SocialNetwork)socialNetwork withTarget:(NSString *)target {
    [self.tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:socialNetworks[socialNetwork] action:socialEvent target:target] build]];
}

- (void)trackExceptionDescription:(NSString *)description {
    [self trackExceptionDescription:description isFatal:@YES];
}

- (void)trackExceptionDescription:(NSString *)description isFatal:(NSNumber *)fatal {
    [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:description withFatal:fatal] build]];
}

@end
