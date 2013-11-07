//
//  NotificationsCell.h
//  AniList
//
//  Created by Corey Roberts on 11/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Notification;

@interface NotificationsCell : UITableViewCell

- (void)setDetails:(Notification *)notification;
+ (CGFloat)cellHeight;

@end
