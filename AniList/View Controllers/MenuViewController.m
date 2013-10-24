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
#import "MALHTTPClient.h"
#import "LoginViewController.h"
#import "TopListViewController.h"
#import "PopularListViewController.h"
#import "CRTransitionLabel.h"

#define kCellTitleKey @"kCellTitleKey"
#define kCellViewControllerKey @"kCellViewControllerKey"
#define kCellActionKey @"kCellActionKey"

@interface MenuViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIImageView *profileImage;
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *animeStats;
@property (nonatomic, weak) IBOutlet UILabel *mangaStats;
@property (nonatomic, weak) IBOutlet UIView *statusView;
@property (nonatomic, weak) IBOutlet UIProgressView *progress;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *statusText;
@end

@implementation MenuViewController

static NSArray *items = nil;
static NSString *CellIdentifier = @"Cell";

- (id)init {
    self = [super init];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchProfile) name:kUserLoggedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:kAnimeDownloadProgress object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:kMangaDownloadProgress object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.scrollEnabled = NO;

    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImage.backgroundColor = [UIColor clearColor];
    self.profileImage.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.4f].CGColor;
    
    if(!items) {
        items = @[
                  @{
                      kCellTitleKey : @"Anime",
                      kCellViewControllerKey : @"AnimeListViewController",
                      kCellActionKey : @"loadViewController:",
                      },
                  @{
                      kCellTitleKey : @"- Top",
                      kCellViewControllerKey : @"TopListViewController",
                      kCellActionKey : @"loadTopAnimeViewController:"
                      },
                  @{
                      kCellTitleKey : @"- Popular",
                      kCellViewControllerKey : @"PopularListViewController",
                      kCellActionKey : @"loadPopularAnimeViewController:"
                      },
                  @{
                      kCellTitleKey : @"- Upcoming",
                      kCellViewControllerKey : @"TopListViewController",
                      kCellActionKey : @"loadUpcomingAnimeViewController:"
                      },
                  @{
                      kCellTitleKey : @"Manga",
                      kCellViewControllerKey : @"MangaListViewController",
                      kCellActionKey : @"loadViewController:"
                      },
//                  @{
//                      kCellTitleKey : @"Top Manga",
//                      kCellViewControllerKey : @"TopListViewController",
//                      kCellActionKey : @"loadTopMangaViewController:"
//                      },
                  @{
                      kCellTitleKey : @"Search",
                      kCellViewControllerKey : @"SearchViewController",
                      kCellActionKey : @"loadViewController:"
                      },
                  @{
                      kCellTitleKey : @"Friends",
                      kCellViewControllerKey : @"FriendsViewController",
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
    
    [self fetchProfile];
}

- (void)viewWillAppear:(BOOL)animated {
    if(!self.profileImage.image) {
        [self fetchProfile];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Methods

- (void)fetchProfile {
    if([UserProfile userIsLoggedIn]) {
        [[UserProfile profile] fetchProfileWithCompletion:^{
            self.username.text = [[UserProfile profile] username];
            
            self.animeStats.text = [NSString stringWithFormat:@"Anime time in days: %@", [[UserProfile profile] animeStats][kStatsTotalTimeInDays]];
            self.mangaStats.text = [NSString stringWithFormat:@"Manga time in days: %@", [[UserProfile profile] mangaStats][kStatsTotalTimeInDays]];
            
            NSURLRequest *request = [[UserProfile profile] profileImageURL];
            [self.profileImage setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  ALLog(@"image found");
                                                  self.profileImage.image = image;
                                              }
                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                  ALLog(@"image failed.");
                                              }];
        }];
    }
}

- (void)updateProgress:(NSNotification *)notification {
    NSDictionary *dictionary = notification.object;
    
    double value = [dictionary[kDownloadProgress] floatValue];
    
    self.statusText.text = [NSString stringWithFormat:@"Downloading Info (%0.00f%%)...", value*100];
    [self.progress setProgress:value animated:YES];
    
    if(value == 1.0f) {
        self.statusText.text = @"Download completed!";
        
        [UIView animateWithDuration:0.3f
                              delay:2.0f
                            options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                self.statusView.frame = CGRectMake(self.statusView.frame.origin.x, self.statusView.frame.origin.y + self.statusView.frame.size.height, self.statusView.frame.size.width, self.statusView.frame.size.height);
                            }
                         completion:nil];
    }
}

#pragma mark - Cell Action Methods

- (void)loadViewController:(UIViewController *)viewController {
    AniListNavigationController *navigationController = [[AniListNavigationController alloc] initWithRootViewController:viewController];
    [self.revealViewController setFrontViewController:navigationController animated:YES];
}

- (void)loadTopAnimeViewController:(UIViewController *)viewController {
    [self loadTopViewController:viewController forEntity:@"Anime"];
}

- (void)loadPopularAnimeViewController:(UIViewController *)viewController {
    [self loadPopularViewController:viewController forEntity:@"Anime"];
}

- (void)loadUpcomingAnimeViewController:(UIViewController *)viewController {

}

- (void)loadTopMangaViewController:(UIViewController *)viewController {
    [self loadTopViewController:viewController forEntity:@"Manga"];
}

- (void)loadTopViewController:(UIViewController *)viewController forEntity:(NSString *)entity {
    TopListViewController *topListViewController = (TopListViewController *)viewController;
    topListViewController.entityName = entity;
    AniListNavigationController *navigationController = [[AniListNavigationController alloc] initWithRootViewController:topListViewController];
    [self.revealViewController setFrontViewController:navigationController animated:YES];
}

- (void)loadPopularViewController:(UIViewController *)viewController forEntity:(NSString *)entity {
    PopularListViewController *popularListViewController = (PopularListViewController *)viewController;
    popularListViewController.entityName = entity;
    AniListNavigationController *navigationController = [[AniListNavigationController alloc] initWithRootViewController:popularListViewController];
    [self.revealViewController setFrontViewController:navigationController animated:YES];
}

- (void)loadModalViewController:(UIViewController *)viewController {
    AnimeListViewController *animeVC = [[AnimeListViewController alloc] init];
    AniListNavigationController *navigationController = [[AniListNavigationController alloc] initWithRootViewController:animeVC];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.revealViewController presentViewController:viewController animated:YES completion:^{
        [self.revealViewController setFrontViewController:navigationController animated:YES];
    }];
    
}

- (void)logout:(UIViewController *)viewController {
    // wipe all cached data.
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate clearDatabase];
    [[UserProfile profile] logout];
    
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
    if(indexPath.row > 0 && indexPath.row < 4) {
        return 30;
    }
    
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
    
//    [cell addGradient];
    cell.textLabel.text = items[indexPath.row][kCellTitleKey];
    [cell.textLabel addShadow];
    
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
