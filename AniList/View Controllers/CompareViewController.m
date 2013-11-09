//
//  CompareViewController.m
//  AniList
//
//  Created by Corey Roberts on 10/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "CompareViewController.h"
#import "AniListTableView.h"
#import "CompareCell.h"

#import "AnimeService.h"
#import "FriendAnimeService.h"
#import "FriendAnime.h"

#import "MangaService.h"
#import "FriendMangaService.h"
#import "FriendManga.h"

#import "MALHTTPClient.h"

#import "AnimeViewController.h"
#import "MangaViewController.h"

@interface CompareViewController ()

@property (nonatomic, copy) NSArray *mutualMangaItems;
@property (nonatomic, copy) NSArray *friendExclusiveMangaItems;
@property (nonatomic, copy) NSArray *userExclusiveMangaItems;
@property (nonatomic, assign) double userAverageMangaRating;
@property (nonatomic, assign) double friendAverageMangaRating;

@property (nonatomic, copy) NSArray *mutualAnimeItems;
@property (nonatomic, copy) NSArray *friendExclusiveAnimeItems;
@property (nonatomic, copy) NSArray *userExclusiveAnimeItems;
@property (nonatomic, assign) double userAverageAnimeRating;
@property (nonatomic, assign) double friendAverageAnimeRating;

@property (nonatomic, strong) IBOutlet UIView *compareView;
@property (nonatomic, strong) IBOutlet UILabel *friendNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *friendMiniNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *userMiniNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *friendAverageLabel;
@property (nonatomic, strong) IBOutlet UILabel *userAverageLabel;
@property (nonatomic, strong) IBOutlet UILabel *compatibilityLabel;

@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UIImageView *myAvatar;
@property (nonatomic, weak) IBOutlet UIImageView *friendAvatar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *compareControl;

@property (nonatomic, assign) BOOL isAnimeSection;

@end

@implementation CompareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBackButton = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.015f);
    gradient.endPoint = CGPointMake(0.0f, 0.05f);
   
    self.friendMiniNameLabel.text = self.friend.username;
    self.userMiniNameLabel.text = [UserProfile profile].username;
    
    self.friendMiniNameLabel.alpha = 0.6f;
    self.userMiniNameLabel.alpha = 0.6f;
    
    self.friendNameLabel.text = [NSString stringWithFormat:@"%@'s", self.friend.username];
    self.userNameLabel.text = [NSString stringWithFormat:@"%@'s", [UserProfile profile].username];
    
    self.maskView.layer.mask = gradient;
    [self.friendAvatar setImageWithURL:[NSURL URLWithString:self.friend.image_url] placeholderImage:[UIImage placeholderImage]];
    [self.myAvatar setImageWithURL:[[UserProfile profile] profileImageURL].URL placeholderImage:[UIImage placeholderImage]];
    
    self.indicator.alpha = 1.0f;
    self.tableView.alpha = 0.0f;
    
    self.isAnimeSection = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self createAnimeComparison];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTable];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if(indexPath)
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[AnalyticsManager sharedInstance] trackView:kCompareDetailsScreen];
}

#pragma mark - Data Methods

