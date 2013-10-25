//
//  TagsViewController.h
//  AniList
//
//  Created by Corey Roberts on 10/25/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TagView.h"

typedef enum {
    TagTypeTags = 0,
    TagTypeGenres
} TagType;

@interface TagsViewController : BaseViewController<TagViewDelegate>
@property (nonatomic, assign) TagType tagType;
@end
