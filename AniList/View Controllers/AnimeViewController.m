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

- (void)setupViews {
    self.animeDetailsViewController.anime = self.anime;
    self.userInfoView.anime = self.anime;
    self.relatedTableView.delegate = self;
    self.relatedTableView.dataSource = self;
    self.relatedTableView.rowHeight = [AniListMiniCell cellHeight];
    self.relatedTableView.sectionHeaderHeight = 60;
    self.relatedTableView.sectionFooterHeight = 0;
    
    [self.scrollView addSubview:self.animeDetailsViewController.view];
    [self.scrollView addSubview:self.userInfoView.view];
    [self.scrollView addSubview:self.detailsLabel];
    [self.scrollView addSubview:self.synopsisView];
    [self.scrollView addSubview:self.relatedTableView];
    
    NSDictionary *prequels = self.anime.prequels.count ? @{ @"Prequels" : [self.anime.prequels allObjects] } : nil;
    NSDictionary *sequels = self.anime.sequels.count ? @{ @"Sequels" : [self.anime.sequels allObjects] } : nil;
    
    NSMutableArray *related = [NSMutableArray array];
    
    if(prequels)
        [related addObject:prequels];
    
    if(sequels)
        [related addObject:sequels];
    
    self.relatedData = related;
    
    [self.relatedTableView reloadData];
    
    if(self.anime.synopsis)
        [self.synopsisView addSynopsis:self.anime.synopsis];
    
    self.animeDetailsViewController.view.frame = CGRectMake(0, 30, self.animeDetailsViewController.view.frame.size.width, self.animeDetailsViewController.view.frame.size.height);
    self.userInfoView.view.frame = CGRectMake(0, self.animeDetailsViewController.view.frame.origin.y + self.animeDetailsViewController.view.frame.size.height, self.userInfoView.view.frame.size.width, self.userInfoView.view.frame.size.height);
    self.detailsLabel.frame = CGRectMake(self.detailsLabel.frame.origin.x, self.userInfoView.view.frame.origin.y + self.userInfoView.view.frame.size.height, self.detailsLabel.frame.size.width, self.detailsLabel.frame.size.height);
    
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

- (void)updateViewsOnFailure:(BOOL)failure {
    if(self.anime.synopsis) {
        [self.synopsisView addSynopsis:self.anime.synopsis];
    }
    else if(failure) {
        [self.synopsisView addSynopsis:kNoSynopsisString];
    }
    
    NSDictionary *prequels = self.anime.prequels.count ? @{ @"Prequels" : [self.anime.prequels allObjects] } : nil;
    NSDictionary *sequels = self.anime.sequels.count ? @{ @"Sequels" : [self.anime.sequels allObjects] } : nil;
    
    NSMutableArray *related = [NSMutableArray array];
    
    if(prequels)
        [related addObject:prequels];
    
    if(sequels)
        [related addObject:sequels];
    
    self.relatedData = related;
    
    [self.relatedTableView reloadData];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.synopsisView.frame = CGRectMake(0, self.detailsLabel.frame.origin.y + self.detailsLabel.frame.size.height, self.synopsisView.frame.size.width, self.synopsisView.frame.size.height);
                         
                         int tableViewFrame = 0;
                         
                         for(int i = 0; i < self.relatedTableView.numberOfSections; i++) {
                             tableViewFrame += [self.relatedTableView sectionHeaderHeight] + [self.relatedTableView numberOfRowsInSection:i] * [self.relatedTableView rowHeight];
                         }
                         
                         self.relatedTableView.frame = CGRectMake(0, self.synopsisView.frame.origin.y + self.synopsisView.frame.size.height + 20, self.relatedTableView.frame.size.width, tableViewFrame);
                         
                         int defaultContentSize = self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + [UIScreen mainScreen].bounds.size.height + self.relatedTableView.frame.size.height - 90;
                         
                         int contentSizeWithSynopsis = self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.synopsisView.frame.size.height + 20 + self.relatedTableView.frame.size.height + 90;
                         
                         self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, MAX(contentSizeWithSynopsis, defaultContentSize));
                         self.relatedTableView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.relatedTableView.frame.size.height);
                     } completion:nil];
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
    
    Anime *anime = [self.relatedData[indexPath.section] allValues][0][indexPath.row];
    
    AniListMiniCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AniListMiniCell" owner:self options:nil];
        cell = (AniListMiniCell *)nib[0];
    }
    
    cell.title.text = anime.title;
    [cell.title addShadow];
    [cell.title sizeToFit];
    
//    cell.progress.text = [AnimeCell progressTextForAnime:anime];
//    [cell.progress addShadow];
    
    cell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
    [cell.rank addShadow];
    
    cell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
    [cell.type addShadow];
    
//    cell.backgroundColor = [UIColor darkGrayColor];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
    
    UIImage *cachedImage = [anime imageForAnime];
    
    if(cachedImage) {
        //        ALLog(@"Image on disk exists for %@.", anime.title);
    }
    else {
        //        ALLog(@"Image on disk does not exist for %@.", anime.title);
    }
    
    //    ALLog(@"location: %@", cachedImageLocation);
    
    if(!cachedImage) {
        [cell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            //        ALLog(@"Got image for anime %@.", anime.title);
            cell.image.image = image;
            
            // Save the image onto disk if it doesn't exist or they aren't the same.
#warning - need to compare cached image to this new image, and replace if necessary.
#warning - will need to be fast and efficient! Alternatively, we can recycle the cache if need be.
            if(!anime.image) {
                //            ALLog(@"Saving image to disk...");
                NSArray *segmentedURL = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                NSString *filename = [segmentedURL lastObject];
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *animeImagePath = [NSString stringWithFormat:@"%@/anime/%@", documentsDirectory, filename];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    BOOL saved = NO;
                    saved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:animeImagePath options:NSAtomicWrite error:nil];
                    //                ALLog(@"Image %@", saved ? @"saved." : @"did not save.");
                });
                
                // Only save relative URL since Documents URL can change on updates.
                anime.image = [NSString stringWithFormat:@"anime/%@", filename];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            // Log failure.
            //        ALLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
        }];
    }
    else {
        cell.image.image = cachedImage;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.relatedTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Anime *anime = [self.relatedData[indexPath.section] allValues][0][indexPath.row];
    AnimeViewController *avc = [[AnimeViewController alloc] init];
    avc.anime = anime;
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"Back"];

    [self.navigationController pushViewController:avc animated:YES];
}

@end
