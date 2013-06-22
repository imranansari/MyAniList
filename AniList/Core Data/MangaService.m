//
//  MangaService.m
//  AniList
//
//  Created by Corey Roberts on 6/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaService.h"
#import "AniListAppDelegate.h"

#define ENTITY_NAME @"Manga"

@implementation MangaService

+ (Manga *)mangaForID:(NSNumber *)ID {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"manga_id == %d", [ID intValue]];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[MangaService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (Manga *)results[0];
    }
    else return nil;
}



+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
