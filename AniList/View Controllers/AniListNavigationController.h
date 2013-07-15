//
//  AniListNavigationController.h
//  AniList
//
//  Created by Corey Roberts on 7/14/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NavigationStyleAnime = 0,
    NavigationStyleManga,
    NavigationStyleSearch,
    NavigationStyleSettings
} NavigationStyle;

@interface AniListNavigationController : UINavigationController

@property (nonatomic, assign) NavigationStyle navigationStyle;

@end
