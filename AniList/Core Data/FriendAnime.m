//
//  FriendAnime.m
//  AniList
//
//  Created by Corey Roberts on 8/10/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "FriendAnime.h"
#import "Anime.h"
#import "Friend.h"


@implementation FriendAnime

@dynamic score;
@dynamic column;
@dynamic current_episode;
@dynamic watched_status;
@dynamic anime;
@dynamic user;

- (void)setWatched_status:(NSNumber *)watched_status {
    [self willChangeValueForKey:@"watched_status"];
    [self setPrimitiveValue:watched_status forKey:@"watched_status"];
    [self didChangeValueForKey:@"watched_status"];
    
    // Update column appropriately.
    switch ([self.watched_status intValue]) {
        case AnimeWatchedStatusWatching:
            self.column = @(0);
            break;
        case AnimeWatchedStatusCompleted:
            self.column = @(1);
            break;
        case AnimeWatchedStatusOnHold:
            self.column = @(2);
            break;
        case AnimeWatchedStatusDropped:
            self.column = @(3);
            break;
        case AnimeWatchedStatusPlanToWatch:
            self.column = @(4);
            break;
        case AnimeWatchedStatusUnknown:
        default:
            self.column = @(5);
            break;
    }
}

@end
