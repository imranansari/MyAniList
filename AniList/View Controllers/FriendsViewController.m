//
//  FriendsViewController.m
//  AniList
//
//  Created by Corey Roberts on 8/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "FriendsViewController.h"
#import "AniListTableView.h"
#import "Friend.h"
#import "MALHTTPClient.h"
#import "ProfileCell.h"
#import "FriendService.h"
#import "AniListAppDelegate.h"
#import "FriendDetailViewController.h"

@interface FriendsViewController ()
@property (nonatomic, copy) NSArray *sectionHeaders;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, assign) int currentPage;
@end


@implementation FriendsViewController

- (id)init {
    return [self initWithNibName:@"FriendsViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.managedObjectContext = [(AniListAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return self;
}

- (void)dealloc {
    ALLog(@"Friends deallocating.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Friends", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.alpha = 1.0f;
    self.tableView.sectionHeaderHeight = 0;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.015f);
    gradient.endPoint = CGPointMake(0.0f, 0.05f);
    
    self.maskView.layer.mask = gradient;

    
    if([UIApplication isiOS7]) {
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(0, -20);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)entityName {
    return @"Friend";
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ProfileCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:self options:nil];
        cell = (ProfileCell *)nib[0];
    }
    
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withObject:friend];
    
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
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
//    fetchRequest.predicate = [self predicate];
    
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
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
    vc.friend = friend;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![self.tableView isEditing];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    Friend *friend = (Friend *)object;
    ProfileCell *profileCell = (ProfileCell *)cell;
    
    profileCell.username.text = friend.username;
    profileCell.animeStats.text = @"";
    profileCell.mangaStats.text = @"";
    profileCell.lastSeen.text = @"";
    
    if([friend.anime_total_entries intValue] > 0)
        profileCell.animeStats.text = [NSString stringWithFormat:@"%d anime watched, %d listed", [friend.anime_completed intValue], [friend.anime_total_entries intValue]];
    
    
    if([friend.manga_total_entries intValue] > 0)
        profileCell.mangaStats.text = [NSString stringWithFormat:@"%d manga read, %d listed", [friend.manga_completed intValue], [friend.manga_total_entries intValue]];
    
    if(friend.last_seen.length > 0)
        profileCell.lastSeen.text = [NSString stringWithFormat:@"Last seen %@", friend.last_seen];
    
    [profileCell.avatar setImageWithURL:[NSURL URLWithString:friend.image_url]];
}

- (IBAction)addButtonPressed:(id)sender {
    [self.usernameField resignFirstResponder];
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(username.length > 0) {
        Friend *friend = [FriendService addFriend:username];
        [[MALHTTPClient sharedClient] getProfileForUser:friend.username success:^(id operation, id response) {
            ALLog(@"result: %@", response);
            NSDictionary *animeStats = response[kAnimeStats];
            NSDictionary *mangaStats = response[kMangaStats];
            NSDictionary *details = response[@"details"];
            NSString *avatarURL = response[@"avatar_url"];
            
            friend.anime_completed = animeStats[@"completed"];
            friend.anime_total_entries = animeStats[@"total_entries"];
            
            friend.manga_completed = mangaStats[@"completed"];
            friend.manga_total_entries = mangaStats[@"total_entries"];
            
            friend.image_url = avatarURL;
            
            friend.last_seen = [details[@"last_online"] lowercaseString];
            
        } failure:^(id operation, NSError *error) {
            ALLog(@"Failure :(");
        }];
        
        [self.tableView reloadData];
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.usernameField) {
        [self addButtonPressed:nil];
    }
    
    return YES;
}


@end
