//
//  AniListUserInfoEditViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListUserInfoEditViewController.h"
#import "AniListScoreView.h"

@interface AniListUserInfoEditViewController ()
@property (nonatomic, weak) IBOutlet UIScrollView *statusScrollView;
@property (nonatomic, weak) IBOutlet UIButton *startDateButton;
@property (nonatomic, weak) IBOutlet UIButton *endDateButton;
@property (nonatomic, strong) IBOutlet AniListScoreView *scoreView;

@end

@implementation AniListUserInfoEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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

@end
