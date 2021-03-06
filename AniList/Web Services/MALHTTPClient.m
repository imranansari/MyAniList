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
#import "MangaService.h"

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
//    else NSAssert(nil, @"Username and password must be valid!");
}

#pragma mark - Overridden Methods

#pragma mark -

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    [request setValue:@"api-MyAniList-479227514938d8646b93cffa5cb92d4c" forHTTPHeaderField:@"User-Agent"];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:[request copy] success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    [request setValue:@"api-MyAniList-479227514938d8646b93cffa5cb92d4c" forHTTPHeaderField:@"User-Agent"];
    
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:[request copy] success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Profile Methods

- (void)getProfileForUser:(NSString *)user success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting profile info for user %@...", user);
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] getPath:[NSString stringWithFormat:@"/profile/%@", user]
                               parameters:@{}
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      [[AnalyticsManager sharedInstance] trackEvent:kProfileFetchSucceeded forCategory:EventCategoryWebService withMetadata:user];
                                      success(operation, responseObject);
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [[AnalyticsManager sharedInstance] trackEvent:kProfileFetchFailed forCategory:EventCategoryWebService withMetadata:user];
                                      failure(operation, error);
                                  }];
}

#pragma mark - Availability Methods

- (void)officialAPIAvailable:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    [[MALHTTPClient sharedClient] searchForAnimeWithQuery:@"Steins;Gate" success:^(id operation, id response) {
        success(operation, @(YES));
    } failure:^(id operation, NSError *error) {
        failure(operation, error);
    }];
}

- (void)unofficialAPIAvailable:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = @"/anime/9253";
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] getPath:path
                                parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       success(operation, @(YES));
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       failure(operation, error);
                                   }];
}


#pragma mark - User Authentication Methods

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Logging in with username '%@'...,", username);
    
    [[MALHTTPClient sharedClient] setUsername:username andPassword:password];
    [[MALHTTPClient sharedClient] getPath:@"/api/account/verify_credentials.xml"
                               parameters:@{}
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      ALLog(@"Logged in successfully!");
                                      [[AnalyticsManager sharedInstance] trackEvent:kLoginSucceeded forCategory:EventCategoryWebService withMetadata:username];
                                      success(operation, responseObject);
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [[AnalyticsManager sharedInstance] trackEvent:kLoginFailed forCategory:EventCategoryWebService withMetadata:username];
                                      failure(operation, error);
                                  }];
}

#pragma mark - Anime Request Methods

- (void)getAnimeListForUser:(NSString *)user initialFetch:(BOOL)initialFetch success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting anime list for user '%@'...", user);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{ @"type" : @"anime", @"u" : user }];
    
    if(initialFetch) {
        [parameters addEntriesFromDictionary:@{ @"status"  : @"all" }];
    }
    
    [[MALUserClient sharedClient] getPath:@"/malappinfo.php"
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *parseError = nil;
//                                      NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                      NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
                                      if(xmlDictionary) {
                                          [[AnalyticsManager sharedInstance] trackEvent:kAnimeListFetchSucceeded forCategory:EventCategoryWebService withMetadata:user];
                                          success(operation, xmlDictionary);
                                      }
                                      else {
                                          [[AnalyticsManager sharedInstance] trackEvent:kAnimeListFetchFailed forCategory:EventCategoryWebService withMetadata:user];
                                          failure(operation, parseError);
                                      }
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [[AnalyticsManager sharedInstance] trackEvent:kAnimeListFetchFailed forCategory:EventCategoryWebService withMetadata:user];
                                      failure(operation, error);
                                  }];
}

