//
//  MangaCell.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaCell.h"
#import "Manga.h"

@interface MangaCell()
@property (nonatomic, weak) IBOutlet UILabel *editChapterProgress;
@property (nonatomic, weak) IBOutlet UIButton *plusChapterButton;
@end

@implementation MangaCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.editView.hidden = YES;
        self.editView.alpha = 0.0f;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
    }
    
    return self;
}

+ (CGFloat)cellHeight {
    return 90;
}

+ (NSString *)progressTextForManga:(Manga *)manga withSpacing:(BOOL)spacing {
    if([manga.current_chapter intValue] == [manga.total_chapters intValue] &&
       [manga.current_volume intValue] == [manga.total_volumes intValue]) {
        return @"";
    }
    
    NSString *progressString = @"";
    
    // If we've yet to watch it, or the current episode we're on is 0, then list how many episodes exist.
    if([manga.read_status intValue] == MangaReadStatusPlanToRead || ([manga.current_chapter intValue] == 0 && [manga.current_volume intValue] == 0)) {
        if([manga.total_volumes intValue] > 0) {
            progressString = [NSString stringWithFormat:@"%d %@", [manga.total_volumes intValue], [manga.total_volumes intValue] > 1 ? @"volumes" : @"volume"];
        }
        
        if(progressString.length > 0 && [manga.total_chapters intValue] > 0) {
            if(spacing)
                progressString = [NSString stringWithFormat:@"%@\n", progressString];
            else
                progressString = [NSString stringWithFormat:@"%@,", progressString];
        }
        
        if([manga.total_chapters intValue] > 0) {
            if(progressString.length == 0)
                progressString = [NSString stringWithFormat:@"%d %@", [manga.total_chapters intValue], [manga.total_chapters intValue] > 1 ? @"chapters" : @"chapter"];
            else {
                progressString = [NSString stringWithFormat:@"%@ %d %@", progressString, [manga.total_chapters intValue], [manga.total_chapters intValue] > 1 ? @"chapters" : @"chapter"];
            }
        }
        
        return progressString;
    }
    else {
        if([manga.current_volume intValue] > 0) {
            if(spacing) {
                if([manga.total_volumes intValue] < 1) {
                    progressString = [NSString stringWithFormat:@"Volume %d", [manga.current_volume intValue]];
                }
                else {
                    progressString = [NSString stringWithFormat:@"Volume %d of %d", [manga.current_volume intValue], [manga.total_volumes intValue]];
                }
            }
            else {
                progressString = [NSString stringWithFormat:@"Volume %d", [manga.current_volume intValue]];
            }
        }
        
        if(progressString.length > 0 && [manga.current_chapter intValue] > 0) {
            if(spacing)
                progressString = [NSString stringWithFormat:@"%@\n", progressString];
            else
                progressString = [NSString stringWithFormat:@"%@,", progressString];
        }
        
        if([manga.current_chapter intValue] > 0) {
            
            NSString *chapter = spacing ? @"Chapter" : @"chapter";
            
            if(progressString.length == 0) {
                progressString = @"On";
            }
            
            if([manga.total_chapters intValue] > 0) {
                if(progressString.length == 0) {
                    progressString = [NSString stringWithFormat:@"Chapter %d of %d", [manga.current_chapter intValue], [manga.total_chapters intValue]];
                }
                else {
                    progressString = [NSString stringWithFormat:@"%@ %@ %d of %d", progressString, chapter, [manga.current_chapter intValue], [manga.total_chapters intValue]];
                }
            }
            else {
                if(progressString.length == 0) {
                    progressString = [NSString stringWithFormat:@"Chapter %d", [manga.current_chapter intValue]];
                }
                else {
                    progressString = [NSString stringWithFormat:@"%@ %@ %d", progressString, chapter, [manga.current_chapter intValue]];
                }
            }
        }
        
        return progressString;

    }
    
    // Unsure of this format for now, will stick to this until further notice.
    //    switch([anime.type intValue]) {
    //        case AnimeTypeTV:
    return [NSString stringWithFormat:@"Volume %d, chapter %d of %d", [manga.current_volume intValue], [manga.current_chapter intValue], [manga.total_chapters intValue]];
    
    //    }
    
}

- (void)addShadow {
    for(UIView *view in self.subviews) {
        if([view isMemberOfClass:[UILabel class]]) {
            [((UILabel *)view) addShadow];
        }
    }
}

