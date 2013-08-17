//
//  UIView+AniList.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "UIView+AniList.h"
#import "TTTAttributedLabel.h"

@implementation UIView (AniList)

+ (UIView *)tableHeaderWithPrimaryText:(NSString *)primaryString andSecondaryText:(NSString *)secondaryString {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 320, 44)];
    view.backgroundColor = [UIColor clearColor];
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 0, 300, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%@ (%@)", primaryString, secondaryString];
    [label addShadow];
    
    [view addSubview:label];
    
    [UILabel setAttributesForLabel:label withPrimaryText:primaryString andSecondaryText:[NSString stringWithFormat:@"(%@)", secondaryString]];
    
    return view;
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

- (void)animateOut {
    if([UIApplication isiOS7]) {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 0.0f;
                         }
                         completion:nil];
    }
}

- (void)animateIn {
    if([UIApplication isiOS7]) {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 1.0f;
                         }
                         completion:nil];
    }
}

@end
