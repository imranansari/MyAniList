//
//  AnimeService.h
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Anime.h"

#define kID                     @"id"
#define kTitle                  @"title"
#define kOtherTitles            @"other_titles"
#define kSynopsis               @"synopsis"
#define kType                   @"type"
#define kRank                   @"rank"
#define kPopularityRank         @"popularity_rank"
#define kImage                  @"image"
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

@interface AnimeService : NSObject

+ (Anime *)animeForID:(NSNumber *)ID;
+ (BOOL)addAnimeList:(NSDictionary *)data;
+ (Anime *)addAnime:(NSDictionary *)data;
+ (Anime *)editAnime:(NSDictionary *)data;
+ (void)deleteAnime:(Anime *)anime;

+ (NSString *)animeToXML:(NSNumber *)animeID;

@end
