//
//  SettingsViewController.h
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "BaseViewController.h"

typedef enum {
    EnableGenreTagSupportTag = 0,
    ClearImageCacheTag,
    ClearAnimeListTag,
    ClearMangaListTag
} ActionSheetTags;

typedef enum {
    SettingsSectionCustomization = 0,
    SettingsSectionAdvanced,
    SettingsSectionFeedback,
    SettingsSectionNetwork
} SettingsSection;

@interface SettingsViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@end
