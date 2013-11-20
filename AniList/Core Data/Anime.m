//
//  Anime.m
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "Anime.h"
#import "FICUtilities.h"

#pragma mark External Definitions

NSString *const PosterImageFormatFamily = @"PosterImageFormatFamily";
NSString *const PosterImageFormatName = @"PosterImageFormatName";
CGSize const PosterImageSize = {131, 207};

NSString *const ThumbnailPosterImageFormatFamily = @"ThumbnailPosterImageFormatFamily";
NSString *const ThumbnailPosterImageFormatName = @"ThumbnailPosterImageFormatName";
CGSize const ThumbnailPosterImageSize = {58, 91};

NSString *const MiniPosterImageFormatFamily = @"MiniPosterImageFormatFamily";
NSString *const MiniPosterImageFormatName = @"MiniPosterImageFormatName";
CGSize const MiniPosterImageSize = {37, 60};

@interface Anime()  {
    NSURL *_sourceImageURL;
    NSString *_UUID;
    NSString *_thumbnailFilePath;
    BOOL _thumbnailFileExists;
    BOOL _didCheckForThumbnailFile;
}

@end

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

@synthesize sourceImageURL = _sourceImageURL;

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

+ (NSString *)stringForAnimeWatchedStatus:(AnimeWatchedStatus)watchedStatus forAnimeType:(AnimeType)animeType forEditScreen:(BOOL)forEditScreen {
    
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
            return [NSString stringWithFormat:@"%@ watching this %@.", forEditScreen ? @"Currently" : @"You are", seriesText];
        case AnimeWatchedStatusCompleted:
            return [NSString stringWithFormat:@"%@ this %@.", forEditScreen ? @"Finished with" : @"You finished", seriesText];
        case AnimeWatchedStatusOnHold:
            return [NSString stringWithFormat:@"%@ this %@ on hold.", forEditScreen ? @"Putting" : @"You put", seriesText];
        case AnimeWatchedStatusDropped:
            return [NSString stringWithFormat:@"%@ this %@.", forEditScreen ? @"Dropping" : @"You dropped", seriesText];
        case AnimeWatchedStatusPlanToWatch:
            return [NSString stringWithFormat:@"%@ to watch this %@.", forEditScreen ? @"Planning" : @"You plan", seriesText];
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
    NSString *cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, self.image];
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
//    NSString *thumbnailName = [filename stringByReplacingOccurrencesOfString:@".png" withString:@"_tn.png"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *animeImagePath = [NSString stringWithFormat:@"%@/anime/%@", documentsDirectory, filename];
//    NSString *thumbnailImagePath = [NSString stringWithFormat:@"%@/anime/%@", documentsDirectory, thumbnailName];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL saved = NO;
        saved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:animeImagePath options:NSAtomicWrite error:nil];
        ALLog(@"Image %@", saved ? @"saved." : @"did not save.");
        
//        UIImage *thumbnail = [UIImage imageWithImage:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];
//        saved = [UIImageJPEGRepresentation(thumbnail, 1.0) writeToFile:thumbnailImagePath options:NSAtomicWrite error:nil];
//        ALLog(@"Thumbnail %@", saved ? @"saved." : @"did not save.");
    });
    
    // Only save relative URL since Documents URL can change on updates.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image = [NSString stringWithFormat:@"anime/%@", filename];
    });
}

#pragma mark - Property Accessors

- (UIImage *)sourceImage {
    UIImage *sourceImage = [UIImage imageWithContentsOfFile:[self.sourceImageURL path]];
    
    return sourceImage;
}

- (UIImage *)thumbnailImage {
    UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:[self _thumbnailFilePath]];
    
    return thumbnailImage;
}

- (BOOL)thumbnailImageExists {
    BOOL thumbnailImageExists = [[NSFileManager defaultManager] fileExistsAtPath:[self _thumbnailFilePath]];
    
    return thumbnailImageExists;
}

- (NSURL *)sourceImageURL {
    return [NSURL URLWithString:self.image_url];
}

#pragma mark - Conventional Image Caching Techniques

- (NSString *)_thumbnailFilePath {
    if (!_thumbnailFilePath) {
        NSURL *photoURL = [self sourceImageURL];
        _thumbnailFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[photoURL absoluteString] lastPathComponent]];
    }
    
    return _thumbnailFilePath;
}

- (void)generateThumbnail {
    NSString *thumbnailFilePath = [self _thumbnailFilePath];
    if (!_didCheckForThumbnailFile) {
        _didCheckForThumbnailFile = YES;
        _thumbnailFileExists = [[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilePath];
    }
    
    if (_thumbnailFileExists == NO) {
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        CGRect contextBounds = CGRectZero;
        contextBounds.size = CGSizeMake(ThumbnailPosterImageSize.width * screenScale, ThumbnailPosterImageSize.height * screenScale);
        
        UIImage *sourceImage = [self sourceImage];
        
        UIGraphicsBeginImageContext(contextBounds.size);
        
        [sourceImage drawInRect:contextBounds];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        NSData *scaledImageJPEGRepresentation = UIImageJPEGRepresentation(scaledImage, 0.8);
        
        [scaledImageJPEGRepresentation writeToFile:thumbnailFilePath atomically:NO];
        
        UIGraphicsEndImageContext();
        _thumbnailFileExists = YES;
    }
}

- (void)deleteThumbnail {
    [[NSFileManager defaultManager] removeItemAtPath:[self _thumbnailFilePath] error:NULL];
    _thumbnailFileExists = NO;
}


static UIImage * _ThumbnailImageFromImage(UIImage *image) {
    UIGraphicsBeginImageContextWithOptions(ThumbnailPosterImageSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, ThumbnailPosterImageSize.width, ThumbnailPosterImageSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Protocol Implementations

#pragma mark - FICImageCacheEntity

- (NSString *)UUID {
    if (_UUID == nil) {
        // MD5 hashing is expensive enough that we only want to do it once
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([self.sourceImageURL absoluteString]);
        _UUID = FICStringWithUUIDBytes(UUIDBytes);
    }
    
    return _UUID;
}

- (NSString *)sourceImageUUID {
    return [self UUID];
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    return self.sourceImageURL;
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName {
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef contextRef, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(contextRef, contextBounds);
        
        UIGraphicsBeginImageContextWithOptions(contextSize, NO, 0.0f);
        
        CGFloat newWidth = image.size.width * (contextSize.height / image.size.height);
        [image drawInRect:CGRectMake((contextSize.width - newWidth) / 2, 0.0f, newWidth, contextSize.height)];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if ([formatName isEqualToString:PosterImageFormatName]) {
            UIGraphicsPushContext(contextRef);
            [newImage drawInRect:contextBounds];
            UIGraphicsPopContext();
        }
        else if([formatName isEqualToString:ThumbnailPosterImageFormatName]) {
            UIImage *thumbnail = _ThumbnailImageFromImage(newImage);
            UIGraphicsPushContext(contextRef);
            [thumbnail drawInRect:contextBounds];
            UIGraphicsPopContext();
        }
    };
    
    return drawingBlock;
}

@end
