//
//  SettingsViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "AniListTableView.h"
#import "AnimeService.h"
#import "MangaService.h"
#import "MALHTTPClient.h"
#import "CRTransitionLabel.h"
#import "SettingsCell.h"

#define kOptionName @"kOptionName"
#define kAction     @"kAction"

@interface SettingsViewController ()
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *status;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.options = @[
                         @{
                             kOptionName    : @"Enable Genre/Tag Support",
                             kAction        : @"enableGenreTagSupport"
                             },
                         @{
                             kOptionName    : @"Clear Local Images",
                             kAction        : @"clearLocalImages"
                             },
                         @{
                             kOptionName    : @"Reset Anime Cache",
                             kAction        : @"resetAnimeCache"
                             },
                         @{
                             kOptionName    : @"Reset Manga Cache",
                             kAction        : @"resetMangaCache"
                             },
                         ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.status.transitionRate = 0.2f;
    self.status.alpha = 0.0f;
    self.progressView.alpha = 0.0f;
    
    self.title = @"Settings";
    
    SWRevealViewController *revealController = self.revealViewController;
    
    UINavigationController *nvc = ((UINavigationController *)self.revealViewController.frontViewController);
    
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SettingsCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingsCell" owner:self options:nil];
        cell = (SettingsCell *)nib[0];
        [(SettingsCell *)cell setup];
    }
    
    NSDictionary *item = self.options[indexPath.row];
    
    cell.option.text = item[kOptionName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self enableGenreTagSupport];
}

#pragma mark - Action Methods

- (void)enableGenreTagSupport {
    // Confirm to the user that this will take a while.
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will download additional information for your anime and manga lists. This may take a while. Do you wish to continue?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", nil];
    
    [actionSheet showInView:self.view];
}

- (void)downloadInfo {
    
    self.status.text = @"Progress: 0%";
    self.progressView.progress = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.status.alpha = 1.0f;
        self.progressView.alpha = 1.0f;
    }];
    
    NSArray *animeArray = [AnimeService allAnime];
    NSArray *mangaArray = [MangaService allManga];
    float total = animeArray.count + mangaArray.count;
    float __block counter = 0;
    
    for(Anime *anime in animeArray) {
        double delayInSeconds = 1.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[MALHTTPClient sharedClient] getAnimeDetailsForID:anime.anime_id success:^(id operation, id response) {
                counter++;
                [AnimeService addAnime:response];
                
                ALLog(@"Recieved extra details for '%@.'", anime.title);
                ALLog(@"Progress: %0.0f completed", (counter / total) * 100);
                
                self.status.text = [NSString stringWithFormat:@"Progress: %0.0f%%", (counter / total) * 100];
                self.progressView.progress = counter / total;
                
            } failure:^(id operation, NSError *error) {
                counter++;
                
                ALLog(@"Failed to get extra details for '%@.'", anime.title);
                ALLog(@"Progress: %0.0f completed", (counter / total) * 100);
                
                self.status.text = [NSString stringWithFormat:@"Progress: %0.0f%%", (counter / total) * 100];
                self.progressView.progress = counter / total;
            }];
        });
    }
    
    for(Manga *manga in mangaArray) {
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[MALHTTPClient sharedClient] getMangaDetailsForID:manga.manga_id success:^(id operation, id response) {
                counter++;
                [MangaService addManga:response];
                
                ALLog(@"Recieved extra details for '%@.'", manga.title);
                ALLog(@"Progress: %0.0f completed", (counter / total) * 100);
                
                self.status.text = [NSString stringWithFormat:@"Progress: %0.0f%%", (counter / total) * 100];
                self.progressView.progress = counter / total;
                
            } failure:^(id operation, NSError *error) {
                counter++;
                
                ALLog(@"Failed to get extra details for '%@.'", manga.title);
                ALLog(@"Progress: %0.0f completed", (counter / total) * 100);
                
                self.status.text = [NSString stringWithFormat:@"Progress: %0.0f%%", (counter / total) * 100];
                self.progressView.progress = counter / total;
            }];
        });
    }
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        [self downloadInfo];
    }
}

@end
