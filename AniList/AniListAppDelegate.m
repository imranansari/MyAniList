//
//  AniListAppDelegate.m
//  AniList
//
//  Created by Corey Roberts on 4/15/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AniListAppDelegate.h"

#import "MenuViewController.h"
#import "AnimeListViewController.h"
#import "AniListViewController.h"
#import "LoginViewController.h"
#import "UserProfile.h"
#import "AniListNavigationController.h"

#if TARGET_IPHONE_SIMULATOR
#import <SparkInspector/SparkInspector.h>
#endif

@implementation AniListAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    

    MenuViewController *menuVC = [[MenuViewController alloc] init];
    AnimeListViewController *animeVC = [[AnimeListViewController alloc] init];
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    
    AniListNavigationController *navigationController = [[AniListNavigationController alloc] initWithRootViewController:animeVC];
    
    SWRevealViewController *vc = [[SWRevealViewController alloc] initWithRearViewController:menuVC
                                                                        frontViewController:navigationController];
    
    self.window.rootViewController = vc;
    
    if(![UserProfile userIsLoggedIn]) {
        navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [navigationController presentViewController:loginVC animated:NO completion:nil];
    }
    
    [Crashlytics startWithAPIKey:@"c01aa6f0d36b5000da6aa8c83dda558c23be54f8"];
    [AnalyticsManager sharedInstance];
    
    [self setStyleAttributes];
    
    [self createDirectories];
    
    return YES;
}

- (void)setStyleAttributes {
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

    UIImage *backButton = [UIImage imageNamed:@"back.png"];
    backButton = [backButton resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButton.size.width, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setTitleTextAttributes:
                        @{
                            UITextAttributeFont             : [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0],
                            UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, -1)]
                         }
                                                forState: UIControlStateNormal];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
                        @{
                            UITextAttributeFont             : [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0],
                            UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, -1)]
                         }];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [attributes setValue:[UIColor defaultShadowColor] forKey:UITextAttributeTextShadowColor];
    [attributes setValue:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)] forKey:UITextAttributeTextShadowOffset];
    [attributes setValue:[UIFont fontWithName:@"HelveticaNeue-Light" size:0.0] forKey:UITextAttributeFont];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    // Image between two unselected segments.
    [[UISegmentedControl appearance] setDividerImage:[[UIImage alloc] init]
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    // Image between segment selected on the left and unselected on the right.
    [[UISegmentedControl appearance] setDividerImage:[[UIImage alloc] init]
                                 forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    // Image between segment selected on the right and unselected on the right.
    [[UISegmentedControl appearance] setDividerImage:[[UIImage alloc] init]
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
    // Toolbar
    [[UIToolbar appearance] setBackgroundImage:[[UIImage new] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 5, 22, 5)] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"image_placeholder.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    if([UIApplication isiOS7]) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

        [[UINavigationBar appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor],
                                                                UITextAttributeFont      : [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0] }];
    }
}

- (void)createDirectories {
    if(![self directoryExistsWithName:@"anime"]) {
        [self createDirectoryNamed:@"anime"];
    }
    if(![self directoryExistsWithName:@"manga"]) {
        [self createDirectoryNamed:@"manga"];
    }
}

- (void)createDirectoryNamed:(NSString *)directory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                               NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [directories objectAtIndex:0];
    NSString *newDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
    
    if ([fileManager createDirectoryAtPath:newDirectory withIntermediateDirectories:YES attributes:nil error:NULL] == NO) {
        ALLog(@"Failed to create directory '%@'.", directory);
    }
}

- (BOOL)directoryExistsWithName:(NSString *)directory {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                               NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [directories objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:directory];
    
    BOOL isDirectory;
    BOOL fileExistsAtPath = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    return fileExistsAtPath && isDirectory;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            ALLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AniList_1.0" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AniList.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        ALLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (void)clearDatabase {
    ALLog(@"Clearing persistent store.");
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AniList.sqlite"];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    if(!error) {
        ALLog(@"Persistent store removed.");
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)animeImageDirectory {
    NSString *absoluteURL = [[self applicationDocumentsDirectory] absoluteString];
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@anime/", absoluteURL]];
}

- (NSURL *)mangaImageDirectory {
    NSString *absoluteURL = [[self applicationDocumentsDirectory] absoluteString];
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@manga/", absoluteURL]];
}

@end
