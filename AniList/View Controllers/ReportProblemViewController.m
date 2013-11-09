//
//  ReportProblemViewController.m
//  AniList
//
//  Created by Corey Roberts on 11/4/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "ReportProblemViewController.h"
#import "CRHTTPClient.h"

#define kDefaultEmailField @"Email (optional)"
#define kDefaultProblemField @"What do you love/hate/want/need? Your feedback is always appreciated. :)"

@interface ReportProblemViewController ()
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
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
    
    self.title = @"Submit Feedback";
    self.indicator.alpha = 0.0f;
    
    self.emailField.text = [UserProfile profile].email && [UserProfile profile].email.length > 0 ? [UserProfile profile].email : kDefaultEmailField;
    self.textView.text = kDefaultProblemField;
    [self.emailField setFont:[UIFont defaultFontWithSize:14]];
    
    
    self.feedbackButton.alpha = 0.5f;
    self.feedbackButton.userInteractionEnabled = NO;
    
    self.errorLabel.text = @"There was an issue sending feedback. Please try again later.";
    self.errorLabel.alpha = 0.0f;
    self.errorLabel.numberOfLines = 2;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[AnalyticsManager sharedInstance] trackView:kReportIssueScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendFeedbackButtonPressed:(id)sender {
    [UIView animateWithDuration:0.15f animations:^{
        self.indicator.alpha = 1.0f;
        self.errorLabel.alpha = 0.0f;
        self.feedbackButton.alpha = 0.5f;
        self.feedbackButton.userInteractionEnabled = NO;
    }];
    
    NSString *email = self.emailField.text;
    
    if(![self.emailField.text isEqualToString:kDefaultEmailField]) {
        [UserProfile profile].email = self.emailField.text;
    }
    else {
        email = @"";
    }
    
    [[CRHTTPClient sharedClient] submitFeedbackForUser:[UserProfile profile].username withEmail:email andFeedback:self.textView.text success:^(id operation, id response) {
        ALLog(@"Successfully sent feedback!");
        [self.navigationController popViewControllerAnimated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"We'll review your feedback and get back to you if necessary. Thanks for your help!" delegate:nil cancelButtonTitle:@"Yay!" otherButtonTitles:nil, nil];
        [alert show];
        
    } failure:^(id operation, NSError *error) {
        ALLog(@"An error occurred while sending feedback: %@", error.localizedDescription);
        
        [UIView animateWithDuration:0.15f animations:^{
            self.indicator.alpha = 0.0f;
            self.feedbackButton.alpha = 1.0f;
            self.feedbackButton.userInteractionEnabled = YES;
            self.errorLabel.alpha = 1.0f;
        }];
    }];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if([textField.text isEqualToString:kDefaultEmailField]) {
        self.emailField.text = @"";
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.emailField resignFirstResponder];
    [self.textView becomeFirstResponder];
    
    return YES;
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.feedbackButton.userInteractionEnabled = NO;
    
    if([textView.text isEqualToString:kDefaultProblemField]) {
        self.textView.text = @"";
    }
    
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if(self.textView.text.length > 0) {
        self.feedbackButton.alpha = 1.0f;
        self.feedbackButton.userInteractionEnabled = YES;
    }
    else {
        self.feedbackButton.alpha = 0.5f;
        self.feedbackButton.userInteractionEnabled = NO;
    }
    
    return YES;
}

@end