- (void)getTopAnimeForType:(AnimeType)animeType atPage:(NSNumber *)page success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting top list for anime type %@...", [Anime stringForAnimeType:animeType]);
    
    NSString *path = @"/anime/top";
    
    NSDictionary *parameters = @{
//                                 @"type" : [Anime stringForAnimeType:animeType], // not working at the moment.
                                 @"page" : page
                                 };
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] getPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [[AnalyticsManager sharedInstance] trackEvent:kTopAnimeListFetchSucceeded forCategory:EventCategoryWebService];
                                       success(operation, responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [[AnalyticsManager sharedInstance] trackEvent:kTopAnimeListFetchFailed forCategory:EventCategoryWebService];
                                       failure(operation, error);
                                   }];
}

- (void)getPopularAnimeForType:(AnimeType)animeType atPage:(NSNumber *)page success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting popular list for anime type %@...", [Anime stringForAnimeType:animeType]);
    
    NSString *path = @"/anime/popular";
    
    NSDictionary *parameters = @{
                                 // @"type" : [Anime stringForAnimeType:animeType], // not working at the moment.
                                 @"page" : page
                                 };
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] getPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       // If no objects come back, consider the response as failed.
                                       if(((NSArray *)responseObject).count == 0) {
                                           [[AnalyticsManager sharedInstance] trackEvent:kPopularAnimeListFetchFailed forCategory:EventCategoryWebService];
                                           failure(operation, nil);
                                       }
                                       else {
                                           [[AnalyticsManager sharedInstance] trackEvent:kPopularAnimeListFetchSucceeded forCategory:EventCategoryWebService];
                                           success(operation, responseObject);
                                       }
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       failure(operation, error);
                                   }];
}

- (void)getUpcomingAnimeFromDate:(NSDate *)date atPage:(NSNumber *)page success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting upcoming anime from date %@...", date);
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyyMMdd";
//    NSString *dateString = [dateFormatter stringFromDate:date];
//    
    NSString *path = @"/anime/upcoming";

    NSDictionary *parameters = @{
                                 @"page" : page
//                                 @"start_date" : dateString
                                 };
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] getPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [[AnalyticsManager sharedInstance] trackEvent:kUpcomingAnimeListFetchSucceeded forCategory:EventCategoryWebService];
                                       success(operation, responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [[AnalyticsManager sharedInstance] trackEvent:kUpcomingAnimeListFetchFailed forCategory:EventCategoryWebService];
                                       failure(operation, error);
                                   }];
}

- (void)getJustAddedAnimeAtPage:(NSNumber *)page success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting just added anime at page %d.", [page intValue]);

    NSString *path = @"/anime/just_added";
    
    NSDictionary *parameters = @{
                                 @"page" : page
                                 };
    
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

- (void)getAnimeDetailsForID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting anime details for ID %d...", [animeID intValue]);
    
    NSString *path = [NSString stringWithFormat:@"/anime/%d", [animeID intValue]];

    NSDictionary *parameters = @{ @"mine" : @"1" };
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] getPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [[AnalyticsManager sharedInstance] trackEvent:kAnimeDetailsFetchSucceeded forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                       success(operation, responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       // Falling back to the official API.
                                       Anime *anime = [AnimeService animeForID:animeID];
                                       [[MALHTTPClient sharedClient] searchForAnimeWithQuery:anime.title success:^(id operation, id response) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if([response isKindOfClass:[NSArray class]] && ((NSArray *)response).count > 0) {
                                                   for(NSDictionary *data in (NSArray *)response) {
                                                       if(data && [data[kTitle] isEqualToString:anime.title]) {
                                                           [[AnalyticsManager sharedInstance] trackEvent:kAnimeDetailsFetchSucceeded forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                                           success(operation, data);
                                                           break;
                                                       }
                                                   }

                                               }
                                           });
                                       } failure:^(id operation, NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [[AnalyticsManager sharedInstance] trackEvent:kAnimeDetailsFetchFailed forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                               failure(operation, error);
                                           });
                                       }];
                                   }];
}

