//
//  UIBarButtonItem+AniList.m
//  AniList
//
//  Created by Corey Roberts on 7/14/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UIBarButtonItem+AniList.h"

@implementation UIBarButtonItem (AniList)

+ (UIBarButtonItem *)customBackButtonWithTitle:(NSString *)title {
    return [[UIBarButtonItem alloc] initWithTitle:title
                                            style:UIBarButtonItemStyleBordered
                                           target:nil
                                           action:nil];
    
}

@end
