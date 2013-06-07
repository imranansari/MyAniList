//
//  AniListPickerView.m
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListPickerView.h"
#import "Anime.h"

@interface AniListPickerView()
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation AniListPickerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        toolbar.tintColor = [UIColor blackColor];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

        [toolbar setItems:@[flexSpace, doneButton]];
        
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height, [UIScreen mainScreen].bounds.size.width, 162)];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height, [UIScreen mainScreen].bounds.size.width, 162)];
        
        [self addSubview:toolbar];
        [self addSubview:self.pickerView];
    }
    return self;
}


#pragma mark - UIPickerView Datasource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (self.pickerType) {
        case AniListPickerProgressPicker:
            return [self.anime.total_episodes intValue];
        case AniListPickerScorePicker:
            return 10;
        case AniListPickerStatusPicker:
            return 5;
        case AniListPickerDatePicker:
        default:
            return -1;
    }
}

#pragma mark - UIPickerView Delegate Methods

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    
    label.text = @"Dummy!";
    
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont defaultFontWithSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    if(row > 0) {
//        [SettingsModel sharedInstance].splitTableInterval = [[self.splitOptions objectAtIndex:row] doubleValue];
//    }
//    else {
//        [SettingsModel sharedInstance].splitTableInterval = 0;
//    }
}

- (void)doneEditing:(id)sender {
    
}

#pragma mark - Public Methods

- (void)refresh {
    [self.pickerView reloadAllComponents];
}



@end
