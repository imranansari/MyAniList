//
//  Tag.h
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Anime, Manga;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *anime;
@property (nonatomic, retain) NSSet *manga;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addAnimeObject:(Anime *)value;
- (void)removeAnimeObject:(Anime *)value;
- (void)addAnime:(NSSet *)values;
- (void)removeAnime:(NSSet *)values;

- (void)addMangaObject:(Manga *)value;
- (void)removeMangaObject:(Manga *)value;
- (void)addManga:(NSSet *)values;
- (void)removeManga:(NSSet *)values;

@end
