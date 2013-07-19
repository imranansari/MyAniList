//
//  AnimeService.h
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Anime.h"

@interface AnimeService : NSObject

+ (Anime *)animeForID:(NSNumber *)ID;
+ (BOOL)addAnimeList:(NSDictionary *)data;
+ (BOOL)addAnimeListFromSearch:(NSArray *)data;
+ (Anime *)addAnime:(NSDictionary *)data fromList:(BOOL)fromList;
+ (Anime *)editAnime:(NSDictionary *)data fromList:(BOOL)fromList;
+ (void)deleteAnime:(Anime *)anime;

+ (NSString *)animeToXML:(NSNumber *)animeID;

@end
