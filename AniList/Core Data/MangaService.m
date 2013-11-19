//
//  MangaService.m
//  AniList
//
//  Created by Corey Roberts on 6/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaService.h"
#import "AniListAppDelegate.h"
#import "MALHTTPClient.h"
#import "SynonymService.h"
#import "TagService.h"
#import "GenreService.h"
#import "AnimeService.h"
#import "Anime.h"
#import "FriendManga.h"
#import "FriendMangaService.h"
#import "Friend.h"

#define ENTITY_NAME @"Manga"

@implementation MangaService

+ (int)numberOfMangaForReadStatus:(MangaReadStatus)status {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"read_status == %d", status];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    return [[MangaService managedObjectContext] countForFetchRequest:request error:&error];
}
+ (void)deleteAllManga {
    NSArray *allManga = [MangaService allManga];
    
    for(Manga *manga in allManga)
        [[MangaService managedObjectContext] deleteObject:manga];
    
    [[MangaService managedObjectContext] save:nil];
}

+ (NSArray *)allManga {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    request.entity = entity;
    
    NSError *error = nil;
    return [[MangaService managedObjectContext] executeFetchRequest:request error:&error];
}

+ (NSArray *)myManga {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"read_status < 7"];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    return [[MangaService managedObjectContext] executeFetchRequest:request error:&error];
}

+ (void)downloadInfo {
    NSArray *mangaArray = [MangaService allManga];
    double __block counter = 1;
    
    for(Manga *manga in mangaArray) {
        double delayInSeconds = 0.5f + (double)[mangaArray indexOfObject:manga] / 5.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[MALHTTPClient sharedClient] getMangaDetailsForID:manga.manga_id success:^(id operation, id response) {
                [MangaService addManga:response fromList:NO];
                ++counter;
                [[NSNotificationCenter defaultCenter] postNotificationName:kMangaDownloadProgress object:@{ kDownloadProgress : @(counter/(double)mangaArray.count) }];
            } failure:^(id operation, NSError *error) {
                ++counter;
                [[NSNotificationCenter defaultCenter] postNotificationName:kMangaDownloadProgress object:@{ kDownloadProgress : @(counter/(double)mangaArray.count) }];
            }];
        });
    }
}

+ (Manga *)mangaForID:(NSNumber *)ID {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"manga_id == %d", [ID intValue]];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[MangaService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (Manga *)results[0];
    }
    else return nil;
}

+ (BOOL)addMangaListFromSearch:(NSArray *)data {
    for(NSDictionary *result in data) {
        [MangaService addManga:result fromList:YES];
    }
    
    return NO;
}

+ (BOOL)addMangaList:(NSDictionary *)data {
    
    NSDictionary *mangaDetails = data[@"myanimelist"];
    NSDictionary *mangaDictionary = mangaDetails[@"manga"];
    NSDictionary *mangaUserInfo = mangaDetails[@"myinfo"];
    
    if(mangaUserInfo && [UserProfile userIsLoggedIn]) {
        
        int totalEntries = [mangaUserInfo[kUserReading][@"text"] intValue] +
        [mangaUserInfo[kUserCompleted][@"text"] intValue] +
        [mangaUserInfo[kUserOnHold][@"text"] intValue] +
        [mangaUserInfo[kUserDropped][@"text"] intValue] +
        [mangaUserInfo[kUserPlanToRead][@"text"] intValue];
        
        NSDictionary *stats = @{
                                kStatsTotalTimeInDays   : mangaUserInfo[kUserDaysSpentWatching][@"text"],
                                kStatsReading           : mangaUserInfo[kUserReading][@"text"],
                                kStatsCompleted         : mangaUserInfo[kUserCompleted][@"text"],
                                kStatsOnHold            : mangaUserInfo[kUserOnHold][@"text"],
                                kStatsDropped           : mangaUserInfo[kUserDropped][@"text"],
                                kStatsPlanToRead        : mangaUserInfo[kUserPlanToRead][@"text"],
                                kStatsTotalEntries      : [NSString stringWithFormat:@"%d", totalEntries]
                                };
        
        [[UserProfile profile] createMangaStats:stats];
    }
    
    for(NSDictionary *mangaItem in mangaDictionary) {
        NSMutableDictionary *manga = [MangaService createDictionaryForManga:mangaItem];
        [MangaService addManga:manga fromList:YES];
    }
    
    [[MangaService managedObjectContext] save:nil];
    
    
    return NO;
}

