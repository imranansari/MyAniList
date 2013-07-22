//
//  GenreService.h
//  AniList
//
//  Created by Corey Roberts on 7/20/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Genre, Anime, Manga;

@interface GenreService : NSObject

+ (Genre *)addGenre:(NSString *)title toAnime:(Anime *)anime;
+ (Genre *)addGenre:(NSString *)title toManga:(Manga *)manga;

@end
