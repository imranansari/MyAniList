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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
    self.titleLabel.text = self.anime.title;
    
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

- (void)reloadCellWithObject:(NSManagedObject *)object {
//    self.relatedTableView reload
//    for(int i = 0; )
//    for(NSDictionary *section in self.relatedData) {
//        for(NSManagedObject *obj in [section allValues][0]) {
//            if(obj == object) {
    
//            }
//        }
//    }
}

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
    
    self.relatedTableView.frame = CGRectMake(0, self.synopsisView.frame.origin.y + self.synopsisView.frame.size.height, self.relatedTableView.frame.size.width, tableViewFrame);
    
    int defaultContentSize = self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.relatedTableView.frame.size.height + [UIScreen mainScreen].bounds.size.height - 90;
    
    int contentSizeWithSynopsis = self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.synopsisView.frame.size.height + self.relatedTableView.frame.size.height + 90;
    
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

#pragma mark - AniListUserInfoViewControllerDelegate Methods

- (void)userInfoPressed {
    [super userInfoPressed];
    
    AnimeUserInfoEditViewController *vc = [[AnimeUserInfoEditViewController alloc] init];
    vc.anime = self.anime;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
