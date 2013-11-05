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
#import "TagsViewController.h"

#define kCellTitleKey @"kCellTitleKey"
#define kCellViewControllerKey @"kCellViewControllerKey"
#define kCellActionKey @"kCellActionKey"

@interface MenuViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIImageView *profileImage;
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *animeStatsLabel;
@property (nonatomic, weak) IBOutlet UILabel *animeStats;
@property (nonatomic, weak) IBOutlet UILabel *mangaStatsLabel;
@property (nonatomic, weak) IBOutlet UILabel *mangaStats;
@property (nonatomic, weak) IBOutlet UIView *statusView;
@property (nonatomic, weak) IBOutlet UIProgressView *progress;
@property (nonatomic, weak) IBOutlet UILabel *statusText;

@property (nonatomic, assign) BOOL profileFetched;
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
    
    self.progress.tintColor = [UIColor whiteColor];
    self.progress.progress = 0.0f;
    
    self.animeStatsLabel.text = @"Anime Stats";
    self.mangaStatsLabel.text = @"Manga Stats";
    
    self.animeStats.text = self.mangaStats.text = @"-";
    
    self.animeStatsLabel.font = self.mangaStatsLabel.font = [UIFont defaultFontWithSize:12];
    self.animeStats.font = self.mangaStats.font = [UIFont defaultFontWithSize:11];
    self.animeStatsLabel.textColor = self.mangaStatsLabel.textColor = [UIColor grayColor];
    self.animeStats.textColor = self.mangaStats.textColor = [UIColor lightGrayColor];
    
    self.statusText.text = @"";
    
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
//                  @{
//                      kCellTitleKey : @"- Upcoming",
//                      kCellViewControllerKey : @"TopListViewController",
//                      kCellActionKey : @"loadUpcomingAnimeViewController:"
//                      },
                  @{
                      kCellTitleKey : @"- Tags",
                      kCellViewControllerKey : @"TagsViewController",
                      kCellActionKey : @"loadAnimeTagViewController:"
                      },
                  @{
                      kCellTitleKey : @"- Genres",
                      kCellViewControllerKey : @"TagsViewController",
                      kCellActionKey : @"loadAnimeGenreViewController:"
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
                      kCellTitleKey : @"Notifications",
                      kCellViewControllerKey : @"NewsViewController",
                      kCellActionKey : @"loadViewController:"
                      },
                  @{
                      kCellTitleKey : @"Log Out",
                      kCellViewControllerKey : @"LoginViewController",
                      kCellActionKey : @"logout:"
                      }
                  ];
    }
    
    [self.tableView reloadData];
    
    // Set default highlight to Anime.
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [self fetchProfile];
}

- (void)viewWillAppear:(BOOL)animated {
    if(!self.profileFetched)
        [self fetchProfile];
    
    self.animeStats.text = [[UserProfile profile] animeCellStats];
    self.mangaStats.text = [[UserProfile profile] mangaCellStats];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Methods

- (void)fetchProfile {
    if([UserProfile userIsLoggedIn]) {
        
        self.profileImage.image = [UIImage placeholderImage];
        self.username.text = [[UserProfile profile] username];
        
        [[UserProfile profile] fetchProfileWithSuccess:^{
            self.profileFetched = YES;
            
            NSURLRequest *request = [[UserProfile profile] profileImageURL];
            [self.profileImage setImageWithURLRequest:request
                                     placeholderImage:[UIImage placeholderImage]
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  ALLog(@"Profile image found (%@).", [request.URL absoluteString]);
                                                  self.profileImage.image = image;
                                              }
                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                  ALLog(@"Profile image failed to load (%@).", [request.URL absoluteString]);
                                              }];
        } failure:^{
            ALLog(@"Failed to get user profile information.");
        }];
    }
}

- (void)updateProgress:(NSNotification *)notification {
    NSDictionary *dictionary = notification.object;
    
    double value = [dictionary[kDownloadProgress] floatValue];
    
    if(self.progress.progress == 0.0f) {
        [self displayProgressBar];
    }
    
    self.statusText.text = [NSString stringWithFormat:@"Downloading Info (%0.00f%%)...", value*100];
    [self.progress setProgress:value animated:YES];
    
    ALLog(@"Value: %f", value);
    
    if(value >= 1.0f) {
        self.statusText.text = @"Download completed!";
        [self hideProgressBar];
    }
}

- (void)displayProgressBar {
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.statusView.frame = CGRectMake(self.statusView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - self.statusView.frame.size.height, self.statusView.frame.size.width, self.statusView.frame.size.height);
                        }
                     completion:nil];
}

- (void)hideProgressBar {
    [UIView animateWithDuration:0.3f
                          delay:2.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.statusView.frame = CGRectMake(self.statusView.frame.origin.x, self.statusView.frame.origin.y + self.statusView.frame.size.height, self.statusView.frame.size.width, self.statusView.frame.size.height);
                        }
                     completion:^(BOOL finished) {
                         self.progress.progress = 0.0f;
                         self.statusText.text = @"";
                     }];
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

- (void)loadAnimeTagViewController:(UIViewController *)viewController {
    TagsViewController *tagsViewController = (TagsViewController *)viewController;
    tagsViewController.tagType = TagTypeTags;
    
    [self loadViewController:tagsViewController];
}

- (void)loadAnimeGenreViewController:(UIViewController *)viewController {
    TagsViewController *tagsViewController = (TagsViewController *)viewController;
    tagsViewController.tagType = TagTypeGenres;

    [self loadViewController:tagsViewController];
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
    if(indexPath.row > 0 && indexPath.row < 5) {
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
