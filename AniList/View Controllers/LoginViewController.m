//
//  LoginViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/13/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "SWRevealViewController.h"
#import "UserProfile.h"
#import "AniListAppDelegate.h"
#import "MALHTTPClient.h"
#import "AniListNavigationController.h"

@interface LoginViewController ()
@property (nonatomic, weak) IBOutlet UITextField *username;
@property (nonatomic, weak) IBOutlet UITextField *password;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *welcomeView;
@property (nonatomic, weak) IBOutlet UIView *organizeView;
@property (nonatomic, weak) IBOutlet UILabel *organizeLabel;
@property (nonatomic, weak) IBOutlet UIView *discoverView;
@property (nonatomic, weak) IBOutlet UIView *compareView;
@property (nonatomic, weak) IBOutlet UIView *loginView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton *skipToLoginButton;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

// Cells and Tour Items
@property (nonatomic, weak) IBOutlet UIView *organizeCell1;
@property (nonatomic, weak) IBOutlet UIView *organizeCell2;
@property (nonatomic, weak) IBOutlet UIView *organizeCell3;
@property (nonatomic, weak) IBOutlet UIView *discoverParentCell;
@property (nonatomic, weak) IBOutlet UIView *discoverChildCell1;
@property (nonatomic, weak) IBOutlet UIView *discoverChildCell2;
@property (nonatomic, weak) IBOutlet UIView *discoverChildCell3;
@property (nonatomic, weak) IBOutlet UIView *compareCell;
@property (nonatomic, weak) IBOutlet UILabel *friendRatingLabel;
@property (nonatomic, weak) IBOutlet UILabel *myRatingLabel;
@property (nonatomic, weak) IBOutlet UILabel *differenceLabel;
@property (nonatomic, weak) IBOutlet UIView *ratingView;

@property (nonatomic, assign) BOOL presentedOrganizationAnimation;
@property (nonatomic, assign) BOOL presentedDiscoverAnimation;
@property (nonatomic, assign) BOOL presentedComparisonAnimation;

@property (nonatomic, strong) UIView *backgroundView;

