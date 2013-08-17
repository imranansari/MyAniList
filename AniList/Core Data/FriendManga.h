//
//  FriendManga.h
//  AniList
//
//  Created by Corey Roberts on 8/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend, Manga;

@interface FriendManga : NSManagedObject

@property (nonatomic, retain) NSNumber * column;
@property (nonatomic, retain) NSNumber * current_volume;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * read_status;
@property (nonatomic, retain) NSNumber * current_chapter;
@property (nonatomic, retain) Manga *manga;
@property (nonatomic, retain) Friend *user;

@end
