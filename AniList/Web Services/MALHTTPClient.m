//
//  MALHTTPClient.m
//  AniList
//
//  Created by Corey Roberts on 5/27/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MALHTTPClient.h"

#define MAL_UNOFFICIAL_API_BASE_URL     @"http://mal-api.com"
#define MAL_OFFICIAL_API_BASE_URL       @"http://myanimelist.net/api"

@implementation MALHTTPClient

#pragma mark - Private Methods

+ (NSString *)malUAPIBaseURL {
    return MAL_UNOFFICIAL_API_BASE_URL;
}

+ (NSString *)malAPIBaseURL {
    return MAL_OFFICIAL_API_BASE_URL;
}

#pragma mark - Request Methods

+ (void)getAnimeListForUser:(NSString *)user success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *URL = [NSString stringWithFormat:@"%@/animelist/%@", [self malUAPIBaseURL], user];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            if([(NSDictionary *)JSON count] > 0)
                                                                                                success(request, JSON);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            failure(request, error);
                                                                                        }];
    
    [operation start];
}

+ (void)getMangaListForUser:(NSString *)user success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *URL = [NSString stringWithFormat:@"%@/mangalistlist/%@", [self malUAPIBaseURL], user];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            if([(NSDictionary *)JSON count] > 0)
                                                                                                success(request, JSON);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            failure(request, error);
                                                                                        }];
    
    [operation start];
}

@end