- (void)updateProgress {
    if([self.editedManga.total_volumes intValue] > 0) {
        self.editProgress.text = [NSString stringWithFormat:@"%d / %d", [self.editedManga.current_volume intValue], [self.editedManga.total_volumes intValue]];
    }
    else {
        self.editProgress.text = [NSString stringWithFormat:@"%d", [self.editedManga.current_volume intValue]];
    }
    
    if([self.editedManga.total_chapters intValue] > 0) {
        self.editChapterProgress.text = [NSString stringWithFormat:@"%d / %d", [self.editedManga.current_chapter intValue], [self.editedManga.total_chapters intValue]];
    }
    else {
        self.editChapterProgress.text = [NSString stringWithFormat:@"%d", [self.editedManga.current_chapter intValue]];
    }
}

- (void)showEditScreen {
    
    [super showEditScreen];
    
    [self.plusChapterButton setBackgroundImage:[UIImage imageNamed:@"white_bg_pressed.png"] forState:UIControlStateHighlighted];
    
    [self updateProgress];
    
    if([self.editedManga.current_volume intValue] >= [self.editedManga.total_volumes intValue] && [self.editedManga.total_volumes intValue] != 0) {
        self.editedManga.current_volume = @([self.editedManga.total_volumes intValue]);
        self.plusButton.userInteractionEnabled = NO;
        self.plusButton.alpha = 0.5f;
    }
    
    if([self.editedManga.current_chapter intValue] >= [self.editedManga.total_chapters intValue] && [self.editedManga.total_chapters intValue] != 0) {
        self.editedManga.current_chapter = @([self.editedManga.total_chapters intValue]);
        self.plusChapterButton.userInteractionEnabled = NO;
        self.plusChapterButton.alpha = 0.5f;
    }
    
    if([self.editedManga.current_chapter intValue] <= 0) {
        self.editedManga.current_chapter = @(0);
        self.minusButton.userInteractionEnabled = NO;
        self.minusButton.alpha = 0.5f;
    }
}

#pragma mark - Edit UIButton Methods

- (IBAction)plusVolumeButtonPressed:(id)sender {
    if(self.editedManga && [self.editedManga.current_volume intValue] >= 0) {
        self.editedManga.current_volume = @([self.editedManga.current_volume intValue] + 1);
        if([self.editedManga.current_volume intValue] >= [self.editedManga.total_volumes intValue]) {
            
            if([self.editedManga.total_volumes intValue] != 0) {
                self.editedManga.current_volume = @([self.editedManga.total_volumes intValue]);
                
                // Mark as completed?
                self.plusButton.userInteractionEnabled = NO;
                self.plusButton.alpha = 0.5f;
            }
        }
        
        [self updateProgress];
    }
    
    if(!self.minusButton.userInteractionEnabled) {
        self.minusButton.userInteractionEnabled = YES;
        self.minusButton.alpha = 1.0f;
    }
}

- (IBAction)plusChapterButtonPressed:(id)sender {
    if(self.editedManga && [self.editedManga.current_chapter intValue] >= 0) {
        self.editedManga.current_chapter = @([self.editedManga.current_chapter intValue] + 1);
        if([self.editedManga.current_chapter intValue] >= [self.editedManga.total_chapters intValue]) {
            
            if([self.editedManga.total_chapters intValue] != 0) {
                self.editedManga.current_chapter = @([self.editedManga.total_chapters intValue]);
                
                // Mark as completed?
                self.plusChapterButton.userInteractionEnabled = NO;
                self.plusChapterButton.alpha = 0.5f;
            }
        }
        
        [self updateProgress];
    }
    
    if(!self.minusButton.userInteractionEnabled) {
        self.minusButton.userInteractionEnabled = YES;
        self.minusButton.alpha = 1.0f;
    }
}

- (IBAction)deleteButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you really want to delete '%@'?", self.editedManga.title]
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:@"Yes"
                                                    otherButtonTitles:nil];
    actionSheet.tag = ActionSheetPromptDeletion;
    
    [actionSheet showInView:self.superview];
}

- (void)setDetailsForManga:(Manga *)manga {
    self.title.text = manga.title;
    [self.title sizeToFit];
    self.progress.text = [MangaCell progressTextForManga:manga withSpacing:NO];
    self.rank.text = [manga.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [manga.user_score intValue]] : @"";
    self.type.text = [Manga stringForMangaType:[manga.type intValue]];
    
    [self setImageWithItem:manga];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == actionSheet.destructiveButtonIndex) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteManga object:nil];
    }
}


@end