- (void)addAnimeToListWithID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/api/animelist/add/%d.xml", [animeID intValue]];
    
    NSString *animeToXML = [AnimeService animeToXML:animeID];
    NSDictionary *parameters = @{ @"data" : animeToXML };
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] postPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       ALLog(@"response: %@", operation.responseString);
                                       [[AnalyticsManager sharedInstance] trackEvent:kAddAnimeSucceeded forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                       success(operation, responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [[AnalyticsManager sharedInstance] trackEvent:kAddAnimeFailed forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                       ALLog(@"failed response: %@", operation.responseString);
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
                                       ALLog(@"response: %@", operation.responseString);
                                       [[AnalyticsManager sharedInstance] trackEvent:kUpdateAnimeSucceeded forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                       success(operation, responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [[AnalyticsManager sharedInstance] trackEvent:kUpdateAnimeFailed forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                       failure(operation, error);
                                   }];
    
}

- (void)deleteAnimeWithID:(NSNumber *)animeID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/api/animelist/delete/%d.xml", [animeID intValue]];
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] deletePath:path
                                  parameters:nil
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         ALLog(@"Anime deleted: %@", operation.responseString);
                                         [[AnalyticsManager sharedInstance] trackEvent:kDeleteAnimeSucceeded forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                         success(operation, responseObject);
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         ALLog(@"Anime failed to delete. Please try again later.");
                                         [[AnalyticsManager sharedInstance] trackEvent:kDeleteAnimeFailed forCategory:EventCategoryWebService withMetadata:[animeID stringValue]];
                                         failure(operation, error);
                                     }];
}

- (void)searchForAnimeWithQuery:(NSString *)query success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    //http://myanimelist.net/api/anime/search.xml?q=bleach
    
    NSString *path = [NSString stringWithFormat:@"/api/anime/search.xml?q=%@", query];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] getPath:path
                               parameters:@{}
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                                          ALLog(@"result: %@", result);
                                          result = [result stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                                          result = [result stringByDecodingHTMLEntities];
                                          
                                          // If there still are ampersands out there, escape them.
                                          result = [result stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
                                          result = [result stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
//                                          ALLog(@"result: %@", result);
                                          NSError *parseError = nil;
                                          NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:result error:&parseError];
                                          
                                          NSArray *animelist;
                                          id list = xmlDictionary[@"anime"][@"entry"];
                                          
                                          if([list isKindOfClass:[NSDictionary class]]) {
                                              animelist = @[xmlDictionary[@"anime"][@"entry"]];
                                          }
                                          else if([list isKindOfClass:[NSArray class]]) {
                                              animelist = xmlDictionary[@"anime"][@"entry"];
                                          }
                                          
                                          NSMutableArray *cleanedList = [NSMutableArray array];
                                          NSMutableDictionary *cleanedAnime;
                                          for(NSDictionary *anime in animelist) {
                                              cleanedAnime = [[anime cleanupTextTags] mutableCopy];
                                              if([cleanedAnime valueForKey:@"score"] != nil) {
                                                  NSString *value = cleanedAnime[@"score"];
                                                  [cleanedAnime addEntriesFromDictionary:@{ @"members_score" : value }];
                                                  [cleanedAnime removeObjectForKey:@"score"];
                                              }
                                              [cleanedList addObject:cleanedAnime];
                                          }
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [[AnalyticsManager sharedInstance] trackEvent:kSearchAnimeSucceeded forCategory:EventCategoryWebService withMetadata:query];
                                              success(operation, cleanedList);
                                          });
                                      });
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [[AnalyticsManager sharedInstance] trackEvent:kSearchAnimeFailed forCategory:EventCategoryWebService withMetadata:query];
                                      failure(operation, error);
                                  }];
}

