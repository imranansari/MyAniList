//
//  MangaViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaViewController.h"
#import "MangaDetailsViewController.h"
#import "MangaUserInfoViewController.h"
#import "Manga.h"
#import "MangaService.h"
#import "SynopsisView.h"
#import "MALHTTPClient.h"
#import "MangaUserInfoEditViewController.h"

@interface MangaViewController ()
@property (nonatomic, strong) MangaDetailsViewController *mangaDetailsViewController;
@property (nonatomic, strong) MangaUserInfoViewController *userInfoView;
@end

@implementation MangaViewController

- (id)init {
    self = [super init];
    if (self) {
        self.mangaDetailsViewController = [[MangaDetailsViewController alloc] init];
        self.userInfoView = [[MangaUserInfoViewController alloc] init];
        self.userInfoView.delegate = self;
        self.synopsisView = [[SynopsisView alloc] init];
        
        self.detailsLabel = [UILabel whiteHeaderWithFrame:CGRectMake(0, 0, 320, 60) andFontSize:18];
        self.detailsLabel.text = @"Synopsis";
        
        self.hidesBackButton = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsOnFailure:) name:kMangaDidUpdate object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    
    self.titleLabel.text = self.manga.title;
    
    [self adjustTitle];
    
    [[MALHTTPClient sharedClient] getMangaDetailsForID:self.manga.manga_id success:^(NSURLRequest *operation, id response) {
        [MangaService addManga:response];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMangaDidUpdate object:@(YES)];
    } failure:^(NSURLRequest *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMangaDidUpdate object:@(NO)];
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

- (void)refreshData {
    
    NSDictionary *animeAdaptations = self.manga.anime_adaptations.count ? @{ @"Anime Adaptations" : [self.manga.anime_adaptations allObjects] } : nil;
    NSDictionary *relatedManga = self.manga.related_manga.count ? @{ @"Related Manga" : [self.manga.related_manga allObjects] } : nil;
    NSDictionary *alternativeVersions = self.manga.alternative_versions.count ? @{ @"Alternative Versions" : [self.manga.alternative_versions allObjects] } : nil;
    
    NSMutableArray *related = [NSMutableArray array];
    
    if(animeAdaptations)
        [related addObject:animeAdaptations];
    
    if(relatedManga)
        [related addObject:relatedManga];
    
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
    
    
    int defaultContentSize = self.mangaDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.relatedTableView.frame.size.height + [UIScreen mainScreen].bounds.size.height - 90;
    
    int contentSizeWithSynopsis = self.mangaDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.synopsisView.frame.size.height + self.relatedTableView.frame.size.height + 90;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, MAX(contentSizeWithSynopsis, defaultContentSize));
}

- (void)setupViews {
    self.mangaDetailsViewController.manga = self.manga;
    self.userInfoView.manga = self.manga;
    
    [self.scrollView addSubview:self.mangaDetailsViewController.view];
    [self.scrollView addSubview:self.userInfoView.view];
    [self.scrollView addSubview:self.detailsLabel];
    [self.scrollView addSubview:self.synopsisView];
    [self.scrollView addSubview:self.relatedTableView];
    
    if(self.manga.synopsis)
        [self.synopsisView addSynopsis:self.manga.synopsis];
    
    int frameOffset = [UIApplication isiOS7] ? -50 : 0;
    
    self.mangaDetailsViewController.view.frame = CGRectMake(0, 30 + frameOffset, self.mangaDetailsViewController.view.frame.size.width, self.mangaDetailsViewController.view.frame.size.height);
    self.userInfoView.view.frame = CGRectMake(0, self.mangaDetailsViewController.view.frame.origin.y + self.mangaDetailsViewController.view.frame.size.height, self.userInfoView.view.frame.size.width, self.userInfoView.view.frame.size.height);
    self.detailsLabel.frame = CGRectMake(self.detailsLabel.frame.origin.x, self.userInfoView.view.frame.origin.y + self.userInfoView.view.frame.size.height, self.detailsLabel.frame.size.width, self.detailsLabel.frame.size.height);
    
    [self refreshData];
}

- (void)updateViewsOnFailure:(BOOL)failure {
    if(self.manga.synopsis) {
        [self.synopsisView addSynopsis:self.manga.synopsis];
    }
    else if(failure) {
        [self.synopsisView addSynopsis:kNoSynopsisString];
    }
    
    [self refreshData];
}

#pragma mark - AniListUserInfoViewControllerDelegate Methods

- (void)userInfoPressed {
    [super userInfoPressed];
    
    MangaUserInfoEditViewController *vc = [[MangaUserInfoEditViewController alloc] init];
    vc.manga = self.manga;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
