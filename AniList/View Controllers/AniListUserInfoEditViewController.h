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
#import "AniListScoreView.h"

@class AniListScoreView;

@interface AniListUserInfoEditViewController : UIViewController<AniListDatePickerViewDelegate, AniListScoreViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *statusScrollView;
@property (nonatomic, weak) IBOutlet UIButton *startDateButton;
@property (nonatomic, weak) IBOutlet UIButton *endDateButton;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondaryProgressLabel;
@property (nonatomic, weak) IBOutlet UIButton *addItemButton;
@property (nonatomic, weak) IBOutlet UIButton *removeItemButton;
@property (nonatomic, weak) IBOutlet UIButton *secondaryAddItemButton;
@property (nonatomic, weak) IBOutlet UIButton *secondaryRemoveItemButton;
@property (nonatomic, strong) IBOutlet AniListScoreView *scoreView;
@property (nonatomic, strong) AniListDatePickerView *datePicker;


- (NSString *)startDateStringWithDate:(NSDate *)date;
- (NSString *)finishDateStringWithDate:(NSDate *)date;
- (IBAction)addItemButtonPressed:(id)sender;
- (IBAction)removeItemButtonPressed:(id)sender;
- (IBAction)addSecondaryItemButtonPressed:(id)sender;
- (IBAction)removeSecondaryItemButtonPressed:(id)sender;
- (IBAction)startDateButtonPressed:(id)sender;
- (IBAction)endDateButtonPressed:(id)sender;
- (void)save:(id)sender;

@end
