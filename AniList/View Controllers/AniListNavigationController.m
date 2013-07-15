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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma - Overridden Methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
}

@end
