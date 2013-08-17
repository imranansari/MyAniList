//
//  FriendMangaService.h
//  AniList
//
//  Created by Corey Roberts on 8/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FriendManga, Friend, Manga;

@interface FriendMangaService : NSObject

+ (FriendManga *)addFriend:(Friend *)friend toManga:(Manga *)manga;
+ (FriendManga *)manga:(Manga *)manga forFriend:(Friend *)friend;
+ (NSArray *)mangaForFriend:(Friend *)friend;

@end
