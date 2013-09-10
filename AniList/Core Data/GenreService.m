//
//  GenreService.m
//  AniList
//
//  Created by Corey Roberts on 7/20/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "GenreService.h"
#import "Genre.h"
#import "AniListAppDelegate.h"
#import "Anime.h"
#import "Manga.h"

#define ENTITY_NAME @"Genre"

@implementation GenreService

+ (NSArray *)animeWithGenre:(NSString *)genreName {
    return [self animeWithGenre:genreName withContext:[GenreService managedObjectContext]];
}

+ (NSArray *)animeWithGenre:(NSString *)genreName withContext:(NSManagedObjectContext *)context {
    Genre *genre = [GenreService genreWithName:genreName withContext:context];
    if(genre) {
        return [genre.anime allObjects];
    }
    else return nil;
}

+ (NSArray *)mangaWithGenre:(NSString *)genreName {
    return [self mangaWithGenre:genreName withContext:[GenreService managedObjectContext]];
}

+ (NSArray *)mangaWithGenre:(NSString *)genreName withContext:(NSManagedObjectContext *)context {
    Genre *genre = [GenreService genreWithName:genreName withContext:context];
    if(genre) {
        return [genre.manga allObjects];
    }
    else return nil;
}


+ (Genre *)genreWithName:(NSString *)name withContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (Genre *)results[0];
    }
    else return nil;
}

+ (Genre *)addGenre:(NSString *)title toAnime:(Anime *)anime withContext:(NSManagedObjectContext *)context {
    
    // Before adding, check and make sure we don't already have it.
    for(Genre *genre in anime.genres) {
        if([genre.name isEqualToString:title]) {
            ALLog(@"Genre '%@' for '%@' found!", title, anime.title);
            return genre;
        }
    }
    
    
    // If we don't own it, maybe we've already created one? Fetch in the database for the genre and check.
    Genre *genre = [GenreService genreWithName:title withContext:context];
    if(!genre) {
        ALLog(@"Genre '%@' for '%@' is new, adding to the database.", title, anime.title);
        genre = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:context];
        genre.name = title;
    }
    
    [anime addGenresObject:genre];
    
    return genre;
}

+ (Genre *)addGenre:(NSString *)title toManga:(Manga *)manga withContext:(NSManagedObjectContext *)context {
    
    // Before adding, check and make sure we don't already have it.
    for(Genre *genre in manga.genres) {
        if([genre.name isEqualToString:title]) {
            ALLog(@"Genre '%@' for '%@' found!", title, manga.title);
            return genre;
        }
    }
    
    ALLog(@"Genre '%@' for '%@' is new, adding to the database.", title, manga.title);
    
    Genre *genre = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:context];
    
    genre.name = title;
    
    [manga addGenresObject:genre];
    
    return genre;
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}


@end
