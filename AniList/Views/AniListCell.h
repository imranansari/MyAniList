//
//  AniListCell.h
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Anime, Manga;

typedef enum {
    ActionSheetPromptBeginning = 0,
    ActionSheetPromptFinishing,
    ActionSheetPromptDeletion
} ActionSheetPrompts;

@interface AniListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *editTitle;
@property (nonatomic, weak) IBOutlet UILabel *progress;
@property (nonatomic, weak) IBOutlet UILabel *editProgress;
@property (nonatomic, weak) IBOutlet UILabel *type;
@property (nonatomic, weak) IBOutlet UILabel *rank;
@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *editView;
@property (nonatomic, weak) IBOutlet UIView *detailView;

@property (nonatomic, weak) IBOutlet UIButton *plusButton;
@property (nonatomic, weak) IBOutlet UIButton *minusButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

@property (nonatomic, weak) Anime *editedAnime;
@property (nonatomic, weak) Manga *editedManga;

+ (CGFloat)cellHeight;
- (void)addShadow;
- (void)showEditScreen;
- (void)revokeEditScreen;

- (void)showEditScreenForAnime:(Anime *)anime;
- (void)showEditScreenForManga:(Manga *)manga;

- (IBAction)plusButtonPressed:(id)sender;
- (IBAction)minusButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;

@end
