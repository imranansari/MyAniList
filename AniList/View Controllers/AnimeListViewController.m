//
//  AnimeListViewController.m
//  AniList
//
//  Created by Corey Roberts on 4/16/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeListViewController.h"
#import "AnimeViewController.h"
#import "AnimeService.h"
#import "AnimeCell.h"
#import "Anime.h"
#import "MALHTTPClient.h"
#import "AniListAppDelegate.h"
#import "AnimeUserInfoEditViewController.h"

static BOOL alreadyFetched = NO;

@interface AnimeListViewController ()
@property (nonatomic, strong) Anime *editedAnime;
@end

@implementation AnimeListViewController

- (id)init {
    self = [super init];
    if(self) {
        self.title = @"Anime";
        self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:kUserLoggedIn object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAnime) name:kDeleteAnime object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [NSFetchedResultsController deleteCacheWithName:[self entityName]];
    ALLog(@"AnimeList deallocating.");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if(!alreadyFetched) {
        [self fetchData];
    }
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [longPressGestureRecognizer setMinimumPressDuration:0.20f];
    [self.tableView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)entityName {
    return @"Anime";
}

- (NSArray *)sortDescriptors {

    if(self.viewTop) {
        return @[[[NSSortDescriptor alloc] initWithKey:@"average_score" ascending:NO]];
    }
    else if(self.viewPopular) {
        return @[[[NSSortDescriptor alloc] initWithKey:@"popularity_rank" ascending:YES]];
    }
    else {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSSortDescriptor *primaryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"watched_status" ascending:YES];
        return @[primaryDescriptor, sortDescriptor];
    }
}

- (NSPredicate *)predicate {
    if(self.viewTop || self.viewPopular) {
        return nil;
    }
    
    return [NSPredicate predicateWithFormat:@"watched_status < 7"];
}

- (NSString *)sectionKeyPathName {
    if(self.viewTop || self.viewPopular) {
        return nil;
    }
    
    return [super sectionKeyPathName];
}

- (void)fetchData {
    if([UserProfile userIsLoggedIn]) {
        
        if(self.viewTop) {
            [[MALHTTPClient sharedClient] getTopAnimeForType:AnimeTypeTV atPage:@(1) success:^(id operation, id response) {
                ALLog(@"Anime list found: %@", response);
                for(NSDictionary *anime in response) {
                    [AnimeService addAnime:anime fromList:NO];
                }
            } failure:^(id operation, NSError *error) {
                ALLog(@"Could not fetch top.");
            }];
        }
        else if(self.viewPopular) {
            
        }
        else {
            [[MALHTTPClient sharedClient] getAnimeListForUser:[[UserProfile profile] username]
                                                 initialFetch:!alreadyFetched
                                                      success:^(NSURLRequest *operation, id response) {
                                                          [AnimeService addAnimeList:(NSDictionary *)response];
                                                          alreadyFetched = YES;
                                                          [super fetchData];
                                                      }
                                                      failure:^(NSURLRequest *operation, NSError *error) {
                                                          // Derp.
                                                          
                                                          [super fetchData];
                                                      }];
        }
    }
}

- (void)saveAnime:(Anime *)anime {
    if(anime) {
        [[MALHTTPClient sharedClient] updateDetailsForAnimeWithID:anime.anime_id success:^(id operation, id response) {
            ALLog(@"Updated '%@'.", anime.title);
        } failure:^(id operation, NSError *error) {
            ALLog(@"Failed to update '%@'.", anime.title);
        }];
    }
    
    self.tableView.editing = NO;
    self.editedIndexPath = nil;
    self.editedAnime = nil;
}

- (void)deleteAnime {
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:self.editedIndexPath];
    
    if(anime) {
        anime.watched_status = @(AnimeWatchedStatusNotWatching);
    }
    
    self.tableView.editing = NO;
    self.editedIndexPath = nil;
    self.editedAnime = nil;
}

#pragma mark - Gesture Management Methods

- (void)didSwipe:(UIGestureRecognizer *)gestureRecognizer {
    if (([gestureRecognizer isMemberOfClass:[UISwipeGestureRecognizer class]] && gestureRecognizer.state == UIGestureRecognizerStateEnded) ||
        ([gestureRecognizer isMemberOfClass:[UILongPressGestureRecognizer class]] && gestureRecognizer.state == UIGestureRecognizerStateBegan)) {
        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        AniListCell *swipedCell = (AniListCell *)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        
        if(self.editedIndexPath && (self.editedIndexPath.section != swipedIndexPath.section || self.editedIndexPath.row != swipedIndexPath.row)) {
            AniListCell *currentlySwipedCell = (AniListCell *)[self.tableView cellForRowAtIndexPath:self.editedIndexPath];
            if(currentlySwipedCell)
                [currentlySwipedCell revokeEditScreen];
        }
        
        self.editedAnime = [self.fetchedResultsController objectAtIndexPath:swipedIndexPath];
        
        [swipedCell showEditScreenForAnime:self.editedAnime];
        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCancel:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [swipedCell addGestureRecognizer:tapGestureRecognizer];
        
        self.tableView.editing = YES;
        self.editedIndexPath = swipedIndexPath;
    }
}

