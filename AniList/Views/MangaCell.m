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

@end
