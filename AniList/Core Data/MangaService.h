//
//  MangaService.h
//  AniList
//
//  Created by Corey Roberts on 6/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Manga.h"

@class Friend;

@interface MangaService : NSObject

+ (int)numberOfMangaForReadStatus:(MangaReadStatus)status;
+ (NSArray *)allManga;
+ (NSArray *)myManga;
+ (void)downloadInfo;
+ (Manga *)mangaForID:(NSNumber *)ID;
+ (BOOL)addMangaList:(NSDictionary *)data;
+ (BOOL)addMangaList:(NSDictionary *)data forFriend:(Friend *)friend;
+ (Manga *)addManga:(NSDictionary *)data fromRelatedAnime:(Anime *)anime;
+ (BOOL)addMangaListFromSearch:(NSArray *)data;
+ (Manga *)addManga:(NSDictionary *)data fromList:(BOOL)fromList;
+ (Manga *)editManga:(NSDictionary *)data fromList:(BOOL)fromList;
+ (void)deleteManga:(Manga *)manga;
+ (void)deleteAllManga;
+ (NSString *)mangaToXML:(NSNumber *)mangaID;

@end
