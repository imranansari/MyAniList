//
//  NSDate+AniList.h
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (AniList)

- (NSString *)stringValue;
+ (NSDate *)parseDate:(NSString *)stringDate;

@end
