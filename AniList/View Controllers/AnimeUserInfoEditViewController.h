//
//  AnimeUserInfoEditViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/8/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListUserInfoEditViewController.h"
#import "AniListScoreView.h"

@class Anime;

@interface AnimeUserInfoEditViewController : AniListUserInfoEditViewController<AniListScoreViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) Anime *anime;

@end
