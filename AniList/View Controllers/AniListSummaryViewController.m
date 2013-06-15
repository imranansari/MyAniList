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

#pragma mark - Animation Methods

- (void)displayTitle {
    [UIView animateWithDuration:0.5f animations:^{
        self.titleLabel.alpha = 1.0f;
    }];
}

- (void)removeTitle {
    [UIView animateWithDuration:0.3f animations:^{
        self.titleLabel.alpha = 0.0f;
    }];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if(scrollView.contentOffset.y < 36) {
        [self removeTitle];
    }
    else {
        [self displayTitle];
    }
}

@end
