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

@interface FriendDetailViewController ()
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet UIImageView *avatar;

@property (nonatomic, weak) IBOutlet UIButton *animeButton;
@property (nonatomic, weak) IBOutlet UIButton *mangaButton;
@property (nonatomic, weak) IBOutlet UIButton *compareButton;

@property (nonatomic, copy) NSArray *sectionHeaders;

- (IBAction)animeButtonPressed:(id)sender;
- (IBAction)mangaButtonPressed:(id)sender;
- (IBAction)compareButtonPressed:(id)sender;

@end

@implementation FriendDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.managedObjectContext = [(AniListAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
    }
    return self;
}

- (void)viewDidLoad
{
    self.hidesBackButton = NO;
    [super viewDidLoad];
    self.animeButton.selected = YES;
    [self fetchData];
    
    self.title = [NSString stringWithFormat:@"%@'s List", self.friend.username];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.avatar setImageWithURL:[NSURL URLWithString:self.friend.image_url]];
    
    if(![UIApplication isiOS7]) {
        [self.animeButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        [self.mangaButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        [self.compareButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    }
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.015f);
    gradient.endPoint = CGPointMake(0.0f, 0.05f);
    
    self.maskView.layer.mask = gradient;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)entityName {
    if(self.animeButton.selected) {
        return @"FriendAnime";
    }
    else {
        return @"FriendManga";
    }
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortDescriptor;
    NSSortDescriptor *primaryDescriptor;
    
    if(self.animeButton.selected) {
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
#warning - may have to create FriendAnime entities for the current user in order to compare.
    // For comparing, just remove user predicate to get all anime.
    
    if(self.animeButton.selected) {
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
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[MALHTTPClient sharedClient] getAnimeListForUser:self.friend.username initialFetch:YES success:^(NSURLRequest *operation, id response) {
            ALLog(@"Got dat list!");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [AnimeService addAnimeList:(NSDictionary *)response forFriend:self.friend];
            });
        } failure:^(NSURLRequest *operation, NSError *error) {
            ALLog(@"Couldn't fetch list!");
        }];
        
        [[MALHTTPClient sharedClient] getMangaListForUser:self.friend.username initialFetch:YES success:^(NSURLRequest *operation, id response) {
            ALLog(@"Got dat list!");
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [MangaService addMangaList:(NSDictionary *)response forFriend:self.friend];
//            });
        } failure:^(NSURLRequest *operation, NSError *error) {
            ALLog(@"Couldn't fetch list!");
        }];
    });
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
                         
                         [self.tableView reloadData];
                         
                         [UIView animateWithDuration:0.15f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.tableView.alpha = 1.0f;
                                          }
                                          completion:nil];
                     }];
}

- (IBAction)animeButtonPressed:(id)sender {
    if(self.animeButton.selected)
        return;
    
    self.animeButton.selected = YES;
    self.mangaButton.selected = NO;
    
    self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
    
    [self reloadTable];
}

- (IBAction)mangaButtonPressed:(id)sender {
    if(self.mangaButton.selected)
        return;
    
    self.animeButton.selected = NO;
    self.mangaButton.selected = YES;
    
    self.sectionHeaders = @[@"Reading", @"Completed", @"On Hold", @"Dropped", @"Plan To Read"];
    
    [self reloadTable];
}

- (IBAction)compareButtonPressed:(id)sender {
    self.compareButton.selected = !self.compareButton.selected;
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSNumber *headerSection = [self.fetchedResultsController sectionIndexTitles][section];
    NSString *count = [NSString stringWithFormat:@"%d", [self.tableView numberOfRowsInSection:section]];
    UIView *headerView = [UIView tableHeaderWithPrimaryText:self.sectionHeaders[[headerSection intValue]] andSecondaryText:count];
    
    return headerView;
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *animeCellIdentifier = @"AnimeCellIdentifier";
    static NSString *mangaCellIdentifier = @"MangaCellIdentifier";
    
    UITableViewCell *cell;
    
    if(self.animeButton.selected) {
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
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withObject:object];
    
    return cell;
}

#pragma mark - Table view delegate

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
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self.tableView headerViewForSection:newIndexPath.section] setNeedsDisplay];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self.tableView headerViewForSection:indexPath.section] setNeedsDisplay];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withObject:anObject];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURLRequest *imageRequest;
    NSString *cachedImageLocation = @"";
    
    if([object isKindOfClass:[FriendAnime class]]) {
        FriendAnime *friendAnime = (FriendAnime *)object;
        Anime *anime = friendAnime.anime;
        AnimeCell *animeCell = (AnimeCell *)cell;
        animeCell.title.text = anime.title;
        animeCell.progress.text = [AnimeCell progressTextForFriendAnime:friendAnime];
        animeCell.rank.text = [friendAnime.score intValue] != -1 ? [NSString stringWithFormat:@"%d", [friendAnime.score intValue]] : @"";
        animeCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
        imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
        cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, anime.image];
    }
    else if([object isKindOfClass:[FriendManga class]]) {
        FriendManga *friendManga = (FriendManga *)object;
        Manga *manga = friendManga.manga;
        MangaCell *mangaCell = (MangaCell *)cell;
        mangaCell.title.text = manga.title;
        mangaCell.progress.text = [Manga stringForMangaReadStatus:[friendManga.read_status intValue]];
        mangaCell.rank.text = [friendManga.score intValue] != -1 ? [NSString stringWithFormat:@"%d", [friendManga.score intValue]] : @"";
        mangaCell.type.text = [Manga stringForMangaType:[manga.type intValue]];
        imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:manga.image_url]];
        cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, manga.image];
    }
    
    [anilistCell.title sizeToFit];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImageLocation];
        
        if(!cachedImage) {
            [anilistCell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    anilistCell.image.alpha = 0.0f;
                    anilistCell.image.image = image;
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        anilistCell.image.alpha = 1.0f;
                    }];
                });
                
                // Save the image onto disk if it doesn't exist or they aren't the same.
                if([object isKindOfClass:[Anime class]]) {
                    Anime *anime = (Anime *)object;
                    [anime saveImage:image fromRequest:imageRequest];
                }
                else if([object isKindOfClass:[Manga class]]) {
                    Manga *manga = (Manga *)object;
                    [manga saveImage:image fromRequest:imageRequest];
                }
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                // Log failure.
                ALLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                anilistCell.image.image = cachedImage;
            });
        }
    });
}

@end