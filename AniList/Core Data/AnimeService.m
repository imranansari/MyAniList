//
//  AnimeService.m
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeService.h"
#import "AniListAppDelegate.h"

#define ENTITY_NAME @"Anime"

@implementation AnimeService

+ (Anime *)animeForID:(NSNumber *)ID {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"anime_id == %d", [ID intValue]];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[AnimeService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (Anime *)results[0];
    }
    else return nil;
}

+ (Anime *)addAnime:(NSDictionary *)data {
    if([AnimeService animeForID:data[@"id"]]) {
        NSLog(@"Anime already exists!");
        return nil;
    }
    
    NSError *error = nil;
    
    Anime *anime = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
    anime.title = data[@"title"];
    anime.current_episode = data[@"watched_episodes"];
    anime.anime_id = data[@"id"];
    
    [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        return anime;
    }
    else return nil;
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}


@end
