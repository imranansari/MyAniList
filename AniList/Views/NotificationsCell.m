//
//  NotificationsCell.m
//  AniList
//
//  Created by Corey Roberts on 11/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "NotificationsCell.h"
#import "Notification.h"

@interface NotificationsCell()
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *content;
@property (nonatomic, weak) IBOutlet UILabel *date;
@end

@implementation NotificationsCell

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

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *select = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, [NotificationsCell cellHeight])];
    select.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    self.selectedBackgroundView = select;
    self.separatorInset = UIEdgeInsetsZero;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDetails:(Notification *)notification {
    self.date.textColor = [UIColor lightGrayColor];
    self.date.text = [NSDateFormatter localizedStringFromDate:notification.timestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];

    self.title.textColor = [UIColor whiteColor];
    self.title.text = notification.title;
    
    self.content.textColor = [UIColor whiteColor];
    self.content.text = notification.content;
}

+ (CGFloat)cellHeight {
    return 90;
}

@end
