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

#warning - check before adding a new person
    
    ALLog(@"Friend '%@' is new, adding to the database.", username);
    Friend *friend = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[FriendService managedObjectContext]];
    
    friend.username = username;
    
    return friend;
}


+ (NSManagedObjectContext *)managedObjectContext {
    AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

@end
