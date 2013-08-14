//
//  FriendAnimeService.h
//  AniList
//
//  Created by Corey Roberts on 8/10/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FriendAnime, Friend, Anime;

@interface FriendAnimeService : NSObject

+ (FriendAnime *)addFriend:(Friend *)friend toAnime:(Anime *)anime;

@end
