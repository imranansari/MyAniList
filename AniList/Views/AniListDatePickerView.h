//
//  AniListDatePickerView.h
//  AniList
//
//  Created by Corey Roberts on 6/9/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    AniListDatePickerStartDate = 0,
    AniListDatePickerEndDate
} AniListDatePickerViewType;

@protocol AniListDatePickerViewDelegate <NSObject>
- (void)dateSelected:(NSDate *)date forType:(AniListDatePickerViewType)datePickerType;
@end

@interface AniListDatePickerView : UIView

@property (nonatomic, assign) AniListDatePickerViewType datePickerType;
@property (nonatomic, assign) id<AniListDatePickerViewDelegate> delegate;

@end
