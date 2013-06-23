//
//  MangaCell.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaCell.h"
#import "Manga.h"

@implementation MangaCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
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

+ (NSString *)progressTextForManga:(Manga *)manga {
    if([manga.current_chapter intValue] == [manga.total_chapters intValue] &&
       [manga.current_volume intValue] == [manga.total_volumes intValue]) {
        return @"";
    }
    
    // If we've yet to watch it, or the current episode we're on is 0, then list how many episodes exist.
    if([manga.read_status intValue] == MangaReadStatusPlanToRead || ([manga.current_chapter intValue] == 0 && [manga.current_volume intValue] == 0)) {
        return [NSString stringWithFormat:@"%d %@, %d %@", [manga.total_volumes intValue], [manga.total_volumes intValue] > 1 ? @"volumes" : @"volume", [manga.total_chapters intValue], [manga.total_chapters intValue] > 1 ? @"chapters" : @"chapter"];
    }
    
    // Unsure of this format for now, will stick to this until further notice.
    //    switch([anime.type intValue]) {
    //        case AnimeTypeTV:
    return [NSString stringWithFormat:@"On volume %d, chapter %d of %d", [manga.current_volume intValue], [manga.current_chapter intValue], [manga.total_chapters intValue]];
    
    //    }
    
}

- (void)addShadow {
    for(UIView *view in self.subviews) {
        if([view isMemberOfClass:[UILabel class]]) {
            [((UILabel *)view) addShadow];
        }
    }
}

@end
