 //
//  AnimeUserInfoEditViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/8/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeUserInfoEditViewController.h"
#import "Anime.h"

@interface AnimeUserInfoEditViewController ()

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
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[MALHTTPClient sharedClient] updateDetailsForAnimeWithID:self.anime.anime_id success:^(id operation, id response) {
        NSLog(@"update");
    } failure:^(id operation, NSError *error) {
        NSLog(@"failed");
    }];
    
    self.scoreView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusScrollView.contentSize = CGSizeMake(self.statusScrollView.frame.size.width * animeStatusOrder.count, 1);
    self.statusScrollView.superview.backgroundColor = [UIColor defaultBackgroundColor];
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
    
    [self.startDateButton setTitle:[self startDateStringWithDate:self.anime.user_date_start] forState:UIControlStateNormal];
    [self.endDateButton setTitle:[self finishDateStringWithDate:self.anime.user_date_finish] forState:UIControlStateNormal];
    
    [self configureStatus];
    [self configureProgressLabel];
    [self configureRating];
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

- (void)configureStatus {
    for(int i = 0; i < animeStatusOrder.count; i++) {
        if([self.anime.watched_status intValue] == [animeStatusOrder[i] intValue]) {
            int contentOffset = i * self.statusScrollView.frame.size.width;
            [self.statusScrollView scrollRectToVisible:CGRectMake(contentOffset,
                                                                  self.statusScrollView.frame.origin.y,
                                                                  self.statusScrollView.frame.size.width,
                                                                  self.statusScrollView.frame.size.height) animated:NO];
            return;
        }
    }
}

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

#pragma mark - IBAction Methods

- (IBAction)addItemButtonPressed:(id)sender {
    if([self.anime.current_episode intValue] < [self.anime.total_episodes intValue])
        self.anime.current_episode = @([self.anime.current_episode intValue] + 1);
    
    [self configureProgressLabel];
}

- (IBAction)removeItemButtonPressed:(id)sender {
    if([self.anime.current_episode intValue] > 0)
        self.anime.current_episode = @([self.anime.current_episode intValue] - 1);
    
    [self configureProgressLabel];
}

#pragma mark - AniListDatePickerViewDelegate Methods

- (void)dateSelected:(NSDate *)date forType:(AniListDatePickerViewType)datePickerType {
    [super dateSelected:date forType:datePickerType];

    switch (datePickerType) {
        case AniListDatePickerStartDate:
            self.anime.user_date_start = date;
            [self.startDateButton setTitle:[self startDateStringWithDate:self.anime.user_date_start] forState:UIControlStateNormal];
            break;
        case AniListDatePickerEndDate:
            self.anime.user_date_finish = date;
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
}
@end
