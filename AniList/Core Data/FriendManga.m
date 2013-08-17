//
//  FriendManga.m
//  AniList
//
//  Created by Corey Roberts on 8/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "FriendManga.h"
#import "Friend.h"
#import "Manga.h"

@implementation FriendManga

@dynamic column;
@dynamic current_volume;
@dynamic score;
@dynamic read_status;
@dynamic current_chapter;
@dynamic manga;
@dynamic user;

- (void)setRead_status:(NSNumber *)read_status {
    [self willChangeValueForKey:@"read_status"];
    [self setPrimitiveValue:read_status forKey:@"read_status"];
    [self didChangeValueForKey:@"read_status"];
    
    // Update column appropriately.
    switch ([self.read_status intValue]) {
        case MangaReadStatusReading:
            self.column = @(0);
            break;
        case MangaReadStatusCompleted:
            self.column = @(1);
            break;
        case MangaReadStatusOnHold:
            self.column = @(2);
            break;
        case MangaReadStatusDropped:
            self.column = @(3);
            break;
        case MangaReadStatusPlanToRead:
            self.column = @(4);
            break;
        case MangaReadStatusUnknown:
        default:
            self.column = @(5);
            break;
    }
}

@end
