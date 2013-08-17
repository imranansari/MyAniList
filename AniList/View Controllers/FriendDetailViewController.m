//
//  FriendDetailViewController.m
//  AniList
//
//  Created by Corey Roberts on 8/10/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "FriendDetailViewController.h"
#import "AnimeCell.h"
#import "AniListTableView.h"
#import "AniListAppDelegate.h"
#import "Anime.h"
#import "MALHTTPClient.h"
#import "AnimeService.h"
#import "FriendAnime.h"
#import "FriendAnimeService.h"
#import "AnimeViewController.h"
#import "MangaViewController.h"

@interface FriendDetailViewController ()
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, copy) NSArray *sectionHeaders;
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
 
    [self fetchData];
    
    self.title = [NSString stringWithFormat:@"%@'s List", self.friend.username];
    self.tableView.backgroundColor = [UIColor clearColor];
    
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
    return @"FriendAnime";
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"anime.title" ascending:YES];
    NSSortDescriptor *primaryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"watched_status" ascending:YES];
    return @[primaryDescriptor, sortDescriptor];
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"watched_status < 7"];
}

- (NSString *)sectionKeyPathName {
    return @"column";
}

- (void)fetchData {
    [[MALHTTPClient sharedClient] getAnimeListForUser:self.friend.username
                                         initialFetch:YES
                                              success:^(NSURLRequest *operation, id response) {
                                                  ALLog(@"Got dat list!");
                                                  [AnimeService addAnimeList:(NSDictionary *)response forFriend:self.friend];
                                              }
                                              failure:^(NSURLRequest *operation, NSError *error) {
                                                  ALLog(@"Couldn't fetch list!");
                                              }];
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
    
    static NSString *CellIdentifier = @"Cell";
    
    AnimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
        cell = (AnimeCell *)nib[0];
    }
    
    FriendAnime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withObject:anime];
    
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
    FriendAnime *friendAnime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Anime *anime = friendAnime.anime;
    
    AnimeViewController *vc = [[AnimeViewController alloc] init];
    vc.anime = anime;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![self.tableView isEditing];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    FriendAnime *friendAnime = (FriendAnime *)object;
    Anime *anime = friendAnime.anime;
    
    AnimeCell *animeCell = (AnimeCell *)cell;
    animeCell.title.text = anime.title;
    [animeCell.title addShadow];
    [animeCell.title sizeToFit];
    
    animeCell.progress.text = [AnimeCell progressTextForAnime:anime];
    [animeCell.progress addShadow];
    
    animeCell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d | %d", [anime.user_score intValue], [friendAnime.score intValue]] : @"";
    
    [animeCell.rank addShadow];
    
    animeCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
    [animeCell.type addShadow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
        UIImage *cachedImage = [anime imageForAnime];
        
        if(!cachedImage) {
            [animeCell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    animeCell.image.alpha = 0.0f;
                    animeCell.image.image = image;
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        animeCell.image.alpha = 1.0f;
                    }];
                });
                
                if(!anime.image) {
                    // Save the image onto disk if it doesn't exist or they aren't the same.
                    [anime saveImage:image fromRequest:request];
                }
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                // Log failure.
                ALLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                animeCell.image.image = cachedImage;
            });
        }
    });
}

@end
