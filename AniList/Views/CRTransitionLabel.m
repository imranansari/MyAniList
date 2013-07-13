//
//  CRTransitionLabel.m
//  AniList
//
//  Created by Corey Roberts on 7/13/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

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
        
        self.firstLabel.backgroundColor = self.backgroundColor;
        self.secondLabel.backgroundColor = self.backgroundColor;
        
        self.firstLabel.font = self.secondLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        
        self.firstLabel.textColor = self.secondLabel.textColor = [UIColor lightGrayColor];
        
        self.firstLabel.textAlignment = self.secondLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.firstLabel addShadow];
        [self.secondLabel addShadow];
        
        _text = @"";
        self.transitionRate = 0.3f;
        
        [self addSubview:self.firstLabel];
        [self addSubview:self.secondLabel];
    }
    return self;
}

- (void)setText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.firstLabel.text.length == 0) {
            self.firstLabel.text = text;
            self.firstLabel.alpha = 1.0f;
            self.secondLabel.alpha = 0.0f;
        }
        // String is the same, no need to animate.
        else if([self.firstLabel.text isEqualToString:text] || [self.secondLabel.text isEqualToString:text]) {
            return;
        }
        else {
            self.secondLabel.text = text;
            
            [UIView animateWithDuration:self.transitionRate
                             animations:^{
                                 self.firstLabel.alpha = 0.0f;
                                 self.secondLabel.alpha = 1.0f;
                                 
//                                 NSLog(@"alpha: %f | %f", self.firstLabel.alpha, self.secondLabel.alpha);
                             }
                             completion:^(BOOL finished) {
                                 if(finished) {
                                     self.firstLabel.text = self.secondLabel.text;
                                     self.secondLabel.text = @"";
                                     self.firstLabel.alpha = 1.0f;
                                     self.secondLabel.alpha = 0.0f;
//                                     NSLog(@"completed alpha: %f | %f", self.firstLabel.alpha, self.secondLabel.alpha);
                                 }
                             }];
        }
    });
}

@end
