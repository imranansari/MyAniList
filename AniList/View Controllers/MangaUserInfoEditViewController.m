//
//  MangaUserInfoEditViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaUserInfoEditViewController.h"
#import "MangaService.h"
#import "Manga.h"
#import "MALHTTPClient.h"

@interface MangaUserInfoEditViewController ()
#warning - I don't like this implementation, but it's safer than having nil values in a dictionary.
@property (nonatomic, assign) BOOL addMangaToList;
@property (nonatomic, strong) NSDate *originalStartDate;
@property (nonatomic, strong) NSDate *originalEndDate;
@property (nonatomic, strong) NSNumber *originalCurrentEpisode;
@property (nonatomic, strong) NSNumber *originalUserScore;
@end

@implementation MangaUserInfoEditViewController

static NSArray *mangaStatusOrder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mangaStatusOrder = @[
                             @(MangaReadStatusReading),
                             @(MangaReadStatusCompleted),
                             @(MangaReadStatusOnHold),
                             @(MangaReadStatusDropped),
                             @(MangaReadStatusPlanToRead)
                             // Rewatch
                             ];
        
        self.addMangaToList = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.addMangaToList = [self.manga.read_status intValue] == MangaReadStatusNotReading ? YES : NO;
    
    [self setOriginalValues];
    
    self.statusScrollView.contentSize = CGSizeMake(self.statusScrollView.frame.size.width * mangaStatusOrder.count, 1);
    self.statusScrollView.delegate = self;
    self.scoreView.delegate = self;
    
    for(int i = 0; i < mangaStatusOrder.count; i++) {
        UILabel *label = [UILabel whiteLabelWithFrame:CGRectMake(i * self.statusScrollView.frame.size.width, 0, self.statusScrollView.frame.size.width, self.statusScrollView.frame.size.height) andFontSize:17];
        
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [Manga stringForMangaReadStatus:[mangaStatusOrder[i] intValue] forMangaType:[self.manga.type intValue] forEditScreen:YES];
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
    if([self.manga.read_status intValue] == MangaReadStatusNotReading)
        self.manga.user_date_start = [NSDate date];

    
    [self updateLabels];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[AnalyticsManager sharedInstance] trackView:kMangaEditUserInfoScreen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(!self.saving) {
        [self.manga.managedObjectContext rollback];
    }
}

#pragma mark - NSString Methods

- (NSString *)startDateStringWithDate:(NSDate *)date {
    if(date) {
        return [NSString stringWithFormat:@"Started reading on %@", [NSString stringWithDate:date]];
    }
    else {
        return @"When did you start reading this?";
    }
}

- (NSString *)finishDateStringWithDate:(NSDate *)date {
    if(date) {
        return [NSString stringWithFormat:@"Finished reading on %@", [NSString stringWithDate:date]];
    }
    else {
        return @"When did you finish reading this?";
    }
}

#pragma mark - UIView Methods

- (void)configureStatusAnimated:(BOOL)animated {
    
    if([self.manga.read_status intValue] == MangaReadStatusNotReading) {
        self.manga.read_status = @(MangaReadStatusPlanToRead);
    }
    
    for(int i = 0; i < mangaStatusOrder.count; i++) {
        if([self.manga.read_status intValue] == [mangaStatusOrder[i] intValue]) {
            int contentOffset = i * self.statusScrollView.frame.size.width;
            [self.statusScrollView scrollRectToVisible:CGRectMake(contentOffset,
                                                                  self.statusScrollView.frame.origin.y,
                                                                  self.statusScrollView.frame.size.width,
                                                                  self.statusScrollView.frame.size.height) animated:animated];
            return;
        }
    }
}

