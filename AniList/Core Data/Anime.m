//
//  Anime.m
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "Anime.h"

@implementation Anime

@dynamic anime_id;
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
@dynamic fansub_group;
@dynamic favorited_count;
@dynamic image;
@dynamic image_tn;
@dynamic image_url;
@dynamic last_updated;
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
@dynamic alternative_versions;
@dynamic character_anime;
@dynamic english_titles;
@dynamic genres;
@dynamic japanese_titles;
@dynamic manga_adaptations;
@dynamic parent_story;
@dynamic prequels;
@dynamic sequels;
@dynamic side_stories;
@dynamic spin_offs;
@dynamic summaries;
@dynamic synonyms;
@dynamic tags;
@dynamic userlist;

- (void)awakeFromInsert {
    self.watched_status = @(AnimeWatchedStatusNotWatching);
    self.user_score = @(-1);
}

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
    
#warning - ensure value is string based.
    if(status == 1 || [value isEqualToString:@"watching"]) return AnimeWatchedStatusWatching;
    if(status == 2 || [value isEqualToString:@"completed"]) return AnimeWatchedStatusCompleted;
    if(status == 3 || [value isEqualToString:@"on-hold"]) return AnimeWatchedStatusOnHold;
    if(status == 4 || [value isEqualToString:@"dropped"]) return AnimeWatchedStatusDropped;
    if(status == 6 || [value isEqualToString:@"plan to watch"]) return AnimeWatchedStatusPlanToWatch;
    
    return AnimeWatchedStatusNotWatching;
}

+ (NSString *)stringForAnimeWatchedStatus:(AnimeWatchedStatus)watchedStatus {
    switch (watchedStatus) {
        case AnimeWatchedStatusWatching:
            return @"Watching";
        case AnimeWatchedStatusCompleted:
            return @"Completed";
        case AnimeWatchedStatusOnHold:
            return @"On Hold";
        case AnimeWatchedStatusDropped:
            return @"Dropped";
        case AnimeWatchedStatusPlanToWatch:
            return @"Plan to Watch";
        case AnimeWatchedStatusNotWatching:
            return @"";
        case AnimeWatchedStatusUnknown:
        default:
            return @"";
    }
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
            return [NSString stringWithFormat:@"You finished this %@.", seriesText];
        case AnimeWatchedStatusOnHold:
            return [NSString stringWithFormat:@"You put this %@ on hold.", seriesText];
        case AnimeWatchedStatusDropped:
            return [NSString stringWithFormat:@"You dropped this %@.", seriesText];
        case AnimeWatchedStatusPlanToWatch:
            return [NSString stringWithFormat:@"Planning to watch this %@.", seriesText];
        case AnimeWatchedStatusNotWatching:
            return [NSString stringWithFormat:@"Add this %@ to your list?", seriesText];
        case AnimeWatchedStatusUnknown:
        default:
            return @"Unknown?";
    }
}

+ (NSString *)unitForAnimeType:(AnimeType)animeType plural:(BOOL)plural {
    
    NSString *unit = @"";
    
    switch (animeType) {
        case AnimeTypeTV:
        case AnimeTypeOVA:
        case AnimeTypeONA:
        case AnimeTypeSpecial:
            unit = plural ? @"episodes" : @"episode";
            break;
        case AnimeTypeMovie:
            unit = plural ? @"movies" : @"movie";
            break;
        case AnimeTypeMusic:
            unit = plural ? @"songs" : @"song";  // Not sure about this one
            break;
        case AnimeTypeUnknown:
        default:
            unit = plural ? @"episodes" : @"episode";
            break;
    }
    
    return unit;
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

- (UIImage *)imageForAnime {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, self.image_tn];
    UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImageLocation];
    
    if(cachedImage) {
        ALVLog(@"Image on disk exists for %@.", self.title);
    }
    else {
        ALVLog(@"Image on disk does not exist for %@.", self.title);
    }
    
    return cachedImage;
}

- (NSString *)image_tn {
    return [self.image stringByReplacingOccurrencesOfString:@".png" withString:@"_tn.png"];
}

- (void)saveImage:(UIImage *)image fromRequest:(NSURLRequest *)request {
    NSArray *segmentedURL = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
    NSString *filename = [segmentedURL lastObject];
    NSString *thumbnailName = [filename stringByReplacingOccurrencesOfString:@".png" withString:@"_tn.png"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *animeImagePath = [NSString stringWithFormat:@"%@/anime/%@", documentsDirectory, filename];
    NSString *thumbnailImagePath = [NSString stringWithFormat:@"%@/anime/%@", documentsDirectory, thumbnailName];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL saved = NO;
        saved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:animeImagePath options:NSAtomicWrite error:nil];
        ALLog(@"Image %@", saved ? @"saved." : @"did not save.");
        
        UIImage *thumbnail = [UIImage imageWithImage:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
        saved = [UIImageJPEGRepresentation(thumbnail, 1.0) writeToFile:thumbnailImagePath options:NSAtomicWrite error:nil];
        ALLog(@"Thumbnail %@", saved ? @"saved." : @"did not save.");
    });
    
    // Only save relative URL since Documents URL can change on updates.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image = [NSString stringWithFormat:@"anime/%@", filename];
    });
}

@end
