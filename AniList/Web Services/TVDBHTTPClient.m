//
//  TVDBHTTPClient.m
//  AniList
//
//  Created by Corey Roberts on 7/13/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "TVDBHTTPClient.h"

@implementation TVDBHTTPClient

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/xml"];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}


#pragma mark - Singleton Methods

+ (TVDBHTTPClient *)sharedClient {
    static dispatch_once_t pred;
    static TVDBHTTPClient *sharedClient = nil;
    
    dispatch_once(&pred, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://thetvdb.com/api/"]];
    });
    
    return sharedClient;
}

#pragma mark - Private Methods

- (void)setUsername:(NSString *)username andPassword:(NSString *)password {
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}


@end