- (void)configureProgressLabel {
    // Set up primary and secondary labels.
    
    // Volume Label
    if([self.manga.current_volume intValue] > 0) {
        if([self.manga.current_volume intValue] == [self.manga.total_volumes intValue]) {
            self.progressLabel.text = [NSString stringWithFormat:@"Finished all %d volumes", [self.manga.total_volumes intValue]];
        }
        else if([self.manga.total_volumes intValue] == 0) {
            self.progressLabel.text = [NSString stringWithFormat:@"Finished volume %d", [self.manga.current_volume intValue]];
        }
        else {
            self.progressLabel.text = [NSString stringWithFormat:@"Finished volume %d of %d", [self.manga.current_volume intValue], [self.manga.total_volumes intValue]];
        }
    }
    else {
        self.progressLabel.text = @"On the first volume";
    }
    
    // Chapter Label
    if([self.manga.current_chapter intValue] > 0) {
        if([self.manga.current_chapter intValue] == [self.manga.total_chapters intValue]) {
            self.secondaryProgressLabel.text = [NSString stringWithFormat:@"Finished all %d chapters", [self.manga.total_chapters intValue]];
        }
        else if([self.manga.total_chapters intValue] == 0) {
            self.secondaryProgressLabel.text = [NSString stringWithFormat:@"Finished chapter %d", [self.manga.current_chapter intValue]];
        }
        else {
            self.secondaryProgressLabel.text = [NSString stringWithFormat:@"Finished chapter %d of %d", [self.manga.current_chapter intValue], [self.manga.total_chapters intValue]];
        }
    }
    else {
        self.secondaryProgressLabel.text = @"On the first chapter";
    }
}

- (void)configureRating {
    if([self.manga.user_score intValue] > 0) {
        [self.scoreView updateScore:self.manga.user_score];
    }
}

- (void)configureDates {
    [self.startDateButton setTitle:[self startDateStringWithDate:self.manga.user_date_start] forState:UIControlStateNormal];
    [self.endDateButton setTitle:[self finishDateStringWithDate:self.manga.user_date_finish] forState:UIControlStateNormal];
}

- (void)updateLabels {
    [self configureStatusAnimated:NO];
    [self configureProgressLabel];
    [self configureRating];
    [self configureDates];
}

#pragma mark - IBAction Methods

- (IBAction)addItemButtonPressed:(id)sender {
    if([self.manga.total_volumes intValue] == 0) {
        self.manga.current_volume = @([self.manga.current_volume intValue] + 1);
    }
    else if([self.manga.current_volume intValue] < [self.manga.total_volumes intValue]) {
        self.manga.current_volume = @([self.manga.current_volume intValue] + 1);
        self.originalCurrentEpisode = self.manga.current_volume;
        
        if([self.manga.current_volume intValue] == [self.manga.total_volumes intValue] && [self.manga.read_status intValue] != MangaReadStatusCompleted) {
            // Set scroller to completed.
            
            self.manga.read_status = @(MangaReadStatusCompleted);
            [self configureStatusAnimated:YES];
        }
    }
    
    [self configureProgressLabel];
}

- (IBAction)removeItemButtonPressed:(id)sender {
    if([self.manga.current_volume intValue] > 0) {
        self.manga.current_volume = @([self.manga.current_volume intValue] - 1);
        self.originalCurrentEpisode = self.manga.current_volume;
        
        if([self.manga.current_volume intValue] < [self.manga.total_volumes intValue] && [self.manga.read_status intValue] == MangaReadStatusCompleted) {
            // Set scroller to currently watching, if we're coming back from completed.
            
            self.manga.read_status = @(MangaReadStatusReading);
            [self configureStatusAnimated:YES];
        }
    }
    
    [self configureProgressLabel];
}

- (IBAction)addSecondaryItemButtonPressed:(id)sender {
    if([self.manga.total_chapters intValue] == 0) {
        self.manga.current_chapter = @([self.manga.current_chapter intValue] + 1);
    }
    else if([self.manga.current_chapter intValue] < [self.manga.total_chapters intValue]) {
        self.manga.current_chapter = @([self.manga.current_chapter intValue] + 1);
        self.originalCurrentEpisode = self.manga.current_chapter;
        
        
        if([self.manga.current_chapter intValue] == [self.manga.total_chapters intValue] && [self.manga.read_status intValue] != MangaReadStatusCompleted) {
            // Set scroller to completed.
            
            self.manga.read_status = @(MangaReadStatusCompleted);
            [self configureStatusAnimated:YES];
        }
    }
    
    [self configureProgressLabel];
}

