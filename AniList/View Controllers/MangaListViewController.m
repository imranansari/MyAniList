//
//  MangaListViewController.m
//  AniList
//
//  Created by Corey Roberts on 4/16/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaListViewController.h"
#import "MangaViewController.h"
#import "MangaService.h"
#import "MangaCell.h"
#import "Manga.h"
#import "MALHTTPClient.h"
#import "AniListAppDelegate.h"

@interface MangaListViewController ()

@end

@implementation MangaListViewController

- (id)init {
    self = [super init];
    if(self) {
        self.title = @"Manga";
        self.sectionHeaders = @[@"Reading", @"Completed", @"On Hold",
                                @"Dropped", @"Plan To Read"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadList) name:kUserLoggedIn object:nil];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"MangaList deallocating.");
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
    return @"Manga";
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *statusDescriptor = [[NSSortDescriptor alloc] initWithKey:@"read_status" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    return @[statusDescriptor, sortDescriptor];
}

- (NSPredicate *)predicate {
    return [NSPredicate predicateWithFormat:@"read_status < 7"];
}

- (void)loadList {
    if([UserProfile userIsLoggedIn]) {
        [[MALHTTPClient sharedClient] getMangaListForUser:[[UserProfile profile] username]
                                                  success:^(NSURLRequest *operation, id response) {
                                                      [MangaService addMangaList:(NSDictionary *)response];
//                                                      [AnimeService addAnimeList:(NSDictionary *)response];
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
    return [MangaCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"Cell";
    
    MangaCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MangaCell" owner:self options:nil];
        cell = (MangaCell *)nib[0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    MangaViewController *mvc = [[MangaViewController alloc] init];
    mvc.manga = manga;
    
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath  {
    
    Manga *manga = [self.fetchedResultsController objectAtIndexPath:indexPath];
    MangaCell *mangaCell = (MangaCell *)cell;
    mangaCell.title.text = manga.title;
    [mangaCell.title addShadow];
    [mangaCell.title sizeToFit];
    
    mangaCell.progress.text = [MangaCell progressTextForManga:manga];
    [mangaCell.progress addShadow];
    
    mangaCell.rank.text = [manga.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [manga.user_score intValue]] : @"";
    [mangaCell.rank addShadow];
    
    mangaCell.type.text = [Manga stringForMangaType:[manga.type intValue]];
    [mangaCell.type addShadow];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:manga.image_url]];
    NSString *cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, manga.image];
    UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImageLocation];
    
    if(cachedImage) {
        NSLog(@"Image on disk exists for %@.", manga.title);
    }
    else {
        NSLog(@"Image on disk does not exist for %@.", manga.title);
    }
    
    [mangaCell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        NSLog(@"Got image for manga %@.", manga.title);
        mangaCell.image.image = image;
        
        // Save the image onto disk if it doesn't exist or they aren't the same.
#warning - need to compare cached image to this new image, and replace if necessary.
#warning - will need to be fast and efficient! Alternatively, we can recycle the cache if need be.
        if(!manga.image) {
            NSLog(@"Saving image to disk...");
            NSArray *segmentedURL = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
            NSString *filename = [segmentedURL lastObject];
            
            NSString *animeImagePath = [NSString stringWithFormat:@"%@/manga/%@", documentsDirectory, filename];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                BOOL saved = NO;
                saved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:animeImagePath options:NSAtomicWrite error:nil];
                NSLog(@"Image %@", saved ? @"saved." : @"did not save.");
            });
            
            // Only save relative URL since Documents URL can change on updates.
            manga.image = [NSString stringWithFormat:@"manga/%@", filename];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        // Log failure.
        NSLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
    }];

    
}

@end
