//
//  AniListUserInfoEditViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListUserInfoEditViewController.h"
#import "AniListScoreView.h"
#import "Anime.h"

@interface AniListUserInfoEditViewController ()
@property (nonatomic, strong) IBOutlet UIScrollView *statusScrollView;
@property (nonatomic, weak) IBOutlet UIButton *startDateButton;
@property (nonatomic, weak) IBOutlet UIButton *endDateButton;
@property (nonatomic, strong) IBOutlet AniListScoreView *scoreView;
@property (nonatomic, weak) IBOutlet UIView *maskView;

@end

@implementation AniListUserInfoEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusScrollView.contentSize = CGSizeMake(self.statusScrollView.frame.size.width * 6, 1);
    self.statusScrollView.pagingEnabled = YES;
    self.statusScrollView.clipsToBounds = NO;
    self.statusScrollView.backgroundColor = [UIColor clearColor];

    for(int i = 0; i < 6; i++) {
        UILabel *label = [UILabel whiteLabelWithFrame:CGRectMake(i * self.statusScrollView.frame.size.width, 0, self.statusScrollView.frame.size.width, self.statusScrollView.frame.size.height) andFontSize:18];
        
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [Anime stringForAnimeWatchedStatus:i forAnimeType:[self.anime.type intValue]];
        label.clipsToBounds = YES;
        [self.statusScrollView addSubview:label];
        
        if(UI_DEBUG) {
            label.backgroundColor = [UIColor colorWithRed:.1*i green:.1*i blue:.1*i alpha:1.0f];
            self.statusScrollView.backgroundColor = [UIColor blueColor];
        }
    }

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor], (id)[[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], nil];

    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(1.0f, 0.0f);
    
    self.maskView.layer.mask = gradient;

}


@end
