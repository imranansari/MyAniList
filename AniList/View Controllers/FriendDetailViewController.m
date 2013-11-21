//
//  FriendDetailViewController.m
//  AniList
//
//  Created by Corey Roberts on 8/10/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "FriendDetailViewController.h"

#import "AnimeCell.h"
#import "MangaCell.h"

#import "AniListTableView.h"
#import "AniListAppDelegate.h"
#import "AniListTableHeaderView.h"

#import "Anime.h"
#import "Manga.h"

#import "AnimeService.h"
#import "MangaService.h"

#import "MALHTTPClient.h"

#import "FriendAnime.h"
#import "FriendAnimeService.h"

#import "FriendManga.h"
#import "FriendMangaService.h"

#import "AnimeViewController.h"
#import "MangaViewController.h"
#import "CompareViewController.h"
#import "AniListNavigationController.h"

@interface FriendDetailViewController ()
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UIButton *compareButton;
@property (nonatomic, weak) IBOutlet UISegmentedControl *compareControl;

@property (nonatomic, assign) BOOL displayWatching;
@property (nonatomic, assign) BOOL displayCompleted;
@property (nonatomic, assign) BOOL displayOnHold;
@property (nonatomic, assign) BOOL displayDropped;
@property (nonatomic, assign) BOOL displayPlanToWatch;

@property (nonatomic, copy) NSArray *sectionHeaders;
@property (nonatomic, strong) NSMutableArray *sectionHeaderViews;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (IBAction)compareButtonPressed:(id)sender;
- (IBAction)compareControlPressed:(id)sender;

@end

@implementation FriendDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.managedObjectContext = [(AniListAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
        
        self.displayWatching = YES;
        self.sectionHeaderViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)createHeaders {
    for(int i = 0; i < 5; i++) {
        NSString *count = @"";
        int sectionValue = 0;
        
        BOOL expanded = NO;
        
        switch (i) {
            case 0:
                expanded = self.displayWatching;
                sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusWatching forFriend:self.friend];
                break;
            case 1:
                expanded = self.displayCompleted;
                sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusCompleted forFriend:self.friend];
                break;
            case 2:
                expanded = self.displayOnHold;
                sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusOnHold forFriend:self.friend];
                break;
            case 3:
                expanded = self.displayDropped;
                sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusDropped forFriend:self.friend];
                break;
            case 4:
                expanded = self.displayPlanToWatch;
                sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusPlanToWatch forFriend:self.friend];
                break;
            default:
                break;
        }
        
        count = [NSString stringWithFormat:@"%d", sectionValue];
        
        AniListTableHeaderView *headerView = [[AniListTableHeaderView alloc] initWithPrimaryText:self.sectionHeaders[i] andSecondaryText:count isExpanded:expanded];
        headerView.tag = i;
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] init];
        gestureRecognizer.numberOfTapsRequired = 1;
        [gestureRecognizer addTarget:headerView action:@selector(expand)];
        [gestureRecognizer addTarget:self action:@selector(expand:)];
        [headerView addGestureRecognizer:gestureRecognizer];
        
        [self.sectionHeaderViews addObject:headerView];
    }
}

- (void)resetHeaderDefaults {
    self.displayWatching = YES;
    self.displayCompleted = NO;
    self.displayOnHold = NO;
    self.displayDropped = NO;
    self.displayPlanToWatch = NO;
}

- (void)viewDidLoad
{
    self.hidesBackButton = NO;
    
    [super viewDidLoad];
    
    [self createHeaders];
    
    self.compareControl.selectedSegmentIndex = 0;
    
    self.indicator.alpha = 1.0f;
    
    [self fetchAnime];
    [self fetchManga];
    
    self.title = [NSString stringWithFormat:@"%@'s List", self.friend.username];
    self.tableView.backgroundColor = [UIColor clearColor];

    [self.avatar setImageWithURL:[NSURL URLWithString:self.friend.image_url]
                placeholderImage:[UIImage placeholderImage]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.015f);
    gradient.endPoint = CGPointMake(0.0f, 0.05f);
    
    self.maskView.layer.mask = gradient;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.tableView addSubview:self.refreshControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [[AnalyticsManager sharedInstance] trackView:kFriendDetailsScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)entityName {
    if(self.compareControl.selectedSegmentIndex == 0) {
        return @"FriendAnime";
    }
    else {
        return @"FriendManga";
    }
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortDescriptor;
    NSSortDescriptor *primaryDescriptor;
    
    if(self.compareControl.selectedSegmentIndex == 0) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"anime.title" ascending:YES];
        primaryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"watched_status" ascending:YES];
    }
    else {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"manga.title" ascending:YES];
        primaryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"read_status" ascending:YES];
    }

    return @[primaryDescriptor, sortDescriptor];
}

