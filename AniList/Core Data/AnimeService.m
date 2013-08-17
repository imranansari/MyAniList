//
//  AnimeService.m
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeService.h"
#import "AniListAppDelegate.h"
#import "MALHTTPClient.h"
#import "SynonymService.h"
#import "TagService.h"
#import "GenreService.h"
#import "MangaService.h"

#import "Friend.h"
#import "FriendAnime.h"
#import "FriendAnimeService.h"

#define ENTITY_NAME @"Anime"

@interface AnimeService()

@end

static NSArray *cachedAnimeList = nil;

@implementation AnimeService

/* Need to cover:
 other_titles -> english, japanese
 rank
 popularity_rank
 classification
 members_score
 members_count
 favorited_count
 synopsis
 genres
 tags
 manga_adaptations
 prequels
 sequels
 side_stories
 parent_story
 character_anime
 spin_offs
 summaries
 altenative_versions
 */

+ (NSArray *)allAnime {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
    request.entity = entity;
    
    NSError *error = nil;
    return [[AnimeService managedObjectContext] executeFetchRequest:request error:&error];
}

+ (Anime *)animeForID:(NSNumber *)ID {
    return [self animeForID:ID fromCache:NO];
}

+ (Anime *)animeForID:(NSNumber *)ID fromCache:(BOOL)fromCache {
    if(fromCache) {
        if(!cachedAnimeList) {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
            request.entity = entity;
            
            NSError *error = nil;
            cachedAnimeList = [[AnimeService managedObjectContext] executeFetchRequest:request error:&error];
        }
        
        for(Anime *anime in cachedAnimeList) {
            if([anime.anime_id intValue] == [ID intValue])
                return anime;
        }
        
        return nil;
    }
    else {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"anime_id == %d", [ID intValue]];
        request.entity = entity;
        request.predicate = predicate;
        request.fetchLimit = 1;
        
        NSError *error = nil;
        NSArray *results = [[AnimeService managedObjectContext] executeFetchRequest:request error:&error];
        
        if(results.count) {
            return (Anime *)results[0];
        }
        else return nil;
    }
}

+ (BOOL)addAnimeListFromSearch:(NSArray *)data {
    for(NSDictionary *result in data) {
        [AnimeService addAnime:result fromList:NO];
    }
    
    return NO;
}

+ (BOOL)addAnimeList:(NSDictionary *)data {
    
    NSDictionary *animeDetails = data[@"myanimelist"];
    NSArray *animes = animeDetails[@"anime"];
    NSDictionary *animeUserInfo = animeDetails[@"myinfo"];
    
    // This is just one anime.
    if([animes isKindOfClass:[NSDictionary class]]) {
        NSDictionary *soloAnime = (NSDictionary *)animes;
        animes = @[soloAnime];
    }
    
    cachedAnimeList = nil;
    
    MVComputeTimeWithNameAndBlock((const char *)"animelist", ^{
        for(NSDictionary *animeItem in animes) {
            NSMutableDictionary *anime = [AnimeService createDictionaryForAnime:animeItem];
            [AnimeService addAnime:anime fromList:YES];
        }
        
        [[AnimeService managedObjectContext] save:nil];
    });
    
    return NO;
}

+ (BOOL)addAnimeList:(NSDictionary *)data forFriend:(Friend *)friend {
    NSDictionary *animeDetails = data[@"myanimelist"];
    NSArray *animes = animeDetails[@"anime"];
    NSDictionary *animeUserInfo = animeDetails[@"myinfo"];
    
    // This is just one anime.
    if([animes isKindOfClass:[NSDictionary class]]) {
        NSDictionary *soloAnime = (NSDictionary *)animes;
        animes = @[soloAnime];
    }
    
    MVComputeTimeWithNameAndBlock((const char *)"friend_animelist", ^{
        for(NSDictionary *animeItem in animes) {
            
            NSMutableDictionary *animeDictionary = [AnimeService createDictionaryForAnime:animeItem];
            
            NSNumber *friendScore = animeDictionary[kUserScore];
            NSNumber *friendCurrentEpisode = animeDictionary[kUserWatchedEpisodes];
            NSString *friendWatchedStatus = animeDictionary[kUserWatchedStatus];
            
            [animeDictionary removeObjectForKey:kUserScore];
            [animeDictionary removeObjectForKey:kUserWatchedEpisodes];
            [animeDictionary removeObjectForKey:kUserWatchedStatus];
            
            Anime *anime = [AnimeService addAnime:animeDictionary fromList:NO];
            FriendAnime *friendAnime = [FriendAnimeService addFriend:friend toAnime:anime];
            
            if(friendScore && ![friendScore isNull])
                friendAnime.score = [friendScore intValue] == 0 ? @(-1) : [friendScore isKindOfClass:[NSString class]] ? @([friendScore intValue]) : friendScore;
            
            if(friendWatchedStatus && ![friendWatchedStatus isNull])
                friendAnime.watched_status = @([Anime animeWatchedStatusForValue:friendWatchedStatus]);
            
            if(friendCurrentEpisode && ![friendCurrentEpisode isNull])
                friendAnime.current_episode = friendCurrentEpisode;
            
        }
        
        [[AnimeService managedObjectContext] save:nil];
    });
    
    return NO;
}

