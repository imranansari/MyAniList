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

+ (Genre *)addGenre:(NSString *)title toAnime:(Anime *)anime {
    
    // Before adding, check and make sure we don't already have it.
    for(Genre *genre in anime.genres) {
        if([genre.name isEqualToString:title]) {
            ALLog(@"Genre '%@' for '%@' found!", title, anime.title);
            return genre;
        }
    }
    
    
    // If we don't own it, maybe we've already created one? Fetch in the database for the genre and check.
    
    
    
    ALLog(@"Genre '%@' for '%@' is new, adding to the database.", title, anime.title);
    Genre *genre = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[GenreService managedObjectContext]];
    
    genre.name = title;
    
    [anime addGenresObject:genre];
    
    return genre;
}

+ (Genre *)addGenre:(NSString *)title toManga:(Manga *)manga {
    
    // Before adding, check and make sure we don't already have it.
    for(Genre *genre in manga.genres) {
        if([genre.name isEqualToString:title]) {
            ALLog(@"Genre '%@' for '%@' found!", title, manga.title);
            return genre;
        }
    }
    
    ALLog(@"Genre '%@' for '%@' is new, adding to the database.", title, manga.title);
    
    Genre *genre = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[GenreService managedObjectContext]];
    
    genre.name = title;
    
    [manga addGenresObject:genre];
    
    return genre;
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