- (NSPredicate *)predicate {
    if(self.compareControl.selectedSegmentIndex == 0) {
        return [NSPredicate predicateWithFormat:@"watched_status < 7 && user == %@", self.friend];
    }
    else {
        return [NSPredicate predicateWithFormat:@"read_status < 7 && user == %@", self.friend];
    }
}

- (NSString *)sectionKeyPathName {
    return @"column";
}

- (void)fetchData {
    self.tableView.tableFooterView = nil;
    self.compareControl.selectedSegmentIndex == 0 ? [self fetchAnime] : [self fetchManga];
}

- (void)fetchAnime {
    [[MALHTTPClient sharedClient] getAnimeListForUser:self.friend.username initialFetch:YES success:^(NSURLRequest *operation, id response) {
        ALLog(@"Got %@'s animelist!", self.friend.username);
        [AnimeService addAnimeList:(NSDictionary *)response forFriend:self.friend];
        
        if(self.compareControl.selectedSegmentIndex == 0)
            [self dissolveIndicator];
    } failure:^(NSURLRequest *operation, NSError *error) {
        ALLog(@"Couldn't fetch %@'s animelist!", self.friend.username);
        if(self.compareControl.selectedSegmentIndex == 0) {
            [self dissolveIndicator];
            self.tableView.tableFooterView = [UIView tableFooterWithError];
        }
    }];
}

- (void)fetchManga {
    [[MALHTTPClient sharedClient] getMangaListForUser:self.friend.username initialFetch:YES success:^(NSURLRequest *operation, id response) {
        ALLog(@"Got %@'s mangalist!", self.friend.username);
        [MangaService addMangaList:(NSDictionary *)response forFriend:self.friend];
        if(self.compareControl.selectedSegmentIndex == 1)
            [self dissolveIndicator];
    } failure:^(NSURLRequest *operation, NSError *error) {
        ALLog(@"Couldn't fetch %@'s mangalist!", self.friend.username);
        if(self.compareControl.selectedSegmentIndex == 1) {
            [self dissolveIndicator];
            self.tableView.tableFooterView = [UIView tableFooterWithError];
        }
    }];
}

#pragma mark - IBAction methods

- (void)reloadTable {
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tableView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
                         [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                         self.fetchedResultsController = nil;
                         NSError *error = nil;
                         if (![[self fetchedResultsController] performFetch:&error]) {}
                         
                         if(self.fetchedResultsController.fetchedObjects.count == 0) {
                             [self displayIndicator];
                             [self fetchData];
                         }
                         
                         [self resetHeaderDefaults];
                         
                         [self.tableView reloadData];
                         
                         [self updateHeaders];
                         
                         [UIView animateWithDuration:0.15f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.tableView.alpha = 1.0f;
                                          }
                                          completion:nil];
                     }];
}

- (void)displayIndicator {
    [self.refreshControl beginRefreshing];
    
    [UIView animateWithDuration:0.15f
                     animations:^{
                         self.indicator.alpha = 1.0f;
                     }];
}

- (void)dissolveIndicator {
    [self.refreshControl endRefreshing];
    
    [UIView animateWithDuration:0.15f
                     animations:^{
                         self.indicator.alpha = 0.0f;
                     }];
}

- (IBAction)compareControlPressed:(id)sender {
    if(self.compareControl.selectedSegmentIndex == 0) {
        self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
        [self reloadTable];
    }
    else {
        self.sectionHeaders = @[@"Reading", @"Completed", @"On Hold", @"Dropped", @"Plan To Read"];
        [self reloadTable];
    }
}

- (IBAction)compareButtonPressed:(id)sender {
    [[AnalyticsManager sharedInstance] trackEvent:kFriendComparePressed forCategory:EventCategoryAction withMetadata:self.friend.username];
    CompareViewController *vc = [[CompareViewController alloc] init];
    vc.friend = self.friend;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSManagedObject *)objectForIndexPath:(NSIndexPath *)indexPath {
    for(id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultsController sections]) {
        if([sectionInfo.name isEqualToString:[NSString stringWithFormat:@"%d", indexPath.section]]) {
            return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:[[self.fetchedResultsController sections] indexOfObject:sectionInfo]]];
        }
    }
    
    return nil;
}

