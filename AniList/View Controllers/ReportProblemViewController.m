//
//  ReportProblemViewController.m
//  AniList
//
//  Created by Corey Roberts on 11/4/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "ReportProblemViewController.h"

@interface ReportProblemViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *feedbackButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction)sendFeedbackButtonPressed:(id)sender;

@end

@implementation ReportProblemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    self.hidesBackButton = NO;
    
    [super viewDidLoad];
    
    self.title = @"Report a Problem";
    self.indicator.alpha = 0.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendFeedbackButtonPressed:(id)sender {
    [UIView animateWithDuration:0.15f animations:^{
        self.indicator.alpha = 1.0f;
        self.feedbackButton.alpha = 0.5f;
        self.feedbackButton.userInteractionEnabled = NO;
    }];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.feedbackButton.userInteractionEnabled = NO;
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    self.feedbackButton.userInteractionEnabled = YES;
    
    return YES;
}

@end
