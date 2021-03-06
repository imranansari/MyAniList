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
@property (nonatomic, assign) BOOL navigationChangedByGesture;
@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBackButton = YES;
        self.canSwipeNavBar = NO;
        self.canSwipeView = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:kMenuButtonTapped object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if(NO) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        [self.navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(viewPanned:)];
    }
    
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
    
    [self.menuButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    if(!self.navigationChangedByGesture) {
        [self.view animateIn];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(!self.navigationChangedByGesture) {
        [self.view animateOut];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    SWRevealViewController *revealController = self.revealViewController;
    
    if(self.canSwipeView) {
        [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    }
    else if(self.canSwipeNavBar) {
        [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard:(NSNotification *)notification {
    
}

- (void)enable:(BOOL)enable {
	if ([self.view isKindOfClass:[UIScrollView class]])
		((UIScrollView*)self.view).scrollEnabled = enable;
    
	for (UIView *v in self.view.subviews) {
		v.userInteractionEnabled = enable;
	}
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (void)viewPanned:(UIGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        ALLog(@"Gesture stopped.");
        self.navigationChangedByGesture = NO;
    }
    else {
        self.navigationChangedByGesture = YES;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    self.navigationChangedByGesture = YES;
    return YES;
}

@end
