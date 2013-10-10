//
//  FriendMangaService.m
//  AniList
//
//  Created by Corey Roberts on 8/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "FriendMangaService.h"
#import "FriendManga.h"
#import "Friend.h"
#import "Manga.h"
#import "AniListAppDelegate.h"

@implementation FriendMangaService

#define ENTITY_NAME @"FriendManga"


+ (FriendManga *)addFriend:(Friend *)friend toManga:(Manga *)manga {
    FriendManga *friendManga = [FriendMangaService manga:manga forFriend:friend];
    
    if(!friendManga) {
        ALLog(@"Friend '%@' is new for manga '%@', adding to the database.", friend.username, manga.title);
        friendManga = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[FriendMangaService managedObjectContext]];
        friendManga.manga = manga;
        friendManga.user = friend;
        
        [manga addUserlistObject:friendManga];
        [friend addSharedMangaObject:friendManga];
    }
    
    return friendManga;
}

+ (FriendManga *)manga:(Manga *)manga forFriend:(Friend *)friend {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[FriendMangaService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"manga == %@ && user == %@", manga, friend];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[FriendMangaService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (FriendManga *)results[0];
    }
    else return nil;
}

+ (NSArray *)mangaForFriend:(Friend *)friend {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[FriendMangaService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@", friend];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[FriendMangaService managedObjectContext] executeFetchRequest:request error:&error];
    
    NSMutableArray *manga = [NSMutableArray array];
    
    if(results.count) {
        for(FriendManga *friendManga in results) {
            [manga addObject:friendManga.manga];
        }
        return manga;
    }
    else return nil;
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
