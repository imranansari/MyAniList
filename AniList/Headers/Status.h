//
//  Status.h
//  AniList
//
//  Created by Corey Roberts on 4/17/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#ifndef AniList_Status_h
#define AniList_Status_h

typedef enum {
//    k
    
} AirStatus;

// 1/watching, 2/completed, 3/onhold, 4/dropped, 6/plantowatch
typedef enum {
    kWatching = 1,
    kCompleted,
    kOnHold,
    kDropped,
    kPlanToWatch = 6
} WatchingStatus;

//int OR string. 1/reading, 2/completed, 3/onhold, 4/dropped, 6/plantoread
typedef enum {
    kReading = 1,
    
} ReadingStatus;

#endif
