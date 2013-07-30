//
//  SettingsCell.h
//  AniList
//
//  Created by Corey Roberts on 7/30/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *option;

- (void)setup;

@end
