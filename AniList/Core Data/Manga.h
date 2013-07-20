//
//  Manga.h
//  AniList
//
//  Created by Corey Roberts on 6/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#pragma mark - Official typedefs

typedef enum {
    MangaReadStatusUnknown = -1,
    MangaReadStatusReading = 1,
    MangaReadStatusCompleted,
    MangaReadStatusOnHold,
    MangaReadStatusDropped,
    MangaReadStatusPlanToRead = 6,
    MangaReadStatusNotReading
} MangaReadStatus;

typedef enum {
    MangaTypeUnknown = -1,
    MangaTypeManga = 1,
    MangaTypeNovel,
    MangaTypeOneShot,
    MangaTypeDoujin,
    MangaTypeManwha,
    MangaTypeManhua,
    MangaTypeOEL // none found.
} MangaType;

typedef enum {
    MangaPublishStatusUnknown = -1,
    MangaPublishStatusCurrentlyPublishing = 1,
    MangaPublishStatusFinishedPublishing,
    MangaPublishStatusNotYetPublished
} MangaPublishStatus;

#pragma mark - Unofficial typedefs

typedef enum {
    UnofficialMangaReadStatusUnknown = -1,
    UnofficialMangaReadStatusReading,
    UnofficialMangaReadStatusCompleted,
    UnofficialMangaReadStatusOnHold,
    UnofficialMangaReadStatusDropped,
    UnofficialMangaReadStatusPlanToRead,
} UnofficialMangaReadStatus;

typedef enum {
    UnofficialMangaTypeUnknown = -1,
    UnofficialMangaTypeManga = 1,
    UnofficialMangaTypeNovel,
    UnofficialMangaTypeOneShot,
    UnofficialMangaTypeDoujin,
    UnofficialMangaTypeManwha,
    UnofficialMangaTypeManhua,
    UnofficialMangaTypeOEL
} UnofficialMangaType;

typedef enum {
    UnofficialMangaPublishStatusUnknown = -1,
    UnofficialMangaPublishStatusFinishedPublishing,
    UnofficialMangaPublishStatusCurrentlyPublishing,
    UnofficialMangaPublishStatusNotYetPublished
} UnofficialMangaPublishStatus;


@class Anime;

@interface Manga : NSManagedObject

@property (nonatomic, retain) NSNumber *average_count;
@property (nonatomic, retain) NSNumber *average_score;
@property (nonatomic, retain) NSNumber *column;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSNumber *current_chapter;
@property (nonatomic, retain) NSNumber *current_volume;
@property (nonatomic, retain) NSDate *date_finish;
@property (nonatomic, retain) NSDate *date_start;
@property (nonatomic, retain) NSNumber *downloaded_chapters;
@property (nonatomic, retain) NSNumber *enable_discussion;
@property (nonatomic, retain) NSNumber *enable_rereading;
@property (nonatomic, retain) NSString *english_title;
@property (nonatomic, retain) NSNumber *favorited_count;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *image_url;
@property (nonatomic, retain) NSNumber *last_updated;
@property (nonatomic, retain) NSNumber *manga_id;
@property (nonatomic, retain) NSNumber *popularity_rank;
@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSNumber *rank;
@property (nonatomic, retain) NSNumber *read_status;
@property (nonatomic, retain) NSNumber *reread_value;
@property (nonatomic, retain) NSNumber *retail_volumes;
@property (nonatomic, retain) NSString *scan_group;
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSString *synopsis;
@property (nonatomic, retain) NSNumber *times_reread;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *total_chapters;
@property (nonatomic, retain) NSNumber *total_volumes;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSDate *user_date_finish;
@property (nonatomic, retain) NSDate *user_date_start;
@property (nonatomic, retain) NSNumber *user_score;
@property (nonatomic, retain) NSSet *anime_adaptations;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *genres;

+ (MangaType)mangaTypeForValue:(NSString *)value;
+ (NSString *)stringForMangaType:(MangaType)mangaType;
+ (MangaPublishStatus)mangaPublishStatusForValue:(NSString *)value;
+ (NSString *)stringForMangaPublishStatus:(MangaPublishStatus)publishStatus;
+ (MangaReadStatus)mangaReadStatusForValue:(NSString *)value;
+ (NSString *)stringForMangaReadStatus:(MangaReadStatus)readStatus;
+ (NSString *)stringForMangaReadStatus:(MangaReadStatus)readStatus forMangaType:(MangaType)mangaType;

+ (MangaType)unofficialMangaTypeForValue:(NSString *)value;
+ (MangaPublishStatus)unofficialMangaPublishStatusForValue:(NSString *)value;
+ (MangaReadStatus)unofficialMangaReadStatusForValue:(NSString *)value;

- (BOOL)hasAdditionalDetails;

@end

@interface Manga (CoreDataGeneratedAccessors)

- (void)addAnime_adaptationsObject:(Anime *)value;
- (void)removeAnime_adaptationsObject:(Anime *)value;
- (void)addAnime_adaptations:(NSSet *)values;
- (void)removeAnime_adaptations:(NSSet *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addGenresObject:(NSManagedObject *)value;
- (void)removeGenresObject:(NSManagedObject *)value;
- (void)addGenres:(NSSet *)values;
- (void)removeGenres:(NSSet *)values;

@end