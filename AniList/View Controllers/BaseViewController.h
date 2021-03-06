//
//  BaseViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/5/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SWRevealViewController.h"

@interface BaseViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL hidesBackButton;
@property (nonatomic, assign) BOOL canSwipeView;
@property (nonatomic, assign) BOOL canSwipeNavBar;

- (void)enable:(BOOL)enable;

@end
