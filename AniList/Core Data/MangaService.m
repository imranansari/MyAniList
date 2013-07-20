//
//  MangaService.m
//  AniList
//
//  Created by Corey Roberts on 6/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaService.h"
#import "AniListAppDelegate.h"
#import "MALHTTPClient.h"

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

+ (BOOL)addMangaListFromSearch:(NSArray *)data {
    for(NSDictionary *result in data) {
        [MangaService addManga:result fromList:YES];
    }
    
    return NO;
}


+ (BOOL)addMangaList:(NSDictionary *)data {
    
    NSDictionary *mangaDetails = data[@"myanimelist"];
    NSDictionary *mangaDictionary = mangaDetails[@"manga"];
    NSDictionary *mangaUserInfo = mangaDetails[@"myinfo"];
    
    for(NSDictionary *mangaItem in mangaDictionary) {
        NSMutableDictionary *manga = [[NSMutableDictionary alloc] init];
        
        [manga addEntriesFromDictionary:@{ kID : @([mangaItem[@"series_mangadb_id"][@"text"] intValue]) }];
        [manga addEntriesFromDictionary:@{ kUserEndDate : mangaItem[@"my_finish_date"][@"text"] }];
        [manga addEntriesFromDictionary:@{ kUserLastUpdated : @([mangaItem[@"my_last_updated"][@"text"] intValue]) }];
        [manga addEntriesFromDictionary:@{ kUserStartDate : mangaItem[@"my_start_date"][@"text"] }];
        [manga addEntriesFromDictionary:@{ kUserRereadingStatus : @([mangaItem[@"my_rereadingg"][@"text"] intValue]) }];
        [manga addEntriesFromDictionary:@{ kUserRereadingChapter : @([mangaItem[@"my_rereading_chap"][@"text"] intValue])}];
        [manga addEntriesFromDictionary:@{ kUserScore : @([mangaItem[@"my_score"][@"text"] intValue])}];
        [manga addEntriesFromDictionary:@{ kUserReadStatus : @([mangaItem[@"my_status"][@"text"] intValue])}];
        [manga addEntriesFromDictionary:@{ kUserChaptersRead : @([mangaItem[@"my_read_chapters"][@"text"] intValue])}];
        [manga addEntriesFromDictionary:@{ kUserVolumesRead : @([mangaItem[@"my_read_volumes"][@"text"] intValue])}];
        [manga addEntriesFromDictionary:@{ kSeriesEndDate : mangaItem[@"series_end"][@"text"] }];
        [manga addEntriesFromDictionary:@{ kVolumes : @([mangaItem[@"series_volumes"][@"text"] intValue]) }];
        [manga addEntriesFromDictionary:@{ kChapters : @([mangaItem[@"series_chapters"][@"text"] intValue]) }];
        [manga addEntriesFromDictionary:@{ kImageURL : mangaItem[@"series_image"][@"text"] }];
        [manga addEntriesFromDictionary:@{ kSeriesStartDate : mangaItem[@"series_start"][@"text"] }];
        [manga addEntriesFromDictionary:@{ kSeriesStatus : mangaItem[@"series_status"][@"text"] }];
        [manga addEntriesFromDictionary:@{ kTitle : mangaItem[@"series_title"][@"text"] }];
        [manga addEntriesFromDictionary:@{ kType : mangaItem[@"series_type"][@"text"] }];
        
        [MangaService addManga:manga fromList:YES];
    }
    
    [[MangaService managedObjectContext] save:nil];
    
    
    return NO;
}

+ (Manga *)addManga:(NSDictionary *)data fromRelatedAnime:(Anime *)anime {
    Manga *relatedManga = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    relatedManga.manga_id = [data[@"manga_id"] isKindOfClass:[NSString class]] ? @([data[@"manga_id"] intValue]) : data[@"manga_id"];
    relatedManga.title = data[kTitle];
    
    [relatedManga addAnime_adaptationsObject:anime];
    
    return relatedManga;
}

