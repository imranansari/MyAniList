//
//  CRHTTPClient.h
//  AniList
//
//  Created by Corey Roberts on 11/5/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AFHTTPClient.h"

@interface CRHTTPClient : AFHTTPClient

+ (CRHTTPClient *)sharedClient;
- (void)getNewsFromTimestamp:(NSTimeInterval)timestamp success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure;
- (void)submitFeedbackForUser:(NSString *)user withEmail:(NSString *)email andFeedback:(NSString *)feedback success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure;

@end
