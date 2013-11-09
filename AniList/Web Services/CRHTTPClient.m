//
//  CRHTTPClient.m
//  AniList
//
//  Created by Corey Roberts on 11/5/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "CRHTTPClient.h"

#import "NotificationService.h"

@implementation CRHTTPClient

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}


#pragma mark - Singleton Methods

+ (CRHTTPClient *)sharedClient {
    static dispatch_once_t pred;
    static CRHTTPClient *sharedClient = nil;
    
    dispatch_once(&pred, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.coreyjustinroberts.com/anilist/api/1.0"]];
    });
    
    return sharedClient;
}

#pragma mark - Private Methods

- (void)setUsername:(NSString *)username andPassword:(NSString *)password {
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}

#pragma mark - Request Methods

- (void)getNewsFromTimestamp:(NSTimeInterval)timestamp success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"update.php?timestamp=%0.0f", timestamp];
    
    [[CRHTTPClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            for(NSDictionary *dictionary in (NSArray *)responseObject) {
                [NotificationService addNotification:dictionary];
            }
            
            [[UserProfile profile] setNotificationTimestamp:[[NSDate date] timeIntervalSince1970]];
            
            [[AnalyticsManager sharedInstance] trackEvent:kNotificationsFetchSucceeded forCategory:EventCategoryWebService];
            
            success(operation, responseObject);
        }
        @catch (NSException *exception) {
            ALLog(@"An exception occurred while adding notifications: %@", exception);
            [[AnalyticsManager sharedInstance] trackEvent:kNotificationsFetchFailed forCategory:EventCategoryWebService];
            failure(operation, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[AnalyticsManager sharedInstance] trackEvent:kNotificationsFetchFailed forCategory:EventCategoryWebService];
        failure(operation, error);
    }];
}

#pragma mark - Post Methods

- (void)submitFeedbackForUser:(NSString *)user withEmail:(NSString *)email andFeedback:(NSString *)feedback success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    NSString *path = [NSString stringWithFormat:@"submit_feedback.php"];
    
    NSDictionary *parameters = @{
                                 @"username" : user,
                                 @"email" : email,
                                 @"feedback" : feedback
                                 };
    
    [[CRHTTPClient sharedClient] postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[AnalyticsManager sharedInstance] trackEvent:kSendFeedbackSucceeded forCategory:EventCategoryWebService];
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[AnalyticsManager sharedInstance] trackEvent:kSendFeedbackFailed forCategory:EventCategoryWebService];
        failure(operation, error);
    }];
    
}


@end