- (void)didCancel:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tapLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    AniListCell *cell = (AniListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell revokeEditScreen];
    
    AniListCell *editedCell = (AniListCell *)[self.tableView cellForRowAtIndexPath:self.editedIndexPath];
    
    if(editedCell != cell)
        [editedCell revokeEditScreen];
    
    if(([self.editedAnime.current_episode intValue] > 0 && [self.editedAnime.watched_status intValue] != AnimeWatchedStatusWatching)  &&
       ([self.editedAnime.current_episode intValue] > 0 && [self.editedAnime.watched_status intValue] != AnimeWatchedStatusCompleted)) {
        [self promptForBeginning:self.editedAnime];
    }
    else {
        [self saveAnime:self.editedAnime];
    }
}

#pragma mark - Action Sheet Methods

- (void)promptForBeginning:(Anime *)anime {
    if(anime) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want mark '%@' as watching?", anime.title]
                                                                 delegate:self
                                                        cancelButtonTitle:@"No"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Yes", nil];
        actionSheet.tag = ActionSheetPromptBeginning;
        
        [actionSheet showInView:self.view];
    }
}

- (void)promptForFinishing:(Anime *)anime {
    if(anime) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want mark '%@' as completed?", anime.title]
                                                                 delegate:self
                                                        cancelButtonTitle:@"No"
                                                   destructiveButtonTitle:@"Yes"
                                                        otherButtonTitles:nil, nil];
        actionSheet.tag = ActionSheetPromptFinishing;
        
        [actionSheet showInView:self.view];
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AnimeCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    AnimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
        cell = (AnimeCell *)nib[0];
    }
    
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withObject:anime];
    
    if(self.editedIndexPath && self.editedIndexPath.section == indexPath.section && self.editedIndexPath.row == indexPath.row) {
        [cell showEditScreenForAnime:anime];
        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCancel:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [cell addGestureRecognizer:tapGestureRecognizer];
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            break;
            
        case NSFetchedResultsChangeDelete:
            break;
            
        case NSFetchedResultsChangeUpdate:
            if(self.tableView.editing) {
                if([self.editedAnime.current_episode intValue] == [self.editedAnime.total_episodes intValue] &&
                   [self.editedAnime.watched_status intValue] != AnimeWatchedStatusCompleted) {
                    [self promptForFinishing:self.editedAnime];
                }
            }
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    AniListNavigationController *navigationController = (AniListNavigationController *)self.navigationController;
    
    AnimeViewController *animeVC = [[AnimeViewController alloc] init];
    animeVC.anime = anime;
    animeVC.currentYBackgroundPosition = navigationController.imageView.frame.origin.y;
    
    [self.navigationController pushViewController:animeVC animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![self.tableView isEditing];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    Anime *anime = (Anime *)object;
    AnimeCell *animeCell = (AnimeCell *)cell;
    animeCell.title.text = anime.title;
    [animeCell.title addShadow];
    [animeCell.title sizeToFit];
    
    animeCell.progress.text = [AnimeCell progressTextForAnime:anime];
    [animeCell.progress addShadow];
    
    if(self.viewTop) {
        animeCell.rank.text = [NSString stringWithFormat:@"#%d (%0.02f)", [self.tableView indexPathForCell:cell].row+1, [anime.average_score doubleValue]];
    }
    else {
        animeCell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
    }
    
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

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    [self didCancel:nil];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case ActionSheetPromptBeginning:
            if(buttonIndex == 0) {
                self.editedAnime.watched_status = @(AnimeWatchedStatusWatching);
                if(!self.editedAnime.user_date_start)
                    self.editedAnime.user_date_start = [NSDate date];
                [self.editedAnime.managedObjectContext save:nil];
                
                [self saveAnime:self.editedAnime];
            }
            break;
        case ActionSheetPromptFinishing:
            if(buttonIndex == 0) {
                self.editedAnime.watched_status = @(AnimeWatchedStatusCompleted);
                if(!self.editedAnime.user_date_finish)
                    self.editedAnime.user_date_finish = [NSDate date];
                AnimeUserInfoEditViewController *vc = [[AnimeUserInfoEditViewController alloc] init];
                vc.anime = self.editedAnime;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case ActionSheetPromptDeletion:
            if(buttonIndex == actionSheet.destructiveButtonIndex) {
                // Delete
            }
            break;
        default:
            break;
    }
}

@end
