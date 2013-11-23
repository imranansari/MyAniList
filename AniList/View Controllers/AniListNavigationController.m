//
//  AniListNavigationController.m
//  AniList
//
//  Created by Corey Roberts on 7/14/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListNavigationController.h"

@interface AniListNavigationController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *contrastView;
@end

@implementation AniListNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationStyle = NavigationStyleAnime;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContast) name:kUserLoggedOut object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)setNavigationStyle:(NavigationStyle)navigationStyle {
    _navigationStyle = navigationStyle;
    
    UIImage *backgroundImage = nil;
    
    switch (navigationStyle) {
        case NavigationStyleAnime:
            backgroundImage = [UIImage imageNamed:@"anime_background.png"];
            break;
            
        default:
            break;
    }
    
    self.imageView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.imageView.alpha = 0.75f;
    
    self.contrastView = [[UIView alloc] initWithFrame:self.imageView.frame];
    self.contrastView.backgroundColor = [UIColor blackColor];
    self.contrastView.alpha = [UserProfile profile].contrastEnabled ? 0.5 : 0.0f;

    [self.view insertSubview:self.contrastView belowSubview:self.view.subviews[0]];
    [self.view insertSubview:self.imageView belowSubview:self.view.subviews[0]];
}

- (void)enableContrast:(BOOL)enable animated:(BOOL)animated {
    [[UserProfile profile] setContrastEnabled:enable];
    
    float alpha = enable ? 0.5f : 0.0f;
    float duration = animated ? 0.5f : 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        self.contrastView.alpha = alpha;
    }];
}

- (void)resetContast {
    [self enableContrast:NO animated:YES];
}

#pragma - Overridden Methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
}

@end
