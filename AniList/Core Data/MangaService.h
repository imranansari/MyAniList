//
//  MangaService.h
//  AniList
//
//  Created by Corey Roberts on 6/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Manga.h"

@interface MangaService : NSObject

+ (Manga *)mangaForID:(NSNumber *)ID;
+ (BOOL)addMangaList:(NSDictionary *)data;
+ (Manga *)addManga:(NSDictionary *)data fromList:(BOOL)fromList;
+ (Manga *)editManga:(NSDictionary *)data fromList:(BOOL)fromList;
+ (void)deleteManga:(Manga *)manga;

+ (NSString *)mangaToXML:(NSNumber *)mangaID;

@end