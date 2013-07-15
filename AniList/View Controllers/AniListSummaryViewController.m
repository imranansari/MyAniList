//
//  AniListSummaryViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/3/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListSummaryViewController.h"
#import "AniListNavigationController.h"

@interface AniListSummaryViewController ()

@end

@implementation AniListSummaryViewController

- (id)init {
    return [self initWithNibName:@"AniListSummaryViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.alpha = 0.0f;
    self.view.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.075f);
    gradient.endPoint = CGPointMake(0.0f, 0.10f);
    
    self.maskView.layer.mask = gradient;

    [self.titleLabel addShadow];
}

- (void)viewWillAppear:(BOOL)animated {
//    AniListNavigationController *navigationController = (AniListNavigationController *)self.navigationController;
//    [UIView animateWithDuration:1.0f
//                          delay:0.0f
//                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, 0, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
//                     }
//                     completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
//    AniListNavigationController *navigationController = (AniListNavigationController *)self.navigationController;
//    [UIView animateWithDuration:1.0f
//                          delay:0.0f
//                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, self.currentYBackgroundPosition, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
//                     }
//                     completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UILabel Fix Method

- (void)adjustTitle {
    int maxDesiredFontSize = 19;
    int minFontSize = 10;
    CGFloat labelWidth = self.titleLabel.frame.size.width;
    CGFloat labelRequiredHeight = self.titleLabel.frame.size.height;
    
    /* This is where we define the ideal font that the Label wants to use.
     Use the font you want to use and the largest font size you want to use. */
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:maxDesiredFontSize];
    
    /* Time to calculate the needed font size.
     This for loop starts at the largest font size, and decreases by two point sizes (i=i-2)
     Until it either hits a size that will fit or hits the minimum size we want to allow (i > 10) */
    int i = 0;
    for(i = maxDesiredFontSize; i > minFontSize; i = i-2) {
        // Set the new font size.
        font = [font fontWithSize:i];
        // You can log the size you're trying: NSLog(@"Trying size: %u", i);
        
        /* This step is important: We make a constraint box
         using only the fixed WIDTH of the UILabel. The height will
         be checked later. */
        CGSize constraintSize = CGSizeMake(labelWidth, MAXFLOAT);
        
        // This step checks how tall the label would be with the desired font.
        CGSize labelSize = [self.titleLabel.text sizeWithFont:font
                                            constrainedToSize:constraintSize
                                                lineBreakMode:NSLineBreakByTruncatingTail];
        
        /* Here is where you use the height requirement!
         Set the value in the if statement to the height of your UILabel
         If the label fits into your required height, it will break the loop
         and use that font size. */
        if(labelSize.height <= labelRequiredHeight)
            break;
    }

    ALLog(@"Best size calculated: %u", i);
    
    // Set the UILabel's font to the newly adjusted font.
    self.titleLabel.font = font;
}

#pragma mark - Animation Methods

- (void)displayTitle {
    [UIView animateWithDuration:0.5f animations:^{
        self.titleLabel.alpha = 1.0f;
    }];
}

- (void)removeTitle {
    [UIView animateWithDuration:0.3f animations:^{
        self.titleLabel.alpha = 0.0f;
    }];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y < 38) {
        [self removeTitle];
    }
    else {
        [self displayTitle];
    }
    
//    AniListNavigationController *navigationController = (AniListNavigationController *)self.navigationController;
//    
//    // Since we know this background will fit the screen height, we can use this value.
//    float height = [UIScreen mainScreen].bounds.size.height;
//    
//    if(scrollView.contentOffset.y <= 0) {
//        navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, 0, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
//    }
//    else {
//        float yOrigin = -((navigationController.imageView.frame.size.height - height) * (scrollView.contentOffset.y / scrollView.contentSize.height));
//        navigationController.imageView.frame = CGRectMake(navigationController.imageView.frame.origin.x, yOrigin, navigationController.imageView.frame.size.width, navigationController.imageView.frame.size.height);
//    }
}

@end
