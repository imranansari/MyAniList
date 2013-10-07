//
//  CompareCell.h
//  AniList
//
//  Created by Corey Roberts on 8/19/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompareCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *theirScore;
@property (nonatomic, weak) IBOutlet UILabel *myScore;
@property (nonatomic, weak) IBOutlet UILabel *difference;
@property (nonatomic, weak) IBOutlet UIView *loadingView;

+ (CGFloat)cellHeight;

@end
