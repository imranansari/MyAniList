//
//  UIColor+AniList.m
//  AniList
//
//  Created by Corey Roberts on 6/10/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UIColor+AniList.h"

@implementation UIColor (AniList)

+ (UIColor *)defaultBackgroundColor {
    return [UIColor colorWithWhite:1.0f alpha:0.1f];
}

+ (UIColor *)subtleBlueColor {
    return [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.05f];
}

+ (UIColor *)defaultShadowColor {
    return [UIColor colorWithWhite:0.0f alpha:0.5f];
}

+ (UIColor *)iOS7TintColor {
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

@end
