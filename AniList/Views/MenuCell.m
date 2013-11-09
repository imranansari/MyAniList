//
//  MenuCell.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MenuCell.h"

@interface MenuCell()
@property (nonatomic, strong) UIView *indicatorView;
@end

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.textLabel.font = [UIFont defaultFontWithSize:18];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        UIView *select = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, [MenuCell cellHeight])];
        select.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.05f];
        self.selectedBackgroundView = select;
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(230, ([MenuCell cellHeight] - 20.0f) / 2.0f, 20.0f, 20.0f)];
        accessoryView.backgroundColor = [UIColor defaultBackgroundColor];
        
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:accessoryView.bounds];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.font = [UIFont defaultFontWithSize:14];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        
        [accessoryView addSubview:numberLabel];
        
        self.indicatorView = accessoryView;
        self.indicatorView.alpha = 0.5f;
        self.indicatorView.hidden = YES;
        
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return 40;
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

- (void)setCellValue:(NSInteger)cellValue {
    if(cellValue == 0) {
        self.indicatorView.hidden = YES;
    }
    else {
        self.indicatorView.hidden = NO;
    }

    for(UIView *view in self.indicatorView.subviews) {
        if([view isKindOfClass:[UILabel class]]) {
            ((UILabel *)view).text = [NSString stringWithFormat:@"%d", cellValue];
            break;
        }
    }
}

@end
