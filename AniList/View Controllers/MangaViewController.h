//
//  MangaViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListSummaryViewController.h"
#import "AniListUserInfoViewController.h"

@class Manga;

@interface MangaViewController : AniListSummaryViewController<AniListUserInfoViewControllerDelegate>

@property (nonatomic, strong) Manga *manga;

@end
