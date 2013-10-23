//
//  AniListSearchDisplayController.m
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListSearchDisplayController.h"

@implementation AniListSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    [self.searchContentsController.navigationController setNavigationBarHidden:YES animated:NO];
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
    self.searchResultsTableView.backgroundColor = [UIColor clearColor];
}

@end
