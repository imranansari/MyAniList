//
//  AniListMiniCell.h
//  AniList
//
//  Created by Corey Roberts on 7/19/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AniListMiniCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *progress;
@property (nonatomic, weak) IBOutlet UILabel *type;
@property (nonatomic, weak) IBOutlet UILabel *rank;
@property (nonatomic, weak) IBOutlet UIView *loadingView;

- (void)setup;
+ (CGFloat)cellHeight;
- (void)addShadow;
- (void)setImageWithItem:(NSManagedObject *)object;

@end
