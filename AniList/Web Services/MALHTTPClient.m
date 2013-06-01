//
//  MALHTTPClient.m
//  AniList
//
//  Created by Corey Roberts on 5/27/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MALHTTPClient.h"
#import "XMLReader.h"

#define MAL_UNOFFICIAL_API_BASE_URL     @"http://mal-api.com"
#define MAL_OFFICIAL_API_BASE_URL       @"http://myanimelist.net/api"

@interface MALHTTPClient()
- (void)setUsername:(NSString *)username andPassword:(NSString *)password;
@end

@implementation MALHTTPClient

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

+ (MALHTTPClient *)sharedClient {
    static dispatch_once_t pred;
    static MALHTTPClient *sharedClient = nil;
    
    dispatch_once(&pred, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:MAL_UNOFFICIAL_API_BASE_URL]];
    });
    
    return sharedClient;
}

#pragma mark - Private Methods

+ (NSString *)malUAPIBaseURL {
    return MAL_UNOFFICIAL_API_BASE_URL;
}

+ (NSString *)malAPIBaseURL {
    return MAL_OFFICIAL_API_BASE_URL;
}

- (void)setUsername:(NSString *)username andPassword:(NSString *)password {
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}

#pragma mark - Request Methods

#pragma mark - Anime Request Methods

- (void)getAnimeListForUser:(NSString *)user success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    //http://myanimelist.net/malappinfo.php?status=all&type=anime&u=SpacePyro
    
    [[MALUserClient sharedClient] getPath:@"/malappinfo.php" parameters:@{@"status" : @"all", @"type" : @"anime", @"u" : @"SpacePyro"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
        success(operation, xmlDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

+ (void)getAnimeDetailsForID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/anime/%d", [animeID intValue]];

    [[MALHTTPClient sharedClient] setUsername:@"SpacePyro" andPassword:@"pyro08"];
    [[MALHTTPClient sharedClient] getPath:path parameters:@{@"mine" : @"1"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}



#pragma mark - Manga Request Methods

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
