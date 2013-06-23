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

+ (NSDate *)parseDate:(NSString *)stringDate {
    // First format: from malappinfo.php.
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date;
    
    // There exist two date formats. Should probably consolidate this somehow.
    // Typically, we'd add a Z for timezone instead of hardcoding +0000, but we want to preserve the raw date
    // since it seems like timezones are not used in the database.
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    date = [dateFormatter dateFromString:stringDate];
    
    if(date) {
        return date;
    }
    
    // Typically, we'd add a Z for timezone instead of hardcoding +0000, but we want to preserve the raw date
    // since it seems like timezones are not used in the database.
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss +0000";
    
    date = [dateFormatter dateFromString:stringDate];
    
    if(date) {
        return date;
    }
    
    return nil;
}

@end
