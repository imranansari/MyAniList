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
        NSLog(@"Anime exists. Updating details.");
        return [AnimeService editAnime:data];
    }
    
    NSError *error = nil;
    
    Anime *anime = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[AnimeService managedObjectContext]];
    
    anime.anime_id = data[@"id"];
    anime.title = data[@"title"];
//    anime.synonyms = data[@"other_titles"];
    // english
    // japanese
    
    // rank (global)
    // popularity_rank
    
    anime.image = data[@"image_url"];
    anime.type = @([Anime animeTypeForValue:data[@"type"]]);
    anime.total_episodes = [data[@"episodes"] isNull] ? @(-1) : data[@"episodes"];
    anime.status = @([Anime animeAirStatusForValue:data[@"status"]]);
    
    // note: not the user start/end date.
    anime.date_start = nil;
    anime.date_finish = nil;
    
//    anime.classification = data[@"classification"];
//    anime.average_score = data[@"members_score"];
//    anime.average_count = data[@"members_count"];
//    anime.favorited_count = data[@"favorited_count"];
//    anime.synopsis = data[@"synopsis"];
//    anime.genres = data[@"genres"];
//    anime.tags = data[@"tags"];
//    anime.manga_adaptations = data[@"manga_adaptations"];
    
    anime.watched_status = @([Anime animeWatchedStatusForValue:data[@"watched_status"]]);
    anime.current_episode = data[@"watched_episodes"];
    anime.user_score = [data[@"score"] intValue] == 0 ? @(-1) : data[@"score"];
    
    [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        return anime;
    }
    else return nil;
}

/* Need to cover:
 other_titles -> english, japanese
 rank
 popularity_rank
 classification
 members_score
 members_count
 favorited_count
 synopsis
 genres
 tags
 manga_adaptations
 prequels
 sequels
 side_stories
 parent_story
 character_anime
 spin_offs
 summaries
 altenative_versions
 */


+ (Anime *)editAnime:(NSDictionary *)data {
    if(![AnimeService animeForID:data[@"id"]]) {
        NSLog(@"Anime does not exist; unable to edit!");
        return nil;
    }
    
    NSError *error = nil;
    
    Anime *anime = [AnimeService animeForID:data[@"id"]];
    
    // Edit.
    
    [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        return anime;
    }
    else return nil;
}

+ (void)deleteAnime:(Anime *)anime {
    NSError *error = nil;
    
    [[AnimeService managedObjectContext] deleteObject:anime];
    [[AnimeService managedObjectContext] save:&error];
    
    if(!error) {
        NSLog(@"There was an error trying to delete this anime with ID (%d).", [anime.anime_id intValue]);
    }
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}


@end