+ (NSMutableDictionary *)createDictionaryForAnime:(NSDictionary *)animeItem {
    NSMutableDictionary *anime = [[NSMutableDictionary alloc] init];
    
    [anime addEntriesFromDictionary:@{ kID : @([animeItem[@"series_animedb_id"][@"text"] intValue]) } ];
    [anime addEntriesFromDictionary:@{ kUserEndDate : animeItem[@"my_finish_date"][@"text"] }];
    [anime addEntriesFromDictionary:@{ kUserLastUpdated : @([animeItem[@"my_last_updated"][@"text"] intValue]) }];
    [anime addEntriesFromDictionary:@{ kUserStartDate : animeItem[@"my_start_date"][@"text"] }];
    [anime addEntriesFromDictionary:@{ kUserRewatchingStatus : @([animeItem[@"my_rewatching"][@"text"] intValue]) }];
    [anime addEntriesFromDictionary:@{ kUserRewatchingEpisode : @([animeItem[@"my_rewatching_ep"][@"text"] intValue]) }];
    [anime addEntriesFromDictionary:@{ kUserScore : @([animeItem[@"my_score"][@"text"] intValue]) }];
    [anime addEntriesFromDictionary:@{ kUserWatchedStatus : animeItem[@"my_status"][@"text"] }];
    
    [anime addEntriesFromDictionary:@{ kUserWatchedEpisodes : @([animeItem[@"my_watched_episodes"][@"text"] intValue]) }];
    [anime addEntriesFromDictionary:@{ kAirEndDate : animeItem[@"series_end"][@"text"] }];
    [anime addEntriesFromDictionary:@{ kEpisodes : @([animeItem[@"series_episodes"][@"text"] intValue]) }];
    [anime addEntriesFromDictionary:@{ kImageURL : animeItem[@"series_image"][@"text"] }];
    [anime addEntriesFromDictionary:@{ kAirStartDate : animeItem[@"series_start"][@"text"] }];
    [anime addEntriesFromDictionary:@{ kAirStatus : animeItem[@"series_status"][@"text"] }];
    
    NSString *synonyms = animeItem[@"series_synonyms"][@"text"];
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
        [anime addEntriesFromDictionary:otherTitles];
    }
    
#warning - no support for user generated tags so far.
    //            NSString *tags = animeItem[@"my_tags"][@"text"];
    //            NSArray *tagsArray = [tags componentsSeparatedByString:@","];
    //            NSMutableArray *tagResults = [NSMutableArray array];
    //
    //            for(int i = 0; i < tagsArray.count; i++) {
    //                NSString *tag = tagsArray[i];
    //                tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //                if(tag.length > 0)
    //                    [tagResults addObject:tag];
    //            }
    //
    //            if(tagResults.count > 0) {
    //                NSDictionary *animeTags = @{ kTag : tagResults };
    //                [anime addEntriesFromDictionary:animeTags];
    //            }
    
    [anime addEntriesFromDictionary:@{ kTitle : animeItem[@"series_title"][@"text"] }];
    [anime addEntriesFromDictionary:@{ kType : animeItem[@"series_type"][@"text"] }];

    return anime;
}

+ (Anime *)addAnime:(NSDictionary *)data fromRelatedManga:(Manga *)manga {
    Anime *relatedAnime = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
    relatedAnime.anime_id = [data[@"anime_id"] isKindOfClass:[NSString class]] ? @([data[@"anime_id"] intValue]) : data[@"anime_id"];
    relatedAnime.title = data[kTitle];
    
    [relatedAnime addManga_adaptationsObject:manga];
    
    return relatedAnime;
}

