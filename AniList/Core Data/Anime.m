//
//  Anime.m
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "Anime.h"
#import "Anime.h"


@implementation Anime

@dynamic average_count;
@dynamic average_score;
@dynamic classification;
@dynamic column;
@dynamic comments;
@dynamic current_episode;
@dynamic date_finish;
@dynamic date_start;
@dynamic downloaded_episodes;
@dynamic enable_discussion;
@dynamic enable_rewatching;
@dynamic english_title;
@dynamic fansub_group;
@dynamic favorited_count;
@dynamic anime_id;
@dynamic image;
@dynamic image_url;
@dynamic popularity_rank;
@dynamic priority;
@dynamic rank;
@dynamic rewatch_value;
@dynamic status;
@dynamic storage_type;
@dynamic storage_value;
@dynamic synopsis;
@dynamic times_rewatched;
@dynamic title;
@dynamic total_episodes;
@dynamic type;
@dynamic user_date_finish;
@dynamic user_date_start;
@dynamic user_score;
@dynamic watched_status;
@dynamic tags;
@dynamic genres;
@dynamic synonyms;
@dynamic sequels;
@dynamic side_stories;
@dynamic prequels;
@dynamic parent_story;
@dynamic manga_adaptations;

+ (AnimeType)animeTypeForValue:(NSString *)value {
    
    // If value is passed in as an int, convert it.
    int type = [value intValue];
    
    if(type == 1 || [value isEqualToString:@"TV"]) return AnimeTypeTV;
    if(type == 2 || [value isEqualToString:@"OVA"]) return AnimeTypeOVA;
    if(type == 3 || [value isEqualToString:@"Movie"]) return AnimeTypeMovie;
    if(type == 4 || [value isEqualToString:@"Special"]) return AnimeTypeSpecial;
    if(type == 5 || [value isEqualToString:@"ONA"]) return AnimeTypeONA;
    if(type == 6 || [value isEqualToString:@"Music"]) return AnimeTypeMusic;
    
    return AnimeTypeUnknown;
}

+ (NSString *)stringForAnimeType:(AnimeType)animeType {
    switch (animeType) {
        case AnimeTypeTV:
            return @"TV";
        case AnimeTypeMovie:
            return @"Movie";
        case AnimeTypeOVA:
            return @"OVA";
        case AnimeTypeONA:
            return @"ONA";
        case AnimeTypeSpecial:
            return @"Special";
        case AnimeTypeMusic:
            return @"Music";
        default:
            return @"Unknown";
    }
}

+ (AnimeAirStatus)animeAirStatusForValue:(NSString *)value {
    value = [value lowercaseString];
    int airStatus = [value intValue];
    
    if(airStatus == 1 || [value isEqualToString:@"currently airing"]) return AnimeAirStatusCurrentlyAiring;
    if(airStatus == 2 || [value isEqualToString:@"finished airing"]) return AnimeAirStatusFinishedAiring;
    if(airStatus == 3 || [value isEqualToString:@"not yet aired"]) return AnimeAirStatusNotYetAired;
    
    return AnimeAirStatusUnknown;
}

+ (NSString *)stringForAnimeAirStatus:(AnimeAirStatus)airStatus {
    switch (airStatus) {
        case AnimeAirStatusCurrentlyAiring:
            return @"Currently airing";
        case AnimeAirStatusFinishedAiring:
            return @"Finished airing";
        case AnimeAirStatusNotYetAired:
            return @"Not yet aired";
        case AnimeAirStatusUnknown:
        default:
            return @"Unknown";
    }
}

+ (AnimeWatchedStatus)animeWatchedStatusForValue:(NSString *)value {
    
    // 1/watching, 2/completed, 3/onhold, 4/dropped, 6/plantowatch
    int status = [value intValue];
    
    if(status == 1 || [value isEqualToString:@"watching"]) return AnimeWatchedStatusWatching;
    if(status == 2 || [value isEqualToString:@"completed"]) return AnimeWatchedStatusCompleted;
    if(status == 3 || [value isEqualToString:@"on-hold"]) return AnimeWatchedStatusOnHold;
    if(status == 4 || [value isEqualToString:@"dropped"]) return AnimeWatchedStatusDropped;
    if(status == 6 || [value isEqualToString:@"plan to watch"]) return AnimeWatchedStatusPlanToWatch;
    
    return AnimeWatchedStatusNotWatching;
}

