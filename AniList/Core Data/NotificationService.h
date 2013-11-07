//
//  NotificationService.h
//  AniList
//
//  Created by Corey Roberts on 11/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Notification;

@interface NotificationService : NSObject

+ (NSInteger)unreadNotifications;
+ (NSArray *)allNotifications;
+ (Notification *)addNotification:(NSDictionary *)dictionary;

@end
