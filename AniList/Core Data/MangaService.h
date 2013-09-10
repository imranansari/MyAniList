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

+ (NSArray *)allManga;
+ (Manga *)mangaForID:(NSNumber *)ID;
+ (Manga *)mangaForID:(NSNumber *)ID withMOC:(NSManagedObjectContext *)context;
+ (BOOL)addMangaList:(NSDictionary *)data;
+ (BOOL)addMangaList:(NSDictionary *)data forFriend:(Friend *)friend;
+ (Manga *)addManga:(NSDictionary *)data fromRelatedAnime:(Anime *)anime withContext:(NSManagedObjectContext *)context;
+ (BOOL)addMangaListFromSearch:(NSArray *)data;
+ (Manga *)addManga:(NSDictionary *)data;
+ (Manga *)addManga:(NSDictionary *)data withMOC:(NSManagedObjectContext *)context;
+ (Manga *)editManga:(NSDictionary *)data withMOC:(NSManagedObjectContext *)context withObject:(Manga *)manga;
+ (void)deleteManga:(Manga *)manga;

+ (NSString *)mangaToXML:(NSNumber *)mangaID;

@end
