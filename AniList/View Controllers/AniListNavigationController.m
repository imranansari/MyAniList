//
//  AniListNavigationController.m
//  AniList
//
//  Created by Corey Roberts on 7/14/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListNavigationController.h"

@interface AniListNavigationController ()

@end

@implementation AniListNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationStyle = NavigationStyleAnime;
    }
    return self;
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
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
    imageView.alpha = 0.75f;

    [self.view insertSubview:imageView belowSubview:self.view.subviews[0]];
}

#pragma - Overridden Methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
}

@end
