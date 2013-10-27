//
//  AniListAppDelegate.h
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Crashlytics/Crashlytics.h>
#import "FICImageCache.h"

@interface AniListAppDelegate : UIResponder <UIApplicationDelegate, FICImageCacheDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)animeImageDirectory;
- (NSURL *)mangaImageDirectory;
- (void)clearDatabase;

@end
