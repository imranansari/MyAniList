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

@dynamic average_count;
@dynamic average_score;
@dynamic column;
@dynamic comments;
@dynamic current_chapter;
@dynamic current_volume;
@dynamic date_finish;
@dynamic date_start;
@dynamic downloaded_chapters;
@dynamic enable_discussion;
@dynamic enable_rereading;
@dynamic favorited_count;
@dynamic image;
@dynamic image_tn;
@dynamic image_url;
@dynamic last_updated;
@dynamic manga_id;
@dynamic popularity_rank;
@dynamic priority;
@dynamic rank;
@dynamic read_status;
@dynamic reread_value;
@dynamic retail_volumes;
@dynamic scan_group;
@dynamic status;
@dynamic synopsis;
@dynamic times_reread;
@dynamic title;
@dynamic total_chapters;
@dynamic total_volumes;
@dynamic type;
@dynamic user_date_finish;
@dynamic user_date_start;
@dynamic user_score;
@dynamic alternative_versions;
@dynamic anime_adaptations;
@dynamic english_titles;
@dynamic genres;
@dynamic japanese_titles;
@dynamic related_manga;
@dynamic synonyms;
@dynamic tags;
@dynamic userlist;

- (void)awakeFromInsert {
    self.read_status = @(MangaReadStatusNotReading);
    self.user_score = @(-1);
}

+ (MangaType)mangaTypeForValue:(NSString *)value {    
    // If value is passed in as an int, convert it.
    int type = [value intValue];

    if(type == 1 || [value isEqualToString:@"Manga"]) return MangaTypeManga;
    if(type == 2 || [value isEqualToString:@"Novel"]) return MangaTypeNovel;
    if(type == 3 || [value isEqualToString:@"One Shot"]) return MangaTypeOneShot;
    if(type == 4 || [value isEqualToString:@"Doujin"]) return MangaTypeDoujin;
    if(type == 5 || [value isEqualToString:@"Manwha"]) return MangaTypeManwha;
    if(type == 6 || [value isEqualToString:@"Manhua"]) return MangaTypeManhua;
    
    // An assumption.
    if(type == 7 || [value isEqualToString:@"OEL"]) return MangaTypeOEL;

    return MangaTypeUnknown;
}

+ (NSString *)stringForMangaType:(MangaType)mangaType {
    
    switch (mangaType) {
        case MangaTypeManga:
            return @"Manga";
        case MangaTypeNovel:
            return @"Novel";
        case MangaTypeOneShot:
            return @"One Shot";
        case MangaTypeDoujin:
            return @"Doujin";
        case MangaTypeManwha:
            return @"Manwha";
        case MangaTypeManhua:
            return @"Manhua";
        case MangaTypeOEL:
            return @"OEL";
        case MangaTypeUnknown:
        default:
            return @"Unknown";
            break;
    }
}

+ (MangaPublishStatus)mangaPublishStatusForValue:(NSString *)value {
    value = [value lowercaseString];
    int publishStatus = [value intValue];

    if(publishStatus == 1 || [value isEqualToString:@"publishing"]) return MangaPublishStatusCurrentlyPublishing;
    if(publishStatus == 2 || [value isEqualToString:@"finished"]) return MangaPublishStatusFinishedPublishing;
    if(publishStatus == 3 || [value isEqualToString:@"not yet published"]) return MangaPublishStatusNotYetPublished;

    return MangaPublishStatusUnknown;
}

+ (NSString *)stringForMangaPublishStatus:(MangaPublishStatus)publishStatus {
    
    switch (publishStatus) {
        case MangaPublishStatusCurrentlyPublishing:
            return @"Currently publishing";
        case MangaPublishStatusFinishedPublishing:
            return @"Finished";
        case MangaPublishStatusNotYetPublished:
            return @"Not yet published";
        case MangaPublishStatusUnknown:
        default:
            return @"Unknown";
    }
}

+ (MangaReadStatus)mangaReadStatusForValue:(NSString *)value {
    
// 1/reading, 2/completed, 3/onhold, 4/dropped, 6/plantoread
    int status = [value intValue];
    
#warning - unit tests.
    if(status == 1 || ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"reading"]))
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

+ (NSString *)stringForMangaReadStatus:(MangaReadStatus)readStatus {
    switch (readStatus) {
        case MangaReadStatusReading:
            return @"Reading";
        case MangaReadStatusCompleted:
            return @"Completed";
        case MangaReadStatusOnHold:
            return @"On Hold";
        case MangaReadStatusDropped:
            return @"Dropped";
        case MangaReadStatusPlanToRead:
            return @"Plan to Read";
        case MangaReadStatusNotReading:
            return @"";
        case MangaReadStatusUnknown:
        default:
            return @"";
    }
}

+ (NSString *)stringForMangaReadStatus:(MangaReadStatus)readStatus forMangaType:(MangaType)mangaType {
    
    NSString *seriesText = @"";
    
    switch (mangaType) {
        case MangaTypeNovel:
            seriesText = @"novel";
            break;
        case MangaTypeManga:
            seriesText = @"manga";
            break;
        case MangaTypeOneShot:
            seriesText = @"one shot";
            break;
        case MangaTypeDoujin:
            seriesText = @"doujin";
            break;
        case MangaTypeManwha:
            seriesText = @"manwha";
            break;
        case MangaTypeManhua:
            seriesText = @"manhua";
            break;
        case MangaTypeOEL:
            seriesText = @"OEL";
            break;
        case MangaTypeUnknown:
        default:
            seriesText = @"manga";
            break;
    }
    
    switch (readStatus) {
        case MangaReadStatusReading:
            return [NSString stringWithFormat:@"Currently reading this %@.", seriesText];
        case MangaReadStatusCompleted:
            return [NSString stringWithFormat:@"You finished this %@.", seriesText];
        case MangaReadStatusOnHold:
            return [NSString stringWithFormat:@"You put this %@ on hold.", seriesText];
        case MangaReadStatusDropped:
            return [NSString stringWithFormat:@"You dropped this %@.", seriesText];
        case MangaReadStatusPlanToRead:
            return [NSString stringWithFormat:@"Planning to read this %@.", seriesText];
        case MangaReadStatusNotReading:
            return [NSString stringWithFormat:@"Add this %@ to your list?", seriesText];
        case MangaReadStatusUnknown:
        default:
            return @"Unknown?";
    }
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

- (UIImage *)imageForManga {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, self.image_tn];
    UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImageLocation];
    
    if(cachedImage) {
        ALLog(@"Image on disk exists for %@.", self.title);
    }
    else {
        ALLog(@"Image on disk does not exist for %@.", self.title);
    }
    
    return cachedImage;
}

- (NSString *)image_tn {
    return [self.image stringByReplacingOccurrencesOfString:@".png" withString:@"_tn.png"];
}

- (void)saveImage:(UIImage *)image fromRequest:(NSURLRequest *)request {
    ALLog(@"Saving image to disk...");
    NSArray *segmentedURL = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
    NSString *filename = [segmentedURL lastObject];
    NSString *thumbnailName = [filename stringByReplacingOccurrencesOfString:@".png" withString:@"_tn.png"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *animeImagePath = [NSString stringWithFormat:@"%@/manga/%@", documentsDirectory, filename];
    NSString *thumbnailImagePath = [NSString stringWithFormat:@"%@/manga/%@", documentsDirectory, thumbnailName];
    
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
        self.image = [NSString stringWithFormat:@"manga/%@", filename];
    });

}

@end
