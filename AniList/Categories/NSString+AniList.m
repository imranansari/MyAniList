//
//  NSString+AniList.m
//  AniList
//
//  Created by Corey Roberts on 6/3/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NSString+AniList.h"

@implementation NSString (AniList)

- (NSString *)cleanHTMLTags {
    NSRange r;
    NSString *s = self;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    
    return s;
}

+ (NSString *)stringWithDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, yyyy";
    return [dateFormatter stringFromDate:date];
}

@end
