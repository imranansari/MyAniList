//
//  FriendAnimeService.m
//  AniList
//
//  Created by Corey Roberts on 8/10/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "FriendAnimeService.h"
#import "FriendAnime.h"
#import "Friend.h"
#import "Anime.h"
#import "AniListAppDelegate.h"

#define ENTITY_NAME @"FriendAnime"

@implementation FriendAnimeService

+ (FriendAnime *)addFriend:(Friend *)friend toAnime:(Anime *)anime {
    FriendAnime *friendAnime = [FriendAnimeService anime:anime forFriend:friend];
    
    if(!friendAnime) {
        ALLog(@"Friend '%@' is new for anime '%@', adding to the database.", friend.username, anime.title);
        friendAnime = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[FriendAnimeService managedObjectContext]];
        friendAnime.anime = anime;
        friendAnime.user = friend;
        
        [anime addUserlistObject:friendAnime];
        [friend addSharedAnimeObject:friendAnime];
    }
    
    return friendAnime;
}
                                
+ (FriendAnime *)anime:(Anime *)anime forFriend:(Friend *)friend {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[FriendAnimeService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"anime == %@ && user == %@", anime, friend];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[FriendAnimeService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (FriendAnime *)results[0];
    }
    else return nil;

}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
