//
//  AniListTableHeaderView.m
//  AniList
//
//  Created by Corey Roberts on 11/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListTableHeaderView.h"

@interface AniListTableHeaderView()
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, strong) UIImageView *chevron;
@end

@implementation AniListTableHeaderView

- (id)initWithFrame:(CGRect)frame {
    return [self initWithPrimaryText:@"" andSecondaryText:@""];
}

- (id)initWithPrimaryText:(NSString *)primaryText andSecondaryText:(NSString *)secondaryText {
    self = [super initWithFrame:CGRectMake(20, 0, 300, 44)];
    if(self) {
        UIView *view = [UIView tableHeaderWithPrimaryText:primaryText andSecondaryText:secondaryText];
        
        self.chevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron.png"]];
        [view addSubview:self.chevron];
        self.chevron.frame = CGRectMake(view.frame.size.width - 50, view.frame.size.height / 2 - self.chevron.frame.size.height / 2 + 1, self.chevron.frame.size.width, self.chevron.frame.size.height);
        
        [self addSubview:view];
    }
    
    return self;
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
