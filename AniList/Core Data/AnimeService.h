//
//  AnimeService.h
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Anime.h"

@class Friend;

@interface AnimeService : NSObject

+ (NSArray *)allAnime;
+ (Anime *)animeForID:(NSNumber *)ID;
+ (Anime *)animeForID:(NSNumber *)ID withMOC:(NSManagedObjectContext *)context;
+ (BOOL)addAnimeList:(NSDictionary *)data;
+ (BOOL)addAnimeList:(NSDictionary *)data forFriend:(Friend *)friend;
+ (Anime *)addAnime:(NSDictionary *)data fromRelatedManga:(Manga *)manga withContext:(NSManagedObjectContext *)context;
+ (BOOL)addAnimeListFromSearch:(NSArray *)data;
+ (Anime *)addAnime:(NSDictionary *)data;
+ (Anime *)addAnime:(NSDictionary *)data withMOC:(NSManagedObjectContext *)context;
+ (Anime *)editAnime:(NSDictionary *)data withMOC:(NSManagedObjectContext *)context withObject:(Anime *)anime;
+ (void)deleteAnime:(Anime *)anime;

+ (NSString *)animeToXML:(NSNumber *)animeID;

@end
