//
//  SearchViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SearchViewController : BaseViewController<UISearchDisplayDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@end
