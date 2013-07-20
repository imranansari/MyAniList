//
//  AnimeViewController.m
//  AniList
//
//  Created by Corey Roberts on 4/16/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeViewController.h"
#import "AnimeService.h"
#import "AnimeDetailsViewController.h"
#import "AnimeUserInfoViewController.h"
#import "Anime.h"
#import "SynopsisView.h"
#import "AnimeUserInfoEditViewController.h"
#import "MALHTTPClient.h"
#import "AniListMiniCell.h"
#import "Manga.h"
#import "MangaCell.h"
#import "MangaViewController.h"

@interface AnimeViewController ()
@property (nonatomic, strong) AnimeDetailsViewController *animeDetailsViewController;
@property (nonatomic, strong) AnimeUserInfoViewController *userInfoView;
@end

@implementation AnimeViewController

- (id)init {
    self = [super init];
    if (self) {
        self.animeDetailsViewController = [[AnimeDetailsViewController alloc] init];
        self.userInfoView = [[AnimeUserInfoViewController alloc] init];
        self.userInfoView.delegate = self;
        self.synopsisView = [[SynopsisView alloc] init];
        
        self.detailsLabel = [UILabel whiteHeaderWithFrame:CGRectMake(0, 0, 320, 60) andFontSize:18];
        self.detailsLabel.text = @"Synopsis";
        
        self.hidesBackButton = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsOnFailure:) name:kAnimeDidUpdate object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
    
    self.titleLabel.text = self.anime.title;
//    self.relatedTableView.backgroundColor = [UIColor grayColor];
    [self adjustTitle];
    
    [[MALHTTPClient sharedClient] getAnimeDetailsForID:self.anime.anime_id success:^(NSURLRequest *operation, id response) {
        [AnimeService addAnime:response fromList:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnimeDidUpdate object:@(YES)];
    } failure:^(NSURLRequest *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnimeDidUpdate object:@(NO)];
        [self updateViewsOnFailure:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.userInfoView viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View Management Methods

- (void)refreshData {
    NSDictionary *prequels = self.anime.prequels.count ? @{ @"Prequels" : [self.anime.prequels allObjects] } : nil;
    NSDictionary *sequels = self.anime.sequels.count ? @{ @"Sequels" : [self.anime.sequels allObjects] } : nil;
    NSDictionary *mangaAdaptations = self.anime.manga_adaptations.count ? @{ @"Manga Adaptations" : [self.anime.manga_adaptations allObjects] } : nil;
    NSDictionary *sideStories = self.anime.side_stories.count ? @{ @"Side Stories" : [self.anime.side_stories allObjects] } : nil;
    NSDictionary *parentStory = self.anime.parent_story.count ? @{ @"Parent Story" : [self.anime.parent_story allObjects] } : nil;
    NSDictionary *characterAnimes = self.anime.character_anime.count ? @{ @"Character Anime" : [self.anime.character_anime allObjects] } : nil;
    NSDictionary *spinoffs = self.anime.spin_offs.count ? @{ @"Spin-offs" : [self.anime.spin_offs allObjects] } : nil;
    NSDictionary *summaries = self.anime.summaries.count ? @{ @"Summaries" : [self.anime.summaries allObjects] } : nil;
    NSDictionary *alternativeVersions = self.anime.alternative_versions.count ? @{ @"Alternative Versions" : [self.anime.alternative_versions allObjects] } : nil;
    
    
    NSMutableArray *related = [NSMutableArray array];
    
    if(prequels)
        [related addObject:prequels];
    
    if(sequels)
        [related addObject:sequels];
    
    if(mangaAdaptations)
        [related addObject:mangaAdaptations];
    
    if(sideStories)
        [related addObject:sideStories];
    
    if(parentStory)
        [related addObject:parentStory];
    
    if(characterAnimes)
        [related addObject:characterAnimes];
    
    if(spinoffs)
        [related addObject:spinoffs];
    
    if(summaries)
        [related addObject:summaries];
    
    if(alternativeVersions)
        [related addObject:alternativeVersions];
    
    self.relatedData = related;
    
    [self.relatedTableView reloadData];
    
    self.synopsisView.frame = CGRectMake(0, self.detailsLabel.frame.origin.y + self.detailsLabel.frame.size.height, self.synopsisView.frame.size.width, self.synopsisView.frame.size.height);
    
    int tableViewFrame = 0;
    
    for(int i = 0; i < self.relatedTableView.numberOfSections; i++) {
        tableViewFrame += [self.relatedTableView sectionHeaderHeight] + [self.relatedTableView numberOfRowsInSection:i] * [self.relatedTableView rowHeight];
    }
    
    self.relatedTableView.frame = CGRectMake(0, self.synopsisView.frame.origin.y + self.synopsisView.frame.size.height + 20, self.relatedTableView.frame.size.width, tableViewFrame);
    
    int defaultContentSize = self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.relatedTableView.frame.size.height + [UIScreen mainScreen].bounds.size.height - 90;
    
    int contentSizeWithSynopsis = self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.relatedTableView.frame.size.height + 20 + self.synopsisView.frame.size.height + 90;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, MAX(contentSizeWithSynopsis, defaultContentSize));
}

- (void)setupViews {
    self.animeDetailsViewController.anime = self.anime;
    self.userInfoView.anime = self.anime;
    
    [self.scrollView addSubview:self.animeDetailsViewController.view];
    [self.scrollView addSubview:self.userInfoView.view];
    [self.scrollView addSubview:self.detailsLabel];
    [self.scrollView addSubview:self.synopsisView];
    [self.scrollView addSubview:self.relatedTableView];
    
    if(self.anime.synopsis)
        [self.synopsisView addSynopsis:self.anime.synopsis];
    
    self.animeDetailsViewController.view.frame = CGRectMake(0, 30, self.animeDetailsViewController.view.frame.size.width, self.animeDetailsViewController.view.frame.size.height);
    self.userInfoView.view.frame = CGRectMake(0, self.animeDetailsViewController.view.frame.origin.y + self.animeDetailsViewController.view.frame.size.height, self.userInfoView.view.frame.size.width, self.userInfoView.view.frame.size.height);
    self.detailsLabel.frame = CGRectMake(self.detailsLabel.frame.origin.x, self.userInfoView.view.frame.origin.y + self.userInfoView.view.frame.size.height, self.detailsLabel.frame.size.width, self.detailsLabel.frame.size.height);
    
    [self refreshData];
}

- (void)updateViewsOnFailure:(BOOL)failure {
    if(self.anime.synopsis) {
        [self.synopsisView addSynopsis:self.anime.synopsis];
    }
    else if(failure) {
        [self.synopsisView addSynopsis:kNoSynopsisString];
    }
    
    [self refreshData];
    
//    [UIView animateWithDuration:0.5f
//                          delay:0.0f
//                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         
//                     } completion:nil];
}

- (void)configureAnimeCell:(AniListMiniCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Anime *anime = [self.relatedData[indexPath.section] allValues][0][indexPath.row];
    
    cell.title.text = anime.title;
    [cell.title addShadow];
    [cell.title sizeToFit];
    
    //    cell.progress.text = [AnimeCell progressTextForAnime:anime];
    //    [cell.progress addShadow];
    
    cell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
    [cell.rank addShadow];
    
    cell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
    [cell.type addShadow];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
    UIImage *cachedImage = [anime imageForAnime];
    
    if(!cachedImage) {
        [cell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            cell.image.image = image;
            
            if(!anime.image) {
                ALLog(@"Saving image to disk...");
                NSArray *segmentedURL = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                NSString *filename = [segmentedURL lastObject];
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *animeImagePath = [NSString stringWithFormat:@"%@/anime/%@", documentsDirectory, filename];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [UIImageJPEGRepresentation(image, 1.0) writeToFile:animeImagePath options:NSAtomicWrite error:nil];
                });
                
                // Only save relative URL since Documents URL can change on updates.
                anime.image = [NSString stringWithFormat:@"anime/%@", filename];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            // Log failure.
            ALLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
        }];
    }
    else {
        cell.image.image = cachedImage;
    }
}

