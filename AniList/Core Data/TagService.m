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

+ (Tag *)addTag:(NSString *)title toAnime:(Anime *)anime {
    
    // Before adding, check and make sure we don't already have it.
    for(Tag *tag in anime.tags) {
        if([tag.name isEqualToString:title]) {
            ALLog(@"Tag '%@' for '%@' found!", title, anime.title);
            return tag;
        }
    }
    
    ALLog(@"Tag '%@' for '%@' is new, adding to the database.", title, anime.title);
    Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[TagService managedObjectContext]];
    
    tag.name = title;
    
    [anime addTagsObject:tag];
    
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
    
    ALLog(@"Tag '%@' for '%@' is new, adding to the database.", title, manga.title);
    
    Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[TagService managedObjectContext]];
    
    tag.name = title;
    
    [manga addTagsObject:tag];
    
    return tag;
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
