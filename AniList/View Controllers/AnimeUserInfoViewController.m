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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.anime.watched_status && [self.anime.watched_status intValue] != AnimeWatchedStatusUnknown) {
        UILabel *watchingStatusLabel = [self labelForView:self.watchingStatusView];
        watchingStatusLabel.text = [Anime stringForAnimeWatchedStatus:[self.anime.watched_status intValue]];
    }
    
    if(self.anime.user_date_start) {
        UILabel *startDate = [self labelForView:self.startDateView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayPickerOfType:(AnimePickerTypes)pickerType {
    switch(pickerType) {
        case AnimePickerWatchingStatus:
            break;
        case AnimePickerStartDate:
            break;
        case AnimePickerEndDate:
            break;
        case AnimePickerProgress:
            break;
        case AnimePickerScore:
            break;
        default:
            break;
    }
}

- (UILabel *)labelForView:(UIView *)view {
    for(UIView *subview in view.subviews) {
        if([subview isMemberOfClass:[UILabel class]]) {
            return (UILabel *)subview;
        }
    }
    
    return nil;
}

@end
