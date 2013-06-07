//
//  AnimeUserInfoViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListUserInfoViewController.h"

@protocol AniListUserInfoViewControllerDelegate <NSObject>
- (void)userInfoPressed;
@end

@class Anime;

@interface AnimeUserInfoViewController : AniListUserInfoViewController

@property (nonatomic, strong) Anime *anime;
@property (nonatomic, assign) id<AniListUserInfoViewControllerDelegate> delegate;

@end
