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
@property (nonatomic, copy) NSArray *myItems;
@property (nonatomic, copy) NSArray *friendItems;

@property (nonatomic, copy) NSArray *mutualItems;
@property (nonatomic, copy) NSArray *friendExclusiveItems;
@property (nonatomic, copy) NSArray *userExclusiveItems;

@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UIImageView *myAvatar;
@property (nonatomic, weak) IBOutlet UIImageView *friendAvatar;

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
    
    self.maskView.layer.mask = gradient;
    [self.friendAvatar setImageWithURL:[NSURL URLWithString:self.friend.image_url]];
    [self.myAvatar setImageWithURL:[[UserProfile profile] profileImageURL].URL];
    
    self.friendItems = [FriendAnimeService animeForFriend:self.friend];
    self.myItems = [AnimeService myAnime];
    
    ALLog(@"Number of anime for friend '%@': %d", self.friend.username, self.friendItems.count);
    ALLog(@"Number of anime for user: %d", self.myItems.count);
    
    NSMutableSet *set1 = [NSMutableSet setWithArray:self.myItems];
    NSSet *set2 = [NSSet setWithArray:self.friendItems];
    
    [set1 intersectSet:set2];
    
    NSMutableArray *intersectedItems = [[set1 allObjects] mutableCopy];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [intersectedItems sortUsingDescriptors:@[sortDescriptor]];
    
    
    NSMutableArray *mutualItems = [NSMutableArray array];
    NSMutableArray *exclusiveFriendItems = [NSMutableArray array];
    NSMutableArray *exclusiveUserItems = [NSMutableArray array];
    
    for(Anime *anime in intersectedItems) {
        FriendAnime *friendAnime = [FriendAnimeService anime:anime forFriend:self.friend];
        
        // Friend has not seen this anime.
        if([friendAnime.score intValue] == -1 && [anime.user_score intValue] > -1) {
            [exclusiveUserItems addObject:anime];
        }
        // You have not seen this anime.
        else if([anime.user_score intValue] == -1 && [friendAnime.score intValue] > -1) {
            [exclusiveFriendItems addObject:anime];
        }
        else {
            [mutualItems addObject:anime];
        }
    }
    
    self.mutualItems = [mutualItems copy];
    self.userExclusiveItems = [exclusiveUserItems copy];
    self.friendExclusiveItems = [exclusiveFriendItems copy];
    
    ALLog(@"Anime count: %d", set1.count);
    ALLog(@"Mutual items: %d", self.mutualItems.count);
    ALLog(@"Friend-exclusive items: %d", self.friendExclusiveItems.count);
    ALLog(@"User-exclusive items: %d", self.userExclusiveItems.count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *title = @"";
    NSArray *data;
    
    switch (section) {
        case ComparisonSectionMutual:
            title = @"Shared";
            data = self.mutualItems;
            break;
        case ComparisonSectionFriend:
            title = [NSString stringWithFormat:@"Rated by %@", self.friend.username];
            data = self.friendExclusiveItems;
            break;
        case ComparisonSectionUser:
            title = [NSString stringWithFormat:@"Rated by %@", [UserProfile profile].username];
            data = self.userExclusiveItems;
            break;
        default:
            return nil;
    }
    
    NSString *count = [NSString stringWithFormat:@"%d", data.count];
    
    return [UIView tableHeaderWithPrimaryText:title andSecondaryText:count];
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    indicator.frame = view.bounds;
//    [indicator startAnimating];
//    
//    [view addSubview:indicator];
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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
            return [self.mutualItems count];
            break;
        case ComparisonSectionFriend:
            return [self.friendExclusiveItems count];
            break;
        case ComparisonSectionUser:
            return [self.userExclusiveItems count];
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
            data = self.mutualItems;
            break;
        case ComparisonSectionFriend:
            data = self.friendExclusiveItems;
            break;
        case ComparisonSectionUser:
            data = self.userExclusiveItems;
            break;
        default:
            NSAssert(nil, @"");
            break;
    }
    
    NSManagedObject *item = data[indexPath.row];
    [self configureCell:cell withObject:item];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data;
    
    switch (indexPath.section) {
        case ComparisonSectionMutual:
            data = self.mutualItems;
            break;
        case ComparisonSectionFriend:
            data = self.friendExclusiveItems;
            break;
        case ComparisonSectionUser:
            data = self.userExclusiveItems;
            break;
        default:
            NSAssert(nil, @"");
            break;
    }
    
    AnimeViewController *vc = [[AnimeViewController alloc] init];
    vc.anime = data[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    CompareCell *anilistCell = (CompareCell *)cell;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURLRequest *imageRequest;
    NSString *cachedImageLocation = @"";
    
    if([object isMemberOfClass:[Anime class]]) {
        Anime *anime = (Anime *)object;
        FriendAnime *friendAnime = [FriendAnimeService anime:anime forFriend:self.friend];
        
        anilistCell.title.text = anime.title;
        
        if([friendAnime.score intValue] > -1)
            anilistCell.theirScore.text = [NSString stringWithFormat:@"%d", [friendAnime.score intValue]];
        else
            anilistCell.theirScore.text = @"-";
        
        if([anime.user_score intValue] > -1)
            anilistCell.myScore.text = [NSString stringWithFormat:@"%d", [anime.user_score intValue]];
        else
            anilistCell.myScore.text = @"-";
        
        if([friendAnime.score intValue] > -1 && [anime.user_score intValue] > -1)
            anilistCell.difference.text = [NSString stringWithFormat:@"%d", [anime.user_score intValue] - [friendAnime.score intValue]];
        else
            anilistCell.difference.text = @"-";
        
        imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
        cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, anime.image];
    }
    else if([object isKindOfClass:[Manga class]]) {
        Manga *manga = (Manga *)object;
        FriendManga *friendManga = [FriendMangaService manga:manga forFriend:self.friend];

        anilistCell.title.text = manga.title;
        
        anilistCell.theirScore.text = [NSString stringWithFormat:@"%d", [friendManga.score intValue]];
        anilistCell.myScore.text = [NSString stringWithFormat:@"%d", [manga.user_score intValue]];
        
        anilistCell.difference.text = [NSString stringWithFormat:@"%d", [manga.user_score intValue] - [friendManga.score intValue]];
        
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
                    [[ImageManager sharedManager] addImage:image forAnime:anime];
                }
                else if([object isKindOfClass:[Manga class]]) {
                    Manga *manga = (Manga *)object;
                    [manga saveImage:image fromRequest:imageRequest];
                    [[ImageManager sharedManager] addImage:image forManga:manga];
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
