//
//  AniListViewController.h
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BaseViewController.h"
#import "AniListTableView.h"
#import "AniListNavigationController.h"
#import "EGORefreshTableHeaderView.h"

@interface AniListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) NSArray *sectionHeaders;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;

- (void)fetchData;
- (NSString *)entityName;
- (NSArray *)sortDescriptors;
- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object;

@end
