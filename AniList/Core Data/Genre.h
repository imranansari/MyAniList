//
//  Genre.h
//  AniList
//
//  Created by Corey Roberts on 7/20/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Anime, Manga;

@interface Genre : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Anime *anime;
@property (nonatomic, retain) Manga *manga;

@end