+ (Manga *)addMangaAdaptation:(NSDictionary *)data toAnime:(Anime *)anime {
    Manga *mangaAdaptation = [MangaService mangaForID:data[@"manga_id"]];
    
    if(mangaAdaptation) {
        ALLog(@"Manga adaptation '%@' exists for '%@'.", mangaAdaptation.title, anime.title);
    }
    else {
        // Add Manga here.
        ALLog(@"Manga adaptation '%@' does not exist for '%@'. Adding to the database.", mangaAdaptation.title, anime.title);
        mangaAdaptation = [MangaService addManga:data fromRelatedAnime:anime];
    }
    
    [anime addManga_adaptationsObject:mangaAdaptation];
    
    return mangaAdaptation;
}

+ (Anime *)addRelatedAnime:(NSDictionary *)data toAnime:(Anime *)anime relationType:(AnimeRelation)relationType {
    Anime *relatedAnime = [AnimeService animeForID:data[@"anime_id"] fromCache:NO];
    
    if(relatedAnime) {
        ALLog(@"Related anime exists.");
    }
    else {
        ALLog(@"Related anime does not exist. Creating.");
        relatedAnime = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
        relatedAnime.anime_id = [data[@"anime_id"] isKindOfClass:[NSString class]] ? @([data[@"anime_id"] intValue]) : data[@"anime_id"];
        relatedAnime.title = data[kTitle];
    }
    
    switch (relationType) {
        case AnimeRelationPrequel:
            [relatedAnime addSequelsObject:anime];
            [anime addPrequelsObject:relatedAnime];
            break;
        case AnimeRelationSequel:
            [relatedAnime addPrequelsObject:anime];
            [anime addSequelsObject:relatedAnime];
            break;
        case AnimeRelationSideStory:
            [anime addSide_storiesObject:relatedAnime];
            break;
        case AnimeRelationCharacterAnime:
            [anime addCharacter_animeObject:relatedAnime];
            break;
        case AnimeRelationSpinOff:
            [anime addSpin_offsObject:relatedAnime];
            break;
        case AnimeRelationParentStory:
            [anime addParent_storyObject:relatedAnime];
            break;
        case AnimeRelationAlternativeVersions:
            [anime addAlternative_versionsObject:relatedAnime];
            break;
        case AnimeRelationSummaries:
            [anime addSummariesObject:relatedAnime];
            break;
        default:
            break;
    }
    
    return relatedAnime;
}

