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
    
    [self addShadow];
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
    [self.editTitle addShadow];
    self.editTitle.text = self.title.text;
    [self.editTitle sizeToFit];
    self.editTitle.frame = CGRectMake(self.title.frame.origin.x,
                                      self.title.frame.origin.y,
                                      self.editTitle.frame.size.width,
                                      self.editTitle.frame.size.height);
    
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"red_bg_pressed.png"] forState:UIControlStateHighlighted];
    [self.plusButton setBackgroundImage:[UIImage imageNamed:@"white_bg_pressed.png"] forState:UIControlStateHighlighted];
    [self.minusButton setBackgroundImage:[UIImage imageNamed:@"white_bg_pressed.png"] forState:UIControlStateHighlighted];
}

#pragma mark - UIGestureRecognizer Callback

- (void)showEditScreen {
    // Edit screen is already up, don't reanimate!
    if(self.editView.alpha > 0.0f) {
        return;
    }
    
    self.editView.alpha = 0.0f;
    self.editView.hidden = NO;
    
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
    self.editProgress.text = [NSString stringWithFormat:@"%d / %d", [anime.current_episode intValue], [anime.total_episodes intValue]];
    
    [self showEditScreen];
}

- (void)showEditScreenForManga:(Manga *)manga {
    self.editedManga = manga;
//    self.progress.text = [NSString stringWithFormat:@"%d / %d", [anime.current_episode intValue], [anime.total_episodes intValue]];
    
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

                         for(UIGestureRecognizer *gestures in self.gestureRecognizers) {
                             [self removeGestureRecognizer:gestures];
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
