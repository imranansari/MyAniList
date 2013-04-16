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

#define kCellTitleKey @"kCellTitleKey"
#define kCellViewControllerKey @"kCellViewControllerKey"
#define kCellActionKey @"kCellActionKey"

typedef enum {
    kCellTypeProfile = 0,
    kCellTypeMenu
} CellType;

@interface MenuViewController ()

@end

@implementation MenuViewController

static NSArray *items = nil;

static NSString *CellIdentifier = @"Cell";
static NSString *ProfileCellIdentifier = @"ProfileCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!items) {
        items = @[
                  @{
                      kCellTitleKey : @"Anime",
                      kCellViewControllerKey : @"AnimeViewController",
                      kCellActionKey : @"loadViewController:"
                      },
                  @{
                      kCellTitleKey : @"Manga",
                      kCellViewControllerKey : @"MangaViewController",
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
                  
                  
                  
                  ];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadViewController:(UIViewController *)viewController {
    [self.revealViewController setFrontViewController:viewController animated:YES];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kCellTypeProfile :
            return [ProfileCell cellHeight];
        case kCellTypeMenu :
            return [MenuCell cellHeight];
        default:
            NSAssert(NO, @"Cell must either be a ProfileCell or MenuCell.");
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kCellTypeProfile :
            return 1;
        case kCellTypeMenu :
            return items.count;
        default :
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case kCellTypeProfile : {
            ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfileCellIdentifier];
            if(!cell) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[ProfileCell cellID] owner:self options:nil];
                cell = (ProfileCell *)[nib objectAtIndex:0];
//                cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProfileCellIdentifier];
            }
            
            cell.username.text = @"SpacePyro";
            cell.avatar.image = [UIImage imageNamed:@"spacepyro.jpg"];
            
            return cell;
        }
            
        case kCellTypeMenu : {
            MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!cell) {
                cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = items[indexPath.row][kCellTitleKey];
            
            return cell;
        }
            
        default : {
            NSAssert(NO, @"Cell must either be a ProfileCell or MenuCell.");
            return nil;
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case kCellTypeProfile : {
            return;
        }
            
        case kCellTypeMenu : {
            Class class = NSClassFromString(items[indexPath.row][kCellViewControllerKey]);
            if([class isSubclassOfClass:[UIViewController class]]) {
                UIViewController *viewController = [[class alloc] init];
                [self loadViewController:viewController];
            }
            break;
        }
            
        default:
            NSAssert(NO, @"Cell must either be a ProfileCell or MenuCell.");
    }
}

@end