+ (Anime *)addAnime:(NSDictionary *)data fromList:(BOOL)fromList {
    Anime *existingAnime = [AnimeService animeForID:data[kID] fromCache:fromList];
    
    if(existingAnime) {
        ALLog(@"Anime exists. Updating details.");
        return [AnimeService editAnime:data fromList:fromList withObject:existingAnime];
    }
    
    NSError *error = nil;
    
    Anime *anime = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
    
    anime.anime_id = [data[kID] isKindOfClass:[NSString class]] ? @([data[kID] intValue]) : data[kID];
    anime.title = data[kTitle];
    
    anime.last_updated = data[kUserLastUpdated];
    
    NSDictionary *otherTitles = data[kOtherTitles];
    if(otherTitles[kSynonyms] && ![otherTitles[kSynonyms] isNull]) {
        for(NSString *synonym in otherTitles[kSynonyms]) {
            [SynonymService addSynonym:synonym toAnime:anime];
        }
    }
    
    if(otherTitles[kEnglishTitles] && ![otherTitles[kEnglishTitles] isNull]) {
        for(NSString *englishTitle in otherTitles[kEnglishTitles]) {
            [SynonymService addEnglishTitle:englishTitle toAnime:anime];
        }
    }
    
    if(otherTitles[kJapaneseTitles] && ![otherTitles[kJapaneseTitles] isNull]) {
        for(NSString *japaneseTitle in otherTitles[kJapaneseTitles]) {
            [SynonymService addJapaneseTitle:japaneseTitle toAnime:anime];
        }
    }
    
    if(data[kRank] && ![data[kRank] isNull])
        anime.rank = data[kRank];
    
    if(data[kPopularityRank] && ![data[kPopularityRank] isNull])
        anime.popularity_rank = data[kPopularityRank];
    
    if(data[kMembersScore] && ![data[kMembersScore] isNull])
        anime.average_score = [data[kMembersScore] isKindOfClass:[NSString class]] ? @([data[kMembersScore] doubleValue]) : data[kMembersScore];
    
    if(data[kImageURL] && ![data[kImageURL] isNull])
        anime.image_url = data[kImageURL];
    else if(data[kImage] && ![data[kImage] isNull])
        anime.image_url = data[kImage];
    
    // Strip out any letters in the filename.
    if(anime.image_url) {
        NSString *extension = [[anime.image_url lastPathComponent] pathExtension];
        NSString *filename = [[anime.image_url lastPathComponent] stringByDeletingPathExtension];
        NSString *path = [anime.image_url stringByDeletingLastPathComponent];
        filename = [filename stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
        filename = [NSString stringWithFormat:@"%@/%@.%@", path, filename, extension];
        anime.image_url = filename;
    }
    
    anime.type = @([Anime animeTypeForValue:data[kType]]);
    anime.total_episodes = [data[kEpisodes] isNull] ? @(-1) : [data[kEpisodes] isKindOfClass:[NSString class]] ? @([data[kEpisodes] intValue]) : data[kEpisodes];
    
    if(data[kAirStartDate] && ![data[kAirStatus] isNull])
        anime.status = @([Anime animeAirStatusForValue:data[kAirStatus]]);
    
    // note: not the user start/end date
    if(data[kAirStartDate] && ![data[kAirStartDate] isNull])
        anime.date_start = [NSDate parseDate:data[kAirStartDate]];
    if(data[kAirEndDate] && ![data[kAirEndDate] isNull])
        anime.date_finish = [NSDate parseDate:data[kAirEndDate]];
    
    if(data[kUserStartDate] && ![data[kUserStartDate] isNull])
        anime.user_date_start = [NSDate parseDate:data[kUserStartDate]];
    if(data[kUserEndDate] && ![data[kUserEndDate] isNull])
        anime.user_date_finish = [NSDate parseDate:data[kUserEndDate]];
    
//    anime.classification = data[@"classification"];
//    anime.average_score = data[@"members_score"];
//    anime.average_count = data[@"members_count"];
//    anime.favorited_count = data[@"favorited_count"];
//    anime.synopsis = data[@"synopsis"];
//    anime.genres = data[@"genres"];
//    anime.tags = data[@"tags"];
//    anime.manga_adaptations = data[@"manga_adaptations"];
    
    if(data[kUserWatchedStatus] && ![data[kUserWatchedStatus] isNull])
        anime.watched_status = @([Anime animeWatchedStatusForValue:data[kUserWatchedStatus]]);
    
    if(data[kUserWatchedEpisodes] && ![data[kUserWatchedEpisodes] isNull])
        anime.current_episode = data[kUserWatchedEpisodes];
    
    if(data[kUserScore] && ![data[kUserScore] isNull])
        anime.user_score = [data[kUserScore] intValue] == 0 ? @(-1) : [data[kUserScore] isKindOfClass:[NSString class]] ? @([data[kUserScore] intValue]) : data[kUserScore];
    
    if(!fromList)
        [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        return anime;
    }
    else return nil;
}

+ (Anime *)editAnime:(NSDictionary *)data fromList:(BOOL)fromList withObject:(Anime *)anime {
    if(!anime) {
        ALLog(@"Anime does not exist; unable to edit!");
        return nil;
    }
    
    NSError *error = nil;
    
    anime.anime_id = [data[kID] isKindOfClass:[NSString class]] ? @([data[kID] intValue]) : data[kID];
    anime.title = [data[kTitle] stringByDecodingHTMLEntities];
    
    NSDictionary *otherTitles = data[kOtherTitles];
    if(otherTitles[kSynonyms] && ![otherTitles[kSynonyms] isNull]) {
        for(NSString *synonym in otherTitles[kSynonyms]) {
            [SynonymService addSynonym:synonym toAnime:anime];
        }
    }
    
    if(otherTitles[kEnglishTitles] && ![otherTitles[kEnglishTitles] isNull]) {
        for(NSString *englishTitle in otherTitles[kEnglishTitles]) {
            [SynonymService addEnglishTitle:englishTitle toAnime:anime];
        }
    }
    
    if(otherTitles[kJapaneseTitles] && ![otherTitles[kJapaneseTitles] isNull]) {
        for(NSString *japaneseTitle in otherTitles[kJapaneseTitles]) {
            [SynonymService addJapaneseTitle:japaneseTitle toAnime:anime];
        }
    }
    
    // Genres
    if(data[kGenres] && ![data[kGenres] isNull]) {
        for(NSString *genre in data[kGenres]) {
            [GenreService addGenre:genre toAnime:anime];
        }
    }
    
    // Tags
    if(data[kTag] && ![data[kTag] isNull]) {
        for(NSString *tag in data[kTag]) {
            [TagService addTag:tag toAnime:anime];
        }
    }

    if(data[kRank] && ![data[kRank] isNull])
        anime.rank = data[kRank];
    
    if(data[kPopularityRank] && ![data[kPopularityRank] isNull])
        anime.popularity_rank = data[kPopularityRank];
    
    [AnimeService parseRelatedInformation:data forAnime:anime];
    
    if(data[kImageURL] && ![data[kImageURL] isNull])
        anime.image_url = data[kImageURL];
    
    // Strip out any letters in the filename.
    if(anime.image_url) {
        NSString *extension = [[anime.image_url lastPathComponent] pathExtension];
        NSString *filename = [[anime.image_url lastPathComponent] stringByDeletingPathExtension];
        NSString *path = [anime.image_url stringByDeletingLastPathComponent];
        filename = [filename stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
        filename = [NSString stringWithFormat:@"%@/%@.%@", path, filename, extension];
        anime.image_url = filename;
    }
    
    anime.type = @([Anime animeTypeForValue:data[kType]]);
    anime.total_episodes = [data[kEpisodes] isNull] ? @(-1) : [data[kEpisodes] isKindOfClass:[NSString class]] ? @([data[kEpisodes] intValue]) : data[kEpisodes];
    
    if(data[kAirStartDate] && ![data[kAirStatus] isNull])
        anime.status = @([Anime animeAirStatusForValue:data[kAirStatus]]);
    
    if(data[kAirStartDate] && ![data[kAirStartDate] isNull])
        anime.date_start = [NSDate parseDate:data[kAirStartDate]];
    if(data[kAirEndDate] && ![data[kAirEndDate] isNull])
        anime.date_finish = [NSDate parseDate:data[kAirEndDate]];
    
    //    anime.classification = data[@"classification"];
    if(data[kMembersScore] && ![data[kMembersScore] isNull])
        anime.average_score = [data[kMembersScore] isKindOfClass:[NSString class]] ? @([data[kMembersScore] doubleValue]) : data[kMembersScore];
    if(data[kMembersCount] &&![data[kMembersCount] isNull])
        anime.average_count = data[kMembersCount];
    if(data[kFavoritedCount] &&![data[kFavoritedCount] isNull])
        anime.favorited_count = data[kFavoritedCount];
    if(data[kSynopsis] &&![data[kSynopsis] isNull]) {
        anime.synopsis = [((NSString *)data[kSynopsis]) cleanHTMLTags];
        anime.synopsis = [anime.synopsis stringByConvertingHTMLToPlainText];
    }
    //    anime.genres = data[@"genres"];
    //    anime.tags = data[@"tags"];
    
    
    
    // User details below.
    NSNumber *lastUpdated = data[kUserLastUpdated];
    
    // If the last time we updated (according to the server) is less than what we get from the server,
    // don't bother updating user details.
    if(lastUpdated && [lastUpdated intValue] <= [anime.last_updated intValue]) {
        ALLog(@"Update times match, no need to update user data.");
    }
    else {
        ALLog(@"Update times differ, updating user data...");
        
        if(data[kUserStartDate] && ![data[kUserStartDate] isNull])
            anime.user_date_start = [NSDate parseDate:data[kUserStartDate]];
        if(data[kUserEndDate] && ![data[kUserEndDate] isNull])
            anime.user_date_finish = [NSDate parseDate:data[kUserEndDate]];
        
        if(data[kUserWatchedStatus] && ![data[kUserWatchedStatus] isNull])
            anime.watched_status = @([Anime animeWatchedStatusForValue:data[kUserWatchedStatus]]);
        
        if(data[kUserWatchedEpisodes] && ![data[kUserWatchedEpisodes] isNull])
            anime.current_episode = data[kUserWatchedEpisodes];
        
        if(data[kUserScore] && ![data[kUserScore] isNull])
            anime.user_score = ([data[kUserScore] isNull] || [data[kUserScore] intValue] == 0) ? @(-1) : [data[kUserScore] isKindOfClass:[NSString class]] ? @([data[kUserScore] intValue]) : data[kUserScore];
    }
    
    if(!fromList)
        [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        return anime;
    }
    else return nil;

}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

#pragma mark - Data Conversion Methods

+ (void)parseRelatedInformation:(NSDictionary *)data forAnime:(Anime *)anime {
    
    // Prequels
    if(data[kPrequels] && ![data[kPrequels] isNull]) {
        NSArray *prequels = data[kPrequels];
        for(NSDictionary *prequel in prequels) {
            Anime *prequelAnime = [self addRelatedAnime:prequel toAnime:anime relationType:AnimeRelationPrequel];
            if(prequelAnime) {
                ALLog(@"Prequel found for %@ -> %@.", anime.title, prequelAnime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([prequelAnime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:prequelAnime.anime_id success:^(id operation, id response) {
                        [self addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:prequelAnime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get prequel.");
                    }];
                }
            }
        }
    }
    
    // Sequels
    if(data[kSequels] && ![data[kSequels] isNull]) {
        NSArray *sequels = data[kSequels];
        for(NSDictionary *sequel in sequels) {
            Anime *sequelAnime = [self addRelatedAnime:sequel toAnime:anime relationType:AnimeRelationSequel];
            if(sequelAnime) {
                ALLog(@"Sequel found for %@ -> %@.", anime.title, sequelAnime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([sequelAnime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:sequelAnime.anime_id success:^(id operation, id response) {
                        [self addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:sequelAnime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get sequel.");
                    }];
                }
            }
        }
    }
    
    // Manga Adaptations
    if(data[kMangaAdaptations] && ![data[kMangaAdaptations] isNull]) {
        NSArray *mangaAdaptations = data[kMangaAdaptations];
        for(NSDictionary *mangaAdaptation in mangaAdaptations) {
            Manga *manga = [self addMangaAdaptation:mangaAdaptation toAnime:anime];
            if(manga) {
                ALLog(@"Manga adaptation found for %@ -> %@.", anime.title, manga.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([manga.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getMangaDetailsForID:manga.manga_id success:^(id operation, id response) {
                        [MangaService addManga:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedMangaDidUpdate object:manga];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get manga.");
                    }];
                }
            }
        }
    }
    
    // Side Stories
    if(data[kSideStores] && ![data[kSideStores] isNull]) {
        NSArray *sideStories = data[kSideStores];
        for(NSDictionary *sideStory in sideStories) {
            Anime *sideStoryAnime = [self addRelatedAnime:sideStory toAnime:anime relationType:AnimeRelationSideStory];
            if(sideStoryAnime) {
                ALLog(@"Side story found for %@ -> %@.", anime.title, sideStoryAnime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([sideStoryAnime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:sideStoryAnime.anime_id success:^(id operation, id response) {
                        [self addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:sideStoryAnime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get side story.");
                    }];
                }
            }
        }
    }
    
    // Parent Story
    if(data[kParentStory] && ![data[kParentStory] isNull]) {
        
        NSArray *parentStories = nil;
        if([data[kParentStory] isKindOfClass:[NSDictionary class]]) {
            parentStories = @[data[kParentStory]];
        }
        else {
            parentStories = data[kParentStory];
        }
        
        for(NSDictionary *parentStory in parentStories) {
            Anime *parentStoryAnime = [self addRelatedAnime:parentStory toAnime:anime relationType:AnimeRelationParentStory];
            if(parentStoryAnime) {
                ALLog(@"Parent story found for %@ -> %@.", anime.title, parentStoryAnime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([parentStoryAnime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:parentStoryAnime.anime_id success:^(id operation, id response) {
                        [self addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:parentStoryAnime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get parent story.");
                    }];
                }
            }
        }
    }
    
    // Character Anime
    if(data[kCharacterAnime] && ![data[kCharacterAnime] isNull]) {
        NSArray *characters = data[kCharacterAnime];
        for(NSDictionary *character in characters) {
            Anime *characterAnime = [self addRelatedAnime:character toAnime:anime relationType:AnimeRelationCharacterAnime];
            if(character) {
                ALLog(@"Character anime found for %@ -> %@.", anime.title, characterAnime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([characterAnime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:characterAnime.anime_id success:^(id operation, id response) {
                        [self addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:characterAnime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get character anime.");
                    }];
                }
            }
        }
    }
    
    // Spin Offs
    if(data[kSpinOffs] && ![data[kSpinOffs] isNull]) {
        NSArray *spinoffs = data[kSpinOffs];
        for(NSDictionary *spinoff in spinoffs) {
            Anime *spinoffAnime = [self addRelatedAnime:spinoff toAnime:anime relationType:AnimeRelationSpinOff];
            if(spinoffAnime) {
                ALLog(@"Spinoff anime found for %@ -> %@.", anime.title, spinoffAnime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([spinoffAnime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:spinoffAnime.anime_id success:^(id operation, id response) {
                        [self addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:spinoffAnime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get spinoff.");
                    }];
                }
            }
        }
    }
    
    // Summaries
    if(data[kSummaries] && ![data[kSummaries] isNull]) {
        NSArray *summaries = data[kSummaries];
        for(NSDictionary *summary in summaries) {
            Anime *summaryAnime = [self addRelatedAnime:summary toAnime:anime relationType:AnimeRelationSummaries];
            if(summaryAnime) {
                ALLog(@"Summary anime found for %@ -> %@.", anime.title, summaryAnime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([summaryAnime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:summaryAnime.anime_id success:^(id operation, id response) {
                        [self addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:summaryAnime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get summary anime.");
                    }];
                }
            }
        }
    }
    
    // Alternative Versions
    if(data[kAlternativeVersions] && ![data[kAlternativeVersions] isNull]) {
        NSArray *alternativeVersions = data[kAlternativeVersions];
        for(NSDictionary *alternativeVersion in alternativeVersions) {
            Anime *alternativeVersionAnime = [self addRelatedAnime:alternativeVersion toAnime:anime relationType:AnimeRelationAlternativeVersions];
            if(alternativeVersionAnime) {
                ALLog(@"Alternative Version anime found for %@ -> %@.", anime.title, alternativeVersionAnime.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([alternativeVersionAnime.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getAnimeDetailsForID:alternativeVersionAnime.anime_id success:^(id operation, id response) {
                        [self addAnime:response fromList:NO];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRelatedAnimeDidUpdate object:alternativeVersionAnime];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get alternative version.");
                    }];
                }
            }
        }
    }
}

+ (NSString *)animeToXML:(NSNumber *)animeID {
    
    /*
     <?xml version="1.0" encoding="UTF-8"?>
     <entry>
     <episode>11</episode>
     <status>1</status>
     <score>7</score>
     <downloaded_episodes></downloaded_episodes>
     <storage_type></storage_type>
     <storage_value></storage_value>
     <times_rewatched></times_rewatched>
     <rewatch_value></rewatch_value>
     <date_start></date_start>
     <date_finish></date_finish>
     <priority></priority>
     <enable_discussion></enable_discussion>
     <enable_rewatching></enable_rewatching>
     <comments></comments>
     <fansub_group></fansub_group>
     <tags>test tag, 2nd tag</tags>
     </entry>
     */
    
    Anime *anime = [AnimeService animeForID:animeID];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMddyyyy";
    
    NSString *startDate = [dateFormatter stringFromDate:anime.user_date_start];
    NSString *endDate = [dateFormatter stringFromDate:anime.user_date_finish];
    
    NSMutableString *XML = [NSMutableString stringWithString:@"<entry>"];
    [XML appendString:[NSString stringWithFormat:@"<episode>%d</episode>", [anime.current_episode intValue]]];
    [XML appendString:[NSString stringWithFormat:@"<status>%d</status>", [anime.watched_status intValue]]];

    if([anime.user_score intValue] > 0)
        [XML appendString:[NSString stringWithFormat:@"<score>%d</score>", [anime.user_score intValue]]];
    
    if(startDate)
        [XML appendString:[NSString stringWithFormat:@"<date_start>%@</date_start>", startDate]];
    
    if(endDate)
        [XML appendString:[NSString stringWithFormat:@"<date_finish>%@</date_finish>", endDate]];

    [XML appendString:@"</entry>"];
    
    return XML;
}

@end
