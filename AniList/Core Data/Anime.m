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
    if([value isEqualToString:@"finished airing"])
        return AnimeAirStatusFinishedAiring;
    if([value isEqualToString:@"currently airing"])
        return AnimeAirStatusCurrentlyAiring;
    if([value isEqualToString:@"not yet aired"])
        return AnimeAirStatusNotYetAired;
    
    return AnimeAirStatusUnknown;
}

+ (AnimeWatchedStatus)animeWatchedStatusForValue:(NSString *)value {
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

- (NSNumber *)column {
    switch ([self.watched_status intValue]) {
        case AnimeWatchedStatusWatching:
            return @(0);
        case AnimeWatchedStatusCompleted:
            return @(1);
        case AnimeWatchedStatusOnHold:
            return @(2);
        case AnimeWatchedStatusDropped:
            return @(3);
        case AnimeWatchedStatusPlanToWatch:
            return @(4);
        case AnimeWatchedStatusUnknown:
        default:
            return @(5);
    }
}

@end
