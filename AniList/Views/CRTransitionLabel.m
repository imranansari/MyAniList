//
//  CRTransitionLabel.m
//  AniList
//
//  Created by Corey Roberts on 7/13/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "CRTransitionLabel.h"

@interface CRTransitionLabel()
@property (nonatomic, strong) UILabel *firstLabel;
@property (nonatomic, strong) UILabel *secondLabel;
@end

@implementation CRTransitionLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return [self initWithFrame:self.frame];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.firstLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.secondLabel = [[UILabel alloc] initWithFrame:self.bounds];
        
        self.firstLabel.font = self.secondLabel.font = self.font;
        self.firstLabel.textColor = self.secondLabel.textColor = self.textColor;
        self.firstLabel.shadowColor = self.secondLabel.shadowColor = self.shadowColor;
        self.firstLabel.shadowOffset = self.secondLabel.shadowOffset = self.shadowOffset;
        self.firstLabel.textAlignment = self.secondLabel.textAlignment = self.textAlignment;
        self.backgroundColor = [UIColor clearColor];
        
        [self addShadow];
        
        self.transitionRate = 0.3f;
        
        [self addSubview:self.firstLabel];
        [self addSubview:self.secondLabel];
    }
    return self;
}

#pragma mark - UILabel Overridden Methods

- (void)setFont:(UIFont *)font {
    self.firstLabel.font = self.secondLabel.font = font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    self.firstLabel.textAlignment = self.secondLabel.textAlignment = textAlignment;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.firstLabel.backgroundColor = self.secondLabel.backgroundColor = backgroundColor;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.firstLabel.bounds = self.secondLabel.bounds = frame;
}

- (void)setTextColor:(UIColor *)textColor {
    self.firstLabel.textColor = self.secondLabel.textColor = textColor;
}

- (void)setShadowColor:(UIColor *)shadowColor {
    self.firstLabel.shadowColor = self.secondLabel.shadowColor = shadowColor;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    self.firstLabel.shadowOffset = self.secondLabel.shadowOffset = shadowOffset;
}

- (void)setText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [super setText:@""];
        
        if(self.firstLabel.text.length == 0) {
            self.firstLabel.text = text;
            self.firstLabel.alpha = 1.0f;
            self.secondLabel.alpha = 0.0f;
        }
        // String is the same, no need to animate.
        else if([self.firstLabel.text isEqualToString:text] || [self.secondLabel.text isEqualToString:text] || text.length == 0) {
            return;
        }
        else {
            self.secondLabel.text = text;
            
            [UIView animateWithDuration:self.transitionRate
                                  delay:0.0f
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.firstLabel.alpha = 0.0f;
                                 self.secondLabel.alpha = 1.0f;
                             }
                             completion:^(BOOL finished) {
                                 if(finished) {

                                     // If too many requests come in, this text label can get to 0.
                                     // Any way of keeping track of animations? Wrap in a queue maybe?
                                     if(self.secondLabel.text.length == 0) {
                                         self.secondLabel.text = text;
                                     }
                                     
                                     self.firstLabel.text = self.secondLabel.text;
                                     self.secondLabel.text = @"";
                                     self.firstLabel.alpha = 1.0f;
                                     self.secondLabel.alpha = 0.0f;
                                 }
                             }];
        }
    });
}

#pragma mark - Public Setters

- (void)setTransitionRate:(float)transitionRate {
    _transitionRate = transitionRate < 0.0f ? 0.0f : transitionRate;
}

@end
