//
//  MALUserClient.m
//  AniList
//
//  Created by Corey Roberts on 6/1/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MALUserClient.h"

#define MAL_GET_USER_INFO_BASE_URL      @"http://myanimelist.net"

@implementation MALUserClient

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/xml"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}

#pragma mark - Singleton Methods

+ (MALUserClient *)sharedClient {
    static dispatch_once_t pred;
    static MALUserClient *sharedClient = nil;
    
    dispatch_once(&pred, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:MAL_GET_USER_INFO_BASE_URL]];
    });
    
    return sharedClient;
}

@end
