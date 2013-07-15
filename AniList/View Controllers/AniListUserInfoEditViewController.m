//
//  AniListUserInfoEditViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListUserInfoEditViewController.h"
#import "AniListScoreView.h"

@interface AniListUserInfoEditViewController ()

@property (nonatomic, weak) IBOutlet UIView *maskView;

@end

@implementation AniListUserInfoEditViewController

- (id)init {
    return [self initWithNibName:@"AniListUserInfoEditViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.datePicker = [[AniListDatePickerView alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.statusScrollView.pagingEnabled = YES;
    self.statusScrollView.clipsToBounds = NO;
    self.statusScrollView.delegate = self;
    self.statusScrollView.backgroundColor = [UIColor clearColor];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor], (id)[[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], nil];

    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(1.0f, 0.0f);
    
    self.maskView.layer.mask = gradient;
    
    UIColor *shadowColor = [UIColor defaultShadowColor];
    
    [self.startDateButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    [self.endDateButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    [self.addItemButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    [self.removeItemButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    
    self.datePicker.delegate = self;
    self.datePicker.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
    [self.view addSubview:self.datePicker];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.scoreView.delegate = nil;
}

#pragma mark - UIView Methods

- (void)dismissDate {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.view.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
                     }
                     completion:nil];
}

#pragma mark - NSString Methods

- (NSString *)startDateStringWithDate:(NSDate *)date {
    // override
    return nil;
}

- (NSString *)finishDateStringWithDate:(NSDate *)date {
    // override
    return nil;
}

#pragma mark - IBAction Methods

- (IBAction)startDateButtonPressed:(id)sender {
    
    self.datePicker.datePickerType = AniListDatePickerStartDate;
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.view.frame.size.height - self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
                     }
                     completion:nil];
}

- (IBAction)endDateButtonPressed:(id)sender {
    
    self.datePicker.datePickerType = AniListDatePickerEndDate;
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.view.frame.size.height - self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
                     }
                     completion:nil];
}

- (IBAction)addItemButtonPressed:(id)sender {
    
}

- (IBAction)removeItemButtonPressed:(id)sender {
    
}

- (void)save:(id)sender {
    // override
}

- (void)setOriginalValues {
    // override
}

- (void)revertValuesToDefault {
   // override
}

#pragma mark - AniListDatePickerViewDelegate Methods

- (void)cancelPressed {
    [self dismissDate];
}

- (void)dateSelected:(NSDate *)date forType:(AniListDatePickerViewType)datePickerType {
    [self dismissDate];
}


@end
