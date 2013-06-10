//
//  AniListScoreView.m
//  AniList
//
//  Created by Corey Roberts on 6/7/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListScoreView.h"
#import "RRSGlowLabel.h"

#define NUMBER_OF_RATINGS       10
#define SIZE_OF_RATING_VIEW     [UIScreen mainScreen].bounds.size.width / NUMBER_OF_RATINGS

@implementation AniListScoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounds = self.frame = CGRectMake(0, 0, 320, 72);
        for(int i = 0; i < NUMBER_OF_RATINGS; i++) {
            UIButton *numberButton = [[UIButton alloc] initWithFrame:CGRectMake(SIZE_OF_RATING_VIEW * i, 0, SIZE_OF_RATING_VIEW, self.frame.size.height)];
            numberButton.backgroundColor = [UIColor clearColor];
            RRSGlowLabel *numberLabel = [[RRSGlowLabel alloc] initWithFrame:numberButton.bounds];
            numberLabel.text = [NSString stringWithFormat:@"%d", i+1];
            numberLabel.textColor = [UIColor whiteColor];
            numberLabel.backgroundColor = [UIColor clearColor];
            
            [numberButton addSubview:numberLabel];
            
            [self addSubview:numberButton];
            
            if(UI_DEBUG) {
                numberButton.backgroundColor = [UIColor grayColor];
                numberLabel.backgroundColor = [UIColor darkGrayColor];
            }
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 320, 72);
        self.backgroundColor = [UIColor defaultBackgroundColor];
        
        for(int i = 0; i < NUMBER_OF_RATINGS; i++) {
            UIButton *numberButton = [[UIButton alloc] initWithFrame:CGRectMake(SIZE_OF_RATING_VIEW * i, 0, SIZE_OF_RATING_VIEW, self.frame.size.height)];
            numberButton.backgroundColor = [UIColor clearColor];
            [numberButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            RRSGlowLabel *numberLabel = [[RRSGlowLabel alloc] initWithFrame:numberButton.bounds];
            numberLabel.text = [NSString stringWithFormat:@"%d", i+1];
            numberLabel.textColor = [UIColor whiteColor];
            numberLabel.alpha = 0.5f;
            numberLabel.backgroundColor = [UIColor clearColor];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.font = [UIFont defaultFontWithSize:24];
            numberLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
            numberLabel.shadowOffset = CGSizeMake(0, 1);
            numberLabel.glowColor = [UIColor whiteColor];
            numberLabel.glowAmount = 50;
            numberLabel.tag = 1;
            
            [numberButton addSubview:numberLabel];
            
            if(UI_DEBUG) {
                numberButton.backgroundColor = [UIColor darkGrayColor];
            }
            
            [self addSubview:numberButton];
        }
    }
    return self;
}

#pragma mark - Button Methods

- (void)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    UILabel *selectedLabel;
    NSLog(@"Score pressed.");
    
    for(UIView *subview in button.subviews) {
        if(subview.tag == 1) {
            selectedLabel = (UILabel *)subview;
            NSLog(@"Found label %@.", selectedLabel.text);
            [UIView animateWithDuration:0.2f animations:^{
                selectedLabel.alpha = 1.0f;
            }];
        }
    }
    
    for(UIView *subview in self.subviews) {
        if([subview isMemberOfClass:[UIButton class]]) {
            for(UIView *buttonSubview in subview.subviews) {
                if(buttonSubview.tag == 1 && buttonSubview != selectedLabel) {
                    UILabel *label = (UILabel *)buttonSubview;
                    [UIView animateWithDuration:0.2f animations:^{
                        label.alpha = 0.5f;
                    }];
                }
            }
        }
    }
    
    // Fetch label and make it brighter.
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