- (void)searchForMangaWithQuery:(NSString *)query success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/api/manga/search.xml?q=%@", query];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] getPath:path
                               parameters:@{}
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                          
                                          result = [result stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                                          result = [result stringByDecodingHTMLEntities];
                                          
                                          // If there still are ampersands out there, escape them.
                                          result = [result stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
                                          result = [result stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
                                          
                                          NSError *parseError = nil;
                                          NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:result error:&parseError];
                                          
                                          NSArray *mangalist;
                                          id list = xmlDictionary[@"manga"][@"entry"];
                                          
                                          if([list isKindOfClass:[NSDictionary class]]) {
                                              mangalist = @[xmlDictionary[@"manga"][@"entry"]];
                                          }
                                          else if([list isKindOfClass:[NSArray class]]) {
                                              mangalist = xmlDictionary[@"manga"][@"entry"];
                                          }
                                          
                                          NSMutableArray *cleanedList = [NSMutableArray array];
                                          NSMutableDictionary *cleanedManga;
                                          for(NSDictionary *manga in mangalist) {
                                              cleanedManga = [[manga cleanupTextTags] mutableCopy];
                                              if([cleanedManga valueForKey:@"score"] != nil) {
                                                  NSString *value = cleanedManga[@"score"];
                                                  [cleanedManga addEntriesFromDictionary:@{ @"members_score" : value }];
                                                  [cleanedManga removeObjectForKey:@"score"];
                                              }
                                              [cleanedList addObject:cleanedManga];
                                          }
                                          
                                          [[AnalyticsManager sharedInstance] trackEvent:kSearchMangaSucceeded forCategory:EventCategoryWebService withMetadata:query];
                                          success(operation, cleanedList);
                                      });
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [[AnalyticsManager sharedInstance] trackEvent:kSearchMangaFailed forCategory:EventCategoryWebService withMetadata:query];
                                      failure(operation, error);
                                  }];
}

#pragma mark - Manga Request Methods

- (void)getMangaListForUser:(NSString *)user initialFetch:(BOOL)initialFetch success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{ @"type" : @"manga", @"u" : user }];
    
//    if(initialFetch) {
        [parameters addEntriesFromDictionary:@{ @"status"  : @"all" }];
//    }
    
    [[MALUserClient sharedClient] getPath:@"/malappinfo.php"
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *parseError = nil;
                                      NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:operation.responseData error:&parseError];
                                      if(xmlDictionary) {
                                          [[AnalyticsManager sharedInstance] trackEvent:kMangaListFetchSucceeded forCategory:EventCategoryWebService withMetadata:user];
                                          success(operation, xmlDictionary);
                                      }
                                      else {
                                          [[AnalyticsManager sharedInstance] trackEvent:kMangaListFetchFailed forCategory:EventCategoryWebService withMetadata:user];
                                          failure(operation, parseError);
                                      }
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [[AnalyticsManager sharedInstance] trackEvent:kMangaListFetchFailed forCategory:EventCategoryWebService withMetadata:user];
                                      failure(operation, error);
                                  }];
}

- (void)getTopMangaForType:(MangaType)mangaType atPage:(NSNumber *)page success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting top list for manga type %@...", [Manga stringForMangaType:mangaType]);
    
    NSString *path = @"/manga/top";
    
    NSDictionary *parameters = @{
                                 //                                 @"type" : [Anime stringForAnimeType:animeType], // not working at the moment.
                                 @"page" : page
                                 };
    
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

- (void)getPopularMangaForType:(MangaType)mangaType atPage:(NSNumber *)page success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    
    ALLog(@"Getting popular list for manga type %@...", [Manga stringForMangaType:mangaType]);
    
    NSString *path = @"/manga/popular";
    
    NSDictionary *parameters = @{
                                 //                                 @"type" : [Anime stringForAnimeType:animeType], // not working at the moment.
                                 @"page" : page
                                 };
    
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

