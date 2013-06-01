//
//  AniNavigationBar.m
//  AniList
//
//  Created by Corey Roberts on 4/19/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniNavigationBar.h"

@implementation AniNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        self.rightbutton = [[UIButton alloc] initWithFrame:CGRectMake(280, 0, 40, 44)];
        self.barTitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 0, 224, 44)];
        
        self.barTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        self.barTitle.textColor = [UIColor whiteColor];
        self.barTitle.textAlignment = UITextAlignmentCenter;
        self.barTitle.numberOfLines = 2;
        self.barTitle.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.leftButton];
        [self addSubview:self.rightbutton];
        [self addSubview:self.barTitle];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
    // Drawing code
//}

@end
