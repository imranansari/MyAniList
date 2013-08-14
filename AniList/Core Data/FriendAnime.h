//
//  FriendAnime.h
//  AniList
//
//  Created by Corey Roberts on 8/10/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Anime, Friend;

@interface FriendAnime : NSManagedObject

@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) Anime *anime;
@property (nonatomic, retain) Friend *user;

@end
