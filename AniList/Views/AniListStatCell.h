//
//  AniListStatCell.h
//  AniList
//
//  Created by Corey Roberts on 7/30/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AniListStatCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *progress;
@property (nonatomic, weak) IBOutlet UILabel *type;
@property (nonatomic, weak) IBOutlet UILabel *rank;
@property (nonatomic, weak) IBOutlet UILabel *average_rank;
@property (nonatomic, weak) IBOutlet UILabel *stat;
@property (nonatomic, weak) IBOutlet UIView *loadingView;

+ (CGFloat)cellHeight;
- (void)setImageWithItem:(NSManagedObject *)object;

@end
