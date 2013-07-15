//
//  AnimeListViewController.m
//  AniList
//
//  Created by Corey Roberts on 4/16/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeListViewController.h"
#import "AnimeViewController.h"
#import "AnimeService.h"
#import "AnimeCell.h"
#import "Anime.h"
#import "MALHTTPClient.h"
#import "AniListAppDelegate.h"

@interface AnimeListViewController ()

@end

@implementation AnimeListViewController

- (id)init {
    self = [super init];
    if(self) {
        self.title = @"Anime";
        self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadList) name:kUserLoggedIn object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [NSFetchedResultsController deleteCacheWithName:[self entityName]];
    ALLog(@"AnimeList deallocating.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)entityName {
    return @"Anime";
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *statusDescriptor = [[NSSortDescriptor alloc] initWithKey:@"watched_status" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    return @[statusDescriptor, sortDescriptor];
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"watched_status < 7"];
}

- (void)loadList {
    if([UserProfile userIsLoggedIn]) {
        [[MALHTTPClient sharedClient] getAnimeListForUser:[[UserProfile profile] username]
                                                  success:^(NSURLRequest *operation, id response) {
                                                      [AnimeService addAnimeList:(NSDictionary *)response];
                                                  }
                                                  failure:^(NSURLRequest *operation, NSError *error) {
                                                      // Derp.
                                                  }];
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AnimeCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    AnimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
        cell = (AnimeCell *)nib[0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    AnimeViewController *animeVC = [[AnimeViewController alloc] init];
    animeVC.anime = anime;
        
    [self.navigationController pushViewController:animeVC animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    AnimeCell *animeCell = (AnimeCell *)cell;
    animeCell.title.text = anime.title;
    [animeCell.title addShadow];
    [animeCell.title sizeToFit];
    
    animeCell.progress.text = [AnimeCell progressTextForAnime:anime];
    [animeCell.progress addShadow];
    
    animeCell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
    [animeCell.rank addShadow];
    
    animeCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
    [animeCell.type addShadow];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];

    UIImage *cachedImage = [anime imageForAnime];

    if(cachedImage) {
//        ALLog(@"Image on disk exists for %@.", anime.title);
    }
    else {
//        ALLog(@"Image on disk does not exist for %@.", anime.title);
    }

//    ALLog(@"location: %@", cachedImageLocation);
    
    if(!cachedImage) {
    [animeCell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
//        ALLog(@"Got image for anime %@.", anime.title);
        animeCell.image.image = image;
        
        // Save the image onto disk if it doesn't exist or they aren't the same.
#warning - need to compare cached image to this new image, and replace if necessary.
#warning - will need to be fast and efficient! Alternatively, we can recycle the cache if need be.
        if(!anime.image) {
//            ALLog(@"Saving image to disk...");
            NSArray *segmentedURL = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
            NSString *filename = [segmentedURL lastObject];
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *animeImagePath = [NSString stringWithFormat:@"%@/anime/%@", documentsDirectory, filename];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                BOOL saved = NO;
                saved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:animeImagePath options:NSAtomicWrite error:nil];
//                ALLog(@"Image %@", saved ? @"saved." : @"did not save.");
            });
            
            // Only save relative URL since Documents URL can change on updates.
            anime.image = [NSString stringWithFormat:@"anime/%@", filename];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        // Log failure.
//        ALLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
    }];
    }
    else {
        animeCell.image.image = cachedImage;
    }
}

@end
