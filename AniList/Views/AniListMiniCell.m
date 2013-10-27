//
//  AniListMiniCell.m
//  AniList
//
//  Created by Corey Roberts on 7/19/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListMiniCell.h"
#import "Anime.h"
#import "Manga.h"

@implementation AniListMiniCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return [self initWithFrame:self.frame];
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
    
    self.image.clipsToBounds = YES;
}

+ (CGFloat)cellHeight {
    return 60;
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
                                                     withFormatName:MiniPosterImageFormatName
                                                    completionBlock:completionBlock];
        
        if (imageExists == NO) {
            ALVLog(@"image does not exist.");
        }
    });
}

@end
