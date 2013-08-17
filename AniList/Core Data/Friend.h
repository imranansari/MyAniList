//
//  Friend.h
//  AniList
//
//  Created by Corey Roberts on 8/16/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendAnime;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString *image_url;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSNumber *anime_completed;
@property (nonatomic, retain) NSNumber *anime_total_entries;
@property (nonatomic, retain) NSNumber *manga_completed;
@property (nonatomic, retain) NSNumber *manga_total_entries;
@property (nonatomic, retain) NSString *last_seen;
@property (nonatomic, retain) NSSet *sharedAnime;
@end

@interface Friend (CoreDataGeneratedAccessors)

- (void)addSharedAnimeObject:(FriendAnime *)value;
- (void)removeSharedAnimeObject:(FriendAnime *)value;
- (void)addSharedAnime:(NSSet *)values;
- (void)removeSharedAnime:(NSSet *)values;

@end
