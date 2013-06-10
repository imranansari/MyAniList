//
//  SynopsisView.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "SynopsisView.h"

@interface SynopsisView()
@property (nonatomic, strong) UILabel *synopsis;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation SynopsisView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounds = self.frame = CGRectMake(0, 0, 320, 44);
        
        self.synopsis = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 100)];
        self.synopsis.alpha = 0.0f;
        self.synopsis.backgroundColor = [UIColor clearColor];
        
        self.synopsis.textColor = [UIColor whiteColor];
        self.synopsis.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        self.synopsis.numberOfLines = 0;
        self.synopsis.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        [self.indicator startAnimating];
        
        [self addSubview:self.synopsis];
        [self addSubview:self.indicator];
    }
    return self;
}

- (id)initWithSynopsis:(NSString *)synopsis {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)addSynopsis:(NSString *)synopsis {
    
    self.synopsis.text = synopsis;

#warning - iOS 5 does some goofy stuff with this.
    [self.synopsis sizeToFit];
    
    if([synopsis isEqualToString:kNoSynopsisString]) {
        self.synopsis.frame = CGRectMake(0, self.synopsis.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.synopsis.frame.size.height);
        self.synopsis.textAlignment = NSTextAlignmentCenter;
    }
    
    self.synopsis.frame = CGRectMake(self.synopsis.frame.origin.x, self.synopsis.frame.origin.y, self.synopsis.frame.size.width, self.synopsis.frame.size.height);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.synopsis.frame.size.width, self.synopsis.frame.size.height);
    
    [self setNeedsDisplay];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.synopsis.alpha = 1.0f;
                         self.indicator.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator removeFromSuperview];
                     }];
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
