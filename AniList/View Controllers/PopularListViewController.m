//
//  PopularListViewController.m
//  AniList
//
//  Created by Corey Roberts on 8/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "PopularListViewController.h"
#import "AniListTableView.h"
#import "Anime.h"
#import "AnimeViewController.h"
#import "Manga.h"
#import "MangaViewController.h"
#import "AniListStatCell.h"
#import "MALHTTPClient.h"

#import "AnimeService.h"
#import "MangaService.h"

@interface PopularListViewController ()
@property (nonatomic, copy) NSArray *sectionHeaders;
@property (nonatomic, strong) NSMutableArray *topItems;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int attempts;
@end

@implementation PopularListViewController

- (id)init {
    return [self initWithNibName:@"PopularListViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    ALLog(@"PopularList deallocating.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Popular %@", self.entityName];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.alpha = 0.0f;
    self.topItems = [[NSMutableArray alloc] init];
    self.currentPage = 1;
    
    self.indicator.alpha = 1.0f;
    self.errorLabel.alpha = 0.0f;
    
    [self fetchTopItemsAtPage:@(self.currentPage)];
    
    if(![UIApplication is4Inch]) {
        self.indicator.frame = CGRectMake(self.indicator.frame.origin.x,
                                          self.indicator.frame.origin.y - 60,
                                          self.indicator.frame.size.width,
                                          self.indicator.frame.size.height);
        
        self.errorLabel.frame = CGRectMake(self.errorLabel.frame.origin.x,
                                           self.errorLabel.frame.origin.y - 60,
                                           self.errorLabel.frame.size.width,
                                           self.errorLabel.frame.size.height);
    }
}

static BOOL fetching = NO;

- (void)fetchTopItemsAtPage:(NSNumber *)page {
    if(!fetching && self.attempts < MAX_ATTEMPTS) {
        ALLog(@"Fetching entity for page: %d", [page intValue]);
        fetching = YES;
        self.attempts++;
        
        if([self.entityName isEqualToString:@"Anime"]) {
            [[MALHTTPClient sharedClient] getPopularAnimeForType:AnimeTypeTV atPage:page success:^(id operation, id response) {
                
                int rank = 1 + (30 * ([page intValue] - 1));
                
                ALLog(@"Items fetched: %d", ((NSArray *)response).count);
                
                if(((NSArray *)response).count <= 0) {
                    // No results, so a silent fail. Retry.
                    fetching = NO;
                    [self fetchTopItemsAtPage:page];
                    return;
                }
                
                [self.tableView beginUpdates];
                for(NSDictionary *topAnime in response) {
                    
                    NSMutableDictionary *mutableTopAnime = [topAnime mutableCopy];
                    mutableTopAnime[@"popularity_rank"] = @(rank);
                    
                    ALLog(@"rank: %0.02f", [mutableTopAnime[@"popularity_rank"] floatValue]);
                    ALLog(@"score: %0.02f", [mutableTopAnime[@"members_score"] floatValue]);
                    
                    Anime *anime = [AnimeService addAnime:[mutableTopAnime copy] fromList:NO];
                    
                    [self.topItems addObject:anime];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(rank-1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    
                    rank++;
                }
                
                [self.tableView endUpdates];
                
                if(self.tableView.alpha == 0) {
                    [UIView animateWithDuration:0.3f animations:^{
                        self.tableView.alpha = 1.0f;
                        self.indicator.alpha = 0.0f;
                    }];
                }
                
                self.currentPage++;
                fetching = NO;
            } failure:^(id operation, NSError *error) {
                ALLog(@"Unable to get items. Trying again. Error: %@", error.localizedDescription);
                fetching = NO;
                [self fetchTopItemsAtPage:page];
            }];
        }
        else if([self.entityName isEqualToString:@"Manga"]) {
            [[MALHTTPClient sharedClient] getPopularMangaForType:MangaTypeManga atPage:page success:^(id operation, id response) {
                
                int rank = 1 + (30 * ([page intValue] - 1));
                
                ALLog(@"Items fetched: %d", ((NSArray *)response).count);
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                
                for(NSDictionary *topManga in response) {
                    
                    NSMutableDictionary *mutableTopManga = [topManga mutableCopy];
                    mutableTopManga[@"rank"] = @(rank);
                    
                    rank++;
                    Manga *manga = [MangaService addManga:[mutableTopManga copy] fromList:NO];
                    
                    [self.topItems addObject:manga];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:(rank-1) inSection:0]];
                }
                
                if(self.tableView.alpha == 0) {
                    [UIView animateWithDuration:0.3f animations:^{
                        self.tableView.alpha = 1.0f;
                        self.indicator.alpha = 0.0f;
                    }];
                }
                
                [self.tableView reloadData];
                self.currentPage++;
                fetching = NO;
            } failure:^(id operation, NSError *error) {
                ALLog(@"Unable to get items. Trying again. Error: %@", error.localizedDescription);
                fetching = NO;
            }];
        }
    }
    else {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.indicator.alpha = 0.0f;
                             if(self.topItems.count == 0) {
                                 self.errorLabel.text = kPopularAnimeDownErrorMessage;
                                 self.errorLabel.alpha = 1.0f;
                             }
                         }];
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

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.frame = view.bounds;
    [indicator startAnimating];
    
    [view addSubview:indicator];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AniListStatCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AniListStatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AniListStatCell" owner:self options:nil];
        cell = (AniListStatCell *)nib[0];
    }
    
    NSManagedObject *item = self.topItems[indexPath.row];
    [self configureCell:cell withObject:item];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = self.topItems[indexPath.row];
    
    if([object isMemberOfClass:[Anime class]]) {
        AnimeViewController *vc = [[AnimeViewController alloc] init];
        vc.anime = (Anime *)object;
        self.navigationItem.backBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"Anime"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([object isMemberOfClass:[Manga class]]) {
        MangaViewController *vc = [[MangaViewController alloc] init];
        vc.manga = (Manga *)object;
        self.navigationItem.backBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"Manga"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject<FICEntity> *)object {
    AniListStatCell *anilistCell = (AniListStatCell *)cell;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURLRequest *imageRequest;
    NSString *cachedImageLocation = @"";
    
    if([object isMemberOfClass:[Anime class]]) {
        Anime *anime = (Anime *)object;
        anilistCell.title.text = anime.title;
        anilistCell.progress.text = [Anime stringForAnimeWatchedStatus:[anime.watched_status intValue]];
        anilistCell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
        anilistCell.average_rank.text = [anime.average_score intValue] != -1 ? [NSString stringWithFormat:@"%0.02f", [anime.average_score doubleValue]] : @"";
        anilistCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
        anilistCell.stat.text = [NSString stringWithFormat:@"#%d", [anime.popularity_rank intValue]];
        imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
        cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, anime.image];
    }
    else if([object isKindOfClass:[Manga class]]) {
        Manga *manga = (Manga *)object;
        anilistCell.title.text = manga.title;
        anilistCell.progress.text = [Manga stringForMangaReadStatus:[manga.read_status intValue]];
        anilistCell.rank.text = [manga.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [manga.user_score intValue]] : @"";
        anilistCell.average_rank.text = [manga.average_score intValue] != -1 ? [NSString stringWithFormat:@"%0.02f", [manga.average_score doubleValue]] : @"";
        anilistCell.type.text = [Manga stringForMangaType:[manga.type intValue]];
        anilistCell.stat.text = [NSString stringWithFormat:@"#%d", [manga.popularity_rank intValue]];
        imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:manga.image_url]];
        cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, manga.image];
    }
    
    [anilistCell.title sizeToFit];
    
    [anilistCell setImageWithItem:object];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.topItems.count > 0) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height + 100 > scrollView.contentSize.height) {
            [self fetchTopItemsAtPage:@(self.currentPage)];
        }
    }
}

@end