- (IBAction)skipToLoginButtonPressed:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)backgroundButtonPressed:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AniListNavigationController *nvc = ((AniListNavigationController *)self.revealViewController.frontViewController);
    
    UIImage *backgroundImage = [UIImage imageNamed:@"intro_background.png"];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-30, 0, backgroundImage.size.width, backgroundImage.size.height)];
    
    backgroundImageView.image = backgroundImage;
    
    UIView *overlay = [[UIView alloc] initWithFrame:backgroundImageView.frame];
    overlay.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    
    UIView *topOverlay = [[UIView alloc] initWithFrame:backgroundImageView.frame];
    topOverlay.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    
    self.backgroundView = [[UIView alloc] initWithFrame:backgroundImageView.frame];
    
    [self.backgroundView addSubview:backgroundImageView];
    [self.backgroundView addSubview:overlay];
    [self.backgroundView addSubview:topOverlay];
    
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    
    self.scrollView.contentSize = CGSizeMake(self.welcomeView.frame.size.width * 5, self.welcomeView.frame.size.height);
    
    [self.scrollView addSubview:self.welcomeView];
    self.welcomeView.frame = CGRectMake(0, 0, self.welcomeView.frame.size.width, self.welcomeView.frame.size.height);
    self.welcomeView.backgroundColor = [UIColor clearColor];
    
    [self.scrollView addSubview:self.organizeView];
    self.organizeView.frame = CGRectMake(self.welcomeView.frame.origin.x + self.welcomeView.frame.size.width, 0, self.organizeView.frame.size.width, self.organizeView.frame.size.height);
    self.organizeView.backgroundColor = [UIColor clearColor];
    
    [self.scrollView addSubview:self.discoverView];
    self.discoverView.frame = CGRectMake(self.organizeView.frame.origin.x + self.organizeView.frame.size.width, 0, self.discoverView.frame.size.width, self.discoverView.frame.size.height);
    self.discoverView.backgroundColor = [UIColor clearColor];
    
    [self.scrollView addSubview:self.compareView];
    self.compareView.frame = CGRectMake(self.discoverView.frame.origin.x + self.discoverView.frame.size.width, 0, self.compareView.frame.size.width, self.compareView.frame.size.height);
    self.compareView.backgroundColor = [UIColor clearColor];
    
    [self.scrollView addSubview:self.loginView];
    self.loginView.frame = CGRectMake(self.compareView.frame.origin.x + self.compareView.frame.size.width, 0, self.loginView.frame.size.width, self.loginView.frame.size.height);
    self.loginView.backgroundColor = [UIColor clearColor];
    
    self.indicator.alpha = 0.0f;
    self.statusLabel.text = @"";
    self.statusLabel.alpha = 0.0f;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(-50, 0, backgroundImageView.frame.size.width+50, backgroundImageView.frame.size.height*2);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1.0f alpha:0.25] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:1.0] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.15f);
    gradient.endPoint = CGPointMake(0.0f, 0.40f);
    
    overlay.layer.mask = gradient;
    
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(-50, 0, backgroundImageView.frame.size.width+50, backgroundImageView.frame.size.height*2);
    topGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1.0f alpha:1.0f] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:0.35f] CGColor], nil];
    
    topGradient.startPoint = CGPointMake(0.0, 0.00f);
    topGradient.endPoint = CGPointMake(0.0f, 0.10f);

    topOverlay.layer.mask = topGradient;
    
    nvc.navigationBar.hidden = YES;
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kShowSkipToLoginButton]) {
        self.skipToLoginButton.hidden = YES;
    }
    
    self.organizeCell1.frame = CGRectMake(self.organizeCell1.frame.origin.x, 0, self.organizeCell1.frame.size.width, self.organizeCell1.frame.size.height);
    self.organizeCell2.frame = CGRectMake(self.organizeCell2.frame.origin.x, self.organizeCell1.frame.origin.y, self.organizeCell2.frame.size.width, self.organizeCell2.frame.size.height);
    self.organizeCell3.frame = CGRectMake(self.organizeCell3.frame.origin.x, self.organizeCell2.frame.origin.y, self.organizeCell3.frame.size.width, self.organizeCell3.frame.size.height);
    self.organizeCell1.alpha = 0.0f;
    self.organizeCell2.alpha = 0.0f;
    self.organizeCell3.alpha = 0.0f;
    
    self.discoverParentCell.frame = self.organizeCell1.frame;
    self.discoverParentCell.alpha = 0.0f;
    
    
    self.discoverChildCell1.frame = CGRectMake(self.discoverChildCell1.frame.origin.x,
                                               self.discoverParentCell.frame.origin.y + self.discoverParentCell.frame.size.height - self.discoverChildCell1.frame.size.height,
                                               self.discoverChildCell1.frame.size.width,
                                               self.discoverChildCell1.frame.size.height);
    
    self.discoverChildCell2.frame = self.discoverChildCell3.frame = self.discoverChildCell1.frame;
    
    self.discoverChildCell1.alpha = self.discoverChildCell2.alpha = self.discoverChildCell3.alpha = 0.0f;
    
    self.compareCell.frame = self.discoverParentCell.frame;
    self.compareCell.alpha = 0.0f;
    
    self.myRatingLabel.alpha = 0.0f;
    self.friendRatingLabel.alpha = 0.0f;
    self.differenceLabel.alpha = 0.0f;
    
    self.ratingView.frame = CGRectMake(self.ratingView.frame.origin.x,
                                       self.compareCell.frame.origin.y + self.compareCell.frame.size.height + 20,
                                       self.ratingView.frame.size.width,
                                       self.ratingView.frame.size.height);
    self.ratingView.alpha = 0.0f;
    
    self.myRatingLabel.frame = CGRectMake(self.myRatingLabel.frame.origin.x,
                                          self.myRatingLabel.frame.origin.y + 15,
                                          self.myRatingLabel.frame.size.width,
                                          self.myRatingLabel.frame.size.height);
    
    self.friendRatingLabel.frame = CGRectMake(self.friendRatingLabel.frame.origin.x,
                                              self.friendRatingLabel.frame.origin.y + 15,
                                              self.friendRatingLabel.frame.size.width,
                                              self.friendRatingLabel.frame.size.height);
    
    self.differenceLabel.frame = CGRectMake(self.differenceLabel.frame.origin.x,
                                            self.differenceLabel.frame.origin.y + 15,
                                            self.differenceLabel.frame.size.width,
                                            self.differenceLabel.frame.size.height);
 
    if(![UIApplication is4Inch]) {
        self.indicator.frame = CGRectMake(self.indicator.frame.origin.x, self.indicator.frame.origin.y + 20, self.indicator.frame.size.width, self.indicator.frame.size.height);
        self.statusLabel.frame = CGRectMake(self.statusLabel.frame.origin.x, self.statusLabel.frame.origin.y + 20, self.statusLabel.frame.size.width, self.statusLabel.frame.size.height);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[AnalyticsManager sharedInstance] trackView:kLoginScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// cell is off origin by 34
- (void)animateOrganizeScreen {
    self.presentedOrganizationAnimation = YES;
    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.organizeCell2.frame = CGRectMake(self.organizeCell2.frame.origin.x,
                                              self.organizeLabel.frame.origin.y - 34,
                                              self.organizeCell2.frame.size.width,
                                              self.organizeCell2.frame.size.height);
        
        self.organizeCell1.frame = CGRectMake(self.organizeCell1.frame.origin.x,
                                              self.organizeCell2.frame.origin.y - self.organizeCell1.frame.size.height - 5,
                                              self.organizeCell1.frame.size.width,
                                              self.organizeCell1.frame.size.height);
        
        self.organizeCell3.frame = CGRectMake(self.organizeCell3.frame.origin.x,
                                              self.organizeCell1.frame.origin.y - self.organizeCell3.frame.size.height - 5,
                                              self.organizeCell3.frame.size.width,
                                              self.organizeCell3.frame.size.height);
        
        self.organizeCell1.alpha = 1.0f;
        self.organizeCell2.alpha = 1.0f;
        self.organizeCell3.alpha = 1.0f;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)animateDiscoverScreen {
    self.presentedDiscoverAnimation = YES;
    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.discoverParentCell.frame = CGRectMake(self.discoverParentCell.frame.origin.x,
                                                   self.organizeLabel.frame.origin.y - 174,
                                                   self.discoverParentCell.frame.size.width,
                                                   self.discoverParentCell.frame.size.height);
        
        self.discoverChildCell1.frame = CGRectMake(self.discoverChildCell1.frame.origin.x,
                                                   self.discoverParentCell.frame.origin.y + self.discoverParentCell.frame.size.height - self.discoverChildCell1.frame.size.height,
                                                   self.discoverChildCell1.frame.size.width,
                                                   self.discoverChildCell1.frame.size.height);
        
        self.discoverChildCell2.frame = self.discoverChildCell3.frame = self.discoverChildCell1.frame;

        
        self.discoverParentCell.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.75f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             self.discoverChildCell1.frame = CGRectMake(self.discoverChildCell1.frame.origin.x,
                                                                        self.discoverParentCell.frame.origin.y + self.discoverParentCell.frame.size.height + 5,
                                                                        self.discoverChildCell1.frame.size.width,
                                                                        self.discoverChildCell1.frame.size.height);
                             
                             self.discoverChildCell2.frame = CGRectMake(self.discoverChildCell2.frame.origin.x,
                                                                        self.discoverChildCell1.frame.origin.y + self.discoverChildCell1.frame.size.height + 5,
                                                                        self.discoverChildCell2.frame.size.width,
                                                                        self.discoverChildCell2.frame.size.height);
                             
                             self.discoverChildCell3.frame = CGRectMake(self.discoverChildCell3.frame.origin.x,
                                                                        self.discoverChildCell2.frame.origin.y + self.discoverChildCell2.frame.size.height + 5,
                                                                        self.discoverChildCell3.frame.size.width,
                                                                        self.discoverChildCell3.frame.size.height);
                             
                             
                             self.discoverChildCell1.alpha = self.discoverChildCell2.alpha = self.discoverChildCell3.alpha = 1.0f;
                         }
                         completion:nil];
    }];
}

