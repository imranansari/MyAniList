//
//  ProfileCell.h
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *animeStats;
@property (nonatomic, weak) IBOutlet UILabel *mangaStats;
@property (nonatomic, weak) IBOutlet UILabel *lastSeen;
@property (nonatomic, weak) IBOutlet UIImageView *avatar;

+ (CGFloat)cellHeight;
+ (NSString *)cellID;

@end
