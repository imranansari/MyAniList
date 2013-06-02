//
//  SynopsisView.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "SynopsisView.h"

@implementation SynopsisView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    
#warning - temporary, just seeing where the frame is getting set.
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
                     }
                     completion:nil];
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