- (void)createAnimeComparison {
    
    // If we've already created the arrays, no need to do it again.
    if(self.userExclusiveAnimeItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.friendAverageLabel.text = [NSString stringWithFormat:@"%0.02f", self.friendAverageAnimeRating];
            self.userAverageLabel.text = [NSString stringWithFormat:@"%0.02f", self.userAverageAnimeRating];
            [self setCompatibilityWithFriendScore:self.friendAverageAnimeRating andUserScore:self.userAverageAnimeRating];
        });
        return;
    }
    
    NSArray *friendItemsArray = [FriendAnimeService animeForFriend:self.friend];
    NSArray *myItemsArray = [AnimeService myAnime];
    
    ALLog(@"Number of anime for friend '%@': %d", self.friend.username, friendItemsArray.count);
    ALLog(@"Number of anime for user: %d", myItemsArray.count);
    
    double counter = 0;
    double totalScore = 0;
    
    // Calculate average ratings for friend.
    for(Anime *anime in friendItemsArray) {
        FriendAnime *friendAnime = [FriendAnimeService anime:anime forFriend:self.friend];
        if([friendAnime.score intValue] > 0) {
            counter++;
            totalScore += [friendAnime.score doubleValue];
        }
    }
    
    self.friendAverageAnimeRating = counter > 0 ? totalScore / counter : 0;
    ALLog(@"Average anime rating for friend: %0.02f", self.friendAverageAnimeRating);
    
    counter = 0;
    totalScore = 0;
    
    // Calculate average ratings for user.
    for(Anime *anime in myItemsArray) {
        if([anime.user_score intValue] > 0) {
            counter++;
            totalScore += [anime.user_score doubleValue];
        }
    }
    
    self.userAverageAnimeRating = counter > 0 ? totalScore / counter : 0;
    ALLog(@"Average anime rating for user: %0.02f", self.userAverageAnimeRating);
    
    NSMutableSet *userItems = [NSMutableSet setWithArray:myItemsArray];
    NSSet *friendItems = [NSSet setWithArray:friendItemsArray];
    
    // Items that both the user and friend share in common.
    [userItems intersectSet:friendItems];
    
    NSSet *intersectedSet = [userItems copy];
    NSMutableArray *intersectedItems = [[intersectedSet allObjects] mutableCopy];
    
    NSMutableArray *friendArray = [friendItemsArray mutableCopy];
    NSMutableArray *userArray = [myItemsArray mutableCopy];
    
    [friendArray removeObjectsInArray:userArray];
    
    NSMutableArray *mutualItems = [NSMutableArray array];
    NSMutableArray *exclusiveFriendItems = [friendArray mutableCopy];

    // Reset friend array to intersect against user items.
    friendArray = [friendItemsArray mutableCopy];
    
    [userArray removeObjectsInArray:friendArray];
    
    NSMutableArray *exclusiveUserItems = [userArray mutableCopy];
    
    for(Anime *anime in intersectedItems) {
        FriendAnime *friendAnime = [FriendAnimeService anime:anime forFriend:self.friend];
        
        // Both users have this anime and have watched some of it at one point.
        if([anime.watched_status intValue] != AnimeWatchedStatusPlanToWatch &&
           [friendAnime.watched_status intValue] != AnimeWatchedStatusPlanToWatch) {
            [mutualItems addObject:anime];
        }
    }
    
    // Remove anime that are listed as planned to watch in both exclusive arrays.
    NSMutableArray *animeToRemove = [NSMutableArray array];
    for(Anime *anime in exclusiveFriendItems) {
        FriendAnime *friendAnime = [FriendAnimeService anime:anime forFriend:self.friend];
        if([friendAnime.watched_status intValue] == AnimeWatchedStatusPlanToWatch)
            [animeToRemove addObject:anime];
    }
    
    [exclusiveFriendItems removeObjectsInArray:animeToRemove];
    
    [animeToRemove removeAllObjects];
    for(Anime *anime in exclusiveUserItems) {
        if([anime.watched_status intValue] == AnimeWatchedStatusPlanToWatch)
            [animeToRemove addObject:anime];
    }
    
    [exclusiveUserItems removeObjectsInArray:animeToRemove];
    
    // Sort all arrays.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [mutualItems sortUsingDescriptors:@[sortDescriptor]];
    [exclusiveUserItems sortUsingDescriptors:@[sortDescriptor]];
    [exclusiveFriendItems sortUsingDescriptors:@[sortDescriptor]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mutualAnimeItems = [mutualItems copy];
        self.userExclusiveAnimeItems = [exclusiveUserItems copy];
        self.friendExclusiveAnimeItems = [exclusiveFriendItems copy];
        
        self.friendAverageLabel.text = [NSString stringWithFormat:@"%0.02f", self.friendAverageAnimeRating];
        self.userAverageLabel.text = [NSString stringWithFormat:@"%0.02f", self.userAverageAnimeRating];
        [self setCompatibilityWithFriendScore:self.friendAverageAnimeRating andUserScore:self.userAverageAnimeRating];
    });
    
    ALLog(@"Anime count: %d", intersectedSet.count);
    ALLog(@"Mutual items: %d", self.mutualAnimeItems.count);
    ALLog(@"Friend-exclusive items: %d", self.friendExclusiveAnimeItems.count);
    ALLog(@"User-exclusive items: %d", self.userExclusiveAnimeItems.count);
}