- (void)getMangaDetailsForID:(NSNumber *)mangaID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/manga/%d", [mangaID intValue]];
    
    NSDictionary *parameters = @{ @"mine" : @"1" };
    
    [[UMALHTTPClient sharedClient] authenticate];
    [[UMALHTTPClient sharedClient] getPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [[AnalyticsManager sharedInstance] trackEvent:kMangaDetailsFetchSucceeded forCategory:EventCategoryWebService withMetadata:[mangaID stringValue]];
                                       success(operation, responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       // Falling back to the official API.
                                       Manga *manga = [MangaService mangaForID:mangaID];
                                       [[MALHTTPClient sharedClient] searchForMangaWithQuery:manga.title success:^(id operation, id response) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if([response isKindOfClass:[NSArray class]] && ((NSArray *)response).count > 0) {
                                                   for(NSDictionary *data in (NSArray *)response) {
                                                       if(data && [data[kTitle] isEqualToString:manga.title]) {
                                                           [[AnalyticsManager sharedInstance] trackEvent:kMangaDetailsFetchSucceeded forCategory:EventCategoryWebService withMetadata:[mangaID stringValue]];
                                                           success(operation, data);
                                                           break;
                                                       }
                                                   }
                                               }
                                           });
                                       } failure:^(id operation, NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [[AnalyticsManager sharedInstance] trackEvent:kMangaDetailsFetchFailed forCategory:EventCategoryWebService withMetadata:[mangaID stringValue]];
                                               failure(operation, error);
                                           });
                                       }];
                                   }];
}

- (void)addMangaToListWithID:(NSNumber *)mangaID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/api/mangalist/add/%d.xml", [mangaID intValue]];
    
    NSString *mangaToXML = [MangaService mangaToXML:mangaID];
    NSDictionary *parameters = @{ @"data" : mangaToXML };
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] postPath:path
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       ALLog(@"response: %@", operation.responseString);
                                       [[AnalyticsManager sharedInstance] trackEvent:kAddMangaSucceeded forCategory:EventCategoryWebService withMetadata:[mangaID stringValue]];
                                       success(operation, responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       ALLog(@"failed response: %@", operation.responseString);
                                       [[AnalyticsManager sharedInstance] trackEvent:kAddMangaFailed forCategory:EventCategoryWebService withMetadata:[mangaID stringValue]];
                                       failure(operation, error);
                                   }];
    
}

- (void)updateDetailsForMangaWithID:(NSNumber *)mangaID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"api/mangalist/update/%d.xml", [mangaID intValue]];
    
    NSString *mangaToXML = [MangaService mangaToXML:mangaID];
    NSDictionary *parameters = @{ @"data" : mangaToXML };
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] postPath:path
                                 parameters:parameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        ALLog(@"response: %@", operation.responseString);
                                        [[AnalyticsManager sharedInstance] trackEvent:kUpdateMangaSucceeded forCategory:EventCategoryWebService withMetadata:[mangaID stringValue]];
                                        success(operation, responseObject);
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        [[AnalyticsManager sharedInstance] trackEvent:kUpdateMangaFailed forCategory:EventCategoryWebService withMetadata:[mangaID stringValue]];
                                        failure(operation, error);
                                    }];
    
}

- (void)deleteMangaWithID:(NSNumber *)mangaID success:(HTTPSuccessBlock)success failure:(HTTPFailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"/api/mangalist/delete/%d.xml", [mangaID intValue]];
    
    [[MALHTTPClient sharedClient] authenticate];
    [[MALHTTPClient sharedClient] deletePath:path
                                  parameters:nil
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         ALLog(@"Manga deleted: %@", operation.responseString);
                                         [[AnalyticsManager sharedInstance] trackEvent:kDeleteMangaSucceeded forCategory:EventCategoryAction withMetadata:[mangaID stringValue]];
                                         success(operation, responseObject);
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         ALLog(@"Manga failed to delete. Please try again later.");
                                         [[AnalyticsManager sharedInstance] trackEvent:kDeleteMangaFailed forCategory:EventCategoryAction withMetadata:[mangaID stringValue]];
                                         failure(operation, error);
                                     }];
}

@end
