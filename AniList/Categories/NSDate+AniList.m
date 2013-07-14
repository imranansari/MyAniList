//
//  NSDate+AniList.m
//  AniList
//
//  Created by Corey Roberts on 6/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NSDate+AniList.h"

@implementation NSDate (AniList)

static NSDateFormatter *dateFormatter = nil;
static NSDateFormatter *dateFormatterExtended = nil;

- (NSString *)stringValue {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, yyyy";
    
    return [dateFormatter stringFromDate:self];
}

+ (NSDate *)parseDate:(NSString *)stringDate {
    // First format: from malappinfo.php.
    NSDate *date;
    
    // There exist two date formats. Should probably consolidate this somehow.
    // Typically, we'd add a Z for timezone instead of hardcoding +0000, but we want to preserve the raw date
    // since it seems like timezones are not used in the database.
    date = [[NSDate baseDateFormatter] dateFromString:stringDate];
    
    if(date) {
        return date;
    }
    
    // Typically, we'd add a Z for timezone instead of hardcoding +0000, but we want to preserve the raw date
    // since it seems like timezones are not used in the database.
    date = [[NSDate extendedDateFormatter] dateFromString:stringDate];
    
    if(date) {
        return date;
    }
    
    return nil;
}

+ (NSDateFormatter *)baseDateFormatter {
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return dateFormatter;
}

+ (NSDateFormatter *)extendedDateFormatter {
    if(!dateFormatterExtended) {
        dateFormatterExtended = [[NSDateFormatter alloc] init];
        dateFormatterExtended.dateFormat = @"yyyy-MM-dd HH:mm:ss +0000";
    }
    
    return dateFormatterExtended;
}



@end
