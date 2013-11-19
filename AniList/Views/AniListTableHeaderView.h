//
//  AniListTableHeaderView.h
//  AniList
//
//  Created by Corey Roberts on 11/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AniListTableHeaderView : UITableViewHeaderFooterView

- (id)initWithPrimaryText:(NSString *)primaryText andSecondaryText:(NSString *)secondaryText;
- (id)initWithPrimaryText:(NSString *)primaryText andSecondaryText:(NSString *)secondaryText isExpanded:(BOOL)expanded;

- (void)expand;
- (void)expand:(BOOL)expand;
- (void)expand:(BOOL)expand animated:(BOOL)animated;

@end
