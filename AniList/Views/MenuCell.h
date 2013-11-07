//
//  MenuCell.h
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MenuCell : UITableViewCell

@property (nonatomic, assign) NSInteger cellValue;

+ (CGFloat)cellHeight;
- (void)addGradient;

@end
