//
//  UMALHTTPClient.m
//  AniList
//
//  Created by Corey Roberts on 6/12/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UMALHTTPClient.h"

#define MAL_UNOFFICIAL_API_BASE_URL     @"http://mal-api.com"

@implementation UMALHTTPClient

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}

#pragma mark - Singleton Methods

+ (UMALHTTPClient *)sharedClient {
    static dispatch_once_t pred;
    static UMALHTTPClient *sharedClient = nil;
    
    dispatch_once(&pred, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:MAL_UNOFFICIAL_API_BASE_URL]];
    });
    
    return sharedClient;
}

- (void)setUsername:(NSString *)username andPassword:(NSString *)password {
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}

- (void)authenticate {
    if([UserProfile userIsLoggedIn])
        [self setUsername:[[UserProfile profile] username] andPassword:[[UserProfile profile] password]];
}

@end
