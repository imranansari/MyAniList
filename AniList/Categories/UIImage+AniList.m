//
//  UIImage+AniList.m
//  AniList
//
//  Created by Corey Roberts on 10/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UIImage+AniList.h"

@implementation UIImage (AniList)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"placeholder.png"];
}

@end
