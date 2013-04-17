//
//  AniListViewController.h
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AniListTableView.h"

@interface AniListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;

- (NSString *)entityName;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
