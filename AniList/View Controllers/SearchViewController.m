//
//  SearchViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "SearchViewController.h"
#import "AniListAppDelegate.h"
#import "AnimeViewController.h"
#import "AnimeCell.h"
#import "AnimeService.h"
#import "MangaViewController.h"
#import "MangaCell.h"
#import "MangaService.h"
#import "MALHTTPClient.h"

@interface SearchViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL fromMenu;
@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = delegate.managedObjectContext;
        self.fromMenu = YES;
        [self.managedObjectContext save:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Search";
    
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor clearColor];
    self.searchDisplayController.searchBar.tintColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    if(self.fromMenu) {
        [self.searchDisplayController.searchBar becomeFirstResponder];
        self.fromMenu = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchWithQuery:(NSString *)query {
    [[MALHTTPClient sharedClient] searchForAnimeWithQuery:query success:^(id operation, NSArray *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ALLog(@"Got anime results: %d", response.count);
            [AnimeService addAnimeListFromSearch:response];
        });
    } failure:^(id operation, NSError *error) {
        ALLog(@"Anime search failure.");
    }];

    [[MALHTTPClient sharedClient] searchForMangaWithQuery:query success:^(id operation, NSArray *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ALLog(@"Got manga results: %d", response.count);
            [MangaService addMangaListFromSearch:response];
        });
    } failure:^(id operation, NSError *error) {
        ALLog(@"Manga search failure.");
    }];
}

- (NSString *)currentEntity {
    return self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0 ? @"Anime" : @"Manga";
}

#pragma mark - Table view data sourceu

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AnimeCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    ALLog(@"Number of objects fetched: %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSNumber *headerSection = [self.fetchedResultsController sectionIndexTitles][section];
//    NSString *count = [NSString stringWithFormat:@"%d", [self.tableView numberOfRowsInSection:section]];
//    return [UIView tableHeaderWithPrimaryText:self.sectionHeaders[[headerSection intValue]] andSecondaryText:count];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AnimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
        cell = (AnimeCell *)nib[0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if([object isKindOfClass:[Anime class]]) {
        Anime *anime = (Anime *)object;
        AnimeViewController *avc = [[AnimeViewController alloc] init];
        avc.anime = anime;
        [self.navigationController pushViewController:avc animated:YES];
    }
    else {
        Manga *manga = (Manga *)object;
        MangaViewController *mvc = [[MangaViewController alloc] init];
        mvc.manga = manga;
        [self.navigationController pushViewController:mvc animated:YES];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Can't fetch anything if the search query is empty...
    if(self.searchDisplayController.searchBar.text == nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self currentEntity] inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains [cd] %@", self.searchDisplayController.searchBar.text];
    
    fetchRequest.predicate = predicate;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
    [self.searchDisplayController.searchResultsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.searchDisplayController.searchResultsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.searchDisplayController.searchResultsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.searchDisplayController.searchResultsTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.searchDisplayController.searchResultsTableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AniListCell *anilistCell = (AniListCell *)cell;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURLRequest *imageRequest;
    NSString *cachedImageLocation = @"";
    
#warning - all of this code is gross. Will need to add a core data parent entity here with common traits.
    
    if([object isKindOfClass:[Anime class]]) {
        Anime *anime = (Anime *)object;
        anilistCell.title.text = anime.title;
        anilistCell.progress.text = [Anime stringForAnimeWatchedStatus:[anime.watched_status intValue]];
        anilistCell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
        anilistCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
        imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
        cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, anime.image];
    }
    else if([object isKindOfClass:[Manga class]]) {
        Manga *manga = (Manga *)object;
        anilistCell.title.text = manga.title;
        anilistCell.progress.text = [Manga stringForMangaReadStatus:[manga.read_status intValue]];
        anilistCell.rank.text = [manga.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [manga.user_score intValue]] : @"";
        anilistCell.type.text = [Manga stringForMangaType:[manga.type intValue]];
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

#pragma mark - UISearchDisplayDelegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
//    if(searchString.length > 2) {
//        [self searchWithQuery:searchString];
//    }
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchWithQuery:searchBar.text];
}

#pragma mark -
#pragma mark Content Filtering

#warning - how big of a performance cost is this?
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope {
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
}


#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView; {
    // search is done so get rid of the search FRC and reclaim memory
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}

@end
