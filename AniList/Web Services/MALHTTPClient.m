//
//  MALHTTPClient.m
//  AniList
//
//  Created by Corey Roberts on 5/27/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MALHTTPClient.h"
#import "XMLReader.h"
#import "AnimeService.h"

#define MAL_OFFICIAL_API_BASE_URL       @"http://myanimelist.net"

@interface MALHTTPClient()
- (void)setUsername:(NSString *)username andPassword:(NSString *)password;
@end

@implementation MALHTTPClient

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
//    [self setDefaultHeader:@"Accept" value:@"application/xml"];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}

#pragma mark - Singleton Methods

+ (MALHTTPClient *)sharedClient {
    static dispatch_once_t pred;
    static MALHTTPClient *sharedClient = nil;
    
    dispatch_once(&pred, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:MAL_OFFICIAL_API_BASE_URL]];
    });
    
    return sharedClient;
}

#pragma mark - Private Methods

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

- (void)getAnimeDetailsForID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/anime/%d", [animeID intValue]];

    [[UMALHTTPClient sharedClient] setUsername:@"SpacePyro" andPassword:@"pyro08"];
    [[UMALHTTPClient sharedClient] getPath:path parameters:@{@"mine" : @"1"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

- (void)updateDetailsForAnimeWithID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/api/animelist/update/%d.xml", [animeID intValue]];
    
    NSString *animeToXML = [AnimeService animeToXML:animeID];
    
    [[MALHTTPClient sharedClient] setUsername:@"SpacePyro" andPassword:@"pyro08"];
    [[MALHTTPClient sharedClient] postPath:path parameters:@{@"data" : animeToXML} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", operation.responseString);
        NSError *parseError = nil;
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
        success(operation, xmlDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
    
}

#pragma mark - Manga Request Methods

- (void)getMangaListForUser:(NSString *)user success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    [[MALUserClient sharedClient] getPath:@"/malappinfo.php" parameters:@{@"status" : @"all", @"type" : @"manga", @"u" : @"SpacePyro"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
        success(operation, xmlDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

- (void)getMangaDetailsForID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/manga/%d", [animeID intValue]];
    
    [[MALHTTPClient sharedClient] setUsername:@"SpacePyro" andPassword:@"pyro08"];
    [[MALHTTPClient sharedClient] getPath:path parameters:@{@"mine" : @"1"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

- (void)updateDetailsForMangaWithID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"api/mangalist/update/%d.xml", [animeID intValue]];
    
    NSString *animeToXML = [AnimeService animeToXML:animeID];
    
    [[UMALHTTPClient sharedClient] setUsername:@"SpacePyro" andPassword:@"pyro08"];
    [[UMALHTTPClient sharedClient] postPath:path parameters:@{@"data" : animeToXML} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *parseError = nil;
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
        success(operation, xmlDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
    
}

@end
