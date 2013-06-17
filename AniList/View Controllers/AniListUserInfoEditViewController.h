//
//  AniListUserInfoEditViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AniListDatePickerView.h"

@class Anime;
@class AniListScoreView;

@interface AniListUserInfoEditViewController : UIViewController<AniListDatePickerViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *statusScrollView;
@property (nonatomic, weak) IBOutlet UIButton *startDateButton;
@property (nonatomic, weak) IBOutlet UIButton *endDateButton;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIButton *addItemButton;
@property (nonatomic, weak) IBOutlet UIButton *removeItemButton;
@property (nonatomic, strong) IBOutlet AniListScoreView *scoreView;
@property (nonatomic, strong) Anime *anime;

- (IBAction)addItemButtonPressed:(id)sender;
- (IBAction)removeItemButtonPressed:(id)sender;
- (IBAction)startDateButtonPressed:(id)sender;
- (IBAction)endDateButtonPressed:(id)sender;
- (void)save:(id)sender;

@end
