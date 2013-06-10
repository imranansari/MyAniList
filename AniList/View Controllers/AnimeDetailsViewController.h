//
//  AnimeDetailsViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

@class Anime;

@interface AnimeDetailsViewController : AniListDetailsViewController

@property (nonatomic, strong) Anime *anime;

@end
