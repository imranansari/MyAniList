//
//  TagView.m
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "TagView.h"
#import "Tag.h"
#import "Genre.h"

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

- (void)createGenreTags:(NSSet *)genreTags {
    // No tags = no view to create! Whomp whomp.
    if(genreTags.count == 0) return;
    
    for(UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    UILabel *header = [UILabel whiteHeaderWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60) andFontSize:18];
    header.text = @"Genres";
    
    [self addSubview:header];
    
    NSMutableArray *tagViews = [NSMutableArray array];
    
    for(Genre *genre in genreTags) {
        UIButton *button = [UIButton tagButtonWithTitle:genre.name];
        [button addTarget:self action:@selector(genreTapped:) forControlEvents:UIControlEventTouchUpInside];
        //        ALLog(@"Frame: %f, %f, %f, %f", button.frame.origin.x, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
        [tagViews addObject:button];
        
        [self addSubview:button];
    }
    
    [self arrangeTags:tagViews];
}

- (void)createTags:(NSSet *)tags {
    // No tags = no view to create! Whomp whomp.
    if(tags.count == 0) return;
    
    for(UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    UILabel *header = [UILabel whiteHeaderWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60) andFontSize:18];
    header.text = @"Tags";
    
    [self addSubview:header];
    
    NSMutableArray *tagViews = [NSMutableArray array];
    
    for(Tag *tag in tags) {
        UIButton *button = [UIButton tagButtonWithTitle:tag.name];
        [button addTarget:self action:@selector(tagTapped:) forControlEvents:UIControlEventTouchUpInside];
//        ALLog(@"Frame: %f, %f, %f, %f", button.frame.origin.x, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
        [tagViews addObject:button];
        
        [self addSubview:button];
    }
    
    [self arrangeTags:tagViews];
}

- (void)arrangeTags:(NSArray *)tags {
    // Now, arrange the tags so that they fit in multiple lines.
    // Keep track of which line we're on.
    int currentLineIndex = 0;
    int widthPadding = ([UIScreen mainScreen].bounds.size.width - MAX_WIDTH) / 2;
    int currentWidthPlacement = widthPadding;
    
    for(UIButton *button in tags) {
        //        ALLog(@"Current line index: %d", currentLineIndex);
        //        ALLog(@"Current width placement: %d", currentWidthPlacement);
        if(currentWidthPlacement + button.frame.size.width + TAG_WIDTH_PADDING < MAX_WIDTH + widthPadding) {
            //            ALLog(@"Tag '%@' will be placed on line %d, starting at %d.", button.titleLabel.text, currentLineIndex, currentWidthPlacement);
            button.frame = CGRectMake(currentWidthPlacement, currentLineIndex * (TAG_HEIGHT_PADDING + TAG_HEIGHT), button.frame.size.width, button.frame.size.height);
            currentWidthPlacement += button.frame.size.width + TAG_WIDTH_PADDING;
        }
        else {
            // Tag would extend beyond the bounds, so push it off onto the next line.
            currentLineIndex++;
            //            ALLog(@"Tag '%@' extends beyond this line, so it will now be placed on line %d.", button.titleLabel.text, currentLineIndex);
            currentWidthPlacement = widthPadding + button.frame.size.width + TAG_WIDTH_PADDING;
            button.frame = CGRectMake(widthPadding, currentLineIndex * (TAG_HEIGHT + TAG_HEIGHT_PADDING), button.frame.size.width, button.frame.size.height);
        }
        
        // Bump everything down by 60 so the header above can fit.
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y + 60, button.frame.size.width, button.frame.size.height);
    }
    
    // Set this view's frame accordingly.
    self.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60 + (currentLineIndex + 1) * (TAG_HEIGHT + TAG_HEIGHT_PADDING));
    self.frame = self.bounds;
}

#pragma mark - UIButton Callback Method

- (void)tagTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    ALLog(@"Tag '%@' tapped!", button.titleLabel.text);
    if(self.delegate && [self.delegate respondsToSelector:@selector(tagTappedWithTitle:)]) {
        [self.delegate tagTappedWithTitle:button.titleLabel.text];
    }
}

- (void)genreTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    ALLog(@"Genre '%@' tapped!", button.titleLabel.text);
    if(self.delegate && [self.delegate respondsToSelector:@selector(genreTappedWithTitle:)]) {
        [self.delegate genreTappedWithTitle:button.titleLabel.text];
    }
}

@end
