//
//  TagListViewController.m
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "TagListViewController.h"
#import "CRTransitionLabel.h"
#import "Anime.h"
#import "AnimeViewController.h"
#import "Manga.h"
#import "MangaViewController.h"
#import "Tag.h"
#import "TagService.h"
#import "Genre.h"
#import "GenreService.h"
#import "AniListCell.h"
#import "MALHTTPClient.h"


@interface TagListViewController ()
@property (nonatomic, copy) NSArray *sectionHeaders;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *topSectionLabel;
@property (nonatomic, strong) NSArray *taggedItems;
@end

@implementation TagListViewController

- (id)init {
    return [self initWithNibName:@"TagListViewController" bundle:[NSBundle mainBundle]];
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

    self.topSectionLabel.backgroundColor = [UIColor clearColor];
    self.topSectionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    self.topSectionLabel.textColor = [UIColor lightGrayColor];
    self.topSectionLabel.textAlignment = NSTextAlignmentCenter;
    
    self.topSectionLabel.text = @"";
    self.topSectionLabel.alpha = 0.0f;
    
    // Fetch.
    if(self.isAnime) {
        if(self.tag) {
            self.taggedItems = [TagService animeWithTag:self.tag];
            self.title = self.tag;
        }
        else if(self.genre) {
            self.taggedItems = [GenreService animeWithGenre:self.genre];
            self.title = [NSString stringWithFormat:@"%@ Anime", self.genre];
        }
    }
    else {
        if(self.tag) {
            self.taggedItems = [TagService mangaWithTag:self.tag];
            self.title = self.tag;
        }
        else if(self.genre) {
            self.taggedItems = [GenreService mangaWithGenre:self.genre];
            self.title = [NSString stringWithFormat:@"%@ Manga", self.genre];
        }
    }
        
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [[AnalyticsManager sharedInstance] trackView:kAnimeTagsScreen];
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
    return 1;
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
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    return [sectionInfo numberOfObjects];
    return [self.taggedItems count];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSNumber *headerSection = @(0);//[self.fetchedResultsController sectionIndexTitles][section];
//    NSString *count = [NSString stringWithFormat:@"%d", [self.tableView numberOfRowsInSection:section]];
//    return [UIView tableHeaderWithPrimaryText:self.sectionHeaders[[headerSection intValue]] andSecondaryText:count];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AniListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
        cell = (AniListCell *)nib[0];
    }
    
    NSManagedObject<FICEntity> *item = self.taggedItems[indexPath.row];
    [self configureCell:cell withObject:item];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = self.taggedItems[indexPath.row];
    
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

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject<FICEntity> *)object {
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
    
    [anilistCell setImageWithItem:object];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    ALLog(@"content offset: %f", scrollView.contentOffset.y);
    
    if(scrollView.contentOffset.y > 36) {
        NSArray *visibleSections = [[[NSSet setWithArray:[[self.tableView indexPathsForVisibleRows] valueForKey:@"section"]] allObjects] sortedArrayUsingSelector:@selector(compare:)];
        //        ALLog(@"indices: %@", [self.tableView indexPathsForVisibleRows]);
        //        ALLog(@"visible sections: %@", visibleSections);
        
        if(visibleSections.count > 0) {
            int topSection = [visibleSections[0] intValue];
            
            NSNumber *headerSection = @(0);//[self.fetchedResultsController sectionIndexTitles][topSection];
            
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
}

@end
