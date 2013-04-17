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
    return [super init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Inside a Table View Controller's viewDidLoad method
//    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
//    [refresh addTarget:self
//                action:nil
//      forControlEvents:UIControlEventValueChanged];
//    self.tableView. = refresh;
    
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
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
        cell = (AnimeCell *)nib[0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AnimeViewController *animeVC = [[AnimeViewController alloc] init];
    [self.navigationController pushViewController:animeVC animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell = (AnimeCell *)cell;
    cell.textLabel.text = anime.title;
}

@end
