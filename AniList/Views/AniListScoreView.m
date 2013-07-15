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
#define DEFAULT_ALPHA           0.3f
#define SELECTED_ALPHA          1.0f

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
            numberButton.tag = i+1; // Button tag is the value of the label.
            [numberButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            RRSGlowLabel *numberLabel = [[RRSGlowLabel alloc] initWithFrame:numberButton.bounds];
            numberLabel.text = [NSString stringWithFormat:@"%d", i+1];
            numberLabel.textColor = [UIColor whiteColor];
            numberLabel.alpha = DEFAULT_ALPHA;
            numberLabel.backgroundColor = [UIColor clearColor];
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.font = [UIFont defaultFontWithSize:24];
            [numberLabel addShadow];
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

#pragma mark - Public Methods

- (void)updateScore:(NSNumber *)score {
    for(UIView *subview in self.subviews) {
        if([subview isMemberOfClass:[UIButton class]] && subview.tag == [score intValue]) {
            [self buttonPressed:subview];
        }
    }

}

#pragma mark - Button Methods

- (void)buttonPressed:(id)sender {
    ALLog(@"Number pressed.");
    
    UIButton *button = (UIButton *)sender;
    UILabel *selectedLabel;
    
    for(UIView *subview in button.subviews) {
        if(subview.tag == 1) {
            selectedLabel = (UILabel *)subview;
            ALLog(@"Found %@ as the updated score.", selectedLabel.text);
            [UIView animateWithDuration:0.2f animations:^{
                // This is the selected score. Pass value to delegate if possible.
                selectedLabel.alpha = SELECTED_ALPHA;
                NSNumber *value = @([selectedLabel.text intValue]);
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(scoreUpdated:)]) {
                    [self.delegate scoreUpdated:value];
                }
            }];
        }
    }
    
    for(UIView *subview in self.subviews) {
        if([subview isMemberOfClass:[UIButton class]]) {
            for(UIView *buttonSubview in subview.subviews) {
                if(buttonSubview.tag == 1 && buttonSubview != selectedLabel) {
                    UILabel *label = (UILabel *)buttonSubview;
                    [UIView animateWithDuration:0.2f animations:^{
                        label.alpha = DEFAULT_ALPHA;
                    }];
                }
            }
        }
    }
}

@end
