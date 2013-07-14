//
//  AniListDetailsViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AniListDetailsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *poster;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *type;
@property (nonatomic, weak) IBOutlet UILabel *seriesStatus;

@property (nonatomic, weak) IBOutlet UIView *detailView;
@property (nonatomic, weak) IBOutlet UILabel *score;
@property (nonatomic, weak) IBOutlet UILabel *totalPeopleScored;
@property (nonatomic, weak) IBOutlet UILabel *rank;
@property (nonatomic, weak) IBOutlet UILabel *popularity;
@property (nonatomic, weak) IBOutlet UILabel *errorMessageLabel;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

- (void)displayDetailsViewAnimated:(BOOL)animated;
- (void)displayErrorMessage;
- (void)adjustLabels;

- (void)updatePoster;

@end
