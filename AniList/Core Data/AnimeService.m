//
//  AnimeService.m
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeService.h"
#import "AniListAppDelegate.h"

#define ENTITY_NAME @"Anime"

#define kID                     @"id"
#define kTitle                  @"title"
#define kOtherTitles            @"other_titles"
#define kSynopsis               @"synopsis"
#define kType                   @"type"
#define kRank                   @"rank"
#define kPopularityRank         @"popularity_rank"
#define kImageURL               @"image_url"
#define kEpisodes               @"episodes"
#define kAirStatus              @"status"
#define kAirStartDate           @"start_date"
#define kAirEndDate             @"end_date"
#define kGenres                 @"genres"
#define kTag                    @"tags"
#define kClassicication         @"classification"
#define kMembersScore           @"members_score"
#define kMembersCount           @"members_count"
#define kFavoritedCount         @"favorited_count"
#define kMangaAdaptations       @"manga_adaptations"
#define kPrequels               @"prequels"
#define kSequels                @"sequels"  
#define kSideStores             @"side_stories"
#define kParentStory            @"parent_story"
#define kCharacterAnime         @"character_anime"
#define kSpinOffs               @"spin_offs"
#define kSummaries              @"summaries"
#define kAlternativeVersions    @"alternative_versions"
#define kListedAnimeID          @"listed_anime_id"
#define kUserWatchedEpisodes    @"watched_episodes"
#define kUserScore              @"score"
#define kUserWatchedStatus      @"watched_status"
#define kUserStartDate          @"user_start_date"
#define kUserEndDate            @"user_end_date"
#define kUserRewatchingStatus   @"user_rewatching_status"
#define kUserRewatchingEpisode  @"user_rewatching_episode"
#define kUserLastUpdated        @"user_last_updated"


@implementation AnimeService

+ (Anime *)animeForID:(NSNumber *)ID {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"anime_id == %d", [ID intValue]];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[AnimeService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (Anime *)results[0];
    }
    else return nil;
}

+ (BOOL)addAnimeList:(NSDictionary *)data {
    
    NSDictionary *animeDetails = data[@"myanimelist"];
    NSDictionary *animeDictionary = animeDetails[@"anime"];
    NSDictionary *animeUserInfo = animeDetails[@"myinfo"];
    
    for(NSDictionary *animeItem in animeDictionary) {
        NSMutableDictionary *anime = [[NSMutableDictionary alloc] init];
        
        [anime addEntriesFromDictionary:@{ kID : @([animeItem[@"series_animedb_id"][@"text"] intValue]) } ];
        [anime addEntriesFromDictionary:@{ kUserEndDate : animeItem[@"my_finish_date"][@"text"] }];
        [anime addEntriesFromDictionary:@{ kUserLastUpdated : @([animeItem[@"my_last_updated"][@"text"] intValue]) }];
        [anime addEntriesFromDictionary:@{ kUserStartDate : animeItem[@"my_start_date"][@"text"] }];
        [anime addEntriesFromDictionary:@{ kUserRewatchingStatus : @([animeItem[@"my_rewatching"][@"text"] intValue]) }];
        [anime addEntriesFromDictionary:@{ kUserRewatchingEpisode : @([animeItem[@"my_rewatching_ep"][@"text"] intValue]) }];
        [anime addEntriesFromDictionary:@{ kUserScore : @([animeItem[@"my_score"][@"text"] intValue]) }];
        [anime addEntriesFromDictionary:@{ kUserWatchedStatus : animeItem[@"my_status"][@"text"] }];
        
        // no tag support...yet.
//        [anime addEntriesFromDictionary:@{ @"user_tags" : animeItem[@"my_tags"][@"text"] }];
        
        [anime addEntriesFromDictionary:@{ kUserWatchedEpisodes : @([animeItem[@"my_watched_episodes"][@"text"] intValue]) }];
        [anime addEntriesFromDictionary:@{ kAirEndDate : animeItem[@"series_end"][@"text"] }];
        [anime addEntriesFromDictionary:@{ kEpisodes : @([animeItem[@"series_episodes"][@"text"] intValue]) }];
        [anime addEntriesFromDictionary:@{ kImageURL : animeItem[@"series_image"][@"text"] }];
        [anime addEntriesFromDictionary:@{ kAirStartDate : animeItem[@"series_start"][@"text"] }];
        [anime addEntriesFromDictionary:@{ kAirStatus : animeItem[@"series_status"][@"text"] }];
        
        // no synonym support...yet.
//        [anime addEntriesFromDictionary:@{ @"series_synonyms" : animeItem[@"series_synonyms"][@"text"] }];
        
        [anime addEntriesFromDictionary:@{ kTitle : animeItem[@"series_title"][@"text"] }];
        [anime addEntriesFromDictionary:@{ kType : animeItem[@"series_type"][@"text"] }];
        
        [AnimeService addAnime:anime];
    }
    
    return NO;
}

