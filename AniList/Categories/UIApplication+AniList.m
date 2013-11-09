//
//  UIApplication+AniList.m
//  AniList
//
//  Created by Corey Roberts on 8/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UIApplication+AniList.h"

@implementation UIApplication (AniList)

+ (BOOL)isiOS7 {
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
		return NO;
	
	return YES;
}

+ (BOOL)isRetinaDevice {
    return [UIScreen mainScreen].scale == 2;
}

+ (BOOL)is4Inch {
    return [UIScreen mainScreen].bounds.size.height > 480;
}


@end
