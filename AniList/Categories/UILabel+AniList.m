//
//  UILabel+AniList.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UILabel+AniList.h"

@implementation UILabel (AniList)

+ (UILabel *)whiteLabelWithFrame:(CGRect)frame andFontSize:(int)size {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont defaultFontWithSize:size];
    label.backgroundColor = [UIColor clearColor];
    [label addShadow];
    label.shadowOffset = CGSizeMake(0, 1);
    
    return label;
}

+ (UILabel *)whiteHeaderWithFrame:(CGRect)frame andFontSize:(int)size {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont defaultFontWithSize:size];
    label.backgroundColor = [UIColor clearColor];
    [label addShadow];
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header_bg.png"]];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void)addShadow {
//    self.shadowColor = [UIColor defaultShadowColor];
//    self.shadowOffset = CGSizeMake(0, 1);
}

@end
