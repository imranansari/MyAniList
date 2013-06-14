//
//  AniListScoreView.h
//  AniList
//
//  Created by Corey Roberts on 6/7/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AniListScoreViewDelegate <NSObject>
- (void)scoreUpdated:(NSNumber *)number;
@end

@interface AniListScoreView : UIView

@property (nonatomic, assign) id<AniListScoreViewDelegate> delegate;

- (void)updateScore:(NSNumber *)score;

@end
