//
//  FriendService.m
//  AniList
//
//  Created by Corey Roberts on 8/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "FriendService.h"
#import "Friend.h"
#import "AniListAppDelegate.h"

#define ENTITY_NAME @"Friend"

@implementation FriendService

+ (Friend *)addFriend:(NSString *)username {
    Friend *friend = [FriendService friendWithUsername:username];
    
    if(!friend) {
        ALLog(@"Friend '%@' is new, adding to the database.", username);
        friend = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[FriendService managedObjectContext]];
        friend.username = username;
    }
    
    return friend;
}

+ (Friend *)friendWithUsername:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[FriendService managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", name];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [[FriendService managedObjectContext] executeFetchRequest:request error:&error];
    
    if(results.count) {
        return (Friend *)results[0];
    }
    else return nil;
}


+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
