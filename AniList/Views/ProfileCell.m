//
//  ProfileCell.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "ProfileCell.h"

@implementation ProfileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        selectedBackgroundView.backgroundColor = [UIColor defaultBackgroundColor];
        
        self.selectedBackgroundView = selectedBackgroundView;

        self.username.textColor = [UIColor whiteColor];
        self.animeStats.textColor = [UIColor whiteColor];
        self.mangaStats.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return 90;
}

+ (NSString *)cellID {
    return @"ProfileCell";
}

@end
