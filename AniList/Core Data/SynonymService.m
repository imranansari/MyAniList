//
//  SynonymService.m
//  AniList
//
//  Created by Corey Roberts on 7/20/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "SynonymService.h"
#import "AniListAppDelegate.h"
#import "Synonym.h"
#import "Anime.h"
#import "Manga.h"

#define ENTITY_NAME @"Synonym"

@implementation SynonymService

+ (Synonym *)addSynonym:(NSString *)title toAnime:(Anime *)anime {
    
    // Before adding, check and make sure we don't already have it.
    for(Synonym *synonym in anime.synonyms) {
        if([synonym.name isEqualToString:title]) {
            ALLog(@"Synonym '%@' for '%@' found!", title, anime.title);
            return synonym;
        }
    }
    
    ALLog(@"Synonym '%@' for '%@' is new, adding to the database.", title, anime.title);
    Synonym *synonym = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[SynonymService managedObjectContext]];
    
    synonym.name = title;
    
    [anime addSynonymsObject:synonym];
    
    [[SynonymService managedObjectContext] save:nil];
    
    return synonym;
}

+ (Synonym *)addSynonym:(NSString *)title toManga:(Manga *)manga {
    
    // Before adding, check and make sure we don't already have it.
    for(Synonym *synonym in manga.synonyms) {
        if([synonym.name isEqualToString:title]) {
            ALLog(@"Synonym '%@' for '%@' found!", title, manga.title);
            return synonym;
        }
    }
    
    ALLog(@"Synonym '%@' for '%@' is new, adding to the database.", title, manga.title);
    
    Synonym *synonym = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[SynonymService managedObjectContext]];
    
    synonym.name = title;
    
    [manga addSynonymsObject:synonym];
    
    [[SynonymService managedObjectContext] save:nil];
    
    return synonym;
}

+ (Synonym *)addEnglishTitle:(NSString *)englishTitle toAnime:(Anime *)anime {
    // Before adding, check and make sure we don't already have it.
    for(Synonym *synonym in anime.english_titles) {
        if([synonym.name isEqualToString:englishTitle]) {
            ALLog(@"English title '%@' for '%@' found!", englishTitle, anime.title);
            return synonym;
        }
    }
    
    ALLog(@"English title '%@' for '%@' is new, adding to the database.", englishTitle, anime.title);
    Synonym *synonym = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[SynonymService managedObjectContext]];
    
    synonym.name = englishTitle;
    
    [anime addEnglish_titlesObject:synonym];
    
    [[SynonymService managedObjectContext] save:nil];
    
    return synonym;
}

+ (Synonym *)addEnglishTitle:(NSString *)englishTitle toManga:(Manga *)manga {
    // Before adding, check and make sure we don't already have it.
    for(Synonym *synonym in manga.english_titles) {
        if([synonym.name isEqualToString:englishTitle]) {
            ALLog(@"English title '%@' for '%@' found!", englishTitle, manga.title);
            return synonym;
        }
    }
    
    ALLog(@"English title '%@' for '%@' is new, adding to the database.", englishTitle, manga.title);
    Synonym *synonym = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[SynonymService managedObjectContext]];
    
    synonym.name = englishTitle;
    
    [manga addEnglish_titlesObject:synonym];
    
    [[SynonymService managedObjectContext] save:nil];
    
    return synonym;
}

+ (Synonym *)addJapaneseTitle:(NSString *)japaneseTitle toAnime:(Anime *)anime {
    // Before adding, check and make sure we don't already have it.
    for(Synonym *synonym in anime.japanese_titles) {
        if([synonym.name isEqualToString:japaneseTitle]) {
            ALLog(@"Japanese title '%@' for '%@' found!", japaneseTitle, anime.title);
            return synonym;
        }
    }
    
    ALLog(@"Japanese title '%@' for '%@' is new, adding to the database.", japaneseTitle, anime.title);
    Synonym *synonym = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[SynonymService managedObjectContext]];
    
    synonym.name = japaneseTitle;
    
    [anime addJapanese_titlesObject:synonym];
    
    [[SynonymService managedObjectContext] save:nil];
    
    return synonym;
}

+ (Synonym *)addJapaneseTitle:(NSString *)japaneseTitle toManga:(Manga *)manga {
    // Before adding, check and make sure we don't already have it.
    for(Synonym *synonym in manga.japanese_titles) {
        if([synonym.name isEqualToString:japaneseTitle]) {
            ALLog(@"Japanese title '%@' for '%@' found!", japaneseTitle, manga.title);
            return synonym;
        }
    }
    
    ALLog(@"Japanese title '%@' for '%@' is new, adding to the database.", japaneseTitle, manga.title);
    Synonym *synonym = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[SynonymService managedObjectContext]];
    
    synonym.name = japaneseTitle;
    
    [manga addJapanese_titlesObject:synonym];
    
    [[SynonymService managedObjectContext] save:nil];
    
    return synonym;
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