+ (Manga *)addRelatedManga:(NSDictionary *)data toManga:(Manga *)manga relationType:(MangaRelation)relationType {
    Manga *relatedManga = [MangaService mangaForID:data[@"manga_id"]];
    
    if(relatedManga) {
        ALLog(@"Related manga exists.");
    }
    else {
        ALLog(@"Related manga does not exist. Creating.");
        relatedManga = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
        relatedManga.manga_id = [data[@"manga_id"] isKindOfClass:[NSString class]] ? @([data[@"manga_id"] intValue]) : data[@"manga_id"];
        relatedManga.title = data[kTitle];
    }
    
    switch (relationType) {
        case MangaRelationPrequel:
//            [relatedManga addSequelsObject:manga];
//            [manga addPrequelsObject:relatedManga];
            break;
        case MangaRelationSequel:
//            [relatedManga addPrequelsObject:manga];
//            [manga addSequelsObject:relatedManga];
            break;
        default:
            break;
    }
    
    return relatedManga;
}

+ (Manga *)addManga:(NSDictionary *)data fromList:(BOOL)fromList {
    Manga *existingManga = [MangaService mangaForID:data[kID]];
    if(existingManga) {
        ALLog(@"Manga exists. Updating details.");
        return [MangaService editManga:data fromList:fromList withObject:existingManga];
    }
    
    NSError *error = nil;
    
    Manga *manga = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[MangaService managedObjectContext]];
    
    manga.manga_id = [data[kID] isKindOfClass:[NSString class]] ? @([data[kID] intValue]) : data[kID];
    manga.title = data[kTitle];
    
    manga.last_updated = data[kUserLastUpdated];
    
    if(data[kImageURL] && ![data[kImageURL] isNull])
        manga.image_url = data[kImageURL];
    else if(data[kImage] && ![data[kImage] isNull])
        manga.image_url = data[kImage];
    
    manga.type = @([Manga mangaTypeForValue:data[kType]]);
    manga.total_chapters = [data[kChapters] isNull] ? @(0) : [data[kChapters] isKindOfClass:[NSString class]] ? @([data[kChapters] intValue]) : data[kChapters];
    manga.total_volumes = [data[kVolumes] isNull] ? @(0) : [data[kVolumes] isKindOfClass:[NSString class]] ? @([data[kVolumes] intValue]) : data[kVolumes];
    manga.status = @([Manga mangaPublishStatusForValue:data[kSeriesStatus]]);
    
    // note: not the user start/end date.
    manga.date_start = [NSDate parseDate:data[kSeriesStartDate]];
    manga.date_finish = [NSDate parseDate:data[kSeriesEndDate]];
    
    manga.user_date_start = [NSDate parseDate:data[kUserStartDate]];
    manga.user_date_finish = [NSDate parseDate:data[kUserEndDate]];
    
    //    anime.classification = data[@"classification"];
    //    anime.average_score = data[@"members_score"];
    //    anime.average_count = data[@"members_count"];
    //    anime.favorited_count = data[@"favorited_count"];
    //    anime.synopsis = data[@"synopsis"];
    //    anime.genres = data[@"genres"];
    //    anime.tags = data[@"tags"];
    //    anime.manga_adaptations = data[@"manga_adaptations"];
    
    manga.read_status = @([Manga mangaReadStatusForValue:data[kUserReadStatus]]);
    manga.current_chapter = data[kUserChaptersRead];
    manga.current_volume = data[kUserVolumesRead];
    manga.user_score = [data[kUserScore] intValue] == 0 ? @(-1) : [data[kUserScore] isKindOfClass:[NSString class]] ? @([data[kUserScore] intValue]) : data[kUserScore];
    
    if(!fromList)
        [[MangaService managedObjectContext] save:&error];
    
    if(!error) {
        return manga;
    }
    else return nil;
}

