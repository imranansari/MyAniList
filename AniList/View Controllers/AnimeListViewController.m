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

@interface AnimeListViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation AnimeListViewController

- (id)init {
    self = [super init];
    if(self) {
        self.sectionHeaders = @[@"Watching", @"Completed", @"On Hold", @"Dropped", @"Plan To Watch"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.navigation.barTitle.text = @"Anime";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mal-api.com/animelist/spacepyro"]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            NSLog(@"Success!");
                                                                                            NSArray *animeList = [JSON objectForKey:@"anime"];
                                                                                            for(NSDictionary *animeItem in animeList) {
                                                                                                [AnimeService addAnime:animeItem];
                                                                                            }
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"Failure");
                                                                                        }];
    
    [operation start];
                                         
	// Do any additional setup after loading the view.
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    AnimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
//        AnimeCell *cell = [AnimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"
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
    animeCell.progress.text = [NSString stringWithFormat:@"On episode %d of %d", [anime.current_episode intValue], [anime.total_episodes intValue]];
    animeCell.rank.text = [NSString stringWithFormat:@"%d", [anime.user_score intValue]];
    animeCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
//    animeCell.backgroundView = nil;
    animeCell.backgroundColor = [UIColor clearColor];
    animeCell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image]];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
        
        animeCell.image.image = image;
//        [UIView animateWithDuration:0.3f animations:^{
//            animeCell.image.alpha = 1.0f;
//            animeCell.image.image = image;
//        }];
    }];
    
    [operation start];
}

@end
