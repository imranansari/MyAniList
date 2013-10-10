//
//  MangaListViewController.m
//  AniList
//
//  Created by Corey Roberts on 4/16/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaListViewController.h"
#import "MangaViewController.h"
#import "MangaService.h"
#import "MangaCell.h"
#import "Manga.h"
#import "MALHTTPClient.h"
#import "AniListAppDelegate.h"
#import "MangaUserInfoEditViewController.h"

static BOOL alreadyFetched = NO;

@interface MangaListViewController ()
@property (nonatomic, strong) Manga *editedManga;
@end

@implementation MangaListViewController

- (id)init {
    self = [super init];
    if(self) {
        self.title = @"Manga";
        self.sectionHeaders = @[@"Reading", @"Completed", @"On Hold",
                                @"Dropped", @"Plan To Read"];
        
        for(int i = 0; i < self.sectionHeaders.count; i++) {
            [self.sectionHeaderViews addObject:[[UIView alloc] init]];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:kUserLoggedIn object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteManga) name:kDeleteManga object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [NSFetchedResultsController deleteCacheWithName:[self entityName]];
    ALLog(@"MangaList deallocating.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!alreadyFetched)
        [self fetchData];
    
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)entityName {
    return @"Manga";
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *statusDescriptor = [[NSSortDescriptor alloc] initWithKey:@"read_status" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    return @[statusDescriptor, sortDescriptor];
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"read_status < 7"];
}

- (void)fetchData {
    if([UserProfile userIsLoggedIn]) {
        [[MALHTTPClient sharedClient] getMangaListForUser:[[UserProfile profile] username]
                                             initialFetch:!alreadyFetched
                                                  success:^(NSURLRequest *operation, id response) {
                                                      [MangaService addMangaList:(NSDictionary *)response];
                                                      alreadyFetched = YES;
                                                      [super fetchData];
                                                  }
                                                  failure:^(NSURLRequest *operation, NSError *error) {
                                                      // Derp.
                                                      
                                                      [super fetchData];
                                                  }];
    }
}


- (void)saveManga:(Manga *)manga {
    if(manga) {
        [[MALHTTPClient sharedClient] updateDetailsForMangaWithID:manga.manga_id success:^(id operation, id response) {
            ALLog(@"Updated '%@'.", manga.title);
        } failure:^(id operation, NSError *error) {
            ALLog(@"Failed to update '%@'.", manga.title);
        }];
    }
    
    self.tableView.editing = NO;
    self.editedIndexPath = nil;
    self.editedManga = nil;
}

- (void)deleteManga {
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:self.editedIndexPath];
    
    if(manga) {
        manga.read_status = @(MangaReadStatusNotReading);
    }
    
    self.tableView.editing = NO;
    self.editedIndexPath = nil;
    self.editedManga = nil;
}


#pragma mark - Gesture Management Methods

- (void)didSwipe:(UIGestureRecognizer *)gestureRecognizer {
    [super didSwipe:gestureRecognizer];
    
    if (([gestureRecognizer isMemberOfClass:[UISwipeGestureRecognizer class]] && gestureRecognizer.state == UIGestureRecognizerStateEnded) ||
        ([gestureRecognizer isMemberOfClass:[UILongPressGestureRecognizer class]] && gestureRecognizer.state == UIGestureRecognizerStateBegan)) {
        
        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        AniListCell *swipedCell = (AniListCell *)[self.tableView cellForRowAtIndexPath:swipedIndexPath];
        
        self.editedManga = [self.fetchedResultsController objectAtIndexPath:swipedIndexPath];
        
        [swipedCell showEditScreenForManga:self.editedManga];
    }
}

- (void)didCancel:(UIGestureRecognizer *)gestureRecognizer {
    [super didCancel:gestureRecognizer];
        
//        if(([self.editedAnime.current_episode intValue] > 0 && [self.editedAnime.watched_status intValue] != AnimeWatchedStatusWatching)  &&
//           ([self.editedAnime.current_episode intValue] > 0 && [self.editedAnime.watched_status intValue] != AnimeWatchedStatusCompleted)) {
//            [self promptForBeginning:self.editedManga];
//        }
//        else {
//            [self saveManga:self.editedManga];
//        }
    
    [self saveManga:self.editedManga];

}

#pragma mark - Action Sheet Methods

- (void)promptForBeginning:(Manga *)manga {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to mark '%@' as reading?", manga.title]
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", nil];
    actionSheet.tag = ActionSheetPromptBeginning;
    
    [actionSheet showInView:self.view];
}

- (void)promptForFinishing:(Manga *)manga {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to mark '%@' as completed?", manga.title]
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", nil];
    actionSheet.tag = ActionSheetPromptFinishing;
    
    [actionSheet showInView:self.view];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MangaCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"Cell";
    
    MangaCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MangaCell" owner:self options:nil];
        cell = (MangaCell *)nib[0];
    }
    
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withObject:manga];
    
    if(self.editedIndexPath && self.editedIndexPath.section == indexPath.section && self.editedIndexPath.row == indexPath.row) {
        [cell showEditScreenForManga:manga];
        
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
                if((([self.editedManga.current_chapter intValue] == [self.editedManga.total_chapters intValue]) ||
                    ([self.editedManga.current_volume intValue] == [self.editedManga.total_volumes intValue])) &&
                     [self.editedManga.read_status intValue] != MangaReadStatusCompleted &&
                    ([self.editedManga.total_chapters intValue] != 0 || [self.editedManga.total_volumes intValue] != 0) ) {
                    
                    [self promptForFinishing:self.editedManga];
                }
            }
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    AniListNavigationController *navigationController = (AniListNavigationController *)self.navigationController;
    
    MangaViewController *mvc = [[MangaViewController alloc] init];
    mvc.manga = manga;
    mvc.currentYBackgroundPosition = navigationController.imageView.frame.origin.y;
    
    [self.navigationController pushViewController:mvc animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![self.tableView isEditing];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    
    Manga *manga = (Manga *)object;
    MangaCell *mangaCell = (MangaCell *)cell;
    mangaCell.title.text = manga.title;
    [mangaCell.title sizeToFit];
    mangaCell.progress.text = [MangaCell progressTextForManga:manga withSpacing:NO];
    mangaCell.rank.text = [manga.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [manga.user_score intValue]] : @"";
    mangaCell.type.text = [Manga stringForMangaType:[manga.type intValue]];
    
    [mangaCell setImageWithItem:manga];
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
                self.editedManga.read_status = @(MangaReadStatusReading);
                if(!self.editedManga.user_date_start)
                    self.editedManga.user_date_start = [NSDate date];
                [self.editedManga.managedObjectContext save:nil];
                
                [self saveManga:self.editedManga];
            }
            break;
        case ActionSheetPromptFinishing:
            if(buttonIndex == 0) {
                self.editedManga.read_status = @(MangaReadStatusCompleted);
                self.editedManga.current_chapter = self.editedManga.total_chapters;
                self.editedManga.current_volume = self.editedManga.total_volumes;

                if(!self.editedManga.user_date_finish)
                    self.editedManga.user_date_finish = [NSDate date];
                MangaUserInfoEditViewController *vc = [[MangaUserInfoEditViewController alloc] init];
                vc.manga = self.editedManga;
                [self.navigationController pushViewController:vc animated:YES];
                self.tableView.editing = NO;
                self.editedIndexPath = nil;
                self.editedManga = nil;
            }
            break;
        case ActionSheetPromptDeletion:
            break;
        default:
            break;
    }
}

@end
