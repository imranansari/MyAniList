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

static BOOL alreadyFetched = NO;

@interface AnimeListViewController ()

@end

@implementation AnimeListViewController

- (id)init {
    self = [super init];
    if(self) {
        self.title = @"Anime";
        self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:kUserLoggedIn object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [NSFetchedResultsController deleteCacheWithName:[self entityName]];
    ALLog(@"AnimeList deallocating.");
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    if(!alreadyFetched) {
        [self fetchData];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)entityName {
    return @"Anime";
}

- (NSArray *)sortDescriptors {

    if(self.viewTop) {
        return @[[[NSSortDescriptor alloc] initWithKey:@"average_score" ascending:NO]];
    }
    else if(self.viewPopular) {
        return @[[[NSSortDescriptor alloc] initWithKey:@"popularity_rank" ascending:YES]];
    }
    else {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSSortDescriptor *primaryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"watched_status" ascending:YES];
        return @[primaryDescriptor, sortDescriptor];
    }
}

- (NSPredicate *)predicate {
    if(self.viewTop || self.viewPopular) {
        return nil;
    }
    
    return [NSPredicate predicateWithFormat:@"watched_status < 7"];
}

- (NSString *)sectionKeyPathName {
    if(self.viewTop || self.viewPopular) {
        return nil;
    }
    
    return [super sectionKeyPathName];
}

- (void)fetchData {
    if([UserProfile userIsLoggedIn]) {
        
        if(self.viewTop) {
            [[MALHTTPClient sharedClient] getTopAnimeForType:AnimeTypeTV atPage:@(1) success:^(id operation, id response) {
                ALLog(@"Anime list found: %@", response);
                for(NSDictionary *anime in response) {
                    [AnimeService addAnime:anime fromList:NO];
                }
            } failure:^(id operation, NSError *error) {
                ALLog(@"Could not fetch top.");
            }];
        }
        else if(self.viewPopular) {
            
        }
        else {
            [[MALHTTPClient sharedClient] getAnimeListForUser:[[UserProfile profile] username]
                                                 initialFetch:!alreadyFetched
                                                      success:^(NSURLRequest *operation, id response) {
                                                          [AnimeService addAnimeList:(NSDictionary *)response];
                                                          alreadyFetched = YES;
                                                          [super fetchData];
                                                      }
                                                      failure:^(NSURLRequest *operation, NSError *error) {
                                                          // Derp.
                                                          
                                                          [super fetchData];
                                                      }];
        }
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
    
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withObject:anime];

    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[MALHTTPClient sharedClient] deleteAnimeWithID:anime.anime_id success:^(id operation, id response) {
            ALLog(@"'%@' successfully deleted.", anime.title);
        } failure:^(id operation, NSError *error) {
            ALLog(@"'%@' was not successfully deleted.", anime.title);
        }];
        
        AniListAppDelegate *delegate = (AniListAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.managedObjectContext deleteObject:anime];
        
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    AniListNavigationController *navigationController = (AniListNavigationController *)self.navigationController;
    
    AnimeViewController *animeVC = [[AnimeViewController alloc] init];
    animeVC.anime = anime;
    animeVC.currentYBackgroundPosition = navigationController.imageView.frame.origin.y;
    
    [self.navigationController pushViewController:animeVC animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    Anime *anime = (Anime *)object;
    AnimeCell *animeCell = (AnimeCell *)cell;
    animeCell.title.text = anime.title;
    [animeCell.title addShadow];
    [animeCell.title sizeToFit];
    
    animeCell.progress.text = [AnimeCell progressTextForAnime:anime];
    [animeCell.progress addShadow];
    
    if(self.viewTop) {
        animeCell.rank.text = [NSString stringWithFormat:@"#%d (%0.02f)", [self.tableView indexPathForCell:cell].row+1, [anime.average_score doubleValue]];
    }
    else {
        animeCell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
    }
    
    [animeCell.rank addShadow];
    
    animeCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
    [animeCell.type addShadow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
        UIImage *cachedImage = [anime imageForAnime];
        
        if(!cachedImage) {
            [animeCell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    animeCell.image.alpha = 0.0f;
                    animeCell.image.image = image;
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        animeCell.image.alpha = 1.0f;
                    }];
                });
                
                if(!anime.image) {
                    // Save the image onto disk if it doesn't exist or they aren't the same.
                    [anime saveImage:image fromRequest:request];
                }
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                // Log failure.
                ALLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                animeCell.image.image = cachedImage;
            });
        }
    });
}

@end
