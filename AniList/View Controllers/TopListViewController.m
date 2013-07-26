//
//  TopListViewController.m
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "TopListViewController.h"
#import "AniListTableView.h"
#import "Anime.h"
#import "AnimeViewController.h"
#import "Manga.h"
#import "MangaViewController.h"
#import "AniListCell.h"
#import "MALHTTPClient.h"

#import "AnimeService.h"
#import "MangaService.h"

@interface TopListViewController ()
@property (nonatomic, copy) NSArray *sectionHeaders;
@property (nonatomic, strong) NSMutableArray *topItems;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, assign) int currentPage;
@end

@implementation TopListViewController

- (id)init {
    return [self initWithNibName:@"TopListViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBackButton = NO;
    }
    return self;
}

- (void)dealloc {
    ALLog(@"TagList deallocating.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.topItems = [[NSMutableArray alloc] init];
    self.currentPage = 1;
    
    [self fetchTopItemsAtPage:@(self.currentPage)];
}

static BOOL fetching = NO;

- (void)fetchTopItemsAtPage:(NSNumber *)page {
    if(!fetching) {
        ALLog(@"Fetching anime at page: %d", [page intValue]);
        fetching = YES;
        
        if([self.entityName isEqualToString:@"Anime"]) {
            [[MALHTTPClient sharedClient] getTopAnimeForType:AnimeTypeTV atPage:page success:^(id operation, id response) {
                ALLog(@"Items fetched: %d", ((NSArray *)response).count);
                
                for(NSDictionary *topAnime in response) {
                    Anime *anime = [AnimeService addAnime:topAnime fromList:NO];
                    [self.topItems addObject:anime];
                }
                
                [self.tableView reloadData];
                self.currentPage++;
                fetching = NO;
            } failure:^(id operation, NSError *error) {
                ALLog(@"Unable to get items. Trying again. Error: %@", error.localizedDescription);
                fetching = NO;
            }];
        }
        else {
            
        }
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
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AniListCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AniListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
        cell = (AniListCell *)nib[0];
    }
    
    NSManagedObject *item = self.topItems[indexPath.row];
    [self configureCell:cell withObject:item];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = self.topItems[indexPath.row];
    
#warning - back button can get pretty long here. Best solution?
    
    if([object isMemberOfClass:[Anime class]]) {
        AnimeViewController *vc = [[AnimeViewController alloc] init];
        vc.anime = (Anime *)object;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([object isMemberOfClass:[Manga class]]) {
        MangaViewController *vc = [[MangaViewController alloc] init];
        vc.manga = (Manga *)object;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    AniListCell *anilistCell = (AniListCell *)cell;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURLRequest *imageRequest;
    NSString *cachedImageLocation = @"";
    
    if([object isMemberOfClass:[Anime class]]) {
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y + scrollView.frame.size.height + 100 > scrollView.contentSize.height) {
        [self fetchTopItemsAtPage:@(self.currentPage)];
    }
}

@end
