//
//  CompareViewController.h
//  AniList
//
//  Created by Corey Roberts on 10/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "Friend.h"

typedef enum {
    ComparisonSectionMutual = 0,
    ComparisonSectionFriend,
    ComparisonSectionUser
} ComparisonSection;

@interface CompareViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Friend *friend;

@end
