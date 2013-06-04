//
//  SynopsisView.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "SynopsisView.h"

@interface SynopsisView()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation SynopsisView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounds = self.frame = CGRectMake(0, 0, 320, 44);
        self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        [self.indicator startAnimating];
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 100)];
    label.text = synopsis;
    label.alpha = 0.0f;
    label.backgroundColor = [UIColor clearColor];
    
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
#warning - iOS 5 does some goofy stuff with this.
    [label sizeToFit];
    
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, label.frame.size.width, label.frame.size.height);
    
    [self addSubview:label];
    
    [self setNeedsDisplay];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         label.alpha = 1.0f;
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