- (void)animateCompareScreen {
    self.presentedComparisonAnimation = YES;
    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.compareCell.frame = CGRectMake(self.compareCell.frame.origin.x,
                                            self.organizeLabel.frame.origin.y - 174,
                                            self.compareCell.frame.size.width,
                                            self.compareCell.frame.size.height);
        
        self.ratingView.frame = CGRectMake(self.ratingView.frame.origin.x,
                                           self.compareCell.frame.origin.y + self.compareCell.frame.size.height + 20,
                                           self.ratingView.frame.size.width,
                                           self.ratingView.frame.size.height);
        
        self.compareCell.alpha = 1.0f;
    } completion:nil];
    
    [UIView animateWithDuration:1.0f delay:0.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.ratingView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.myRatingLabel.alpha = 1.0f;
            self.friendRatingLabel.alpha = 1.0f;
            self.differenceLabel.alpha = 1.0f;
            
            self.myRatingLabel.frame = CGRectMake(self.myRatingLabel.frame.origin.x,
                                                  self.myRatingLabel.frame.origin.y - 15,
                                                  self.myRatingLabel.frame.size.width,
                                                  self.myRatingLabel.frame.size.height);
            
            self.friendRatingLabel.frame = CGRectMake(self.friendRatingLabel.frame.origin.x,
                                                      self.friendRatingLabel.frame.origin.y - 15,
                                                      self.friendRatingLabel.frame.size.width,
                                                      self.friendRatingLabel.frame.size.height);
            
            self.differenceLabel.frame = CGRectMake(self.differenceLabel.frame.origin.x,
                                                    self.differenceLabel.frame.origin.y - 15,
                                                    self.differenceLabel.frame.size.width,
                                                    self.differenceLabel.frame.size.height);
        } completion:nil];
        
        
    }];
    
}

