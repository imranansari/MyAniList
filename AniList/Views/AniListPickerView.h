//
//  AniListPickerView.h
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Anime;

typedef enum {
    AniListPickerDatePicker = 0,
    AniListPickerStatusPicker,
    AniListPickerProgressPicker,
    AniListPickerScorePicker
} AniListPickerType;

@interface AniListPickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) AniListPickerType pickerType;
@property (nonatomic, assign) int minValue;
@property (nonatomic, assign) int maxValue;
@property (nonatomic, strong) Anime *anime;

- (void)refresh;

@end
