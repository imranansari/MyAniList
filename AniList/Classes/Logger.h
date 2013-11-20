//
//  Logger.h
//  AniList
//
//  Created by Corey Roberts on 11/4/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OVERRIDE_MSG \
@throw [NSException exceptionWithName:@"Failed to override an abstract method." reason:[NSString stringWithFormat:@"%s must be overridden.", __PRETTY_FUNCTION__] userInfo:nil] \


@interface Logger : NSObject

+ (Logger *)sharedInstance;
- (void)log:(NSString *)format, ...;

@end