- (void)createMangaComparison {
    
    // If we've already created the arrays, no need to do it again.
    if(self.userExclusiveMangaItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.friendAverageLabel.text = [NSString stringWithFormat:@"%0.02f", self.friendAverageMangaRating];
            self.userAverageLabel.text = [NSString stringWithFormat:@"%0.02f", self.userAverageMangaRating];
            [self setCompatibilityWithFriendScore:self.friendAverageMangaRating andUserScore:self.userAverageMangaRating];
            
        });
        return;
    }
    
    NSArray *friendItemsArray = [FriendMangaService mangaForFriend:self.friend];
    NSArray *myItemsArray = [MangaService myManga];
    
    ALLog(@"Number of manga for friend '%@': %d", self.friend.username, friendItemsArray.count);
    ALLog(@"Number of manga for user: %d", myItemsArray.count);
    
    double counter = 0;
    double totalScore = 0;
    
    // Calculate average ratings for friend.
    for(Manga *manga in friendItemsArray) {
        FriendManga *friendManga = [FriendMangaService manga:manga forFriend:self.friend];
        if([friendManga.score intValue] > 0) {
            counter++;
            totalScore += [friendManga.score doubleValue];
        }
    }
    
    self.friendAverageMangaRating = counter > 0 ? totalScore / counter : 0;
    ALLog(@"Average manga rating for friend: %0.02f", self.friendAverageMangaRating);
    
    counter = 0;
    totalScore = 0;
    
    // Calculate average ratings for user.
    for(Manga *manga in myItemsArray) {
        if([manga.user_score intValue] > 0) {
            counter++;
            totalScore += [manga.user_score doubleValue];
        }
    }
    
    self.userAverageMangaRating = counter > 0 ? totalScore / counter : 0;
    ALLog(@"Average manga rating for user: %0.02f", self.userAverageMangaRating);
    
    NSMutableSet *userItems = [NSMutableSet setWithArray:myItemsArray];
    NSSet *friendItems = [NSSet setWithArray:friendItemsArray];
    
    // Items that both the user and friend share in common.
    [userItems intersectSet:friendItems];
    
    NSSet *intersectedSet = [userItems copy];
    NSMutableArray *intersectedItems = [[intersectedSet allObjects] mutableCopy];
    
    NSMutableArray *friendArray = [friendItemsArray mutableCopy];
    NSMutableArray *userArray = [myItemsArray mutableCopy];
    
    [friendArray removeObjectsInArray:userArray];
    
    NSMutableArray *mutualItems = [NSMutableArray array];
    NSMutableArray *exclusiveFriendItems = [friendArray mutableCopy];
    
    // Reset friend array to intersect against user items.
    friendArray = [friendItemsArray mutableCopy];
    
    [userArray removeObjectsInArray:friendArray];
    
    NSMutableArray *exclusiveUserItems = [userArray mutableCopy];
    
    for(Manga *manga in intersectedItems) {
        FriendManga *friendManga = [FriendMangaService manga:manga forFriend:self.friend];
        
        // Both users read some of all of this manga at one point.
        if([manga.read_status intValue] != MangaReadStatusPlanToRead &&
           [friendManga.read_status intValue] != MangaReadStatusPlanToRead) {
            [mutualItems addObject:manga];
        }
    }
    
    // Remove manga that are listed as planned to read in both exclusive arrays.
    NSMutableArray *mangaToRemove = [NSMutableArray array];
    for(Manga *manga in exclusiveFriendItems) {
        FriendManga *friendManga = [FriendMangaService manga:manga forFriend:self.friend];
        if([friendManga.read_status intValue] == MangaReadStatusPlanToRead)
            [mangaToRemove addObject:manga];
    }
    
    [exclusiveFriendItems removeObjectsInArray:mangaToRemove];
    
    [mangaToRemove removeAllObjects];
    for(Manga *manga in exclusiveUserItems) {
        if([manga.read_status intValue] == MangaReadStatusPlanToRead)
            [mangaToRemove addObject:manga];
    }
    
    [exclusiveUserItems removeObjectsInArray:mangaToRemove];
    
    // Sort all arrays.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [mutualItems sortUsingDescriptors:@[sortDescriptor]];
    [exclusiveUserItems sortUsingDescriptors:@[sortDescriptor]];
    [exclusiveFriendItems sortUsingDescriptors:@[sortDescriptor]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mutualMangaItems = [mutualItems copy];
        self.userExclusiveMangaItems = [exclusiveUserItems copy];
        self.friendExclusiveMangaItems = [exclusiveFriendItems copy];
        
        self.friendAverageLabel.text = [NSString stringWithFormat:@"%0.02f", self.friendAverageMangaRating];
        self.userAverageLabel.text = [NSString stringWithFormat:@"%0.02f", self.userAverageMangaRating];
        [self setCompatibilityWithFriendScore:self.friendAverageMangaRating andUserScore:self.userAverageMangaRating];
    });
    
    ALLog(@"Manga count: %d", intersectedSet.count);
    ALLog(@"Mutual items: %d", self.mutualMangaItems.count);
    ALLog(@"Friend-exclusive items: %d", self.friendExclusiveMangaItems.count);
    ALLog(@"User-exclusive items: %d", self.userExclusiveMangaItems.count);
}

