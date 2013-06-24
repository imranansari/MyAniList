//
//  MangaDetailsViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListDetailsViewController.h"

@class Manga;

@interface MangaDetailsViewController : AniListDetailsViewController

@property (nonatomic, strong) Manga *manga;

@end
