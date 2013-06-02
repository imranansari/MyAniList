//
//  UILabel+AniList.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (AniList)

+ (UILabel *)whiteLabelWithFrame:(CGRect)frame andFontSize:(int)size;
+ (UILabel *)whiteHeaderWithFrame:(CGRect)frame andFontSize:(int)size;
- (void)addShadow;

@end