- (BOOL)indexPathShouldUpdateTable:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return self.displayWatching;
        case 1:
            return self.displayCompleted;
        case 2:
            return self.displayOnHold;
        case 3:
            return self.displayDropped;
        case 4:
            return self.displayPlanToWatch;
        default:
            return NO;
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.sectionHeaderViews[section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AnimeCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    for(id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultsController sections]) {
        ALVLog(@"Section to look for: %d", section);
        if((section == 0 && !self.displayWatching)     ||
           (section == 1 && !self.displayCompleted)    ||
           (section == 2 && !self.displayOnHold)       ||
           (section == 3 && !self.displayDropped)      ||
           (section == 4 && !self.displayPlanToWatch)) {
            ALVLog(@"Section %d is hidden.", section);
            return 0;
        }
        if([sectionInfo.name isEqualToString:[NSString stringWithFormat:@"%d", section]]) {
            ALVLog(@"Found section %d with %d objects", section, [sectionInfo numberOfObjects]);
            return [sectionInfo numberOfObjects];
        }
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.fetchedResultsController sections].count > 0)
        return [self.sectionHeaders count];
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *animeCellIdentifier = @"AnimeCellIdentifier";
    static NSString *mangaCellIdentifier = @"MangaCellIdentifier";
    
    UITableViewCell *cell;
    
    if(self.compareControl.selectedSegmentIndex == 0) {
        cell = (AnimeCell *)[tableView dequeueReusableCellWithIdentifier:animeCellIdentifier];
        if(!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
            cell = (AnimeCell *)nib[0];
        }
    }
    else {
        cell = (MangaCell *)[tableView dequeueReusableCellWithIdentifier:mangaCellIdentifier];
        if(!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MangaCell" owner:self options:nil];
            cell = (MangaCell *)nib[0];
        }
    }
    
    NSManagedObject *object = [self objectForIndexPath:indexPath];
    [self configureCell:cell withObject:object];
    
    return cell;
}

#pragma mark - Table view delegate

static int map[5] = {-1, -1, -1, -1, -1};
static BOOL initialUpdate = NO;

- (void)updateMapping {
    
    for(int i = 0; i < 5; i++) {
        map[i] = -1;
    }
    
    for(int i = 0; i < self.fetchedResultsController.sections.count; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][i];
        map[i] = [sectionInfo.name intValue];
    }
    
    ALVLog(@"map: (%d, %d, %d, %d, %d)", map[0], map[1], map[2], map[3], map[4]);
}