- (IBAction)removeSecondaryItemButtonPressed:(id)sender {
    if([self.manga.current_chapter intValue] > 0) {
        self.manga.current_chapter = @([self.manga.current_chapter intValue] - 1);
        self.originalCurrentEpisode = self.manga.current_chapter;
        
        if([self.manga.current_chapter intValue] < [self.manga.total_chapters intValue] && [self.manga.read_status intValue] == MangaReadStatusCompleted) {
            // Set scroller to currently watching, if we're coming back from completed.
            
            self.manga.read_status = @(MangaReadStatusReading);
            [self configureStatusAnimated:YES];
        }
    }
    
    [self configureProgressLabel];
}

- (IBAction)startDateButtonPressed:(id)sender {
    self.datePicker.date = self.manga.user_date_start;
    [super startDateButtonPressed:sender];
}

- (IBAction)endDateButtonPressed:(id)sender {
    self.datePicker.date = self.manga.user_date_finish;
    [super endDateButtonPressed:sender];
}

#pragma mark - Data Methods

- (void)save:(id)sender {
    ALLog(@"Saving...");
    
    [[AnalyticsManager sharedInstance] trackEvent:kSaveMangaDetailsPressed forCategory:EventCategoryAction withMetadata:[self.manga.manga_id stringValue]];
    
    self.saving = YES;
    
    [self.manga.managedObjectContext save:nil];
    
    if(self.addMangaToList) {
        
        [[AnalyticsManager sharedInstance] trackEvent:kMangaAdded forCategory:EventCategoryAction withMetadata:[self.manga.manga_id stringValue]];
        
        [[MALHTTPClient sharedClient] addMangaToListWithID:self.manga.manga_id success:^(id operation, id response) {
            ALLog(@"Added manga to list! Returning to manga details view.");
        } failure:^(id operation, NSError *error) {
            ALLog(@"Failed to update.");
        }];
    }
    else {
        
        [[AnalyticsManager sharedInstance] trackEvent:kMangaUpdated forCategory:EventCategoryAction withMetadata:[self.manga.manga_id stringValue]];
        
        [[MALHTTPClient sharedClient] updateDetailsForMangaWithID:self.manga.manga_id success:^(id operation, id response) {
            ALLog(@"Updated. Returning to manga details view.");
        } failure:^(id operation, NSError *error) {
            ALLog(@"Failed to update.");
        }];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setOriginalValues {
    
}

- (void)revertValuesToDefault {
    
}

#pragma mark - AniListDatePickerViewDelegate Methods

- (void)dateSelected:(NSDate *)date forType:(AniListDatePickerViewType)datePickerType {
    [super dateSelected:date forType:datePickerType];
    
    switch (datePickerType) {
        case AniListDatePickerStartDate:
            self.manga.user_date_start = date;
            self.originalStartDate = self.manga.user_date_start;
            [self.startDateButton setTitle:[self startDateStringWithDate:self.manga.user_date_start] forState:UIControlStateNormal];
            break;
        case AniListDatePickerEndDate:
            self.manga.user_date_finish = date;
            self.originalEndDate = self.manga.user_date_finish;
            [self.endDateButton setTitle:[self finishDateStringWithDate:self.manga.user_date_finish] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - AniListScoreViewDelegate Methods

- (void)scoreUpdated:(NSNumber *)number {
    self.manga.user_score = number;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Calculate the page that we're currently looking at, and then fetch the appropriate status.
    int page = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    ALLog(@"Current page: %d", page);
    self.manga.read_status = mangaStatusOrder[page];
    
    [self revertValuesToDefault];
    
#warning - figure this out later.
//    switch ([self.manga.read_status intValue]) {
//        case MangaReadStatusCompleted: {
//            if(!self.manga.user_date_finish) {
//                self.manga.user_date_finish = [NSDate date];
//            }
//            self.manga.current_episode = self.manga.total_episodes;
//            break;
//        }
//        case AnimeWatchedStatusWatching: {
//            if(!self.anime.user_date_start) {
//                self.anime.user_date_start = [NSDate date];
//            }
//            break;
//        }
//        case AnimeWatchedStatusDropped:
//        case AnimeWatchedStatusOnHold:
//        case AnimeWatchedStatusPlanToWatch:
//        default:
//            break;
//    }
    
    [self updateLabels];
}

@end
