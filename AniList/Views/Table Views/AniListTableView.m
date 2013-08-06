//
//  AniListTableView.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListTableView.h"

#define DEFAULT_OFFSET  44

@implementation AniListTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        
        int frameOffset = [UIApplication isiOS7] ? 0 : 10;
        
        self.frame = CGRectMake(self.frame.origin.x - frameOffset,
                                self.frame.origin.y + DEFAULT_OFFSET,
                                self.frame.size.width + (frameOffset * 2),
                                self.frame.size.height - DEFAULT_OFFSET);
        self.backgroundView = nil;
        self.separatorColor = [UIColor grayColor];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
