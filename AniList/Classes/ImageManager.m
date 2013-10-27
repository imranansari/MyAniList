//
//  ImageManager.m
//  AniList
//
//  Created by Corey Roberts on 8/26/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "ImageManager.h"
#import "Anime.h"
#import "Manga.h"

@interface ImageManager()
@property (nonatomic, strong) NSMutableDictionary *animeImages;
@property (nonatomic, strong) NSMutableDictionary *mangaImages;
@property (nonatomic, strong) FICImageCache *sharedImageCache;
@end

@implementation ImageManager

#pragma mark - Singleton Methods

+ (ImageManager *)sharedManager {
    static dispatch_once_t pred;
    static ImageManager *sharedManager = nil;
    
    dispatch_once(&pred, ^{
        sharedManager = [[ImageManager alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        self.sharedImageCache = [FICImageCache sharedImageCache];
        self.sharedImageCache.delegate = self;
        self.sharedImageCache.formats = [self createFormats];
    }
    
    return self;
}

- (NSArray *)createFormats {
    FICImageFormat *thumbnailFormat = [FICImageFormat formatWithName:ThumbnailPosterImageFormatName
                                                              family:PosterImageFormatFamily
                                                           imageSize:ThumbnailPosterImageSize
                                                               style:FICImageFormatStyle32BitBGR
                                                        maximumCount:500
                                                             devices:FICImageFormatDevicePhone];
    
    
    FICImageFormat *standardFormat = [FICImageFormat formatWithName:PosterImageFormatName
                                                               family:PosterImageFormatFamily
                                                            imageSize:PosterImageSize
                                                              style:FICImageFormatStyle32BitBGR
                                                       maximumCount:500
                                                            devices:FICImageFormatDevicePhone];
    
    return @[thumbnailFormat, standardFormat];
}

- (void)imageForAnime:(Anime *)anime withFormat:(NSString *)formatName {
    [self.sharedImageCache asynchronouslyRetrieveImageForEntity:anime
                                                 withFormatName:formatName
                                                completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
    }];
}

- (UIImage *)imageForAnime:(Anime *)anime {

    return self.animeImages[[anime.anime_id stringValue]];
}

- (UIImage *)imageForManga:(Manga *)manga {
    return self.mangaImages[[manga.manga_id stringValue]];
}

- (void)addImage:(UIImage *)image forAnime:(Anime *)anime {
    [self.animeImages addEntriesFromDictionary:@{ [anime.anime_id stringValue] : image }];
}

- (void)addImage:(UIImage *)image forManga:(Manga *)manga {
    [self.mangaImages addEntriesFromDictionary:@{ [manga.manga_id stringValue] : image }];
}

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    
}

@end
