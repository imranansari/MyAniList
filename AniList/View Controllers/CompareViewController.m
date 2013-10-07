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

@interface CompareViewController ()
@property (nonatomic, copy) NSArray *myItems;
@property (nonatomic, copy) NSArray *friendItems;

@property (nonatomic, copy) NSArray *mutualItems;
@property (nonatomic, copy) NSArray *friendExclusiveItems;
@property (nonatomic, copy) NSArray *myExclusiveItems;

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
        // Custom initialization
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
    
    NSArray *intersectedItems = [set1 allObjects];
    
    for(Anime *anime in intersectedItems) {
        FriendAnime *friendAnime = [FriendAnimeService anime:anime forFriend:self.friend];
        
        // Friend has not seen this anime.
        if([friendAnime.score intValue] == -1) {
            
        }
        
        // You have not seen this anime.
        if([anime.user_score intValue] == -1) {
            
        }
    }
    
    self.mutualItems = [set1 allObjects];
    
    ALLog(@"Similar anime count: %d", self.mutualItems.count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CompareCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mutualItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    CompareCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CompareCell" owner:self options:nil];
        cell = (CompareCell *)nib[0];
    }
    
    NSManagedObject *item = self.mutualItems[indexPath.row];
    [self configureCell:cell withObject:item];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = self.mutualItems[indexPath.row];
//    
//#warning - back button can get pretty long here. Best solution?
//    
//    if([object isMemberOfClass:[Anime class]]) {
//        AnimeViewController *vc = [[AnimeViewController alloc] init];
//        vc.anime = (Anime *)object;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//    else if([object isMemberOfClass:[Manga class]]) {
//        MangaViewController *vc = [[MangaViewController alloc] init];
//        vc.manga = (Manga *)object;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        
        anilistCell.theirScore.text = [NSString stringWithFormat:@"%d", [friendAnime.score intValue]];
        anilistCell.myScore.text = [NSString stringWithFormat:@"%d", [anime.user_score intValue]];
        
        anilistCell.difference.text = [NSString stringWithFormat:@"%d", [anime.user_score intValue] - [friendAnime.score intValue]];
        
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
