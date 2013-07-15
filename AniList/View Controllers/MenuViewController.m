//
//  MenuViewController.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"
#import "ProfileCell.h"
#import "AnimeListViewController.h"
#import "AniListAppDelegate.h"
#import "AniListNavigationController.h"

#define kCellTitleKey @"kCellTitleKey"
#define kCellViewControllerKey @"kCellViewControllerKey"
#define kCellActionKey @"kCellActionKey"

@interface MenuViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation MenuViewController

static NSArray *items = nil;
static NSString *CellIdentifier = @"Cell";

- (id)init {
    self = [super init];
    if(self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.tableView.scrollEnabled = NO;
    
    if(!items) {
        items = @[
                  @{
                      kCellTitleKey : @"Anime",
                      kCellViewControllerKey : @"AnimeListViewController",
                      kCellActionKey : @"loadViewController:"
                      },
                  @{
                      kCellTitleKey : @"Manga",
                      kCellViewControllerKey : @"MangaListViewController",
                      kCellActionKey : @"loadViewController:"
                      },
                  @{
                      kCellTitleKey : @"Search",
                      kCellViewControllerKey : @"SearchViewController",
                      kCellActionKey : @"loadViewController:"
                      },
                  @{
                      kCellTitleKey : @"Settings",
                      kCellViewControllerKey : @"SettingsViewController",
                      kCellActionKey : @"loadViewController:"
                      },
                  @{
                      kCellTitleKey : @"Log Out",
                      kCellViewControllerKey : @"LoginViewController",
                      kCellActionKey : @"logout:"
                      }
                  ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cell Action Methods

- (void)loadViewController:(UIViewController *)viewController {
    AniListNavigationController *navigationController = [[AniListNavigationController alloc] initWithRootViewController:viewController];
    [self.revealViewController setFrontViewController:navigationController animated:YES];
}

- (void)loadModalViewController:(UIViewController *)viewController {
    AnimeListViewController *animeVC = [[AnimeListViewController alloc] init];
    AniListNavigationController *navigationController = [[AniListNavigationController alloc] initWithRootViewController:animeVC];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [navigationController presentViewController:viewController animated:YES completion:^{
        [self.revealViewController setFrontViewController:navigationController animated:YES];
    }];
}

- (void)logout:(UIViewController *)viewController {
    // wipe all cached data.
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate clearDatabase];
    
    [self loadModalViewController:viewController];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MenuCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = items[indexPath.row][kCellTitleKey];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = NSClassFromString(items[indexPath.row][kCellViewControllerKey]);
    SEL selector = NSSelectorFromString(items[indexPath.row][kCellActionKey]);
    
    if([class isSubclassOfClass:[UIViewController class]]) {
        UIViewController *viewController = [[class alloc] init];
        [self performSelector:selector withObject:viewController];
    }
}

@end