#pragma mark - IBAction Methods

- (IBAction)compareControlPressed:(id)sender {
    [self hideTable];
    double delayInSeconds = 0.15f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(self.compareControl.selectedSegmentIndex == 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self createAnimeComparison];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadTable];
                });
            });
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self createMangaComparison];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadTable];
                });
            });
        }
    });
}

#pragma mark - UI Methods

- (void)setCompatibilityWithFriendScore:(double)friendScore andUserScore:(double)userScore {
    self.compatibilityLabel.text = [NSString stringWithFormat:@"%0.02f", userScore - friendScore];
    
    if(userScore > friendScore) {
        self.compatibilityLabel.text = [NSString stringWithFormat:@"+%0.02f", userScore - friendScore];
        self.compatibilityLabel.textColor = [UIColor greenColor];
    }
    else if(friendScore > userScore) {
        self.compatibilityLabel.textColor = [UIColor redColor];
    }
    else {
        self.compatibilityLabel.textColor = [UIColor whiteColor];
    }
}

- (void)hideTable {
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tableView.alpha = 0.0f;
                         self.indicator.alpha = 1.0f;
                     }
                     completion:nil];
}

- (void)reloadTable {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    self.isAnimeSection = self.compareControl.selectedSegmentIndex == 0;
    
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tableView.alpha = 1.0f;
                         self.indicator.alpha = 0.0f;
                     }
                     completion:nil];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *title = @"";
    NSArray *data;
    
    switch (section) {
        case ComparisonSectionMutual:
            title = @"Shared";
            data = self.isAnimeSection ? self.mutualAnimeItems : self.mutualMangaItems;
            break;
        case ComparisonSectionFriend:
            title = [NSString stringWithFormat:@"Unique to %@", self.friend.username];
            data = self.isAnimeSection ? self.friendExclusiveAnimeItems : self.friendExclusiveMangaItems;
            break;
        case ComparisonSectionUser:
            title = [NSString stringWithFormat:@"Unique to %@", [UserProfile profile].username];
            data = self.isAnimeSection ? self.userExclusiveAnimeItems : self.userExclusiveMangaItems;
            break;
        default:
            return nil;
    }
    
    NSString *count = [NSString stringWithFormat:@"%d", data.count];
    
    UIView *headerView;
    
    if(section == ComparisonSectionMutual) {
        UIView *sectionHeader = [UIView tableHeaderWithPrimaryText:title andSecondaryText:count];
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.compareView.frame.size.width, self.compareView.frame.size.height + sectionHeader.frame.size.height)];
        [headerView addSubview:self.compareView];
        [headerView addSubview:sectionHeader];
        
        sectionHeader.frame = CGRectMake(sectionHeader.frame.origin.x - 10, sectionHeader.frame.origin.y + self.compareView.frame.size.height, sectionHeader.frame.size.width, sectionHeader.frame.size.height);
    }
    else {
        headerView = [UIView tableHeaderWithPrimaryText:title andSecondaryText:count];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == ComparisonSectionMutual) {
        return 44 + self.compareView.frame.size.height;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CompareCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case ComparisonSectionMutual:
            return self.isAnimeSection ? self.mutualAnimeItems.count : self.mutualMangaItems.count;
            break;
        case ComparisonSectionFriend:
            return self.isAnimeSection ? self.friendExclusiveAnimeItems.count : self.friendExclusiveMangaItems.count;
            break;
        case ComparisonSectionUser:
            return self.isAnimeSection ? self.userExclusiveAnimeItems.count : self.userExclusiveMangaItems.count;
            break;
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    CompareCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CompareCell" owner:self options:nil];
        cell = (CompareCell *)nib[0];
    }
    
    NSArray *data;

    switch (indexPath.section) {
        case ComparisonSectionMutual:
            data = self.isAnimeSection ? self.mutualAnimeItems : self.mutualMangaItems;
            break;
        case ComparisonSectionFriend:
            data = self.isAnimeSection ? self.friendExclusiveAnimeItems : self.friendExclusiveMangaItems;
            break;
        case ComparisonSectionUser:
            data = self.isAnimeSection ? self.userExclusiveAnimeItems : self.userExclusiveMangaItems;
            break;
        default:
            NSAssert(nil, @"");
            break;
    }
    
    NSManagedObject<FICEntity> *item = data[indexPath.row];
    [self configureCell:cell withObject:item];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data;
    
    switch (indexPath.section) {
        case ComparisonSectionMutual:
            data = self.isAnimeSection ? self.mutualAnimeItems : self.mutualMangaItems;
            break;
        case ComparisonSectionFriend:
            data = self.isAnimeSection ? self.friendExclusiveAnimeItems : self.friendExclusiveMangaItems;
            break;
        case ComparisonSectionUser:
            data = self.isAnimeSection ? self.userExclusiveAnimeItems : self.userExclusiveMangaItems;
            break;
        default:
            NSAssert(nil, @"");
            break;
    }
    
    NSManagedObject *object = data[indexPath.row];
    if([object isKindOfClass:[Anime class]]) {
        AnimeViewController *vc = [[AnimeViewController alloc] init];
        vc.anime = data[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([object isKindOfClass:[Manga class]]) {
        MangaViewController *vc = [[MangaViewController alloc] init];
        vc.manga = data[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject<FICEntity> *)object {
    CompareCell *anilistCell = (CompareCell *)cell;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURLRequest *imageRequest;
    NSString *cachedImageLocation = @"";
    
    if([object isMemberOfClass:[Anime class]]) {
        Anime *anime = (Anime *)object;
        FriendAnime *friendAnime = [FriendAnimeService anime:anime forFriend:self.friend];
        
        anilistCell.title.text = anime.title;
        
        [anilistCell setUserScore:[anime.user_score intValue] andFriendScore:[friendAnime.score intValue]];
        
        imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
        cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, anime.image];
    }
    else if([object isKindOfClass:[Manga class]]) {
        Manga *manga = (Manga *)object;
        FriendManga *friendManga = [FriendMangaService manga:manga forFriend:self.friend];

        anilistCell.title.text = manga.title;
        
        [anilistCell setUserScore:[manga.user_score intValue] andFriendScore:[friendManga.score intValue]];
        
        imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:manga.image_url]];
        cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, manga.image];
    }
    
    [anilistCell.title sizeToFit];
    
    [anilistCell setImageWithItem:object];
}

@end
