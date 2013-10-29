//
//  BaseViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/5/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "AniListNavigationController.h"

@interface BaseViewController ()
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIButton *menuButton;
@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBackButton = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:kMenuButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScreen:) name:kMenuButtonTapped object:nil];
    }
    return self;
}

- (void)hideKeyboard:(NSNotification *)notification {
    // Override if necessary.
}

- (void)enableScreen:(NSNotification *)notification {
//    self.revealViewController.frontViewController.view.userInteractionEnabled = !self.revealViewController.frontViewController.view.userInteractionEnabled;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    SWRevealViewController *revealController = self.revealViewController;
    
    AniListNavigationController *nvc = ((AniListNavigationController *)self.revealViewController.frontViewController);
    
    // This value is implicitly set to YES in iOS 7.0.
    nvc.navigationBar.translucent = YES; // Setting this slides the view up, underneath the nav bar (otherwise it'll appear black)
    
    if([[UIDevice currentDevice].systemVersion compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        //        nvc.navigationBar.barTintColor = [UIColor clearColor];
    }
    else {
        const float colorMask[6] = {222, 255, 222, 255, 222, 255};
        UIImage *img = [[UIImage alloc] init];
        UIImage *maskedImage = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];
        
        [nvc.navigationBar setShadowImage:[[UIImage alloc] init]];
        [nvc.navigationBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault];
    }
    
    if(revealController) {
//        [self.view addGestureRecognizer:revealController.panGestureRecognizer];
        [self.menuButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.075f);
    gradient.endPoint = CGPointMake(0.0f, 0.10f);
    
    self.maskView.layer.mask = gradient;
    
    if(self.hidesBackButton)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view animateIn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view animateOut];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
