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
    // Do any additional setup after loading the view from its nib.
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

@end
