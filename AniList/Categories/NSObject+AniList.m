//
//  NSObject+AniList.m
//  AniList
//
//  Created by Corey Roberts on 5/31/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NSObject+AniList.h"

@implementation NSObject (AniList)

- (BOOL)isNull {
    return [self isMemberOfClass:[NSNull class]];
}

@end