- (void)configureMangaCell:(AniListMiniCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Manga *manga = [self.relatedData[indexPath.section] allValues][0][indexPath.row];
    MangaCell *mangaCell = (MangaCell *)cell;
    mangaCell.title.text = manga.title;
    [mangaCell.title addShadow];
    [mangaCell.title sizeToFit];
    
//    mangaCell.progress.text = [MangaCell progressTextForManga:manga];
//    [mangaCell.progress addShadow];
    
    mangaCell.rank.text = [manga.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [manga.user_score intValue]] : @"";
    [mangaCell.rank addShadow];
    
    mangaCell.type.text = [Manga stringForMangaType:[manga.type intValue]];
    [mangaCell.type addShadow];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:manga.image_url]];
    NSString *cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, manga.image];
    UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImageLocation];
    
    if(cachedImage) {
        ALLog(@"Image on disk exists for %@.", manga.title);
    }
    else {
        ALLog(@"Image on disk does not exist for %@.", manga.title);
    }
    
    [mangaCell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        ALLog(@"Got image for manga %@.", manga.title);
        mangaCell.image.image = image;
        
        // Save the image onto disk if it doesn't exist or they aren't the same.
        if(!manga.image) {
            ALLog(@"Saving image to disk...");
            NSArray *segmentedURL = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
            NSString *filename = [segmentedURL lastObject];
            
            NSString *animeImagePath = [NSString stringWithFormat:@"%@/manga/%@", documentsDirectory, filename];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                BOOL saved = NO;
                saved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:animeImagePath options:NSAtomicWrite error:nil];
                ALLog(@"Image %@", saved ? @"saved." : @"did not save.");
            });
            
            // Only save relative URL since Documents URL can change on updates.
            manga.image = [NSString stringWithFormat:@"manga/%@", filename];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        // Log failure.
        ALLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
    }];
    
    
}

