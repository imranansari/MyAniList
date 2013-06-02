//
//  AnimeCell.h
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListCell.h"

@class Anime;

@interface AnimeCell : AniListCell

+ (CGFloat)cellHeight;

+ (NSString *)progressTextForAnime:(Anime *)anime;
- (void)addShadow;

@end
