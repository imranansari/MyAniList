//
//  AniListTableHeaderView.m
//  AniList
//
//  Created by Corey Roberts on 11/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListTableHeaderView.h"
#import "TTTAttributedLabel.h"

@interface AniListTableHeaderView()
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, strong) UIImageView *chevron;
@property (nonatomic, strong) TTTAttributedLabel *label;
@end

@implementation AniListTableHeaderView

- (id)initWithFrame:(CGRect)frame {
    return [self initWithPrimaryText:@"" andSecondaryText:@""];
}

- (id)initWithPrimaryText:(NSString *)primaryText andSecondaryText:(NSString *)secondaryText {
    self = [super initWithFrame:CGRectMake(0, 0, 300, 44)];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 0, 300, 44)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.text = [NSString stringWithFormat:@"%@ (%@)", primaryText, secondaryText];
        
        self.primaryText = primaryText;
        self.secondaryText = secondaryText;
        
        [self addSubview:self.label];
        
        self.chevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron.png"]];
        [self addSubview:self.chevron];
        self.chevron.frame = CGRectMake(self.frame.size.width - 10, self.frame.size.height / 2 - self.chevron.frame.size.height / 2 + 1, self.chevron.frame.size.width, self.chevron.frame.size.height);
    }
    
    return self;
}

- (void)setPrimaryText:(NSString *)primaryText {
    _primaryText = primaryText;
    [UILabel setAttributesForLabel:self.label withPrimaryText:primaryText andSecondaryText:[NSString stringWithFormat:@"(%@)", self.secondaryText]];
}

- (void)setSecondaryText:(NSString *)secondaryText {
    _secondaryText = secondaryText;
    [UILabel setAttributesForLabel:self.label withPrimaryText:self.primaryText andSecondaryText:[NSString stringWithFormat:@"(%@)", secondaryText]];
}


- (id)initWithPrimaryText:(NSString *)primaryText andSecondaryText:(NSString *)secondaryText isExpanded:(BOOL)expanded {
    self = [self initWithPrimaryText:primaryText andSecondaryText:secondaryText];
    if(self) {
        self.expanded = expanded;
        [self expand:self.expanded animated:NO];
    }
    
    return self;
}

- (void)expand {
    [self expand:!self.expanded];
}

- (void)expand:(BOOL)expand {
    [self expand:expand animated:YES];
}

- (void)expand:(BOOL)expand animated:(BOOL)animated {
    self.expanded = expand;
    float duration = animated ? 0.3f : 0.0f;
    
	CGFloat rotation = !self.expanded ? 0 : M_PI/2;
	[UIView animateWithDuration:duration
                          delay:0
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.chevron.transform = CGAffineTransformMakeRotation(rotation);
					 }
					 completion:^(BOOL finished) {}];
}

@end