+ (BOOL)addMangaList:(NSDictionary *)data forFriend:(Friend *)friend {
    NSDictionary *mangaDetails = data[@"myanimelist"];
    NSArray *mangaDictionary = mangaDetails[@"manga"];
    NSDictionary *mangaUserInfo = mangaDetails[@"myinfo"];
    
    int totalEntries = [mangaUserInfo[kUserReading][@"text"] intValue] +
    [mangaUserInfo[kUserCompleted][@"text"] intValue] +
    [mangaUserInfo[kUserOnHold][@"text"] intValue] +
    [mangaUserInfo[kUserDropped][@"text"] intValue] +
    [mangaUserInfo[kUserPlanToRead][@"text"] intValue];

    friend.manga_total_entries = @(totalEntries);
    friend.manga_completed = @([mangaUserInfo[kUserCompleted][@"text"] intValue]);
    
    // This is just one manga.
    if([mangaDictionary isKindOfClass:[NSDictionary class]]) {
        NSDictionary *soloManga = (NSDictionary *)mangaDictionary;
        mangaDictionary = @[soloManga];
    }
    
    MVComputeTimeWithNameAndBlock((const char *)"friend_mangalist", ^{
        for(NSDictionary *mangaItem in mangaDictionary) {
            
            NSMutableDictionary *mangaDictionary = [MangaService createDictionaryForManga:mangaItem];
            
            NSNumber *friendScore = mangaDictionary[kUserScore];
            NSNumber *friendCurrentChapter = mangaDictionary[kUserChaptersRead];
            NSNumber *friendCurrentVolume = mangaDictionary[kUserVolumesRead];
            NSString *friendReadStatus = mangaDictionary[kUserReadStatus];
            
            [mangaDictionary removeObjectForKey:kUserScore];
            [mangaDictionary removeObjectForKey:kUserChaptersRead];
            [mangaDictionary removeObjectForKey:kUserVolumesRead];
            [mangaDictionary removeObjectForKey:kUserReadStatus];
            
            Manga *manga = [MangaService addManga:mangaDictionary fromList:YES];
            FriendManga *friendManga = [FriendMangaService addFriend:friend toManga:manga];
            
            if(friendScore && ![friendScore isNull])
                friendManga.score = [friendScore intValue] == 0 ? @(-1) : [friendScore isKindOfClass:[NSString class]] ? @([friendScore intValue]) : friendScore;
            
            if(friendReadStatus && ![friendReadStatus isNull])
                friendManga.read_status = @([Manga mangaReadStatusForValue:friendReadStatus]);
            
            if(friendCurrentChapter && ![friendCurrentChapter isNull])
                friendManga.current_chapter = friendCurrentChapter;
            
            if(friendCurrentVolume && ![friendCurrentVolume isNull])
                friendManga.current_volume = friendCurrentVolume;
        }
        
        [[MangaService managedObjectContext] save:nil];
    });
    
    return NO;
}


