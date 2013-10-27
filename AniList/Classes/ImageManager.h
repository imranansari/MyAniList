//
//  ImageManager.h
//  AniList
//
//  Created by Corey Roberts on 8/26/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FICImageCache.h"

@class Anime, Manga;

@interface ImageManager : NSObject<FICImageCacheDelegate>

+ (ImageManager *)sharedManager;
- (UIImage *)imageForAnime:(Anime *)anime;
- (UIImage *)imageForManga:(Manga *)manga;
- (void)addImage:(UIImage *)image forAnime:(Anime *)anime;
- (void)addImage:(UIImage *)image forManga:(Manga *)manga;

@end
