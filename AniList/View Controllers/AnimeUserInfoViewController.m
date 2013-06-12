//
//  AnimeUserInfoViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeUserInfoViewController.h"
#import "Anime.h"

@interface AnimeUserInfoViewController ()
@property (nonatomic, weak) IBOutlet UIView *watchingStatusView;
@property (nonatomic, weak) IBOutlet UIView *startDateView;
@property (nonatomic, weak) IBOutlet UIView *endDateView;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UIView *scoreView;

- (IBAction)progressViewPressed:(id)sender;

@end

@implementation AnimeUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLabels];

}

- (void)setupLabels {
    UILabel *watchingStatusLabel = [self labelForView:self.watchingStatusView];
    UILabel *startDate = [self labelForView:self.startDateView];
    UILabel *endDate = [self labelForView:self.endDateView];
    UILabel *progressLabel = [self labelForView:self.progressView];
    UILabel *scoreLabel = [self labelForView:self.scoreView];
    
    if(self.anime.watched_status && [self.anime.watched_status intValue] != AnimeWatchedStatusUnknown) {
        watchingStatusLabel.text = [Anime stringForAnimeWatchedStatus:[self.anime.watched_status intValue] forAnimeType:[self.anime.type intValue]];
    }
    else {
        // No watch status, shouldn't ever hit here.
    }
    
    // Multiple scenarios for these strings.
    
    if(self.anime.user_date_start) {
        startDate.text = [NSString stringWithFormat:@"Started on %@", [self.anime.user_date_start stringValue]];
    }
    else {
        startDate.text = @"When did you start watching?";
    }
    
    if(self.anime.user_date_finish) {
        endDate.text = [NSString stringWithFormat:@"Finished on %@", [self.anime.user_date_finish stringValue]];
    }
    else {
        endDate.text = @"When did you finish?";
    }
    
    if([self.anime.user_score intValue] > 0) {
        scoreLabel.text = [NSString stringWithFormat:@"You gave this a %d.", [self.anime.user_score intValue]];
    }
    else {
        scoreLabel.text = @"Not scored yet";
    }
    
    
    progressLabel.text = [NSString stringWithFormat:@"Progress: %d / %d", [self.anime.current_episode intValue], [self.anime.total_episodes intValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)labelForView:(UIView *)view {
    for(UIView *subview in view.subviews) {
        if([subview isMemberOfClass:[UILabel class]]) {
            return (UILabel *)subview;
        }
    }
    
    return nil;
}

#pragma mark - IBAction Methods

- (IBAction)userInfoViewPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(userInfoPressed)]) {
        [self.delegate userInfoPressed];
    }
}

- (void)setAnime:(Anime *)anime {
    _anime = anime;
    
    [self setupLabels];
}

@end
