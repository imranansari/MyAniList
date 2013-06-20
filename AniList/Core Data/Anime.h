//
//  Anime.h
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#pragma mark - Official typedefs

typedef enum {
    AnimeWatchedStatusUnknown = -1,
    AnimeWatchedStatusWatching = 1,
    AnimeWatchedStatusCompleted,
    AnimeWatchedStatusOnHold,
    AnimeWatchedStatusDropped,
    AnimeWatchedStatusPlanToWatch = 6,
    AnimeWatchedStatusNotWatching
} AnimeWatchedStatus;

typedef enum {
    AnimeTypeUnknown = -1,
    AnimeTypeTV = 1,
    AnimeTypeOVA,
    AnimeTypeMovie,
    AnimeTypeSpecial,
    AnimeTypeONA,
    AnimeTypeMusic
} AnimeType;

typedef enum {
    AnimeAirStatusUnknown = -1,
    AnimeAirStatusCurrentlyAiring = 1,
    AnimeAirStatusFinishedAiring,
    AnimeAirStatusNotYetAired
} AnimeAirStatus;

#pragma mark - Unofficial typedefs

typedef enum {
    UnofficialAnimeWatchedStatusUnknown = -1,
    UnofficialAnimeWatchedStatusWatching,
    UnofficialAnimeWatchedStatusCompleted,
    UnofficialAnimeWatchedStatusOnHold,
    UnofficialAnimeWatchedStatusDropped,
    UnofficialAnimeWatchedStatusPlanToWatch,
} UnofficialAnimeWatchedStatus;

typedef enum {
    UnofficialAnimeTypeUnknown = -1,
    UnofficialAnimeTypeTV,
    UnofficialAnimeTypeMovie,
    UnofficialAnimeTypeOVA,
    UnofficialAnimeTypeONA,
    UnofficialAnimeTypeSpecial,
    UnofficialAnimeTypeMusic
} UnofficialAnimeType;

typedef enum {
    UnofficialAnimeAirStatusUnknown = -1,
    UnofficialAnimeAirStatusFinishedAiring,
    UnofficialAnimeAirStatusCurrentlyAiring,
    UnofficialAnimeAirStatusNotYetAired
} UnofficialAnimeAirStatus;

@class Anime;

@interface Anime : NSManagedObject

@property (nonatomic, retain) NSNumber *average_count;
@property (nonatomic, retain) NSNumber *average_score;
@property (nonatomic, retain) NSString *classification;
@property (nonatomic, retain) NSNumber *column;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSNumber *current_episode;
@property (nonatomic, retain) NSDate *date_finish;
@property (nonatomic, retain) NSDate *date_start;
@property (nonatomic, retain) NSNumber *downloaded_episodes;
@property (nonatomic, retain) NSNumber *enable_discussion;
@property (nonatomic, retain) NSNumber *enable_rewatching;
@property (nonatomic, retain) NSString *english_title;
@property (nonatomic, retain) NSString *fansub_group;
@property (nonatomic, retain) NSNumber *favorited_count;
@property (nonatomic, retain) NSNumber *anime_id;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *image_url;
@property (nonatomic, retain) NSNumber *popularity_rank;
@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSNumber *rank;
@property (nonatomic, retain) NSNumber *rewatch_value;
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSNumber *storage_type;
@property (nonatomic, retain) NSNumber *storage_value;
@property (nonatomic, retain) NSString *synopsis;
@property (nonatomic, retain) NSNumber *times_rewatched;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *total_episodes;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSDate *user_date_finish;
@property (nonatomic, retain) NSDate *user_date_start;
@property (nonatomic, retain) NSNumber *user_score;
@property (nonatomic, retain) NSNumber *watched_status;
@property (nonatomic, retain) NSManagedObject *tags;
@property (nonatomic, retain) NSManagedObject *genres;
@property (nonatomic, retain) NSSet *synonyms;
@property (nonatomic, retain) Anime *sequels;
@property (nonatomic, retain) Anime *side_stories;
@property (nonatomic, retain) Anime *prequels;
@property (nonatomic, retain) Anime *parent_story;
@property (nonatomic, retain) NSManagedObject *manga_adaptations;
@end

@interface Anime (CoreDataGeneratedAccessors)

- (void)addSynonymsObject:(NSManagedObject *)value;
- (void)removeSynonymsObject:(NSManagedObject *)value;
- (void)addSynonyms:(NSSet *)values;
- (void)removeSynonyms:(NSSet *)values;

+ (AnimeType)animeTypeForValue:(NSString *)value;
+ (NSString *)stringForAnimeType:(AnimeType)animeType;
+ (AnimeAirStatus)animeAirStatusForValue:(NSString *)value;
+ (NSString *)stringForAnimeAirStatus:(AnimeAirStatus)airStatus;
+ (AnimeWatchedStatus)animeWatchedStatusForValue:(NSString *)value;
+ (NSString *)stringForAnimeWatchedStatus:(AnimeWatchedStatus)watchedStatus forAnimeType:(AnimeType)animeType;

- (BOOL)hasAdditionalDetails;

// Methods for Unofficial API
+ (AnimeType)unofficialAnimeTypeForValue:(NSString *)value;
+ (AnimeAirStatus)unofficialAnimeAirStatusForValue:(NSString *)value;
+ (AnimeWatchedStatus)unofficialAnimeWatchedStatusForValue:(NSString *)value;

@end
