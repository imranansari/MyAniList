//
//  AniListUserInfoViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListUserInfoViewController.h"

@interface AniListUserInfoViewController ()

@end

@implementation AniListUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"AniListUserInfoViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (UILabel *)labelForView:(UIView *)view {
    for(UIView *subview in view.subviews) {
        if([subview isMemberOfClass:[UILabel class]]) {
            return (UILabel *)subview;
        }
    }
    
    return nil;
}

- (IBAction)userInfoViewPressed:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(userInfoPressed)]) {
        [self.delegate userInfoPressed];
    }
}


@end
