//
//  NotificationsViewController.m
//  AniList
//
//  Created by Corey Roberts on 11/5/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NotificationsViewController.h"
#import "CRHTTPClient.h"

@interface NotificationsViewController ()

@end

@implementation NotificationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[CRHTTPClient sharedClient] getNewsFromTimestamp:0 success:^(NSURLRequest *operation, id response) {
        ALLog(@"Received data: %@", response);
    } failure:^(NSURLRequest *operation, NSError *error) {
        ALLog(@"Failed to receive news. Error was: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