+ (Manga *)editManga:(NSDictionary *)data fromList:(BOOL)fromList withObject:(Manga *)manga {
    if(![MangaService mangaForID:data[kID]]) {
        ALLog(@"Manga does not exist; unable to edit!");
        return nil;
    }
    
    NSError *error = nil;
    
    manga.manga_id = [data[kID] isKindOfClass:[NSString class]] ? @([data[kID] intValue]) : data[kID];
    manga.title = [data[kTitle] stringByDecodingHTMLEntities];
    
    //    anime.synonyms = data[@"other_titles"];
    // english
    // japanese
    
    // rank (global)
    if(data[kRank] && ![data[kRank] isNull])
        manga.rank = data[kRank];
    
    if(data[kPopularityRank] && ![data[kPopularityRank] isNull])
        manga.popularity_rank = data[kPopularityRank];
    
    // Prequels/sequels
    if(data[kPrequels] && ![data[kPrequels] isNull]) {
        NSArray *prequels = data[kPrequels];
        for(NSDictionary *prequel in prequels) {
            Manga *prequelManga = [self addRelatedManga:prequel toManga:manga relationType:MangaRelationPrequel];
            if(prequelManga) {
                ALLog(@"Prequel found for %@ -> %@.", manga.title, prequelManga.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([prequelManga.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getMangaDetailsForID:prequelManga.manga_id success:^(id operation, id response) {
                        [self addManga:response fromList:NO];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get prequel.");
                    }];
                }
            }
        }
    }
    
    if(data[kSequels] && ![data[kSequels] isNull]) {
        NSArray *sequels = data[kSequels];
        for(NSDictionary *sequel in sequels) {
            Manga *sequelManga = [self addRelatedManga:sequel toManga:manga relationType:MangaRelationSequel];
            if(sequelManga) {
                ALLog(@"Sequel found for %@ -> %@.", manga.title, sequelManga.title);
                
                // We do a simple check; have we added anything else besides the ID and title? If so, don't bother attempting to update.
                if([sequelManga.type intValue] == 0) {
                    [[MALHTTPClient sharedClient] getMangaDetailsForID:sequelManga.manga_id success:^(id operation, id response) {
                        [self addManga:response fromList:NO];
                    } failure:^(id operation, NSError *error) {
                        ALLog(@"Failed to get sequel.");
                    }];
                }
            }
        }
    }
    
    if(data[kImageURL] && ![data[kImageURL] isNull])
        manga.image_url = data[kImageURL];
    else if(data[kImage] && ![data[kImage] isNull])
        manga.image_url = data[kImage];
    
    manga.type = @([Manga mangaTypeForValue:data[kType]]);
    manga.total_chapters = [data[kChapters] isNull] ? @(0) : [data[kChapters] isKindOfClass:[NSString class]] ? @([data[kChapters] intValue]) : data[kChapters];
    manga.total_volumes = [data[kVolumes] isNull] ? @(0) : [data[kVolumes] isKindOfClass:[NSString class]] ? @([data[kVolumes] intValue]) : data[kVolumes];
    manga.status = @([Manga mangaPublishStatusForValue:data[kSeriesStatus]]);
    
    if(data[kSeriesStartDate] && ![data[kSeriesStartDate] isNull])
        manga.date_start = [NSDate parseDate:data[kSeriesStartDate]];
    if(data[kSeriesEndDate] && ![data[kSeriesEndDate] isNull])
        manga.date_finish = [NSDate parseDate:data[kSeriesEndDate]];
    
    if(data[kUserStartDate] && ![data[kUserStartDate] isNull])
        manga.user_date_start = [NSDate parseDate:data[kUserStartDate]];
    if(data[kUserEndDate] && ![data[kUserEndDate] isNull])
        manga.user_date_finish = [NSDate parseDate:data[kUserEndDate]];
    
    //    anime.classification = data[@"classification"];
    if(data[kMembersScore] && ![data[kMembersScore] isNull])
        manga.average_score = [data[kMembersScore] isKindOfClass:[NSString class]] ? @([data[kMembersScore] doubleValue]) : data[kMembersScore];
    if(data[kMembersCount] &&![data[kMembersCount] isNull])
        manga.average_count = data[kMembersCount];
    if(data[kFavoritedCount] &&![data[kFavoritedCount] isNull])
        manga.favorited_count = data[kFavoritedCount];
    if(data[kSynopsis] &&![data[kSynopsis] isNull]) {
        manga.synopsis = [((NSString *)data[kSynopsis]) cleanHTMLTags];
        manga.synopsis = [manga.synopsis stringByDecodingHTMLEntities];
    }
    //    anime.genres = data[@"genres"];
    //    anime.tags = data[@"tags"];
    //    anime.manga_adaptations = data[@"manga_adaptations"];
    
    
    // User details below.
    NSNumber *lastUpdated = data[kUserLastUpdated];
    
    // If the last time we updated (according to the server) is less than what we get from the server,
    // don't bother updating user details.
    if(lastUpdated && [lastUpdated intValue] <= [manga.last_updated intValue]) {
        ALLog(@"Update times match, no need to update user data.");
    }
    else {
        ALLog(@"Update times differ, updating user data...");
        
        if(data[kUserReadStatus] && ![data[kUserReadStatus] isNull])
            manga.read_status = @([Manga mangaReadStatusForValue:data[kUserReadStatus]]);
        
        if(data[kUserChaptersRead] && ![data[kUserChaptersRead] isNull])
            manga.current_chapter = data[kUserChaptersRead];
        if(data[kUserVolumesRead] && ![data[kUserVolumesRead] isNull])
            manga.current_volume = data[kUserVolumesRead];
        
        if(data[kUserScore] && ![data[kUserScore] isNull])
            manga.user_score = ([data[kUserScore] isNull] || [data[kUserScore] intValue] == 0) ? @(-1) : [data[kUserScore] isKindOfClass:[NSString class]] ? @([data[kUserScore] intValue]) : data[kUserScore];
    }
        
    if(!fromList)
        [[MangaService managedObjectContext] save:&error];
    
    if(!error) {
        return manga;
    }
    else return nil;
    
}

+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

#pragma mark - Data Conversion Methods

+ (NSString *)mangaToXML:(NSNumber *)mangaID {
    
    /*
     <chapter>6</chapter>
     <volume>1</volume>
     <status>1</status>
     <score>8</score>
     <downloaded_chapters></downloaded_chapters>
     <times_reread></times_reread>
     <reread_value></reread_value>
     <date_start></date_start>
     <date_finish></date_finish>
     <priority></priority>
     <enable_discussion></enable_discussion>
     <enable_rereading></enable_rereading>
     <comments></comments>
     <scan_group></scan_group>
     <tags></tags>
     <retail_volumes></retail_volumes>
     */
    
    Manga *manga = [MangaService mangaForID:mangaID];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMddyyyy";
    
    NSString *startDate = [dateFormatter stringFromDate:manga.user_date_start];
    NSString *endDate = [dateFormatter stringFromDate:manga.user_date_finish];
    
    NSMutableString *XML = [NSMutableString stringWithString:@"<entry>"];
    [XML appendString:[NSString stringWithFormat:@"<chapter>%d</chapter>", [manga.current_chapter intValue]]];
    [XML appendString:[NSString stringWithFormat:@"<volume>%d</volume>", [manga.current_volume intValue]]];
    [XML appendString:[NSString stringWithFormat:@"<status>%d</status>", [manga.read_status intValue]]];
    
    if([manga.user_score intValue] > 0)
        [XML appendString:[NSString stringWithFormat:@"<score>%d</score>", [manga.user_score intValue]]];
    
    if(startDate)
        [XML appendString:[NSString stringWithFormat:@"<date_start>%@</date_start>", startDate]];
    
    if(endDate)
        [XML appendString:[NSString stringWithFormat:@"<date_finish>%@</date_finish>", endDate]];
    
    [XML appendString:@"</entry>"];
    
    return XML;
}

@end
