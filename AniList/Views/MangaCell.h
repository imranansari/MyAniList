//
//  MangaCell.h
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListCell.h"

@class Manga;

@interface MangaCell : AniListCell

+ (CGFloat)cellHeight;

+ (NSString *)progressTextForFriendManga:(FriendManga *)friendManga;
+ (NSString *)progressTextForManga:(Manga *)manga withSpacing:(BOOL)spacing;
- (void)addShadow;
- (void)setDetailsForManga:(Manga *)manga;

@end
