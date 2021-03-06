//
//  NSDictionary+AniList.m
//  AniList
//
//  Created by Corey Roberts on 6/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NSDictionary+AniList.h"

@implementation NSDictionary (AniList)

- (NSDictionary *)cleanupTextTags {
    NSMutableDictionary *cleanDictionary = [NSMutableDictionary dictionary];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = @"";
        
        if(![key isEqualToString:@"text"]) {
            value = self[key][@"text"];
        }
        else {
            value = self[key];
        }
        
//        ALLog(@"%@ = %@", key, value);
        if(value)
            [cleanDictionary addEntriesFromDictionary:@{ key : value }];
        else
            [cleanDictionary addEntriesFromDictionary:@{ key : @""}];
    }];
    
    return [cleanDictionary copy];
}

@end
