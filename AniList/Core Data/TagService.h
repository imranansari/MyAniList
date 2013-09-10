//
//  TagService.h
//  AniList
//
//  Created by Corey Roberts on 7/20/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tag, Anime, Manga;

@interface TagService : NSObject

+ (NSArray *)animeWithTag:(NSString *)tagName;
+ (NSArray *)animeWithTag:(NSString *)tagName withContext:(NSManagedObjectContext *)context;
+ (NSArray *)mangaWithTag:(NSString *)tagName;
+ (NSArray *)mangaWithTag:(NSString *)tagName withContext:(NSManagedObjectContext *)context;
+ (Tag *)addTag:(NSString *)title toAnime:(Anime *)anime;
+ (Tag *)addTag:(NSString *)title toAnime:(Anime *)anime withContext:(NSManagedObjectContext *)context;
+ (Tag *)addTag:(NSString *)title toManga:(Manga *)manga;
+ (Tag *)addTag:(NSString *)title toManga:(Manga *)manga withContext:(NSManagedObjectContext *)context;

@end
