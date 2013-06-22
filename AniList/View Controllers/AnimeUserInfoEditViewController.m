 //
//  AnimeUserInfoEditViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/8/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeUserInfoEditViewController.h"
#import "AnimeService.h"
#import "Anime.h"
#import "MALHTTPClient.h"

@interface AnimeUserInfoEditViewController ()
#warning - I don't like this implementation, but it's safer than having nil values in a dictionary.
@property (nonatomic, assign) BOOL addAnimeToList;
@property (nonatomic, strong) NSDate *originalStartDate;
@property (nonatomic, strong) NSDate *originalEndDate;
@property (nonatomic, strong) NSNumber *originalCurrentEpisode;
@property (nonatomic, strong) NSNumber *originalUserScore;
@end

@implementation AnimeUserInfoEditViewController

static NSArray *animeStatusOrder;

- (id)init {
    self = [super init];
    if(self) {
        animeStatusOrder = @[
                                @(AnimeWatchedStatusWatching),
                                @(AnimeWatchedStatusCompleted),
                                @(AnimeWatchedStatusOnHold),
                                @(AnimeWatchedStatusDropped),
                                @(AnimeWatchedStatusPlanToWatch)
                                // Rewatch
                             ];
        
        self.addAnimeToList = NO;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.scoreView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addAnimeToList = [self.anime.watched_status intValue] == AnimeWatchedStatusNotWatching ? YES : NO;
    
    [self setOriginalValues];
    
    self.statusScrollView.contentSize = CGSizeMake(self.statusScrollView.frame.size.width * animeStatusOrder.count, 1);
    self.statusScrollView.delegate = self;
    self.scoreView.delegate = self;
    
    for(int i = 0; i < animeStatusOrder.count; i++) {
        UILabel *label = [UILabel whiteLabelWithFrame:CGRectMake(i * self.statusScrollView.frame.size.width, 0, self.statusScrollView.frame.size.width, self.statusScrollView.frame.size.height) andFontSize:17];
        
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [Anime stringForAnimeWatchedStatus:[animeStatusOrder[i] intValue] forAnimeType:[self.anime.type intValue]];
        label.tag = i;
        label.clipsToBounds = YES;
        [self.statusScrollView addSubview:label];
        
        if(UI_DEBUG) {
            label.backgroundColor = [UIColor colorWithRed:.1*i green:.1*i blue:.1*i alpha:1.0f];
            self.statusScrollView.backgroundColor = [UIColor blueColor];
            self.statusScrollView.showsHorizontalScrollIndicator = YES;
        }
    }
    
    // If we're coming into this screen after we've done a search (i.e. status is 'not watching' and user tapped
    // to add this to their list), then automatically set the start date to today.
    if([self.anime.watched_status intValue] == AnimeWatchedStatusNotWatching)
        self.anime.user_date_start = [NSDate date];
    
    [self updateLabels];
}

#pragma mark - NSString Methods

- (NSString *)startDateStringWithDate:(NSDate *)date {
    if(date) {
        return [NSString stringWithFormat:@"Started watching on %@", [NSString stringWithDate:date]];
    }
    else {
        return @"When did you start watching this?";
    }
}

- (NSString *)finishDateStringWithDate:(NSDate *)date {
    if(date) {
        return [NSString stringWithFormat:@"Finished watching on %@", [NSString stringWithDate:date]];
    }
    else {
        return @"When did you finish watching this?";
    }
}

#pragma mark - UIView Methods

- (void)configureStatusAnimated:(BOOL)animated {
    
    if([self.anime.watched_status intValue] == AnimeWatchedStatusNotWatching) {
        self.anime.watched_status = @(AnimeWatchedStatusPlanToWatch);
    }
    
    for(int i = 0; i < animeStatusOrder.count; i++) {
        if([self.anime.watched_status intValue] == [animeStatusOrder[i] intValue]) {
            int contentOffset = i * self.statusScrollView.frame.size.width;
            [self.statusScrollView scrollRectToVisible:CGRectMake(contentOffset,
                                                                  self.statusScrollView.frame.origin.y,
                                                                  self.statusScrollView.frame.size.width,
                                                                  self.statusScrollView.frame.size.height) animated:animated];
            return;
        }
    }
}


#warning - will need tweaking.
- (void)configureProgressLabel {
    if([self.anime.current_episode intValue] > 0) {
        if([self.anime.current_episode intValue] == [self.anime.total_episodes intValue]) {
            self.progressLabel.text = [NSString stringWithFormat:@"Finished all %d episodes", [self.anime.total_episodes intValue]];
        }
        else {
            self.progressLabel.text = [NSString stringWithFormat:@"On episode %d of %d", [self.anime.current_episode intValue], [self.anime.total_episodes intValue]];
        }
    }
    else {
        self.progressLabel.text = @"On the first episode";
    }
}

- (void)configureRating {
    if([self.anime.user_score intValue] > 0) {
        [self.scoreView updateScore:self.anime.user_score];
    }
}

- (void)configureDates {
    [self.startDateButton setTitle:[self startDateStringWithDate:self.anime.user_date_start] forState:UIControlStateNormal];
    [self.endDateButton setTitle:[self finishDateStringWithDate:self.anime.user_date_finish] forState:UIControlStateNormal];
}

- (void)updateLabels {
    [self configureStatusAnimated:NO];
    [self configureProgressLabel];
    [self configureRating];
    [self configureDates];
}

#pragma mark - IBAction Methods

- (IBAction)addItemButtonPressed:(id)sender {
    if([self.anime.current_episode intValue] < [self.anime.total_episodes intValue]) {
        self.anime.current_episode = @([self.anime.current_episode intValue] + 1);
        self.originalCurrentEpisode = self.anime.current_episode;
        
        
        if([self.anime.current_episode intValue] == [self.anime.total_episodes intValue] && [self.anime.watched_status intValue] != AnimeWatchedStatusCompleted) {
            // Set scroller to completed.
            
            self.anime.watched_status = @(AnimeWatchedStatusCompleted);
            [self configureStatusAnimated:YES];
        }
    }
    
    [self configureProgressLabel];
}

- (IBAction)removeItemButtonPressed:(id)sender {
    if([self.anime.current_episode intValue] > 0) {
        self.anime.current_episode = @([self.anime.current_episode intValue] - 1);
        self.originalCurrentEpisode = self.anime.current_episode;
        
        if([self.anime.current_episode intValue] < [self.anime.total_episodes intValue] && [self.anime.watched_status intValue] == AnimeWatchedStatusCompleted) {
            // Set scroller to currently watching, if we're coming back from completed.
            
            self.anime.watched_status = @(AnimeWatchedStatusWatching);
            [self configureStatusAnimated:YES];
        }
    }
    
    [self configureProgressLabel];
}

- (void)save:(id)sender {
    NSLog(@"Saving...");
    
    [self.anime.managedObjectContext save:nil];
    
    if(self.addAnimeToList) {
        [[MALHTTPClient sharedClient] addAnimeToListWithID:self.anime.anime_id success:^(id operation, id response) {
            NSLog(@"Added anime to list! Returning to anime details view.");
        } failure:^(id operation, NSError *error) {
            NSLog(@"Failed to update.");
        }];
    }
    else {
        [[MALHTTPClient sharedClient] updateDetailsForAnimeWithID:self.anime.anime_id success:^(id operation, id response) {
            NSLog(@"Updated. Returning to anime details view.");
        } failure:^(id operation, NSError *error) {
            NSLog(@"Failed to update.");
        }];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setOriginalValues {
    self.originalStartDate = self.anime.user_date_start;
    self.originalEndDate = self.anime.user_date_finish;
    self.originalCurrentEpisode = self.anime.current_episode;
    self.originalUserScore = self.anime.user_score;
}

- (void)revertValuesToDefault {
    self.anime.user_date_start = self.originalStartDate;
    self.anime.user_date_finish = self.originalEndDate;
    self.anime.current_episode = self.originalCurrentEpisode;
    self.anime.user_score = self.originalUserScore;
}

#pragma mark - AniListDatePickerViewDelegate Methods

- (void)dateSelected:(NSDate *)date forType:(AniListDatePickerViewType)datePickerType {
    [super dateSelected:date forType:datePickerType];

    switch (datePickerType) {
        case AniListDatePickerStartDate:
            self.anime.user_date_start = date;
            self.originalStartDate = self.anime.user_date_start;
            [self.startDateButton setTitle:[self startDateStringWithDate:self.anime.user_date_start] forState:UIControlStateNormal];
            break;
        case AniListDatePickerEndDate:
            self.anime.user_date_finish = date;
            self.originalEndDate = self.anime.user_date_finish;
            [self.endDateButton setTitle:[self finishDateStringWithDate:self.anime.user_date_finish] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - AniListScoreViewDelegate Methods

- (void)scoreUpdated:(NSNumber *)number {
    self.anime.user_score = number;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Calculate the page that we're currently looking at, and then fetch the appropriate status.
    int page = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSLog(@"Current page: %d", page);
    self.anime.watched_status = animeStatusOrder[page];
    
    [self revertValuesToDefault];
    
    switch ([self.anime.watched_status intValue]) {
        case AnimeWatchedStatusCompleted: {
            if(!self.anime.user_date_finish) {
                self.anime.user_date_finish = [NSDate date];
            }
            self.anime.current_episode = self.anime.total_episodes;
            break;
        }
        case AnimeWatchedStatusWatching: {
            if(!self.anime.user_date_start) {
                self.anime.user_date_start = [NSDate date];
            }
            break;
        }
        case AnimeWatchedStatusDropped:
        case AnimeWatchedStatusOnHold:
        case AnimeWatchedStatusPlanToWatch:
        default:
            break;
    }
    
    [self updateLabels];
}
@end
