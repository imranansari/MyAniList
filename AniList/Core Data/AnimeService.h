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

+ (int)numberOfAnimeForWatchedStatus:(AnimeWatchedStatus)status;
+ (NSArray *)allAnime;
+ (NSArray *)myAnime;
+ (void)downloadInfo;
+ (Anime *)animeForID:(NSNumber *)ID;
+ (BOOL)addAnimeList:(NSDictionary *)data;
+ (BOOL)addAnimeList:(NSDictionary *)data forFriend:(Friend *)friend;
+ (Anime *)addAnime:(NSDictionary *)data fromRelatedManga:(Manga *)manga;
+ (BOOL)addAnimeListFromSearch:(NSArray *)data;
+ (Anime *)addAnimeFromFriend:(NSDictionary *)data;
+ (Anime *)addAnime:(NSDictionary *)data fromList:(BOOL)fromList;
+ (void)deleteAnime:(Anime *)anime;
+ (void)deleteAllAnime;

+ (NSString *)animeToXML:(NSNumber *)animeID;

@end
