//
//  AniListViewController.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListViewController.h"
#import "AniListAppDelegate.h"
#import "CRTransitionLabel.h"
#import "AniListCell.h"

@interface AniListViewController ()
@property (nonatomic, weak) IBOutlet CRTransitionLabel *topSectionLabel;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation AniListViewController

- (id)init {
    return [self initWithNibName:@"AniListViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.managedObjectContext = [(AniListAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        self.sectionHeaderViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
    [NSFetchedResultsController deleteCacheWithName:[self entityName]];
    self.fetchedResultsController = nil;
    
    ALLog(@"AniList deallocating.");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.tableView addSubview:self.refreshControl];
    
    SWRevealViewController *revealController = self.revealViewController;
    
    AniListNavigationController *nvc = ((AniListNavigationController *)self.revealViewController.frontViewController);
    
    self.topSectionLabel.backgroundColor = [UIColor clearColor];
    self.topSectionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    self.topSectionLabel.textColor = [UIColor lightGrayColor];
    self.topSectionLabel.textAlignment = NSTextAlignmentCenter;
    
    // This value is implicitly set to YES in iOS 7.0.
//    nvc.navigationBar.tra .nslucent = YES; // Setting this slides the view up, underneath the nav bar (otherwise it'll appear black)

    if([[UIDevice currentDevice].systemVersion compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
//        nvc.navigationBar.barTintColor = [UIColor blueColor];
        nvc.navigationBar.tintColor = [UIColor whiteColor];
    }
    else {
        const float colorMask[6] = {222, 255, 222, 255, 222, 255};
        UIImage *img = [[UIImage alloc] init];
        UIImage *maskedImage = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];
        
        [nvc.navigationBar setShadowImage:[[UIImage alloc] init]];
        [nvc.navigationBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault];
    }
    
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];

    self.view.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.075f);
    gradient.endPoint = CGPointMake(0.0f, 0.10f);
    
    self.maskView.layer.mask = gradient;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.topSectionLabel.text = @"";
    self.topSectionLabel.alpha = 0.0f;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [longPressGestureRecognizer setMinimumPressDuration:0.4f];
    [self.tableView addGestureRecognizer:longPressGestureRecognizer];
    
    self.maskView.frame = CGRectMake(self.maskView.frame.origin.x, self.maskView.frame.origin.y + 2, self.maskView.frame.size.width, self.maskView.frame.size.height - 2);
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + 46, self.tableView.frame.size.width, self.tableView.frame.size.height - 46);
    
    self.indicator.alpha = 0.0f;
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
        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCancel:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [swipedCell addGestureRecognizer:tapGestureRecognizer];
        
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
}

#pragma mark - Override Methods

// Must call super after fetching is done!
- (void)fetchData {
    [self.refreshControl endRefreshing];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.alpha = 1.0f;
        self.indicator.alpha = 0.0f;
    }];
}

// Must override.
- (NSString *)entityName {
    return @"";
}

- (NSArray *)sortDescriptors {
    return nil;
}

- (NSPredicate *)predicate {
    return nil;
}

- (NSString *)sectionKeyPathName {
    return @"column";
}

- (void)updateHeaderForSections:(NSArray *)sections {
//    for(int i = 0; i < sections.count; i++) {
//        NSIndexPath *indexPath = sections[i];
//        NSNumber *headerSection = [self.fetchedResultsController sectionIndexTitles][indexPath.section];
//        NSString *count = [NSString stringWithFormat:@"%d", [self.tableView numberOfRowsInSection:indexPath.section]];
//        UIView *headerView = [UIView tableHeaderWithPrimaryText:self.sectionHeaders[[headerSection intValue]] andSecondaryText:count];
//    }
//    return;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // OVERRIDE
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:[self sectionKeyPathName] cacheName:[self entityName]];
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

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    // MUST OVERRIDE
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    ALLog(@"content offset: %f", scrollView.contentOffset.y);
    
    if(scrollView.contentOffset.y > 36) {
        NSArray *visibleSections = [[[NSSet setWithArray:[[self.tableView indexPathsForVisibleRows] valueForKey:@"section"]] allObjects] sortedArrayUsingSelector:@selector(compare:)];
//        ALLog(@"indices: %@", [self.tableView indexPathsForVisibleRows]);
//        ALLog(@"visible sections: %@", visibleSections);
        
        if(visibleSections.count > 0 && [self.fetchedResultsController sectionIndexTitles].count) {
            int topSection = [visibleSections[0] intValue];
            
            NSNumber *headerSection = [self.fetchedResultsController sectionIndexTitles][topSection];
            
            self.topSectionLabel.text = self.sectionHeaders[[headerSection intValue]];
            
            [UIView animateWithDuration:0.2f animations:^{
                self.topSectionLabel.alpha = 1.0f;
            }];
        }
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.topSectionLabel.alpha = 0.0f;
        }];
    }
    
    AniListNavigationController *navigationController = (AniListNavigationController *)self.navigationController;
    
    // Since we know this background will fit the screen height, we can use this value.
    float height = [UIScreen mainScreen].bounds.size.height;
    
    if(scrollView.contentSize.height > 400) {
        if(scrollView.contentOffset.y <= 0) {
            navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, 0, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
        }
        else {
            float yOrigin = -((navigationController.imageView.frame.size.height - height) * (scrollView.contentOffset.y / scrollView.contentSize.height));
            navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, yOrigin, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
        }
    }
}

@end
