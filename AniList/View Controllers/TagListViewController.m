//
//  TagListViewController.m
//  AniList
//
//  Created by Corey Roberts on 7/21/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "TagListViewController.h"
#import "CRTransitionLabel.h"
#import "AniListAppDelegate.h"
#import "Anime.h"
#import "Manga.h"
#import "TagService.h"
#import "GenreService.h"
#import "AniListCell.h"
#import "MALHTTPClient.h"
#import "AnimeCell.h"
#import "Tag.h"
#import "Genre.h"

@interface TagListViewController ()
@property (nonatomic, copy) NSArray *sectionHeaders;
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *topSectionLabel;
@property (nonatomic, strong) NSArray *taggedAnime;
@end

@implementation TagListViewController

- (id)init {
    return [self initWithNibName:@"TagListViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBackButton = NO;
    }
    return self;
}

- (void)dealloc {
    ALLog(@"TagList deallocating.");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    SWRevealViewController *revealController = self.revealViewController;
    
    AniListNavigationController *nvc = ((AniListNavigationController *)self.revealViewController.frontViewController);
    
    self.topSectionLabel.backgroundColor = [UIColor clearColor];
    self.topSectionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    self.topSectionLabel.textColor = [UIColor lightGrayColor];
    self.topSectionLabel.textAlignment = NSTextAlignmentCenter;
    
    // This value is implicitly set to YES in iOS 7.0.
    nvc.navigationBar.translucent = YES; // Setting this slides the view up, underneath the nav bar (otherwise it'll appear black)
    
    if([[UIDevice currentDevice].systemVersion compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        //        nvc.navigationBar.barTintColor = [UIColor clearColor];
    }
    else {
        const float colorMask[6] = {222, 255, 222, 255, 222, 255};
        UIImage *img = [[UIImage alloc] init];
        UIImage *maskedImage = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];
        
        [nvc.navigationBar setShadowImage:[[UIImage alloc] init]];
        [nvc.navigationBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault];
    }

    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.075f);
    gradient.endPoint = CGPointMake(0.0f, 0.10f);
    
    self.maskView.layer.mask = gradient;
    
    self.topSectionLabel.text = @"";
    self.topSectionLabel.alpha = 0.0f;
    
    // Fetch anime.
    if(self.tag) {
        self.taggedAnime = [TagService animeWithTag:self.tag];
        self.title = self.tag;
    }
    else if(self.genre) {
        self.taggedAnime = [GenreService animeWithGenre:self.genre];
        self.title = [NSString stringWithFormat:@"%@ Anime", self.genre];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AniListCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    return [sectionInfo numberOfObjects];
    return [self.taggedAnime count];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSNumber *headerSection = @(0);//[self.fetchedResultsController sectionIndexTitles][section];
//    NSString *count = [NSString stringWithFormat:@"%d", [self.tableView numberOfRowsInSection:section]];
//    return [UIView tableHeaderWithPrimaryText:self.sectionHeaders[[headerSection intValue]] andSecondaryText:count];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AnimeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnimeCell" owner:self options:nil];
        cell = (AnimeCell *)nib[0];
    }
    
    Anime *anime = self.taggedAnime[indexPath.row];
    [self configureCell:cell withObject:anime];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object {
    AniListCell *anilistCell = (AniListCell *)cell;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURLRequest *imageRequest;
    NSString *cachedImageLocation = @"";
    
#warning - all of this code is gross. Will need to add a core data parent entity here with common traits.
    
    Anime *anime = (Anime *)object;
    anilistCell.title.text = anime.title;
    anilistCell.progress.text = [Anime stringForAnimeWatchedStatus:[anime.watched_status intValue]];
    anilistCell.rank.text = [anime.user_score intValue] != -1 ? [NSString stringWithFormat:@"%d", [anime.user_score intValue]] : @"";
    anilistCell.type.text = [Anime stringForAnimeType:[anime.type intValue]];
    imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:anime.image_url]];
    cachedImageLocation = [NSString stringWithFormat:@"%@/%@", documentsDirectory, anime.image];
    
    [anilistCell.title sizeToFit];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *cachedImage = [UIImage imageWithContentsOfFile:cachedImageLocation];
        
        if(!cachedImage) {
            [anilistCell.image setImageWithURLRequest:imageRequest placeholderImage:cachedImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    anilistCell.image.alpha = 0.0f;
                    anilistCell.image.image = image;
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        anilistCell.image.alpha = 1.0f;
                    }];
                });
                
                // Save the image onto disk if it doesn't exist or they aren't the same.
                if([object isKindOfClass:[Anime class]]) {
                    Anime *anime = (Anime *)object;
                    [anime saveImage:image fromRequest:imageRequest];
                }
                else if([object isKindOfClass:[Manga class]]) {
                    Manga *manga = (Manga *)object;
                    [manga saveImage:image fromRequest:imageRequest];
                }
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                // Log failure.
                ALLog(@"Couldn't fetch image at URL %@.", [request.URL absoluteString]);
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                anilistCell.image.image = cachedImage;
            });
        }
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    ALLog(@"content offset: %f", scrollView.contentOffset.y);
    
    if(scrollView.contentOffset.y > 36) {
        NSArray *visibleSections = [[[NSSet setWithArray:[[self.tableView indexPathsForVisibleRows] valueForKey:@"section"]] allObjects] sortedArrayUsingSelector:@selector(compare:)];
        //        ALLog(@"indices: %@", [self.tableView indexPathsForVisibleRows]);
        //        ALLog(@"visible sections: %@", visibleSections);
        
        if(visibleSections.count > 0) {
            int topSection = [visibleSections[0] intValue];
            
            NSNumber *headerSection = @(0);//[self.fetchedResultsController sectionIndexTitles][topSection];
            
            self.topSectionLabel.text = self.sectionHeaders[[headerSection intValue]];
            
            [UIView animateWithDuration:0.2f animations:^{
                self.topSectionLabel.alpha = 1.0f;
            }];
        }
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.topSectionLabel.alpha = 0.0f;
        }];
    }
}

@end
