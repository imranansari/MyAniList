//
//  NotificationService.m
//  AniList
//
//  Created by Corey Roberts on 11/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NotificationService.h"
#import "Notification.h"
#import "AniListAppDelegate.h"

#define ENTITY_NAME @"Notification"

@implementation NotificationService

+ (NSInteger)unreadNotifications {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[NotificationService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"read == NO"];
    
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSUInteger count = [[NotificationService managedObjectContext] countForFetchRequest:request error:&error];
    
    if(count == NSNotFound) {
        return 0;
    }
    else return count;
}

+ (NSArray *)allNotifications {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[NotificationService managedObjectContext]];
    request.entity = entity;
    
    NSError *error = nil;
    NSArray *results = [[NotificationService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return results;
    }
    else return nil;
}

+ (Notification *)addNotification:(NSDictionary *)dictionary {
    
    NSArray *notifications = [NotificationService allNotifications];
    
    if(dictionary && dictionary[@"timestamp"]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSDate *date = [dateFormatter dateFromString:dictionary[@"timestamp"]];
        
        // Before adding, check and make sure we don't already have it.
        for(Notification *notification in notifications) {
            if([notification.timestamp compare:date] == NSOrderedSame) {
                ALLog(@"Notification '%@' found!", notification.title);
                return notification;
            }
        }
        
        ALLog(@"Notification '%@' is new, adding to the database.", dictionary[@"title"]);
        Notification *notification = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[NotificationService managedObjectContext]];
        notification.title = dictionary[@"title"];
        notification.content = dictionary[@"description"];
        notification.timestamp = date;
        notification.sticky = @(NO);
        notification.read = @(NO);
        
        [[NotificationService managedObjectContext] save:nil];
        
        return notification;
    }
    else return nil;
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
