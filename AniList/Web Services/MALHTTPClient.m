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
- (void)authenticate;
@end

@implementation MALHTTPClient

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

- (void)authenticate {
    if([UserProfile userIsLoggedIn])
        [self setUsername:[[UserProfile profile] username] andPassword:[[UserProfile profile] password]];
    else NSAssert(nil, @"Username and password must be valid!");
}

#pragma mark - Request Methods

#pragma mark - User Authentication Methods

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    [[MALHTTPClient sharedClient] setUsername:username andPassword:password];
    [[MALHTTPClient sharedClient] getPath:@"/api/account/verify_credentials.xml"
                               parameters:@{}
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSLog(@"Logged in successfully!");
                                      success(operation, responseObject);
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      failure(operation, error);
                                  }];
}

#pragma mark - Anime Request Methods

- (void)getAnimeListForUser:(NSString *)user success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    //http://myanimelist.net/malappinfo.php?status=all&type=anime&u=SpacePyro
    
    NSDictionary *parameters = @{
                                 @"status"  : @"all",
                                 @"type"    : @"anime",
                                 @"u"       : [[UserProfile profile] username]
                                 };
    
    [[MALUserClient sharedClient] getPath:@"/malappinfo.php"
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *parseError = nil;
                                      NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
                                      success(operation, xmlDictionary);
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      failure(operation, error);
                                  }];
}

- (void)getAnimeDetailsForID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/anime/%d", [animeID intValue]];

    NSDictionary *parameters = @{ @"mine" : @"1" };
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] getPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       success(operation, responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       failure(operation, error);
                                   }];
}

- (void)updateDetailsForAnimeWithID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/api/animelist/update/%d.xml", [animeID intValue]];

    NSString *animeToXML = [AnimeService animeToXML:animeID];
    NSDictionary *parameters = @{ @"data" : animeToXML };
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] postPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSLog(@"response: %@", operation.responseString);
                                       NSError *parseError = nil;
                                       NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
                                       success(operation, xmlDictionary);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       failure(operation, error);
                                   }];
    
}

#pragma mark - Manga Request Methods

- (void)getMangaListForUser:(NSString *)user success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    NSDictionary *parameters = @{
                                 @"status"  : @"all",
                                 @"type"    : @"manga",
                                 @"u"       : [[UserProfile profile] username]
                                 };
    
    [[MALUserClient sharedClient] getPath:@"/malappinfo.php"
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *parseError = nil;
                                      NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
                                      success(operation, xmlDictionary);
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      failure(operation, error);
    }];
}

- (void)getMangaDetailsForID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/manga/%d", [animeID intValue]];
    
    NSDictionary *parameters = @{ @"mine" : @"1" };
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] getPath:path
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      success(operation, responseObject);
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      failure(operation, error);
                                  }];
}

- (void)updateDetailsForMangaWithID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"api/mangalist/update/%d.xml", [animeID intValue]];
    
    NSString *animeToXML = [AnimeService animeToXML:animeID];
    NSDictionary *parameters = @{ @"data" : animeToXML };
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] postPath:path
                                 parameters:parameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSError *parseError = nil;
                                        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
                                        success(operation, xmlDictionary);
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        failure(operation, error);
                                    }];
    
}

@end
