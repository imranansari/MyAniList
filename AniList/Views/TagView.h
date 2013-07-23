//
//  TagView.h
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagViewDelegate <NSObject>
- (void)tagTappedWithTitle:(NSString *)title;
- (void)genreTappedWithTitle:(NSString *)title;
@end

@interface TagView : UIView

@property (nonatomic, assign) id<TagViewDelegate> delegate;

- (void)createGenreTags:(NSSet *)genreTags;
- (void)createTags:(NSSet *)tags;

@end
