//
//  Manga.m
//  AniList
//
//  Created by Corey Roberts on 6/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "Manga.h"
#import "Anime.h"


@implementation Manga

@dynamic total_chapters;
@dynamic column;
@dynamic comments;
@dynamic date_finish;
@dynamic date_start;
@dynamic downloaded_chapters;
@dynamic enable_discussion;
@dynamic enable_rereading;
@dynamic image;
@dynamic image_url;
@dynamic manga_id;
@dynamic priority;
@dynamic reread_value;
@dynamic retail_volumes;
@dynamic scan_group;
@dynamic user_score;
@dynamic status;
@dynamic times_reread;
@dynamic title;
@dynamic total_volumes;
@dynamic type;
@dynamic average_count;
@dynamic average_score;
@dynamic current_volume;
@dynamic current_chapter;
@dynamic english_title;
@dynamic favorited_count;
@dynamic popularity_rank;
@dynamic rank;
@dynamic synopsis;
@dynamic user_date_start;
@dynamic user_date_finish;
@dynamic read_status;
@dynamic anime_adaptations;
@dynamic tags;

+ (MangaType)mangaTypeForValue:(NSString *)value {
    
    // If value is passed in as an int, convert it.
    int type = [value intValue];
//    
//    if(type == 1 || [value isEqualToString:@"TV"]) return AnimeTypeTV;
//    if(type == 2 || [value isEqualToString:@"OVA"]) return AnimeTypeOVA;
//    if(type == 3 || [value isEqualToString:@"Movie"]) return AnimeTypeMovie;
//    if(type == 4 || [value isEqualToString:@"Special"]) return AnimeTypeSpecial;
//    if(type == 5 || [value isEqualToString:@"ONA"]) return AnimeTypeONA;
//    if(type == 6 || [value isEqualToString:@"Music"]) return AnimeTypeMusic;
//    
//    return AnimeTypeUnknown;
}

+ (NSString *)stringForMangaType:(MangaType)mangaType {
//    switch (animeType) {
//        case AnimeTypeTV:
//            return @"TV";
//        case AnimeTypeMovie:
//            return @"Movie";
//        case AnimeTypeOVA:
//            return @"OVA";
//        case AnimeTypeONA:
//            return @"ONA";
//        case AnimeTypeSpecial:
//            return @"Special";
//        case AnimeTypeMusic:
//            return @"Music";
//        default:
//            return @"Unknown";
//    }
    return @"nothing";
}

+ (MangaPublishStatus)mangaPublishStatusForValue:(NSString *)value {
    value = [value lowercaseString];
    int publishStatus = [value intValue];
//    
//    if(airStatus == 1 || [value isEqualToString:@"currently airing"]) return AnimeAirStatusCurrentlyAiring;
//    if(airStatus == 2 || [value isEqualToString:@"finished airing"]) return AnimeAirStatusFinishedAiring;
//    if(airStatus == 3 || [value isEqualToString:@"not yet aired"]) return AnimeAirStatusNotYetAired;
//    
//    return AnimeAirStatusUnknown;
}

+ (NSString *)stringForMangaPublishStatus:(MangaPublishStatus)publishStatus {
//    switch (publishStatus) {
//        case AnimeAirStatusCurrentlyAiring:
//            return @"Currently airing";
//        case AnimeAirStatusFinishedAiring:
//            return @"Finished airing";
//        case AnimeAirStatusNotYetAired:
//            return @"Not yet aired";
//        case AnimeAirStatusUnknown:
//        default:
//            return @"Unknown";
//    }
}

+ (MangaReadStatus)mangaReadStatusForValue:(NSString *)value {
    
// 1/reading, 2/completed, 3/onhold, 4/dropped, 6/plantoread
    int status = [value intValue];
    
#warning - unit tests.
    if(status == 1 || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"watching"]))
        return MangaReadStatusReading;
    if(status == 2 || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"completed"]))
        return MangaReadStatusCompleted;
    if(status == 3 || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"on-hold"]))
        return MangaReadStatusOnHold;
    if(status == 4 || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"dropped"]))
        return MangaReadStatusDropped;
    if(status == 6 || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"plan to read"]))
        return MangaReadStatusPlanToRead;
    
    return MangaReadStatusNotReading;
}

