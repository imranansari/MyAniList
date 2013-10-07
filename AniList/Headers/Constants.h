//
//  Constants.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#ifndef AniList_Constants_h
#define AniList_Constants_h

#define kAnimeDidUpdate @"kAnimeDidUpdate"
#define kMangaDidUpdate @"kMangaDidUpdate"
#define kRelatedAnimeDidUpdate @"kRelatedAnimeDidUpdate"
#define kRelatedMangaDidUpdate @"kRelatedMangaDidUpdate"

// Defaults
#define kNoSynopsisString @"Unable to get synopsis. Please try again later."

// Dictionary values for fetching data
#define kID                     @"id"
#define kTitle                  @"title"
#define kOtherTitles            @"other_titles"
#define kSynopsis               @"synopsis"
#define kType                   @"type"
#define kRank                   @"rank"
#define kPopularityRank         @"popularity_rank"
#define kImage                  @"image"
#define kImageURL               @"image_url"
#define kChapters               @"chapters"
#define kVolumes                @"volumes"
#define kEpisodes               @"episodes"
#define kAirStatus              @"status"
#define kAirStartDate           @"start_date"
#define kAirEndDate             @"end_date"
#define kSeriesStatus           @"status"
#define kSeriesStartDate        @"series_start"
#define kSeriesEndDate          @"series_end"
#define kGenres                 @"genres"
#define kTag                    @"tags"
#define kClassicication         @"classification"
#define kMembersScore           @"members_score"
#define kMembersCount           @"members_count"
#define kFavoritedCount         @"favorited_count"
#define kAnimeAdaptations       @"anime_adaptations"
#define kMangaAdaptations       @"manga_adaptations"
#define kRelatedManga           @"related_manga"
#define kRelatedAnime           @"related_anime"
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
#define kUserChaptersRead       @"chapters_read"
#define kUserVolumesRead        @"volumes_read"
#define kUserScore              @"score"
#define kUserWatchedStatus      @"watched_status"
#define kUserReadStatus         @"read_status"
#define kUserStartDate          @"user_start_date"
#define kUserEndDate            @"user_end_date"
#define kUserRewatchingStatus   @"user_rewatching_status"
#define kUserRewatchingEpisode  @"user_rewatching_episode"
#define kUserRereadingStatus    @"user_rereading_status"
#define kUserRereadingChapter   @"user_rereading_chapter"
#define kUserRereadingVolume    @"user_rereading_volume"
#define kUserLastUpdated        @"user_last_updated"
#define kAnimeStats             @"anime_stats"
#define kMangaStats             @"manga_stats"
#define kSynonyms               @"synonyms"
#define kEnglishTitles          @"english"
#define kJapaneseTitles         @"japanese"

static const BOOL UI_DEBUG = NO;

#define VERBOSE_DEBUGGING YES

#ifdef DEBUG
#define ALLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define ALLog( s, ... ) do {} while (0)
#endif

#if VERBOSE_DEBUGGING
#define ALVLog( s, ...) ALLog( s, ... )
#else
#define ALVLog( s, ... ) do {} while (0)
#endif

NS_INLINE void MVComputeTimeWithNameAndBlock(const char *caller, void (^block)()) {
    CFTimeInterval startTimeInterval = CACurrentMediaTime();
    block();
    CFTimeInterval nowTimeInterval = CACurrentMediaTime();
    NSLog(@"%s - Time Running is: %f", caller, nowTimeInterval - startTimeInterval);
}

#define MVComputeTime(...) MVComputeTimeWithNameAndBlock(__PRETTY_FUNCTION__, (__VA_ARGS__))

#endif
