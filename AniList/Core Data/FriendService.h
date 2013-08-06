//
//  FriendService.h
//  AniList
//
//  Created by Corey Roberts on 8/6/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Friend;

@interface FriendService : NSObject

+ (Friend *)addFriend:(NSString *)username;
+ (Friend *)deleteFriend:(Friend *)username;

@end
