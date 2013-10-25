//
//  TagService.m
//  AniList
//
//  Created by Corey Roberts on 7/20/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "TagService.h"
#import "Tag.h"
#import "Anime.h"
#import "Manga.h"
#import "AniListAppDelegate.h"

#define ENTITY_NAME @"Tag"

@implementation TagService

+ (NSArray *)allTags {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[TagService managedObjectContext]];
    request.entity = entity;
    
    NSError *error = nil;
    NSArray *results = [[TagService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return results;
    }
    else return nil;
}

+ (NSArray *)animeWithTag:(NSString *)tagName {
    Tag *tag = [TagService tagWithName:tagName];
    if(tag) {
        return [tag.anime allObjects];
    }
    else return nil;
}

+ (NSArray *)mangaWithTag:(NSString *)tagName {
    Tag *tag = [TagService tagWithName:tagName];
    if(tag) {
        return [tag.manga allObjects];
    }
    else return nil;
}

+ (Tag *)tagWithName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[TagService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[TagService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (Tag *)results[0];
    }
    else return nil;
}

+ (Tag *)addTag:(NSString *)title toAnime:(Anime *)anime {
    
    // Before adding, check and make sure we don't already have it.
    for(Tag *tag in anime.tags) {
        if([tag.name isEqualToString:title]) {
            ALLog(@"Tag '%@' for '%@' found!", title, anime.title);
            return tag;
        }
    }
    
    
    // If we don't own it, maybe we've already created one? Fetch in the database for the genre and check.
    Tag *tag = [TagService tagWithName:title];
    if(!tag) {
        ALLog(@"Tag '%@' for '%@' is new, adding to the database.", title, anime.title);
        tag = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[TagService managedObjectContext]];
        tag.name = title;
    }
    
    [anime addTagsObject:tag];
    [tag addAnimeObject:anime];
    
    return tag;
}

+ (Tag *)addTag:(NSString *)title toManga:(Manga *)manga {
    
    // Before adding, check and make sure we don't already have it.
    for(Tag *tag in manga.tags) {
        if([tag.name isEqualToString:title]) {
            ALLog(@"Tag '%@' for '%@' found!", title, manga.title);
            return tag;
        }
    }
    
    // If we don't own it, maybe we've already created one? Fetch in the database for the genre and check.
    Tag *tag = [TagService tagWithName:title];
    if(!tag) {
        ALLog(@"Tag '%@' for '%@' is new, adding to the database.", title, manga.title);
        tag = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[TagService managedObjectContext]];
        tag.name = title;
    }
    
    [manga addTagsObject:tag];
    [tag addMangaObject:manga];
    
    return tag;
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
