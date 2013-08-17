//
//  MenuCell.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.textLabel.font = [UIFont defaultFontWithSize:18];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        UIView *select = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 44)];
        select.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.05f];
        self.selectedBackgroundView = select;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return 44;
}

- (void)addGradient {
    UIColor *gradientTop = [UIColor colorWithWhite:0.1 alpha:1];
    UIColor *gradientBottom = [UIColor colorWithWhite:0.13 alpha:0.5];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[gradientTop CGColor], (id)[gradientBottom CGColor], nil];
    gradient.opacity = 1;
    
    UIView *background = [[UIView alloc] initWithFrame:self.frame];
    [background.layer insertSublayer:gradient atIndex:0];

    self.backgroundView = background;
}

@end