#pragma mark - AniListUserInfoViewControllerDelegate Methods

- (void)userInfoPressed {
    AnimeUserInfoEditViewController *vc = [[AnimeUserInfoEditViewController alloc] init];
    vc.anime = self.anime;
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"Summary"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView Data Source Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self.relatedData[section] allKeys][0];
    UILabel *label = [UILabel whiteHeaderWithFrame:CGRectMake(0, 0, 320, 60) andFontSize:18];
    label.text = title;
    
    return label;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AniListMiniCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.relatedData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.relatedData[section] allValues][0] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AniListMiniCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AniListMiniCell" owner:self options:nil];
        cell = (AniListMiniCell *)nib[0];
    }
    
    NSManagedObject *object = [self.relatedData[indexPath.section] allValues][0][indexPath.row];
    
    if([object isKindOfClass:[Anime class]]) {
        [self configureAnimeCell:cell atIndexPath:indexPath];
    }
    else if([object isKindOfClass:[Manga class]]) {
        [self configureMangaCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.relatedTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSManagedObject *object = [self.relatedData[indexPath.section] allValues][0][indexPath.row];
    
    UIViewController *vc;
    
    if([object isKindOfClass:[Anime class]]) {
        Anime *anime = (Anime *)object;
        vc = [[AnimeViewController alloc] init];
        ((AnimeViewController *)vc).anime = anime;
    }
    else if([object isKindOfClass:[Manga class]]) {
        Manga *manga = (Manga *)object;
        vc = [[MangaViewController alloc] init];
        ((MangaViewController *)vc).manga = manga;
    }
    else return;
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"Back"];

    [self.navigationController pushViewController:vc animated:YES];
}

@end
