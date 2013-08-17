//
//  UIView+AniList.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AniList)

+ (UIView *)tableHeaderWithPrimaryText:(NSString *)primaryString andSecondaryText:(NSString *)secondaryString;
- (void)animateOut;
- (void)animateIn;

@end