+ (NSString *)stringForMangaReadStatus:(MangaReadStatus)readStatus forMangaType:(MangaType)mangaType {
    
//    NSString *seriesText = @"";
//    
//    switch (animeType) {
//        case AnimeTypeTV:
//            seriesText = @"series";
//            break;
//        case AnimeTypeMovie:
//            seriesText = @"movie";
//            break;
//        case AnimeTypeOVA:
//            seriesText = @"OVA";
//            break;
//        case AnimeTypeONA:
//            seriesText = @"ONA";
//            break;
//        case AnimeTypeSpecial:
//            seriesText = @"special";
//            break;
//        case AnimeTypeMusic:
//            seriesText = @"song";  // Not sure about this one
//            break;
//        case AnimeTypeUnknown:
//        default:
//            seriesText = @"series";
//            break;
//    }
//    
//    switch (watchedStatus) {
//        case AnimeWatchedStatusWatching:
//            return [NSString stringWithFormat:@"Currently watching this %@.", seriesText];
//        case AnimeWatchedStatusCompleted:
//            return [NSString stringWithFormat:@"Finished with this %@.", seriesText];
//        case AnimeWatchedStatusOnHold:
//            return [NSString stringWithFormat:@"Putting this %@ on hold.", seriesText];
//        case AnimeWatchedStatusDropped:
//            return [NSString stringWithFormat:@"Dropping this %@.", seriesText];
//        case AnimeWatchedStatusPlanToWatch:
//            return [NSString stringWithFormat:@"Planning to watch this %@.", seriesText];
//        case AnimeWatchedStatusNotWatching:
//            return [NSString stringWithFormat:@"Add this %@ to your list?", seriesText];
//        case AnimeWatchedStatusUnknown:
//        default:
//            return @"Unknown?";
//    }
}

#pragma mark - Unofficial API Methods

+ (MangaType)unofficialMangaTypeForValue:(NSString *)value {
//    if([value isEqualToString:@"TV"])
//        return AnimeTypeTV;
//    if([value isEqualToString:@"Movie"])
//        return AnimeTypeMovie;
//    if([value isEqualToString:@"OVA"])
//        return AnimeTypeOVA;
//    if([value isEqualToString:@"ONA"])
//        return AnimeTypeONA;
//    if([value isEqualToString:@"Special"])
//        return AnimeTypeSpecial;
//    if([value isEqualToString:@"Music"])
//        return AnimeTypeMusic;
//    
//    return AnimeTypeUnknown;
}

+ (MangaPublishStatus)unofficialMangaPublishStatusForValue:(NSString *)value {
//    if([value isEqualToString:@"finished airing"])
//        return AnimeAirStatusFinishedAiring;
//    if([value isEqualToString:@"currently airing"])
//        return AnimeAirStatusCurrentlyAiring;
//    if([value isEqualToString:@"not yet aired"])
//        return AnimeAirStatusNotYetAired;
//    
//    return AnimeAirStatusUnknown;
}

+ (MangaReadStatus)unofficialMangaReadStatusForValue:(NSString *)value {
//    if([value isEqualToString:@"watching"])
//        return AnimeWatchedStatusWatching;
//    if([value isEqualToString:@"completed"])
//        return AnimeWatchedStatusCompleted;
//    if([value isEqualToString:@"on-hold"])
//        return AnimeWatchedStatusOnHold;
//    if([value isEqualToString:@"dropped"])
//        return AnimeWatchedStatusDropped;
//    if([value isEqualToString:@"plan to watch"])
//        return AnimeWatchedStatusPlanToWatch;
//    
//    return AnimeWatchedStatusUnknown;
}

- (void)setRead_status:(NSNumber *)read_status {
    [self willChangeValueForKey:@"read_status"];
    [self setPrimitiveValue:read_status forKey:@"read_status"];
    [self didChangeValueForKey:@"read_status"];
    
    // Update column appropriately.
    switch ([self.read_status intValue]) {
        case MangaReadStatusReading:
            self.column = @(0);
            break;
        case MangaReadStatusCompleted:
            self.column = @(1);
            break;
        case MangaReadStatusOnHold:
            self.column = @(2);
            break;
        case MangaReadStatusDropped:
            self.column = @(3);
            break;
        case MangaReadStatusPlanToRead:
            self.column = @(4);
            break;
        case MangaReadStatusUnknown:
        default:
            self.column = @(5);
            break;
    }
}

- (BOOL)hasAdditionalDetails {
    return [self.average_count intValue] > 0;
}

@end
