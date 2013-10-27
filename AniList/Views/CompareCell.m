//
//  CompareCell.m
//  AniList
//
//  Created by Corey Roberts on 8/19/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "CompareCell.h"

@implementation CompareCell

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *select = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 90)];
    select.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    self.selectedBackgroundView = select;
}

+ (CGFloat)cellHeight {
    return 90;
}

- (void)setUserScore:(int)userScore andFriendScore:(int)friendScore {
    if(userScore > 0) {
        self.myScore.text = [NSString stringWithFormat:@"%d", userScore];
    }
    else {
        self.myScore.text = @"-";
        self.difference.text = @"-";
    }
    
    if(friendScore > 0) {
        self.theirScore.text = [NSString stringWithFormat:@"%d", friendScore];
    }
    else {
        self.theirScore.text = @"-";
        self.difference.text = @"-";
    }
    
    if(userScore > 0 && friendScore > 0) {
        
        self.difference.text = [NSString stringWithFormat:@"%d", userScore - friendScore];
        
        if(userScore > friendScore) {
            self.difference.textColor = [UIColor greenColor];
        }
        else if(friendScore > userScore) {
            self.difference.textColor = [UIColor redColor];
        }
        else {
            self.difference.textColor = [UIColor whiteColor];
        }
    }
}

- (void)setImageWithItem:(NSManagedObject<FICEntity> *)object {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
        FICImageCacheCompletionBlock completionBlock = ^(id <FICEntity> entity, NSString *formatName, UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image.image = image;
                [self.indicator removeFromSuperview];
            });
        };
        
        BOOL imageExists = [sharedImageCache retrieveImageForEntity:object
                                                     withFormatName:ThumbnailPosterImageFormatName
                                                    completionBlock:completionBlock];
        
        if (imageExists == NO) {
            ALVLog(@"image does not exist.");
        }
    });
}

@end
