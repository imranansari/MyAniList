//
//  AniListDetailsViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListDetailsViewController.h"

@interface AniListDetailsViewController ()

@end

@implementation AniListDetailsViewController

//- (id)init {
//    return [self initWithNibName:@"AniListDetailsViewController" bundle:[NSBundle mainBundle]];
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"AniListDetailsViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.errorMessageLabel.alpha = 0.0f;
    self.indicator.alpha = 1.0f;
    self.detailView.alpha = 0.0f;
    
    self.poster.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.2f].CGColor;
    self.poster.layer.borderWidth = 1.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPosterForObject:(NSManagedObject<FICEntity> *)object {
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    [sharedImageCache retrieveImageForEntity:object withFormatName:PosterImageFormatName completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
        [UIView animateWithDuration:0.3f animations:^{
            self.poster.alpha = 1.0f;
        }];
    }];
}

- (void)updatePoster {
    [UIView animateWithDuration:0.3f animations:^{
        self.poster.alpha = 1.0f;
    }];
}

- (void)displayDetailsViewAnimated:(BOOL)animated {
    if(animated) {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.detailView.alpha = 1.0f;
                             self.indicator.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [self.indicator removeFromSuperview];
                         }];
    }
    else {
        self.detailView.alpha = 1.0f;
        [self.indicator removeFromSuperview];
    }
}

- (void)displayErrorMessage {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.errorMessageLabel.alpha = 1.0f;
                         self.indicator.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.indicator removeFromSuperview];
                     }];
    
}

@end
