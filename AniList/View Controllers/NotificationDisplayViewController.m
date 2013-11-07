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
    self.textView.scrollEnabled = NO;
    self.textView.editable = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
