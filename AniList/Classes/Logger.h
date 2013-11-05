//
//  Logger.h
//  AniList
//
//  Created by Corey Roberts on 11/4/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject

+ (Logger *)sharedInstance;
- (void)log:(NSString *)format, ...;

@end
