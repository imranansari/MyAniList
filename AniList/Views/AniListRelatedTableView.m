//
//  AniListRelatedTableView.m
//  AniList
//
//  Created by Corey Roberts on 7/19/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListRelatedTableView.h"

@implementation AniListRelatedTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.separatorColor = [UIColor clearColor];
        self.scrollEnabled = NO;
    }
    return self;
}

@end
