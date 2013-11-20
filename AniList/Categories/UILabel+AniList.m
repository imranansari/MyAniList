//
//  UILabel+AniList.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UILabel+AniList.h"
#import "TTTAttributedLabel.h"

@implementation UILabel (AniList)

+ (UILabel *)whiteLabelWithFrame:(CGRect)frame andFontSize:(int)size {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont defaultFontWithSize:size];
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

+ (UILabel *)whiteHeaderWithFrame:(CGRect)frame andFontSize:(int)size {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont defaultFontWithSize:size];
    label.backgroundColor = [UIColor clearColor];
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header_bg.png"]];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void)addShadow {
//    self.shadowColor = [UIColor defaultShadowColor];
//    self.shadowOffset = CGSizeMake(0, 1);
}

+ (void)setAttributesForLabel:(TTTAttributedLabel *)label withPrimaryText:(NSString *)primaryText andSecondaryText:(NSString *)secondaryText {
    NSString *text = [NSString stringWithFormat:@"%@ %@", primaryText, secondaryText];
    [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        // Set properties for bold points font.
        NSRange primaryRange = [[mutableAttributedString string] rangeOfString:primaryText options:NSCaseInsensitiveSearch];
        UIFont *primaryFont = [UIFont defaultFontWithSize:18];
        
        CTFontRef primaryFontRef = CTFontCreateWithName((__bridge CFStringRef)primaryFont.fontName, primaryFont.pointSize, NULL);
        
        // Set properties for regular pts font.
        NSRange secondaryRange = [[mutableAttributedString string] rangeOfString:secondaryText options:NSCaseInsensitiveSearch];
        UIFont *secondaryFont = [UIFont defaultFontWithSize:14];
        
        UIColor *secondaryColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        CTFontRef secondaryFontRef = CTFontCreateWithName((__bridge CFStringRef)secondaryFont.fontName, secondaryFont.pointSize, NULL);
        
        if (primaryFontRef) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)primaryFontRef range:primaryRange];
            CFRelease(primaryFontRef);
        }
        
        if(secondaryFontRef) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)secondaryFontRef range:secondaryRange];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:secondaryColor range:secondaryRange];
            CFRelease(secondaryFontRef);
        }
        
        return mutableAttributedString;
    }];
}

@end
