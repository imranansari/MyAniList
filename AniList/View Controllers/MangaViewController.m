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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
    
    self.titleLabel.text = self.manga.title;
    
    [self adjustTitle];
    
    [[MALHTTPClient sharedClient] getMangaDetailsForID:self.manga.manga_id success:^(NSURLRequest *operation, id response) {
        [MangaService addManga:response fromList:NO];
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
    self.mangaDetailsViewController.manga = self.manga;
    self.userInfoView.manga = self.manga;
    
    [self.scrollView addSubview:self.mangaDetailsViewController.view];
    [self.scrollView addSubview:self.userInfoView.view];
    [self.scrollView addSubview:self.detailsLabel];
    [self.scrollView addSubview:self.synopsisView];
    [self.scrollView addSubview:self.relatedTableView];
    
    if(self.manga.synopsis)
        [self.synopsisView addSynopsis:self.manga.synopsis];
    
    self.mangaDetailsViewController.view.frame = CGRectMake(0, 30, self.mangaDetailsViewController.view.frame.size.width, self.mangaDetailsViewController.view.frame.size.height);
    self.userInfoView.view.frame = CGRectMake(0, self.mangaDetailsViewController.view.frame.origin.y + self.mangaDetailsViewController.view.frame.size.height, self.userInfoView.view.frame.size.width, self.userInfoView.view.frame.size.height);
    self.detailsLabel.frame = CGRectMake(self.detailsLabel.frame.origin.x, self.userInfoView.view.frame.origin.y + self.userInfoView.view.frame.size.height, self.detailsLabel.frame.size.width, self.detailsLabel.frame.size.height);
    
    self.synopsisView.frame = CGRectMake(0, self.detailsLabel.frame.origin.y + self.detailsLabel.frame.size.height, self.synopsisView.frame.size.width, self.synopsisView.frame.size.height);
    
    int defaultContentSize = self.mangaDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + [UIScreen mainScreen].bounds.size.height - 90;
    
    int contentSizeWithSynopsis = self.mangaDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.synopsisView.frame.size.height + 90;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, MAX(contentSizeWithSynopsis, defaultContentSize));
}

- (void)updateViewsOnFailure:(BOOL)failure {
    if(self.manga.synopsis) {
        [self.synopsisView addSynopsis:self.manga.synopsis];
    }
    else if(failure) {
        [self.synopsisView addSynopsis:kNoSynopsisString];
    }
    
    self.synopsisView.frame = CGRectMake(0, self.detailsLabel.frame.origin.y + self.detailsLabel.frame.size.height, self.synopsisView.frame.size.width, self.synopsisView.frame.size.height);
    
    int defaultContentSize = self.mangaDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + [UIScreen mainScreen].bounds.size.height - 90;
    
    int contentSizeWithSynopsis = self.mangaDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.synopsisView.frame.size.height + 90;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, MAX(contentSizeWithSynopsis, defaultContentSize));
}

#pragma mark - AniListUserInfoViewControllerDelegate Methods

- (void)userInfoPressed {
    MangaUserInfoEditViewController *vc = [[MangaUserInfoEditViewController alloc] init];
    vc.manga = self.manga;
    
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
    
//    NSManagedObject *object = [self.relatedData[indexPath.section] allValues][0][indexPath.row];
//    
//    if([object isKindOfClass:[Anime class]]) {
//        [self configureAnimeCell:cell atIndexPath:indexPath];
//    }
//    else if([object isKindOfClass:[Manga class]]) {
//        [self configureMangaCell:cell atIndexPath:indexPath];
//    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.relatedTableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    Anime *anime = [self.relatedData[indexPath.section] allValues][0][indexPath.row];
//    AnimeViewController *avc = [[AnimeViewController alloc] init];
//    avc.anime = anime;
//    
//    self.navigationItem.backBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"Back"];
//    
//    [self.navigationController pushViewController:avc animated:YES];
}

@end
