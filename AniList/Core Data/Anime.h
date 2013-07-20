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

typedef enum {
    AnimeRelationPrequel = 0,
    AnimeRelationSequel,
    AnimeRelationSideStory,
    AnimeRelationParentStory,
    AnimeRelationCharacterAnime,
    AnimeRelationSpinOff,
    AnimeRelationSummaries,
    AnimeRelationAlternativeVersions,
    AnimeRelationMangaAdaptation
} AnimeRelation;

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

@class Anime, Manga, Synonym, Genre, Tag;

@interface Anime : NSManagedObject

@property (nonatomic, retain) NSNumber * anime_id;
@property (nonatomic, retain) NSNumber * average_count;
@property (nonatomic, retain) NSNumber * average_score;
@property (nonatomic, retain) NSString * classification;
@property (nonatomic, retain) NSNumber * column;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * current_episode;
@property (nonatomic, retain) NSDate * date_finish;
@property (nonatomic, retain) NSDate * date_start;
@property (nonatomic, retain) NSNumber * downloaded_episodes;
@property (nonatomic, retain) NSNumber * enable_discussion;
@property (nonatomic, retain) NSNumber * enable_rewatching;
@property (nonatomic, retain) NSString * fansub_group;
@property (nonatomic, retain) NSNumber * favorited_count;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSNumber * last_updated;
@property (nonatomic, retain) NSNumber * popularity_rank;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * rewatch_value;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * storage_type;
@property (nonatomic, retain) NSNumber * storage_value;
@property (nonatomic, retain) NSString * synopsis;
@property (nonatomic, retain) NSNumber * times_rewatched;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * total_episodes;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * user_date_finish;
@property (nonatomic, retain) NSDate * user_date_start;
@property (nonatomic, retain) NSNumber * user_score;
@property (nonatomic, retain) NSNumber * watched_status;
@property (nonatomic, retain) NSSet *alternative_versions;
@property (nonatomic, retain) NSSet *character_anime;
@property (nonatomic, retain) NSSet *english_titles;
@property (nonatomic, retain) NSSet *genres;
@property (nonatomic, retain) NSSet *japanese_titles;
@property (nonatomic, retain) NSSet *manga_adaptations;
@property (nonatomic, retain) NSSet *parent_story;
@property (nonatomic, retain) NSSet *prequels;
@property (nonatomic, retain) NSSet *sequels;
@property (nonatomic, retain) NSSet *side_stories;
@property (nonatomic, retain) NSSet *spin_offs;
@property (nonatomic, retain) NSSet *summaries;
@property (nonatomic, retain) NSSet *synonyms;
@property (nonatomic, retain) NSSet *tags;

+ (AnimeType)animeTypeForValue:(NSString *)value;
+ (NSString *)stringForAnimeType:(AnimeType)animeType;
+ (AnimeAirStatus)animeAirStatusForValue:(NSString *)value;
+ (NSString *)stringForAnimeAirStatus:(AnimeAirStatus)airStatus;
+ (AnimeWatchedStatus)animeWatchedStatusForValue:(NSString *)value;
+ (NSString *)stringForAnimeWatchedStatus:(AnimeWatchedStatus)watchedStatus;
+ (NSString *)stringForAnimeWatchedStatus:(AnimeWatchedStatus)watchedStatus forAnimeType:(AnimeType)animeType;
+ (NSString *)unitForAnimeType:(AnimeType)animeType plural:(BOOL)plural;

- (BOOL)hasAdditionalDetails;
- (UIImage *)imageForAnime;

// Methods for Unofficial API
+ (AnimeType)unofficialAnimeTypeForValue:(NSString *)value;
+ (AnimeAirStatus)unofficialAnimeAirStatusForValue:(NSString *)value;
+ (AnimeWatchedStatus)unofficialAnimeWatchedStatusForValue:(NSString *)value;

@end

@interface Anime (CoreDataGeneratedAccessors)

- (void)addAlternative_versionsObject:(Anime *)value;
- (void)removeAlternative_versionsObject:(Anime *)value;
- (void)addAlternative_versions:(NSSet *)values;
- (void)removeAlternative_versions:(NSSet *)values;

- (void)addCharacter_animeObject:(Anime *)value;
- (void)removeCharacter_animeObject:(Anime *)value;
- (void)addCharacter_anime:(NSSet *)values;
- (void)removeCharacter_anime:(NSSet *)values;

- (void)addEnglish_titlesObject:(Synonym *)value;
- (void)removeEnglish_titlesObject:(Synonym *)value;
- (void)addEnglish_titles:(NSSet *)values;
- (void)removeEnglish_titles:(NSSet *)values;

- (void)addGenresObject:(Genre *)value;
- (void)removeGenresObject:(Genre *)value;
- (void)addGenres:(NSSet *)values;
- (void)removeGenres:(NSSet *)values;

- (void)addJapanese_titlesObject:(Synonym *)value;
- (void)removeJapanese_titlesObject:(Synonym *)value;
- (void)addJapanese_titles:(NSSet *)values;
- (void)removeJapanese_titles:(NSSet *)values;

- (void)addManga_adaptationsObject:(Manga *)value;
- (void)removeManga_adaptationsObject:(Manga *)value;
- (void)addManga_adaptations:(NSSet *)values;
- (void)removeManga_adaptations:(NSSet *)values;

- (void)addParent_storyObject:(Anime *)value;
- (void)removeParent_storyObject:(Anime *)value;
- (void)addParent_story:(NSSet *)values;
- (void)removeParent_story:(NSSet *)values;

- (void)addPrequelsObject:(Anime *)value;
- (void)removePrequelsObject:(Anime *)value;
- (void)addPrequels:(NSSet *)values;
- (void)removePrequels:(NSSet *)values;

- (void)addSequelsObject:(Anime *)value;
- (void)removeSequelsObject:(Anime *)value;
- (void)addSequels:(NSSet *)values;
- (void)removeSequels:(NSSet *)values;

- (void)addSide_storiesObject:(Anime *)value;
- (void)removeSide_storiesObject:(Anime *)value;
- (void)addSide_stories:(NSSet *)values;
- (void)removeSide_stories:(NSSet *)values;

- (void)addSpin_offsObject:(Anime *)value;
- (void)removeSpin_offsObject:(Anime *)value;
- (void)addSpin_offs:(NSSet *)values;
- (void)removeSpin_offs:(NSSet *)values;

- (void)addSummariesObject:(Anime *)value;
- (void)removeSummariesObject:(Anime *)value;
- (void)addSummaries:(NSSet *)values;
- (void)removeSummaries:(NSSet *)values;

- (void)addSynonymsObject:(Synonym *)value;
- (void)removeSynonymsObject:(Synonym *)value;
- (void)addSynonyms:(NSSet *)values;
- (void)removeSynonyms:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
