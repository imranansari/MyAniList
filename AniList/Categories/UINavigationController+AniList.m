//
//  UINavigationController+AniList.m
//  AniList
//
//  Created by Corey Roberts on 7/14/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UINavigationController+AniList.h"

@implementation UINavigationController (AniList)

- (void)clearBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:nil
                                                                  action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
}

@end