+ (NSMutableDictionary *)createDictionaryForManga:(NSDictionary *)mangaItem {
    NSMutableDictionary *manga = [[NSMutableDictionary alloc] init];
    
    [manga addEntriesFromDictionary:@{ kID : @([mangaItem[@"series_mangadb_id"][@"text"] intValue]) }];
    [manga addEntriesFromDictionary:@{ kUserEndDate : mangaItem[@"my_finish_date"][@"text"] }];
    [manga addEntriesFromDictionary:@{ kUserLastUpdated : @([mangaItem[@"my_last_updated"][@"text"] intValue]) }];
    [manga addEntriesFromDictionary:@{ kUserStartDate : mangaItem[@"my_start_date"][@"text"] }];
    [manga addEntriesFromDictionary:@{ kUserRereadingStatus : @([mangaItem[@"my_rereadingg"][@"text"] intValue]) }];
    [manga addEntriesFromDictionary:@{ kUserRereadingChapter : @([mangaItem[@"my_rereading_chap"][@"text"] intValue])}];
    [manga addEntriesFromDictionary:@{ kUserScore : @([mangaItem[@"my_score"][@"text"] intValue])}];
    [manga addEntriesFromDictionary:@{ kUserReadStatus : @([mangaItem[@"my_status"][@"text"] intValue])}];
    [manga addEntriesFromDictionary:@{ kUserChaptersRead : @([mangaItem[@"my_read_chapters"][@"text"] intValue])}];
    [manga addEntriesFromDictionary:@{ kUserVolumesRead : @([mangaItem[@"my_read_volumes"][@"text"] intValue])}];
    [manga addEntriesFromDictionary:@{ kSeriesEndDate : mangaItem[@"series_end"][@"text"] }];
    [manga addEntriesFromDictionary:@{ kVolumes : @([mangaItem[@"series_volumes"][@"text"] intValue]) }];
    [manga addEntriesFromDictionary:@{ kChapters : @([mangaItem[@"series_chapters"][@"text"] intValue]) }];
    [manga addEntriesFromDictionary:@{ kImageURL : mangaItem[@"series_image"][@"text"] }];
    [manga addEntriesFromDictionary:@{ kSeriesStartDate : mangaItem[@"series_start"][@"text"] }];
    [manga addEntriesFromDictionary:@{ kSeriesStatus : mangaItem[@"series_status"][@"text"] }];
    [manga addEntriesFromDictionary:@{ kTitle : mangaItem[@"series_title"][@"text"] }];
    [manga addEntriesFromDictionary:@{ kType : mangaItem[@"series_type"][@"text"] }];
    
    NSString *synonyms = mangaItem[@"series_synonyms"][@"text"];
    NSArray *synonymsArray = [synonyms componentsSeparatedByString:@";"];
    NSMutableArray *result = [NSMutableArray array];
    
    for(int i = 0; i < synonymsArray.count; i++) {
        NSString *synonym = synonymsArray[i];
        synonym = [synonym stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(synonym.length > 0)
            [result addObject:synonym];
    }
    
    if(result.count > 0) {
        NSDictionary *otherTitles = @{ kOtherTitles : @{ kSynonyms : result }};
        [manga addEntriesFromDictionary:otherTitles];
    }
    
//    NSString *tags = mangaItem[@"my_tags"][@"text"];
//    NSArray *tagsArray = [tags componentsSeparatedByString:@","];
//    NSMutableArray *tagResults = [NSMutableArray array];
//    
//    for(int i = 0; i < tagsArray.count; i++) {
//        NSString *tag = tagsArray[i];
//        tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if(tag.length > 0)
//            [tagResults addObject:tag];
//    }
//    
//    if(tagResults.count > 0) {
//        NSDictionary *mangaTags = @{ kTag : tagResults };
//        [manga addEntriesFromDictionary:mangaTags];
//    }
    
    return manga;
}

+ (Manga *)addManga:(NSDictionary *)data fromRelatedAnime:(Anime *)anime {
    Manga *relatedManga = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    relatedManga.manga_id = [data[@"manga_id"] isKindOfClass:[NSString class]] ? @([data[@"manga_id"] intValue]) : data[@"manga_id"];
    relatedManga.title = data[kTitle];
    
    [relatedManga addAnime_adaptationsObject:anime];
    
    return relatedManga;
}

+ (Anime *)addAnimeAdaptation:(NSDictionary *)data toManga:(Manga *)manga {
    Anime *animeAdaptation = [AnimeService animeForID:data[@"anime_id"]];
    
    if(animeAdaptation) {
        ALVLog(@"Anime adaptation '%@' exists for '%@'.", animeAdaptation.title, manga.title);
    }
    else {
        ALVLog(@"Anime adaptation '%@' does not exist for '%@'. Addint to the databaes.", animeAdaptation.title, manga.title);
        animeAdaptation = [AnimeService addAnime:data fromRelatedManga:manga];
    }
    
    [manga addAnime_adaptationsObject:animeAdaptation];
    
    return animeAdaptation;
}

+ (Manga *)addRelatedManga:(NSDictionary *)data toManga:(Manga *)manga relationType:(MangaRelation)relationType {
    Manga *relatedManga = [MangaService mangaForID:data[@"manga_id"]];
    
    if(relatedManga) {
        ALVLog(@"Related manga exists.");
    }
    else {
        ALVLog(@"Related manga does not exist. Creating.");
        relatedManga = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
        relatedManga.manga_id = [data[@"manga_id"] isKindOfClass:[NSString class]] ? @([data[@"manga_id"] intValue]) : data[@"manga_id"];
        relatedManga.title = data[kTitle];
    }
    
    switch (relationType) {
        case MangaRelationRelatedManga:
            [relatedManga addRelated_mangaObject:manga];
            [manga addRelated_mangaObject:relatedManga];
            break;
        case MangaRelationAlternativeVersions:
            [relatedManga addAlternative_versionsObject:manga];
            [manga addAlternative_versionsObject:relatedManga];
            break;
        default:
            break;
    }
    
    return relatedManga;
}

+ (Manga *)addManga:(NSDictionary *)data fromList:(BOOL)fromList {
    Manga *existingManga = [MangaService mangaForID:data[kID]];
    
    if(existingManga) {
        ALVLog(@"Manga exists. Updating details.");
        return [MangaService editManga:data fromList:fromList withObject:existingManga];
    }
    
    NSError *error = nil;
    
    Manga *manga = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    
    manga.manga_id = [data[kID] isKindOfClass:[NSString class]] ? @([data[kID] intValue]) : data[kID];
    manga.title = data[kTitle];
    
    manga.last_updated = data[kUserLastUpdated];
    
    NSDictionary *otherTitles = data[kOtherTitles];
    if(otherTitles[kSynonyms] && ![otherTitles[kSynonyms] isNull]) {
        for(NSString *synonym in otherTitles[kSynonyms]) {
            [SynonymService addSynonym:synonym toManga:manga];
        }
    }
    
    if(otherTitles[kEnglishTitles] && ![otherTitles[kEnglishTitles] isNull]) {
        for(NSString *englishTitle in otherTitles[kEnglishTitles]) {
            [SynonymService addEnglishTitle:englishTitle toManga:manga];
        }
    }
    
    if(otherTitles[kJapaneseTitles] && ![otherTitles[kJapaneseTitles] isNull]) {
        for(NSString *japaneseTitle in otherTitles[kJapaneseTitles]) {
            [SynonymService addJapaneseTitle:japaneseTitle toManga:manga];
        }
    }
    
    if(data[kRank] && ![data[kRank] isNull])
        manga.rank = data[kRank];
    
    if(data[kPopularityRank] && ![data[kPopularityRank] isNull])
        manga.popularity_rank = data[kPopularityRank];
    
    if(data[kMembersScore] && ![data[kMembersScore] isNull])
        manga.average_score = [data[kMembersScore] isKindOfClass:[NSString class]] ? @([data[kMembersScore] doubleValue]) : data[kMembersScore];
    
    if(data[kImageURL] && ![data[kImageURL] isNull])
        manga.image_url = data[kImageURL];
    else if(data[kImage] && ![data[kImage] isNull])
        manga.image_url = data[kImage];
    
    manga.type = @([Manga mangaTypeForValue:data[kType]]);
    manga.total_chapters = [data[kChapters] isNull] ? @(0) : [data[kChapters] isKindOfClass:[NSString class]] ? @([data[kChapters] intValue]) : data[kChapters];
    manga.total_volumes = [data[kVolumes] isNull] ? @(0) : [data[kVolumes] isKindOfClass:[NSString class]] ? @([data[kVolumes] intValue]) : data[kVolumes];
    manga.status = @([Manga mangaPublishStatusForValue:data[kSeriesStatus]]);
    
    // note: not the user start/end date.
    if(data[kSeriesStartDate] && ![data[kSeriesStartDate] isNull])
        manga.date_start = [NSDate parseDate:data[kSeriesStartDate]];
    if(data[kSeriesEndDate] && ![data[kSeriesEndDate] isNull])
        manga.date_finish = [NSDate parseDate:data[kSeriesEndDate]];
    
    if(data[kUserStartDate] && ![data[kUserStartDate] isNull])
        manga.user_date_start = [NSDate parseDate:data[kUserStartDate]];
    if(data[kUserEndDate] && ![data[kUserEndDate] isNull])
        manga.user_date_finish = [NSDate parseDate:data[kUserEndDate]];
    
    //    anime.classification = data[@"classification"];
    //    anime.average_score = data[@"members_score"];
    //    anime.average_count = data[@"members_count"];
    //    anime.favorited_count = data[@"favorited_count"];
    //    anime.synopsis = data[@"synopsis"];
    //    anime.genres = data[@"genres"];
    //    anime.tags = data[@"tags"];
    //    anime.manga_adaptations = data[@"manga_adaptations"];
    
    if(data[kUserReadStatus] && ![data[kUserReadStatus] isNull])
        manga.read_status = @([Manga mangaReadStatusForValue:data[kUserReadStatus]]);
    
    if(data[kUserChaptersRead] && ![data[kUserChaptersRead] isNull])
        manga.current_chapter = data[kUserChaptersRead];
    if(data[kUserVolumesRead] && ![data[kUserVolumesRead] isNull])
        manga.current_volume = data[kUserVolumesRead];
    
    if(data[kUserScore] && ![data[kUserScore] isNull])
        manga.user_score = ([data[kUserScore] isNull] || [data[kUserScore] intValue] == 0) ? @(-1) : [data[kUserScore] isKindOfClass:[NSString class]] ? @([data[kUserScore] intValue]) : data[kUserScore];
    
    if(!fromList)
        [[MangaService managedObjectContext] save:&error];
    
    if(!error) {
        return manga;
    }
    else return nil;
}

+ (Manga *)editManga:(NSDictionary *)data fromList:(BOOL)fromList withObject:(Manga *)manga {
    if(![MangaService mangaForID:data[kID]]) {
        ALLog(@"Manga does not exist; unable to edit!");
        return nil;
    }
    
    NSError *error = nil;
    
    manga.manga_id = [data[kID] isKindOfClass:[NSString class]] ? @([data[kID] intValue]) : data[kID];
    manga.title = [data[kTitle] stringByDecodingHTMLEntities];

    NSDictionary *otherTitles = data[kOtherTitles];
    if(otherTitles[kSynonyms] && ![otherTitles[kSynonyms] isNull]) {
        for(NSString *synonym in otherTitles[kSynonyms]) {
            [SynonymService addSynonym:synonym toManga:manga];
        }
    }
    
    if(otherTitles[kEnglishTitles] && ![otherTitles[kEnglishTitles] isNull]) {
        for(NSString *englishTitle in otherTitles[kEnglishTitles]) {
            [SynonymService addEnglishTitle:englishTitle toManga:manga];
        }
    }
    
    if(otherTitles[kJapaneseTitles] && ![otherTitles[kJapaneseTitles] isNull]) {
        for(NSString *japaneseTitle in otherTitles[kJapaneseTitles]) {
            [SynonymService addJapaneseTitle:japaneseTitle toManga:manga];
        }
    }
    
    // Genres
    if(data[kGenres] && ![data[kGenres] isNull]) {
        for(NSString *genre in data[kGenres]) {
            [GenreService addGenre:genre toManga:manga];
        }
    }
    
    // Tags
    if(data[kTag] && ![data[kTag] isNull]) {
        for(NSString *tag in data[kTag]) {
            [TagService addTag:tag toManga:manga];
        }
    }
    
    if(data[kRank] && ![data[kRank] isNull])
        manga.rank = data[kRank];
    
    if(data[kPopularityRank] && ![data[kPopularityRank] isNull])
        manga.popularity_rank = data[kPopularityRank];
    
    [MangaService parseRelatedInformation:data forManga:manga];
    
    if(data[kImageURL] && ![data[kImageURL] isNull])
        manga.image_url = data[kImageURL];
    else if(data[kImage] && ![data[kImage] isNull])
        manga.image_url = data[kImage];
    
    manga.type = @([Manga mangaTypeForValue:data[kType]]);
    manga.total_chapters = [data[kChapters] isNull] ? @(0) : [data[kChapters] isKindOfClass:[NSString class]] ? @([data[kChapters] intValue]) : data[kChapters];
    manga.total_volumes = [data[kVolumes] isNull] ? @(0) : [data[kVolumes] isKindOfClass:[NSString class]] ? @([data[kVolumes] intValue]) : data[kVolumes];
    manga.status = @([Manga mangaPublishStatusForValue:data[kSeriesStatus]]);
    
    if(data[kSeriesStartDate] && ![data[kSeriesStartDate] isNull])
        manga.date_start = [NSDate parseDate:data[kSeriesStartDate]];
    if(data[kSeriesEndDate] && ![data[kSeriesEndDate] isNull])
        manga.date_finish = [NSDate parseDate:data[kSeriesEndDate]];
    
    if(data[kUserStartDate] && ![data[kUserStartDate] isNull])
        manga.user_date_start = [NSDate parseDate:data[kUserStartDate]];
    if(data[kUserEndDate] && ![data[kUserEndDate] isNull])
        manga.user_date_finish = [NSDate parseDate:data[kUserEndDate]];
    
    //    anime.classification = data[@"classification"];
    if(data[kMembersScore] && ![data[kMembersScore] isNull])
        manga.average_score = [data[kMembersScore] isKindOfClass:[NSString class]] ? @([data[kMembersScore] doubleValue]) : data[kMembersScore];
    
    if(data[kMembersCount] &&![data[kMembersCount] isNull])
        manga.average_count = data[kMembersCount];
    if(data[kFavoritedCount] &&![data[kFavoritedCount] isNull])
        manga.favorited_count = data[kFavoritedCount];
    if(data[kSynopsis] &&![data[kSynopsis] isNull]) {
        manga.synopsis = [((NSString *)data[kSynopsis]) cleanHTMLTags];
        manga.synopsis = [manga.synopsis stringByDecodingHTMLEntities];
    }
    //    anime.genres = data[@"genres"];
    //    anime.tags = data[@"tags"];
    
    
    // User details below.
    NSNumber *lastUpdated = data[kUserLastUpdated];
    
    // If the last time we updated (according to the server) is less than what we get from the server,
    // don't bother updating user details.
    if(lastUpdated && [lastUpdated intValue] <= [manga.last_updated intValue]) {
        ALVLog(@"Update times match, no need to update user data.");
    }
    else {
        ALVLog(@"Update times differ, updating user data...");
        
        if(data[kUserReadStatus] && ![data[kUserReadStatus] isNull])
            manga.read_status = @([Manga mangaReadStatusForValue:data[kUserReadStatus]]);
        
        if(data[kUserChaptersRead] && ![data[kUserChaptersRead] isNull])
            manga.current_chapter = data[kUserChaptersRead];
        if(data[kUserVolumesRead] && ![data[kUserVolumesRead] isNull])
            manga.current_volume = data[kUserVolumesRead];
        
        if(data[kUserScore] && ![data[kUserScore] isNull])
            manga.user_score = ([data[kUserScore] isNull] || [data[kUserScore] intValue] == 0) ? @(-1) : [data[kUserScore] isKindOfClass:[NSString class]] ? @([data[kUserScore] intValue]) : data[kUserScore];
    }
        
    if(!fromList)
        [[MangaService managedObjectContext] save:&error];
    
    if(!error) {
        return manga;
    }
    else return nil;
    
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

#pragma mark - Data Conversion Methods

+ (void)parseRelatedInformation:(NSDictionary *)data forManga:(Manga *)manga {
    
    // Anime Adaptations
    if(data[kAnimeAdaptations] && ![data[kAnimeAdaptations] isNull]) {
        NSArray *animeAdaptations = data[kAnimeAdaptations];
        for(NSDictionary *animeAdaptation in animeAdaptations) {
            Anime *anime = [self addAnimeAdaptation:animeAdaptation toManga:manga];
            if(animeAdaptation) {
                ALLog(@"Anime adaptation found for %@ -> %@.", manga.title, anime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([anime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:anime.anime_id success:^(id operation, id response) {
                        [AnimeService addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:anime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get prequel.");
                    }];
                }
            }
        }
    }
    
    if(data[kRelatedManga] && ![data[kRelatedManga] isNull]) {
        NSArray *relatedMangas = data[kRelatedManga];
        for(NSDictionary *relatedManga in relatedMangas) {
            Manga *related = [self addRelatedManga:relatedManga toManga:manga relationType:MangaRelationRelatedManga];
            if(related) {
                ALLog(@"Related manga found for %@ -> %@.", manga.title, related.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([related.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getMangaDetailsForID:related.manga_id success:^(id operation, id response) {
                        [self addManga:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedMangaDidUpdate object:related];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get related manga.");
                    }];
                }
            }
        }
    }
    
    // Alternative Versions
    if(data[kAlternativeVersions] && ![data[kAlternativeVersions] isNull]) {
        NSArray *alternativeVersions = data[kAlternativeVersions];
        for(NSDictionary *alternativeVersion in alternativeVersions) {
            Manga *alternativeVersionManga = [self addRelatedManga:alternativeVersion toManga:manga relationType:MangaRelationAlternativeVersions];
            if(alternativeVersionManga) {
                ALLog(@"Alternative Version manga found for %@ -> %@.", manga.title, alternativeVersionManga.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([alternativeVersionManga.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getMangaDetailsForID:alternativeVersionManga.manga_id success:^(id operation, id response) {
                        [self addManga:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedMangaDidUpdate object:alternativeVersionManga];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get alternative version.");
                    }];
                }
            }
        }
    }
}

+ (NSString *)mangaToXML:(NSNumber *)mangaID {
    
    /*
     <chapter>6</chapter>
     <volume>1</volume>
     <status>1</status>
     <score>8</score>
     <downloaded_chapters></downloaded_chapters>
     <times_reread></times_reread>
     <reread_value></reread_value>
     <date_start></date_start>
     <date_finish></date_finish>
     <priority></priority>
     <enable_discussion></enable_discussion>
     <enable_rereading></enable_rereading>
     <comments></comments>
     <scan_group></scan_group>
     <tags></tags>
     <retail_volumes></retail_volumes>
     */
    
    Manga *manga = [MangaService mangaForID:mangaID];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMddyyyy";
    
    NSString *startDate = [dateFormatter stringFromDate:manga.user_date_start];
    NSString *endDate = [dateFormatter stringFromDate:manga.user_date_finish];
    
    NSMutableString *XML = [NSMutableString stringWithString:@"<entry>"];
    [XML appendString:[NSString stringWithFormat:@"<chapter>%d</chapter>", [manga.current_chapter intValue]]];
    [XML appendString:[NSString stringWithFormat:@"<volume>%d</volume>", [manga.current_volume intValue]]];
    [XML appendString:[NSString stringWithFormat:@"<status>%d</status>", [manga.read_status intValue]]];
    
    if([manga.user_score intValue] > 0)
        [XML appendString:[NSString stringWithFormat:@"<score>%d</score>", [manga.user_score intValue]]];
    
    if(startDate)
        [XML appendString:[NSString stringWithFormat:@"<date_start>%@</date_start>", startDate]];
    
    if(endDate)
        [XML appendString:[NSString stringWithFormat:@"<date_finish>%@</date_finish>", endDate]];
    
    [XML appendString:@"</entry>"];
    
    return XML;
}

@end
