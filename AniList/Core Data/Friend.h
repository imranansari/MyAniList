//
//  Friend.h
//  AniList
//
//  Created by Corey Roberts on 8/10/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendAnime;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSSet *sharedAnime;
@end

@interface Friend (CoreDataGeneratedAccessors)

- (void)addSharedAnimeObject:(FriendAnime *)value;
- (void)removeSharedAnimeObject:(FriendAnime *)value;
- (void)addSharedAnime:(NSSet *)values;
- (void)removeSharedAnime:(NSSet *)values;

@end
