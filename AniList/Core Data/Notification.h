//
//  Notification.h
//  AniList
//
//  Created by Corey Roberts on 11/5/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSNumber *read;
@property (nonatomic, retain) NSNumber *sticky;
@property (nonatomic, retain) NSString *imageURL;

@end
