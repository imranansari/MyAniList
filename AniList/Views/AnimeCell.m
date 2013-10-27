
//  AnimeCell.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeCell.h"
#import "FriendAnime.h"
#import "Anime.h"
#import "FICImageCache.h"

@implementation AnimeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

+ (CGFloat)cellHeight {
    return 90;
}

+ (NSString *)progressTextForFriendAnime:(FriendAnime *)friendAnime {
    
    Anime *anime = friendAnime.anime;
    
    if([friendAnime.current_episode intValue] == [anime.total_episodes intValue] ||
       [anime.total_episodes intValue] < 1                                 ||
       [anime.type intValue] == AnimeTypeMovie) {
        return @"";
    }
    
    // If we've yet to watch it, or the current episode we're on is 0, then list how many episodes exist.
    if([friendAnime.watched_status intValue] == AnimeWatchedStatusPlanToWatch || [friendAnime.current_episode intValue] == 0) {
        return [NSString stringWithFormat:@"%d %@", [anime.total_episodes intValue], [Anime unitForAnimeType:[anime.type intValue] plural:[anime.total_episodes intValue] != 1 ? YES : NO]];
    }
    
    return [NSString stringWithFormat:@"Watched %d of %d %@", [friendAnime.current_episode intValue], [anime.total_episodes intValue], [Anime unitForAnimeType:[anime.type intValue] plural:[anime.total_episodes intValue] != 1 ? YES : NO]];
}

+ (NSString *)progressTextForAnime:(Anime *)anime {
    
    if([anime.current_episode intValue] == [anime.total_episodes intValue] ||
       [anime.total_episodes intValue] < 1                                 ||
       [anime.type intValue] == AnimeTypeMovie) {
        return @"";
    }
    
    // If we've yet to watch it, or the current episode we're on is 0, then list how many episodes exist.
    if([anime.watched_status intValue] == AnimeWatchedStatusPlanToWatch || [anime.current_episode intValue] == 0) {
        return [NSString stringWithFormat:@"%d %@", [anime.total_episodes intValue], [Anime unitForAnimeType:[anime.type intValue] plural:[anime.total_episodes intValue] != 1 ? YES : NO]];
    }

    return [NSString stringWithFormat:@"Watched %d of %d %@", [anime.current_episode intValue], [anime.total_episodes intValue], [Anime unitForAnimeType:[anime.type intValue] plural:[anime.total_episodes intValue] != 1 ? YES : NO]];
}

- (void)addShadow {
    for(UIView *view in self.subviews) {
        if([view isMemberOfClass:[UILabel class]]) {
            [((UILabel *)view) addShadow];
        }
    }
}

- (void)updateProgress {
    if([self.editedAnime.total_episodes intValue] > 0) {
        self.editProgress.text = [NSString stringWithFormat:@"%d / %d", [self.editedAnime.current_episode intValue], [self.editedAnime.total_episodes intValue]];
    }
    else {
        self.editProgress.text = [NSString stringWithFormat:@"%d", [self.editedAnime.current_episode intValue]];
    }
}

- (void)showEditScreen {
    
    [super showEditScreen];
    
    if([self.editedAnime.current_episode intValue] >= [self.editedAnime.total_episodes intValue] && [self.editedAnime.total_episodes intValue] > 0) {
        self.editedAnime.current_episode = @([self.editedAnime.total_episodes intValue]);
        self.plusButton.userInteractionEnabled = NO;
        self.plusButton.alpha = 0.5f;
    }
    
    if([self.editedAnime.current_episode intValue] < 0) {
        self.editedAnime.current_episode = @(0);
        self.minusButton.userInteractionEnabled = NO;
        self.minusButton.alpha = 0.5f;
    }
}

#pragma mark - Edit UIButton Methods

- (IBAction)plusButtonPressed:(id)sender {
    if(self.editedAnime && [self.editedAnime.current_episode intValue] >= 0) {
        self.editedAnime.current_episode = @([self.editedAnime.current_episode intValue] + 1);
        if([self.editedAnime.current_episode intValue] >= [self.editedAnime.total_episodes intValue] && [self.editedAnime.total_episodes intValue] > 0) {
            self.editedAnime.current_episode = @([self.editedAnime.total_episodes intValue]);
            // Mark as completed?
            self.plusButton.userInteractionEnabled = NO;
            self.plusButton.alpha = 0.5f;
        }

        [self updateProgress];
    }
    
    if(!self.minusButton.userInteractionEnabled) {
        self.minusButton.userInteractionEnabled = YES;
        self.minusButton.alpha = 1.0f;
    }
}

- (IBAction)minusButtonPressed:(id)sender {
    if(self.editedAnime && [self.editedAnime.current_episode intValue] <= [self.editedAnime.total_episodes intValue]) {
        self.editedAnime.current_episode = @([self.editedAnime.current_episode intValue] - 1);
        if([self.editedAnime.current_episode intValue] <= 0) {
            self.editedAnime.current_episode = @(0);
            self.minusButton.userInteractionEnabled = NO;
            self.minusButton.alpha = 0.5f;
        }
        
        [self updateProgress];
    }
    
    if(!self.plusButton.userInteractionEnabled) {
        self.plusButton.userInteractionEnabled = YES;
        self.plusButton.alpha = 1.0f;
    }
}

- (IBAction)deleteButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you really want to delete '%@'?", self.editedAnime.title]
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:@"Yes"
                                                    otherButtonTitles:nil];
    actionSheet.tag = ActionSheetPromptDeletion;
    
    [actionSheet showInView:self.superview];
}

- (void)setDetailsForAnime:(Anime *)anime {
    self.title.text = anime.title;
    [self.title sizeToFit];
    
    self.progress.text = [AnimeCell progressTextForAnime:anime];
    self.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
    self.type.text = [Anime stringForAnimeType:[anime.type intValue]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
        FICImageCacheCompletionBlock completionBlock = ^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image.image = image;
                [self.indicator removeFromSuperview];
            });
        };
        
        BOOL imageExists = [sharedImageCache retrieveImageForEntity:anime
                                                     withFormatName:ThumbnailPosterImageFormatName
                                                    completionBlock:completionBlock];
        
        if (imageExists == NO) {
            ALVLog(@"image does not exist.");
        }
    });
}

@end
