//
//  AnimeUserInfoEditViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/8/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeUserInfoEditViewController.h"
#import "Anime.h"

@interface AnimeUserInfoEditViewController ()

@end

@implementation AnimeUserInfoEditViewController

static NSArray *animeStatusOrder;

- (id)init {
    self = [super init];
    if(self) {
        animeStatusOrder = @[
                                @(AnimeWatchedStatusWatching),
                                @(AnimeWatchedStatusCompleted),
                                @(AnimeWatchedStatusOnHold),
                                @(AnimeWatchedStatusDropped),
                                @(AnimeWatchedStatusPlanToWatch)
                                // Rewatch
                             ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusScrollView.contentSize = CGSizeMake(self.statusScrollView.frame.size.width * animeStatusOrder.count, 1);
    
    for(int i = 0; i < animeStatusOrder.count; i++) {
        UILabel *label = [UILabel whiteLabelWithFrame:CGRectMake(i * self.statusScrollView.frame.size.width, 0, self.statusScrollView.frame.size.width, self.statusScrollView.frame.size.height) andFontSize:18];
        
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [Anime stringForAnimeWatchedStatus:[animeStatusOrder[i] intValue] forAnimeType:[self.anime.type intValue]];
        label.clipsToBounds = YES;
        [self.statusScrollView addSubview:label];
        
        if(UI_DEBUG) {
            label.backgroundColor = [UIColor colorWithRed:.1*i green:.1*i blue:.1*i alpha:1.0f];
            self.statusScrollView.backgroundColor = [UIColor blueColor];
            self.statusScrollView.showsHorizontalScrollIndicator = YES;
        }
    }
    
}

@end
