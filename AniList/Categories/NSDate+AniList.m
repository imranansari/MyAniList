//
//  NSDate+AniList.m
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NSDate+AniList.h"

@implementation NSDate (AniList)

- (NSString *)stringValue {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, yyyy";
    
    return [dateFormatter stringFromDate:self];
}

@end
