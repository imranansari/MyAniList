//
//  UIFont+AniList.m
//  AniList
//
//  Created by Corey Roberts on 4/16/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UIFont+AniList.h"

#define kDefaultFont @"HelveticaNeue-Light"
#define kMediumFont  @"HelveticaNeue-Medium"

@implementation UIFont (AniList)

+ (UIFont *)defaultFont {
    return [UIFont fontWithName:kDefaultFont size:12];
}

+ (UIFont *)defaultFontWithSize:(int)size {
    return [UIFont fontWithName:kDefaultFont size:size];
}

+ (UIFont *)mediumFont {
    return [UIFont fontWithName:kMediumFont size:12];
}

+ (UIFont *)mediumFontWithSize:(int)size {
    return [UIFont fontWithName:kMediumFont size:size];
}

@end
