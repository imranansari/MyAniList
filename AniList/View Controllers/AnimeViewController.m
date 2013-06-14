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
#import "SynopsisView.h"
#import "AniListPickerView.h"
#import "AnimeUserInfoEditViewController.h"

@interface AnimeViewController ()
@property (nonatomic, strong) AnimeDetailsViewController *animeDetailsViewController;
@property (nonatomic, strong) AnimeUserInfoViewController *userInfoView;
@property (nonatomic, strong) UILabel *synopsisLabel;
@property (nonatomic, strong) SynopsisView *synopsisView;
@property (nonatomic, strong) UILabel *detailsLabel;
@property (nonatomic, strong) AniListPickerView *pickerView;
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
        
        self.pickerView = [[AniListPickerView alloc] initWithFrame:CGRectMake(self.userInfoView.view.frame.origin.x, self.userInfoView.view.frame.origin.y + self.userInfoView.view.frame.size.height, [UIScreen mainScreen].bounds.size.width, 146)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewsOnFailure:) name:kAnimeDidUpdate object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
    
    self.titleLabel.text = self.anime.title;
    
    [[MALHTTPClient sharedClient] getAnimeDetailsForID:self.anime.anime_id success:^(NSURLRequest *operation, id response) {
        [AnimeService addAnime:response];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAnimeDidUpdate object:@(YES)];
    } failure:^(NSURLRequest *operation, NSError *error) {
        [self updateViewsOnFailure:YES];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
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
    
    [self.scrollView addSubview:self.animeDetailsViewController.view];
    [self.scrollView addSubview:self.userInfoView.view];
    [self.scrollView addSubview:self.detailsLabel];
    [self.scrollView addSubview:self.synopsisView];
    
    if(self.anime.synopsis)
        [self.synopsisView addSynopsis:self.anime.synopsis];
    
    self.animeDetailsViewController.view.frame = CGRectMake(0, 30, self.animeDetailsViewController.view.frame.size.width, self.animeDetailsViewController.view.frame.size.height);
    self.userInfoView.view.frame = CGRectMake(0, self.animeDetailsViewController.view.frame.origin.y + self.animeDetailsViewController.view.frame.size.height, self.userInfoView.view.frame.size.width, self.userInfoView.view.frame.size.height);
    self.detailsLabel.frame = CGRectMake(self.detailsLabel.frame.origin.x, self.userInfoView.view.frame.origin.y + self.userInfoView.view.frame.size.height, self.detailsLabel.frame.size.width, self.detailsLabel.frame.size.height);
    
    self.synopsisView.frame = CGRectMake(0, self.detailsLabel.frame.origin.y + self.detailsLabel.frame.size.height, self.synopsisView.frame.size.width, self.synopsisView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + [UIScreen mainScreen].bounds.size.height - 90);
}

- (void)updateViewsOnFailure:(BOOL)failure {
    if(self.anime.synopsis) {
        [self.synopsisView addSynopsis:self.anime.synopsis];
    }
    else if(failure) {
        [self.synopsisView addSynopsis:kNoSynopsisString];
    }
    
    self.synopsisView.frame = CGRectMake(0, self.detailsLabel.frame.origin.y + self.detailsLabel.frame.size.height, self.synopsisView.frame.size.width, self.synopsisView.frame.size.height);
    
    int defaultContentSize = self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + [UIScreen mainScreen].bounds.size.height - 90;
    
    int contentSizeWithSynopsis = self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.synopsisView.frame.size.height;
    
    if(contentSizeWithSynopsis > defaultContentSize) {
        self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, contentSizeWithSynopsis);
    }
    
//    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.animeDetailsViewController.view.frame.size.height + self.userInfoView.view.frame.size.height + self.detailsLabel.frame.size.height + self.synopsisView.frame.size.height + 20);
}

#pragma mark - AniListUserInfoViewControllerDelegate Methods

- (void)userInfoPressed {
    
    AnimeUserInfoEditViewController *vc = [[AnimeUserInfoEditViewController alloc] init];
    vc.anime = self.anime;
    [self.navigationController pushViewController:vc animated:YES];
    
//    self.pickerView.pickerType = AniListPickerStatusPicker;
//    self.pickerView.anime = self.anime;

//    [self.scrollView scrollRectToVisible:CGRectMake(self.userInfoView.view.frame.origin.x, 133, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20) animated:YES];
    
//    [self.scrollView scrollRectToVisible:CGRectMake(self.userInfoView.view.frame.origin.x, self.userInfoView.view.frame.origin.y - ([UIScreen mainScreen].bounds.size.height - 16 - self.userInfoView.view.frame.size.height - picker.frame.size.height), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.pickerView.frame = CGRectMake(self.userInfoView.view.frame.origin.x, self.userInfoView.view.frame.origin.y + self.userInfoView.view.frame.size.height, [UIScreen mainScreen].bounds.size.width, 146);
    [self.pickerView refresh];

    [self.scrollView addSubview:self.pickerView];
}

@end
