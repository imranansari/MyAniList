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

@interface AnimeListViewController ()

@end

@implementation AnimeListViewController

- (id)init {
    self = [super init];
    if(self) {
        self.title = @"Anime";
        self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
    }
    
    return self;
}

- (void)dealloc {
    [NSFetchedResultsController deleteCacheWithName:[self entityName]];
    NSLog(@"AnimeList deallocating.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)entityName {
    return @"Anime";
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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image]];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
        animeCell.image.image = image;
    }];
    
    [operation start];
}

@end
