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

@interface AniListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) NSArray *sectionHeaders;
@property (nonatomic, strong) NSMutableArray *sectionHeaderViews;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, assign) BOOL viewTop;
@property (nonatomic, assign) BOOL viewPopular;
@property (nonatomic, strong) NSIndexPath *editedIndexPath;

- (void)fetchData;
- (NSString *)entityName;
- (NSArray *)sortDescriptors;
- (NSString *)sectionKeyPathName;
- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object;
- (void)updateHeaders;

@end
