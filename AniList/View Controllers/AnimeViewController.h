//
//  AnimeViewController.h
//  AniList
//
//  Created by Corey Roberts on 4/16/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AniListSummaryViewController.h"
#import "Anime.h"
#import "AnimeUserInfoViewController.h"

@interface AnimeViewController : AniListSummaryViewController<AniListUserInfoViewControllerDelegate>

@property (nonatomic, strong) Anime *anime;

@end
