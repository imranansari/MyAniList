//
//  TagListViewController.h
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TagListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *genre;

@end
