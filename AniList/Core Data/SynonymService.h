//
//  SynonymService.h
//  AniList
//
//  Created by Corey Roberts on 7/20/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Synonym, Anime, Manga;

@interface SynonymService : NSObject

+ (Synonym *)addSynonym:(NSString *)title toAnime:(Anime *)anime;
+ (Synonym *)addSynonym:(NSString *)title toManga:(Manga *)manga;
+ (Synonym *)addEnglishTitle:(NSString *)englishTitle toAnime:(Anime *)anime;
+ (Synonym *)addEnglishTitle:(NSString *)englishTitle toManga:(Manga *)manga;
+ (Synonym *)addJapaneseTitle:(NSString *)japaneseTitle toAnime:(Anime *)anime;
+ (Synonym *)addJapaneseTitle:(NSString *)japaneseTitle toManga:(Manga *)manga;

@end
