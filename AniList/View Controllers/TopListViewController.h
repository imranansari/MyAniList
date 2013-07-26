//
//  TopListViewController.h
//  AniList
//
//  Created by Corey Roberts on 7/26/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "BaseViewController.h"

@interface TopListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *entityName;

@end
