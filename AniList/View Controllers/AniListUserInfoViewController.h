//
//  AniListUserInfoViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AniListUserInfoViewControllerDelegate <NSObject>
- (void)userInfoPressed;
@end

@interface AniListUserInfoViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *seriesStatusView;
@property (nonatomic, weak) IBOutlet UIView *startDateView;
@property (nonatomic, weak) IBOutlet UIView *endDateView;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UIView *scoreView;

@property (nonatomic, assign) id<AniListUserInfoViewControllerDelegate> delegate;

- (UILabel *)labelForView:(UIView *)view;

@end
