//
//  UMALHTTPClient.h
//  AniList
//
//  Created by Corey Roberts on 6/12/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AFHTTPClient.h"

@interface UMALHTTPClient : AFHTTPClient

+ (UMALHTTPClient *)sharedClient;
- (void)setUsername:(NSString *)username andPassword:(NSString *)password;
- (void)authenticate;

@end