- (void)updateHeaders {
    
    BOOL onAnimeList = self.compareControl.selectedSegmentIndex == 0;
    
    for(int i = 0; i < self.sectionHeaderViews.count; i++) {
        AniListTableHeaderView *view = self.sectionHeaderViews[i];
        
        int sectionValue = 0;
        
        switch (i) {
            case 0:
                if(onAnimeList)
                    sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusWatching forFriend:self.friend];
                else
                    sectionValue = [FriendMangaService numberOfMangaForReadStatus:MangaReadStatusReading forFriend:self.friend];
                break;
            case 1:
                if(onAnimeList)
                    sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusCompleted forFriend:self.friend];
                else
                    sectionValue = [FriendMangaService numberOfMangaForReadStatus:MangaReadStatusCompleted forFriend:self.friend];
                break;
            case 2:
                if(onAnimeList)
                    sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusOnHold forFriend:self.friend];
                else
                    sectionValue = [FriendMangaService numberOfMangaForReadStatus:MangaReadStatusOnHold forFriend:self.friend];
                break;
            case 3:
                if(onAnimeList)
                    sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusDropped forFriend:self.friend];
                else
                    sectionValue = [FriendMangaService numberOfMangaForReadStatus:MangaReadStatusDropped forFriend:self.friend];
                break;
            case 4:
                if(onAnimeList)
                    sectionValue = [FriendAnimeService numberOfAnimeForWatchedStatus:AnimeWatchedStatusPlanToWatch forFriend:self.friend];
                else
                    sectionValue = [FriendMangaService numberOfMangaForReadStatus:MangaReadStatusPlanToRead forFriend:self.friend];
                break;
            default:
                break;
        }
        
        view.primaryText = self.sectionHeaders[i];
        view.secondaryText = [NSString stringWithFormat:@"%d", sectionValue];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    fetchRequest.sortDescriptors = [self sortDescriptors];
    fetchRequest.predicate = [self predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:[self sectionKeyPathName] cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    ALLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
        abort();
#endif
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            if([self indexPathShouldUpdateTable:newIndexPath])
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self.tableView headerViewForSection:newIndexPath.section] setNeedsDisplay];
            break;
            
        case NSFetchedResultsChangeDelete:
            if([self indexPathShouldUpdateTable:indexPath])
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self.tableView headerViewForSection:indexPath.section] setNeedsDisplay];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if([self indexPathShouldUpdateTable:indexPath])
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withObject:anObject];
            break;
            
        case NSFetchedResultsChangeMove:
            if([self indexPathShouldUpdateTable:indexPath])
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if([self indexPathShouldUpdateTable:newIndexPath])
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [[self.tableView headerViewForSection:indexPath.section] setNeedsDisplay];
            [[self.tableView headerViewForSection:newIndexPath.section] setNeedsDisplay];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self objectForIndexPath:indexPath];
    
    if([object isMemberOfClass:[FriendAnime class]]) {
        FriendAnime *friendAnime = (FriendAnime *)object;
        Anime *anime = friendAnime.anime;
        AnimeViewController *vc = [[AnimeViewController alloc] init];
        vc.anime = anime;
        self.navigationItem.backBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"Back"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([object isMemberOfClass:[FriendManga class]]) {
        FriendManga *friendManga = (FriendManga *)object;
        Manga *manga = friendManga.manga;
        MangaViewController *vc = [[MangaViewController alloc] init];
        vc.manga = manga;
        self.navigationItem.backBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"Back"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![self.tableView isEditing];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    AniListCell *anilistCell = (AniListCell *)cell;
    
    if([object isKindOfClass:[FriendAnime class]]) {
        FriendAnime *friendAnime = (FriendAnime *)object;
        Anime *anime = friendAnime.anime;
        AnimeCell *animeCell = (AnimeCell *)cell;
        animeCell.title.text = anime.title;
        animeCell.progress.text = [AnimeCell progressTextForFriendAnime:friendAnime];
        animeCell.rank.text = [friendAnime.score intValue] != -1 ? [NSString stringWithFormat:@"%d", [friendAnime.score intValue]] : @"";
        animeCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
        [animeCell setImageWithItem:anime];
    }
    else if([object isKindOfClass:[FriendManga class]]) {
        FriendManga *friendManga = (FriendManga *)object;
        Manga *manga = friendManga.manga;
        MangaCell *mangaCell = (MangaCell *)cell;
        mangaCell.title.text = manga.title;
        mangaCell.progress.text = [MangaCell progressTextForFriendManga:friendManga];
        mangaCell.rank.text = [friendManga.score intValue] != -1 ? [NSString stringWithFormat:@"%d", [friendManga.score intValue]] : @"";
        mangaCell.type.text = [Manga stringForMangaType:[manga.type intValue]];
        [mangaCell setImageWithItem:manga];
    }
    
    [anilistCell.title sizeToFit];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    AniListNavigationController *navigationController = (AniListNavigationController *)self.navigationController;
    
    // Since we know this background will fit the screen height, we can use this value.
    float height = [UIScreen mainScreen].bounds.size.height;
    
    if(scrollView.contentSize.height > 400) {
        if(scrollView.contentOffset.y == 0) {
            [UIView animateWithDuration:0.75f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, 0, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
                             }
                             completion:nil];
        }
        else if(scrollView.contentOffset.y <= 0) {
            navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, 0, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
        }
        else {
            float yOrigin = -((navigationController.imageView.frame.size.height - height) * (scrollView.contentOffset.y / scrollView.contentSize.height));
            navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, yOrigin, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
        }
    }
}

#pragma mark - TapGestureRecognizerDelegate Methods

- (void)expand:(UITapGestureRecognizer *)recognizer {
    ALLog(@"EXPAND!");
    
    NSInteger section = recognizer.view.tag;

    switch (section) {
        case 0:
            self.displayWatching = !self.displayWatching;
            break;
        case 1:
            self.displayCompleted = !self.displayCompleted;
            break;
        case 2:
            self.displayOnHold = !self.displayOnHold;
            break;
        case 3:
            self.displayDropped = !self.displayDropped;
            break;
        case 4:
            self.displayPlanToWatch = !self.displayPlanToWatch;
            break;
        default:
            break;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
