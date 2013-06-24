//
//  MangaUserInfoViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaUserInfoViewController.h"
#import "Manga.h"

@interface MangaUserInfoViewController ()

@end

@implementation MangaUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupLabels];
}

- (void)setupLabels {
    UILabel *watchingStatusLabel = [self labelForView:self.seriesStatusView];
    UILabel *startDate = [self labelForView:self.startDateView];
    UILabel *endDate = [self labelForView:self.endDateView];
    UILabel *progressLabel = [self labelForView:self.progressView];
    UILabel *scoreLabel = [self labelForView:self.scoreView];
    
    if(self.manga.read_status) {
        // If we're coming from the Search view, we should just show a single string
        // to inquire the user for adding the anime to their list.
        if([self.manga.read_status intValue] == MangaReadStatusNotReading) {
            startDate.hidden = YES;
            endDate.hidden = YES;
            progressLabel.hidden = YES;
            scoreLabel.hidden = YES;
            
            watchingStatusLabel.frame = self.view.bounds;
            watchingStatusLabel.text = [Manga stringForMangaReadStatus:[self.manga.read_status intValue] forMangaType:[self.manga.type intValue]];
            watchingStatusLabel.font = [UIFont mediumFontWithSize:18];
        }
        else {
            // Multiple scenarios for these strings.
            startDate.hidden = NO;
            endDate.hidden = NO;
            progressLabel.hidden = NO;
            scoreLabel.hidden = NO;
            
            // 320, 40
            watchingStatusLabel.frame = CGRectMake(0, 0, 320, 40);
            watchingStatusLabel.text = [Manga stringForMangaReadStatus:[self.manga.read_status intValue] forMangaType:[self.manga.type intValue]];;
            watchingStatusLabel.font = [UIFont mediumFontWithSize:16];
            
            if(self.manga.user_date_start) {
                startDate.text = [NSString stringWithFormat:@"Started on %@", [self.manga.user_date_start stringValue]];
            }
            else {
                startDate.text = @"When did you start reading?";
            }
            
            if(self.manga.user_date_finish) {
                endDate.text = [NSString stringWithFormat:@"Finished on %@", [self.manga.user_date_finish stringValue]];
            }
            else {
                endDate.text = @"When did you finish?";
            }
            
            if([self.manga.user_score intValue] > 0) {
                scoreLabel.text = [NSString stringWithFormat:@"You gave this a %d.", [self.manga.user_score intValue]];
            }
            else {
                scoreLabel.text = @"Not scored yet";
            }
            
            progressLabel.text = [NSString stringWithFormat:@"On chapter %d of %d", [self.manga.current_chapter intValue], [self.manga.total_chapters intValue]];
        }
    }
}

#pragma mark - Setter Methods

- (void)setManga:(Manga *)manga {
    _manga = manga;
    
    [self setupLabels];
}

@end
