//
//  AnimeCell.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeCell.h"
#import "Anime.h"

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

+ (NSString *)progressTextForAnime:(Anime *)anime {
    if([anime.current_episode intValue] == [anime.total_episodes intValue]) {
        return @"";
    }
    
    // If we've yet to watch it, or the current episode we're on is 0, then list how many episodes exist.
    if([anime.watched_status intValue] == AnimeWatchedStatusPlanToWatch || [anime.current_episode intValue] == 0) {
        return [NSString stringWithFormat:@"%d %@", [anime.total_episodes intValue], [anime.total_episodes intValue] > 1 ? @"episodes" : @"episode"];
    }
    
    // Unsure of this format for now, will stick to this until further notice.
//    switch([anime.type intValue]) {
//        case AnimeTypeTV:
    return [NSString stringWithFormat:@"Finished %d of %d episodes", [anime.current_episode intValue], [anime.total_episodes intValue]];
            
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
