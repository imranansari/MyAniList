//
//  AniListSummaryViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/3/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListSummaryViewController.h"

@interface AniListSummaryViewController ()

@end

@implementation AniListSummaryViewController

- (id)init {
    return [self initWithNibName:@"AniListSummaryViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.alpha = 0.0f;
    self.view.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.075f);
    gradient.endPoint = CGPointMake(0.0f, 0.10f);
    
    self.maskView.layer.mask = gradient;

    [self.titleLabel addShadow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // y = 36; scrolled off completely.
    // y = 48; matched completely.
    NSLog(@"y: %f", scrollView.contentOffset.y);
    if(scrollView.contentOffset.y < 36) {
        self.titleLabel.alpha = 0.0f;
    }
    else if(scrollView.contentOffset.y >= 36 && scrollView.contentOffset.y < 48) {
        self.titleLabel.alpha = (scrollView.contentOffset.y - 36.0f) / (48.0f - 36.0f);
    }
    else {
        self.titleLabel.alpha = 1.0f;
    }
}

@end