+ (Anime *)addAnime:(NSDictionary *)data {
    if([AnimeService animeForID:data[@"id"]]) {
        NSLog(@"Anime exists. Updating details.");
        return [AnimeService editAnime:data];
    }
    
    NSError *error = nil;
    
    Anime *anime = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
    
    anime.anime_id = data[kID];
    anime.title = data[kTitle];
    
//    anime.synonyms = data[@"other_titles"];
    // english
    // japanese
    
    // rank (global)
    // popularity_rank
    
    anime.image = data[kImageURL];
    anime.type = @([Anime animeTypeForValue:data[kType]]);
    anime.total_episodes = [data[kEpisodes] isNull] ? @(-1) : data[kEpisodes];
    anime.status = @([Anime animeAirStatusForValue:data[kAirStatus]]);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // There exist two date formats. Should probably consolidate this somehow.
    // Typically, we'd add a Z for timezone instead of hardcoding +0000, but we want to preserve the raw date
    // since it seems like timezones are not used in the database.
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    // note: not the user start/end date.
    anime.date_start = [dateFormatter dateFromString:data[kAirStartDate]];
    anime.date_finish = [dateFormatter dateFromString:data[kAirEndDate]];
    
    anime.user_date_start = [dateFormatter dateFromString:data[kUserStartDate]];
    anime.user_date_finish = [dateFormatter dateFromString:data[kUserEndDate]];
    
//    anime.classification = data[@"classification"];
//    anime.average_score = data[@"members_score"];
//    anime.average_count = data[@"members_count"];
//    anime.favorited_count = data[@"favorited_count"];
//    anime.synopsis = data[@"synopsis"];
//    anime.genres = data[@"genres"];
//    anime.tags = data[@"tags"];
//    anime.manga_adaptations = data[@"manga_adaptations"];
    
    anime.watched_status = @([Anime animeWatchedStatusForValue:data[kUserWatchedStatus]]);
    anime.current_episode = data[kUserWatchedEpisodes];
    anime.user_score = [data[kUserScore] intValue] == 0 ? @(-1) : data[kUserScore];
    
    [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        return anime;
    }
    else return nil;
}

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


+ (Anime *)editAnime:(NSDictionary *)data {
    NSLog(@"data: %@", data);
    if(![AnimeService animeForID:data[kID]]) {
        NSLog(@"Anime does not exist; unable to edit!");
        return nil;
    }
    
    NSError *error = nil;
    
    Anime *anime = [AnimeService animeForID:data[kID]];
    
    anime.anime_id = data[kID];
    anime.title = data[kTitle];
    //    anime.synonyms = data[@"other_titles"];
    // english
    // japanese
    
    // rank (global)
    if(data[kRank] && ![data[kRank] isNull])
        anime.rank = data[kRank];
    
    if(data[kPopularityRank] && ![data[kPopularityRank] isNull])
        anime.popularity_rank = data[kPopularityRank];
    
    // Prequels/sequels
    if(data[kPrequels] && ![data[kPrequels] isNull]) {
        NSArray *prequels = data[kPrequels];
        for(NSDictionary *prequel in prequels) {
#warning - fix this later.
//            [AnimeService addAnime:prequel];
        }
    }
    
    anime.image = data[kImageURL];
    anime.type = @([Anime animeTypeForValue:data[kType]]);
    anime.total_episodes = [data[kEpisodes] isNull] ? @(-1) : data[kEpisodes];
    anime.status = @([Anime animeAirStatusForValue:data[kAirStatus]]);
    
    if(data[kAirStartDate] &&![data[kAirStartDate] isNull])
        anime.date_start = [AnimeService parseDate:data[kAirStartDate]];
    if(data[kAirEndDate] &&![data[kAirEndDate] isNull])
        anime.date_finish = [AnimeService parseDate:data[kAirEndDate]];
    
    //    anime.classification = data[@"classification"];
    if(data[kMembersScore] && ![data[kMembersScore] isNull])
        anime.average_score = data[kMembersScore];
    if(data[kMembersCount] &&![data[kMembersCount] isNull])
        anime.average_count = data[kMembersCount];
    if(data[kFavoritedCount] &&![data[kFavoritedCount] isNull])
        anime.favorited_count = data[kFavoritedCount];
    if(data[kSynopsis] &&![data[kSynopsis] isNull]) {
        anime.synopsis = [((NSString *)data[kSynopsis]) cleanHTMLTags];
    }
    //    anime.genres = data[@"genres"];
    //    anime.tags = data[@"tags"];
    //    anime.manga_adaptations = data[@"manga_adaptations"];
    
    anime.watched_status = @([Anime animeWatchedStatusForValue:data[kUserWatchedStatus]]);
    anime.current_episode = data[kUserWatchedEpisodes];
    anime.user_score = ([data[kUserScore] isNull] || [data[kUserScore] intValue] == 0) ? @(-1) : data[kUserScore];
    
    
    [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        return anime;
    }
    else return nil;
}

+ (void)deleteAnime:(Anime *)anime {
    NSError *error = nil;
    
    [[AnimeService managedObjectContext] deleteObject:anime];
    [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        NSLog(@"There was an error trying to delete this anime with ID (%d).", [anime.anime_id intValue]);
    }
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

#pragma mark - Helper Methods

+ (NSDate *)parseDate:(NSString *)stringDate {
    // First format: from malappinfo.php.
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date;
    
    // There exist two date formats. Should probably consolidate this somehow.
    // Typically, we'd add a Z for timezone instead of hardcoding +0000, but we want to preserve the raw date
    // since it seems like timezones are not used in the database.
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    date = [dateFormatter dateFromString:stringDate];
    
    if(date) {
        return date;
    }
    
    // Typically, we'd add a Z for timezone instead of hardcoding +0000, but we want to preserve the raw date
    // since it seems like timezones are not used in the database.
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss +0000";
    
    date = [dateFormatter dateFromString:stringDate];
    
    if(date) {
        return date;
    }

    return nil;
}


@end
