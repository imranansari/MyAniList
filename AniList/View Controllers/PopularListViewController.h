//
//  PopularListViewController.h
//  AniList
//
//  Created by Corey Roberts on 8/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "BaseViewController.h"

@interface PopularListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *entityName;

@end
