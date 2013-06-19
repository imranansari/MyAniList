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

@interface LoginViewController ()
@property (nonatomic, weak) IBOutlet UITextField *username;
@property (nonatomic, weak) IBOutlet UITextField *password;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *nvc = ((UINavigationController *)self.revealViewController.frontViewController);
    
    nvc.navigationBar.hidden = YES;
    if([[UIDevice currentDevice].systemVersion compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        //        nvc.navigationBar.barTintColor = [UIColor clearColor];
    }
    else {

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods

- (IBAction)loginButtonPressed:(id)sender {
    [[MALHTTPClient sharedClient] loginWithUsername:self.username.text andPassword:self.password.text success:^(id operation, id response) {
        [[UserProfile profile] setUsername:self.username.text andPassword:self.password.text];
        NSLog(@"Logged in!");
        [self revokeLoginScreen];
        
    } failure:^(id operation, NSError *error) {
        NSLog(@"Could not log in.");
        // Error logic to handle failure.
    }];
}

- (IBAction)backgroundButtonPressed:(id)sender {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

#pragma mark - Screen Revoke Methods

- (void)revokeLoginScreen {
    if([UserProfile userIsLoggedIn]) {
        AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
        SWRevealViewController *rvc = (SWRevealViewController *)delegate.window.rootViewController;
        UINavigationController *nvc = (UINavigationController *)rvc.frontViewController;
        nvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [nvc dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate Methods

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

@end
