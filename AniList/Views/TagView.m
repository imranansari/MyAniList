//
//  TagView.m
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "TagView.h"
#import "Tag.h"

#define MAX_WIDTH           300
#define TAG_WIDTH_PADDING   5
#define TAG_HEIGHT_PADDING  5
#define TAG_HEIGHT          40

@implementation TagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)createTags:(NSSet *)tags {
    for(UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    UILabel *header = [UILabel whiteHeaderWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60) andFontSize:18];
    header.text = @"Tags";
    
    [self addSubview:header];
    
    NSMutableArray *tagViews = [NSMutableArray array];
    
    int counter = 1;
    for(Tag *tag in tags) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        [button setTitle:tag.name forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont defaultFontWithSize:14];
        [button setTitleShadowColor:[UIColor defaultShadowColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.1f]];
        [button sizeToFit];
        button.tag = counter++;
        button.frame = CGRectMake(0, counter*(TAG_HEIGHT+1), button.frame.size.width+10, TAG_HEIGHT);
        ALLog(@"Frame: %f, %f, %f, %f", button.frame.origin.x, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
        [tagViews addObject:button];
        
        [self addSubview:button];
    }
    
    // Now, arrange the tags so that they fit in multiple lines.
    // Keep track of which line we're on.
    int currentLineIndex = 0;
    int widthPadding = ([UIScreen mainScreen].bounds.size.width - MAX_WIDTH) / 2;
    int currentWidthPlacement = widthPadding;
    
    for(UIButton *button in tagViews) {
        ALLog(@"Current line index: %d", currentLineIndex);
        ALLog(@"Current width placement: %d", currentWidthPlacement);
        if(currentWidthPlacement + button.frame.size.width + TAG_WIDTH_PADDING < MAX_WIDTH + widthPadding) {
            ALLog(@"Tag '%@' will be placed on line %d, starting at %d.", button.titleLabel.text, currentLineIndex, currentWidthPlacement);
            button.frame = CGRectMake(currentWidthPlacement, currentLineIndex * (TAG_HEIGHT_PADDING + TAG_HEIGHT), button.frame.size.width, button.frame.size.height);
            currentWidthPlacement += button.frame.size.width + TAG_WIDTH_PADDING;
        }
        else {
            // Tag would extend beyond the bounds, so push it off onto the next line.
            currentLineIndex++;
            ALLog(@"Tag '%@' extends beyond this line, so it will now be placed on line %d.", button.titleLabel.text, currentLineIndex);
            currentWidthPlacement = widthPadding + button.frame.size.width + TAG_WIDTH_PADDING;
            button.frame = CGRectMake(widthPadding, currentLineIndex * (TAG_HEIGHT + TAG_HEIGHT_PADDING), button.frame.size.width, button.frame.size.height);
        }
        
        // Bump everything down by 60 so the header above can fit.
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y + 60, button.frame.size.width, button.frame.size.height);
    }
}

@end
