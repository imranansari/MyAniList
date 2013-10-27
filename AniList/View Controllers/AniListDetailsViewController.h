//
//  AniListDetailsViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CRTransitionLabel.h"
#import "FICImageCache.h"

@interface AniListDetailsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *poster;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *type;
@property (nonatomic, weak) IBOutlet UILabel *seriesStatus;

@property (nonatomic, weak) IBOutlet UIView *detailView;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *score;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *totalPeopleScored;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *rank;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *popularity;
@property (nonatomic, weak) IBOutlet UILabel *errorMessageLabel;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

- (void)displayDetailsViewAnimated:(BOOL)animated;
- (void)displayErrorMessage;
- (void)updatePoster __deprecated_msg("Deprecated in favor for setupPosterForObject:");
- (void)setupPosterForObject:(NSManagedObject<FICEntity> *)object;

@end
