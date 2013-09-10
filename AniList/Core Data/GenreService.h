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

+ (NSArray *)animeWithGenre:(NSString *)genreName;
+ (NSArray *)animeWithGenre:(NSString *)genreName withContext:(NSManagedObjectContext *)context;
+ (NSArray *)mangaWithGenre:(NSString *)genreName;
+ (NSArray *)mangaWithGenre:(NSString *)genreName withContext:(NSManagedObjectContext *)context;
+ (Genre *)addGenre:(NSString *)title toAnime:(Anime *)anime withContext:(NSManagedObjectContext *)context;
+ (Genre *)addGenre:(NSString *)title toManga:(Manga *)manga withContext:(NSManagedObjectContext *)context;

@end
