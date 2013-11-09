//
//  NotificationDisplayViewController.m
//  AniList
//
//  Created by Corey Roberts on 11/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NotificationDisplayViewController.h"
#import "Notification.h"

@interface NotificationDisplayViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@end

@implementation NotificationDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    self.hidesBackButton = NO;
    
    [super viewDidLoad];
    
    self.title = self.notification.title;
    self.textView.text = self.notification.content;
    self.textView.scrollEnabled = YES;
    self.textView.editable = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [UIColor whiteColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.095f);
    gradient.endPoint = CGPointMake(0.0f, 0.15f);
    
    self.maskView.layer.mask = gradient;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