#pragma mark - IBAction Methods

- (IBAction)skipToLoginButtonPressed:(id)sender {
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.scrollView scrollRectToVisible:self.loginView.frame animated:NO];
                     }
                     completion:nil];
}

- (IBAction)loginButtonPressed:(id)sender {
    
    [[AnalyticsManager sharedInstance] trackEvent:kLoginButtonPressed forCategory:EventCategoryAction];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.indicator.alpha = 1.0f;
        self.statusLabel.alpha = 0.0f;
        self.loginButton.alpha = 0.5f;
        self.loginButton.userInteractionEnabled = NO;
        self.username.enabled = NO;
        self.password.enabled = NO;
    }];
    [[MALHTTPClient sharedClient] loginWithUsername:self.username.text andPassword:self.password.text success:^(id operation, id response) {
        [[UserProfile profile] setUsername:self.username.text andPassword:self.password.text];
        ALLog(@"Logged in!");
        [self revokeLoginScreen];
        
    } failure:^(id operation, NSError *error) {
        ALLog(@"Could not log in.");
        // Error logic to handle failure.
        [UIView animateWithDuration:0.3f animations:^{
            self.indicator.alpha = 0.0f;
            self.statusLabel.alpha = 1.0f;
            self.statusLabel.text = @"Couldn't log in. Please try again.";
            self.loginButton.alpha = 1.0f;
            self.loginButton.userInteractionEnabled = YES;
            self.username.enabled = YES;
            self.password.enabled = YES;
        }];
    }];
}

- (IBAction)backgroundButtonPressed:(id)sender {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

#pragma mark - Screen Revoke Methods

- (void)revokeLoginScreen {
    if([UserProfile userIsLoggedIn]) {
        
        // Set this default to YES so the user can just skip to login next time, in the event they log out.
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShowSkipToLoginButton];
        
        AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
        SWRevealViewController *rvc = (SWRevealViewController *)delegate.window.rootViewController;
        AniListNavigationController *nvc = (AniListNavigationController *)rvc.frontViewController;
        nvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [nvc dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == self.username) {
        if([self.username.text isEqualToString:@"Username"]) {
            self.username.text = @"";
        }
    }
    
    if(textField == self.password) {
        if([self.password.text isEqualToString:@"Password"]) {
            self.password.text = @"";
            self.password.secureTextEntry = YES;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.username) {
        [self.password becomeFirstResponder];
    }
    else if(textField == self.password) {
        [self.password resignFirstResponder];
        [self loginButtonPressed:nil];
    }
    
    return YES;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Since we know this background will fit the screen height, we can use this value.
    float width = [UIScreen mainScreen].bounds.size.width;
    
    // Determine what page we're on.
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    self.pageControl.currentPage = page;
    
    float alpha = 1.0f;
    if(page == 4) {
        alpha = 0.0f;
    }
    
    [UIView animateWithDuration:0.15f
                     animations:^{
                         self.pageControl.alpha = alpha;
                     }];
    
    if(scrollView.contentSize.width > 400) {
        float xOrigin = -((self.backgroundView.frame.size.width - width) * (scrollView.contentOffset.x / scrollView.contentSize.width));
        self.backgroundView.frame = CGRectMake(MAX(xOrigin - 30.0f, -(self.backgroundView.frame.size.width - [UIScreen mainScreen].bounds.size.width - 30)), 0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Determine what page we're on.
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    switch (page) {
        case 1:
            if(!self.presentedOrganizationAnimation)
                [self animateOrganizeScreen];
            break;
        case 2:
            if(!self.presentedDiscoverAnimation)
                [self animateDiscoverScreen];
            break;
        case 3:
            if(!self.presentedComparisonAnimation)
                [self animateCompareScreen];
            break;
        default:
            break;
    }
}

@end