+ (NSString *)stringForAnimeWatchedStatus:(AnimeWatchedStatus)watchedStatus forAnimeType:(AnimeType)animeType {
    
    NSString *seriesText = @"";
    
    switch (animeType) {
        case AnimeTypeTV:
            seriesText = @"series";
            break;
        case AnimeTypeMovie:
            seriesText = @"movie";
            break;
        case AnimeTypeOVA:
            seriesText = @"OVA";
            break;
        case AnimeTypeONA:
            seriesText = @"ONA";
            break;
        case AnimeTypeSpecial:
            seriesText = @"special";
            break;
        case AnimeTypeMusic:
            seriesText = @"song";  // Not sure about this one
            break;
        case AnimeTypeUnknown:
        default:
            seriesText = @"series";
            break;
    }
    
    switch (watchedStatus) {
        case AnimeWatchedStatusWatching:
            return [NSString stringWithFormat:@"Currently watching this %@.", seriesText];
        case AnimeWatchedStatusCompleted:
            return [NSString stringWithFormat:@"Finished with this %@.", seriesText];
        case AnimeWatchedStatusOnHold:
            return [NSString stringWithFormat:@"Putting this %@ on hold.", seriesText];
        case AnimeWatchedStatusDropped:
            return [NSString stringWithFormat:@"Dropping this %@.", seriesText];
        case AnimeWatchedStatusPlanToWatch:
            return [NSString stringWithFormat:@"Planning to watch this %@.", seriesText];
        case AnimeWatchedStatusNotWatching:
            return [NSString stringWithFormat:@"Add this %@ to your list?", seriesText];
        case AnimeWatchedStatusUnknown:
        default:
            return @"Unknown?";
    }
}

#pragma mark - Unofficial API Methods

+ (AnimeType)unofficialAnimeTypeForValue:(NSString *)value {
    if([value isEqualToString:@"TV"])
        return AnimeTypeTV;
    if([value isEqualToString:@"Movie"])
        return AnimeTypeMovie;
    if([value isEqualToString:@"OVA"])
        return AnimeTypeOVA;
    if([value isEqualToString:@"ONA"])
        return AnimeTypeONA;
    if([value isEqualToString:@"Special"])
        return AnimeTypeSpecial;
    if([value isEqualToString:@"Music"])
        return AnimeTypeMusic;
    
    return AnimeTypeUnknown;
}

+ (AnimeAirStatus)unofficialAnimeAirStatusForValue:(NSString *)value {
    if([value isEqualToString:@"finished airing"])
        return AnimeAirStatusFinishedAiring;
    if([value isEqualToString:@"currently airing"])
        return AnimeAirStatusCurrentlyAiring;
    if([value isEqualToString:@"not yet aired"])
        return AnimeAirStatusNotYetAired;
    
    return AnimeAirStatusUnknown;
}

+ (AnimeWatchedStatus)unofficialAnimeWatchedStatusForValue:(NSString *)value {
    if([value isEqualToString:@"watching"])
        return AnimeWatchedStatusWatching;
    if([value isEqualToString:@"completed"])
        return AnimeWatchedStatusCompleted;
    if([value isEqualToString:@"on-hold"])
        return AnimeWatchedStatusOnHold;
    if([value isEqualToString:@"dropped"])
        return AnimeWatchedStatusDropped;
    if([value isEqualToString:@"plan to watch"])
        return AnimeWatchedStatusPlanToWatch;
    
    return AnimeWatchedStatusUnknown;
}

- (void)setWatched_status:(NSNumber *)watched_status {
    [self willChangeValueForKey:@"watched_status"];
    [self setPrimitiveValue:watched_status forKey:@"watched_status"];
    [self didChangeValueForKey:@"watched_status"];
    
    // Update column appropriately.
    switch ([self.watched_status intValue]) {
        case AnimeWatchedStatusWatching:
            self.column = @(0);
            break;
        case AnimeWatchedStatusCompleted:
            self.column = @(1);
            break;
        case AnimeWatchedStatusOnHold:
            self.column = @(2);
            break;
        case AnimeWatchedStatusDropped:
            self.column = @(3);
            break;
        case AnimeWatchedStatusPlanToWatch:
            self.column = @(4);
            break;
        case AnimeWatchedStatusUnknown:
        default:
            self.column = @(5);
            break;
    }
}

- (BOOL)hasAdditionalDetails {
    return [self.average_count intValue] > 0;
}

@end
