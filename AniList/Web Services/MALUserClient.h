//
//  MALUserClient.h
//  AniList
//
//  Created by Corey Roberts on 6/1/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AFHTTPClient.h"

@interface MALUserClient : AFHTTPClient

+ (MALUserClient *)sharedClient;

@end
