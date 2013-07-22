//
//  UIButton+AniList.m
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UIButton+AniList.h"

#define TAG_HEIGHT          40

@implementation UIButton (AniList)

+ (UIButton *)tagButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont defaultFontWithSize:14];
    [button setTitleShadowColor:[UIColor defaultShadowColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.1f]];
    [button sizeToFit];

    button.frame = CGRectMake(0, 0, button.frame.size.width+10, TAG_HEIGHT);
    
    return button;
}

@end
