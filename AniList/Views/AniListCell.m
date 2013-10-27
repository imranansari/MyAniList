//
//  AniListCell.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListCell.h"
#import "Anime.h"
#import "Manga.h"
#import "ImageManager.h"
#import "MALHTTPClient.h"

@implementation AniListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *select = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 90)];
    select.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    self.selectedBackgroundView = select;

    self.editView.hidden = YES;
    self.editView.alpha = 0.0f;
}

+ (CGFloat)cellHeight {
    return 90;
}

#pragma mark - Text Methods

- (void)addShadow {
    [self.title addShadow];
    [self.editTitle addShadow];
    [self.progress addShadow];
    [self.editProgress addShadow];
    [self.type addShadow];
    [self.rank addShadow];
}

- (void)setupEditView {
    [self.plusButton setBackgroundImage:[UIImage imageNamed:@"white_bg_pressed.png"] forState:UIControlStateHighlighted];
    [self.minusButton setBackgroundImage:[UIImage imageNamed:@"white_bg_pressed.png"] forState:UIControlStateHighlighted];
    
    self.plusButton.userInteractionEnabled = YES;
    self.minusButton.userInteractionEnabled = YES;
    
    self.plusButton.alpha = self.minusButton.alpha = 1.0f;
}

- (void)setImageWithItem:(NSManagedObject<FICEntity> *)object {
    [self setImageWithItem:object withFormatName:ThumbnailPosterImageFormatName];
}

- (void)setImageWithItem:(NSManagedObject<FICEntity> *)object withFormatName:(NSString *)formatName {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
        FICImageCacheCompletionBlock completionBlock = ^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image.image = image;
                [self.indicator removeFromSuperview];
            });
        };
        
        BOOL imageExists = [sharedImageCache retrieveImageForEntity:object
                                                     withFormatName:formatName
                                                    completionBlock:completionBlock];
        
        if (imageExists == NO) {
            ALVLog(@"image does not exist.");
        }
    });
}

#pragma mark - UIGestureRecognizer Callback

- (void)showEditScreen {
    // Edit screen is already up, don't reanimate!
    if(self.editView.alpha > 0.0f) {
        return;
    }
    
    self.editView.alpha = 0.0f;
    self.editView.hidden = NO;
    
    [self addSubview:self.editView];
    
    self.detailView.alpha = 1.0f;
    
    [self setupEditView];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.editView.alpha = 1.0f;
                         self.detailView.alpha = 0.0f;
                     }
                     completion:nil];
}

- (void)showEditScreenForAnime:(Anime *)anime {
    self.editedAnime = anime;
    
    if([anime.total_episodes intValue] > 0) {
        self.editProgress.text = [NSString stringWithFormat:@"%d / %d", [anime.current_episode intValue], [anime.total_episodes intValue]];
    }
    else {
        self.editProgress.text = [NSString stringWithFormat:@"%d", [anime.current_episode intValue]];
    }
    
    [self showEditScreen];
}

- (void)showEditScreenForManga:(Manga *)manga {
    self.editedManga = manga;
    
    [self showEditScreen];
}

- (void)revokeEditScreen {
    self.editView.alpha = 1.0f;
    self.detailView.alpha = 0.0f;
    self.detailView.hidden = NO;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.editView.alpha = 0.0f;
                         self.detailView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         self.editView.hidden = YES;
                         
                         [self.editView removeFromSuperview];

                         for(UIGestureRecognizer *gesture in self.gestureRecognizers) {
                             [self removeGestureRecognizer:gesture];
                         }
                     }];
}

- (void)promptForFinishing {
    
}

- (void)promptForBeginning {
    
}

#pragma mark - UIButton methods

- (IBAction)plusButtonPressed:(id)sender {
    
}

- (IBAction)minusButtonPressed:(id)sender {
    
}

- (IBAction)deleteButtonPressed:(id)sender {
    
}

@end
