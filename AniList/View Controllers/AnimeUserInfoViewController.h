//
//  AnimeUserInfoViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListUserInfoViewController.h"

typedef enum {
    AnimePickerWatchingStatus = 0,
    AnimePickerStartDate,
    AnimePickerEndDate,
    AnimePickerProgress,
    AnimePickerScore
} AnimePickerTypes;

@class Anime;

@interface AnimeUserInfoViewController : AniListUserInfoViewController

@end
