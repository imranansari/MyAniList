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
#import "FICImageCache.h"
#import "ReportProblemViewController.h"

#define kOptionName @"kOptionName"
#define kAction     @"kAction"

@interface SettingsViewController ()
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSArray *apiStatus;
@property (nonatomic, weak) IBOutlet CRTransitionLabel *status;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@property (nonatomic, assign) BOOL apiStatusFetched;
@property (nonatomic, assign) BOOL unofficialApiStatusFetched;

@property (nonatomic, assign) BOOL unofficialApiAvailable;

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
                             kAction        : @"confirmClearImageCache"
                             },
                         @{
                             kOptionName    : @"Reset Local Anime Cache",
                             kAction        : @"confirmClearAnimeList"
                             },
                         @{
                             kOptionName    : @"Reset Local Manga Cache",
                             kAction        : @"confirmClearMangaList"
                             },
                         @{
                             kOptionName    : @"Submit Feedback",
                             kAction        : @"reportProblem"
                             }
                         ];
        
        self.apiStatus = @[
                        @{
                            kOptionName    : @"Checking API Status...",
                            kAction        : @"checkOfficialAPIStatus"
                            },
                        @{
                            kOptionName    : @"Checking Unofficial API Status...",
                            kAction        : @"checkUnofficialAPIStatus"
                            }
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
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.scrollEnabled = NO;
    
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
    
    [self checkOfficialAPIStatus];
    [self checkUnofficialAPIStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[AnalyticsManager sharedInstance] trackView:kSettingsScreen];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SettingsCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.options.count;
            break;
        case 1:
            return self.apiStatus.count;
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingsCell" owner:self options:nil];
        cell = (SettingsCell *)nib[0];
        [(SettingsCell *)cell setup];
    }
    
    NSArray *array;
    
    switch (indexPath.section) {
        case 0: {
            cell.accessoryView = nil;
            array = self.options;
            break;
        }
        case 1: {
            if((indexPath.row == 0 && self.apiStatusFetched) || (indexPath.row == 1 && self.unofficialApiStatusFetched)) {
                [UIView animateWithDuration:0.3f
                                 animations:^{
                                     cell.accessoryView.alpha = 0.0f;
                                 }];
            }
            else {
                UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                cell.accessoryView = indicator;
                [indicator startAnimating];
            }
            
            array = self.apiStatus;
            break;
        }
        default:
            array = nil;
            break;
    }
    
    NSDictionary *item = array[indexPath.row];
    
    cell.option.text = item[kOptionName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *options = nil;
    
    switch (indexPath.section) {
        case 0:
            options = self.options;
            break;
        case 1:
            options = self.apiStatus;
            break;
    }
    
    SEL selector = NSSelectorFromString(options[indexPath.row][kAction]);
    
    if([self canPerformAction:selector withSender:nil]) {
        [self performSelector:selector];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)checkOfficialAPIStatus {
    
    NSMutableArray *APIArray = [self.apiStatus mutableCopy];
    NSMutableDictionary *item = nil;
    int index = 0;
    
    for(NSDictionary *option in self.apiStatus) {
        if([option[kAction] isEqualToString:@"checkOfficialAPIStatus"]) {
            item = [option mutableCopy];
            index = [self.apiStatus indexOfObject:option];
            break;
        }
    }
    
    item[kOptionName] = @"Checking API status...";
    [APIArray replaceObjectAtIndex:index withObject:item];
    self.apiStatus = [APIArray copy];
    self.apiStatusFetched = NO;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    
    [[MALHTTPClient sharedClient] officialAPIAvailable:^(id operation, id response) {
        ALLog(@"Official API is available.");
        item[kOptionName] = @"Official API is available.";
        [APIArray replaceObjectAtIndex:index withObject:item];
        self.apiStatus = [APIArray copy];
        self.apiStatusFetched = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    } failure:^(id operation, NSError *error) {
        ALLog(@"Official API is currently unavailable.");
        item[kOptionName] = @"Official API is currently unavailable.";
        [APIArray replaceObjectAtIndex:index withObject:item];
        self.apiStatus = [APIArray copy];
        self.apiStatusFetched = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    }];

}

- (void)checkUnofficialAPIStatus {
    
    NSMutableArray *APIArray = [self.apiStatus mutableCopy];
    NSMutableDictionary *item = nil;
    int index = 0;
    
    for(NSDictionary *option in self.apiStatus) {
        if([option[kAction] isEqualToString:@"checkUnofficialAPIStatus"]) {
            item = [option mutableCopy];
            index = [self.apiStatus indexOfObject:option];
            break;
        }
    }
    
    item[kOptionName] = @"Checking Unofficial API...";
    [APIArray replaceObjectAtIndex:index withObject:item];
    self.apiStatus = [APIArray copy];
    self.unofficialApiStatusFetched = NO;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    
    [[MALHTTPClient sharedClient] unofficialAPIAvailable:^(id operation, id response) {
        ALLog(@"Unofficial API Status is available.");
        item[kOptionName] = @"Unofficial API is available.";
        [APIArray replaceObjectAtIndex:index withObject:item];
        self.apiStatus = [APIArray copy];
        self.unofficialApiStatusFetched = YES;
        self.unofficialApiAvailable = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    } failure:^(id operation, NSError *error) {
        ALLog(@"Unofficial API Status is currently unavailable.");
        item[kOptionName] = @"Unofficial API is currently unavailable.";
        [APIArray replaceObjectAtIndex:index withObject:item];
        self.apiStatus = [APIArray copy];
        self.unofficialApiStatusFetched = YES;
        self.unofficialApiAvailable = NO;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)reportProblem {
    ReportProblemViewController *vc = [[ReportProblemViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action Methods

- (void)confirmClearAnimeList {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will clear your local anime list. Use this only if you or your friend's anime list doesn't look right or updated. Proceed?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:@"Yes"
                                                    otherButtonTitles:nil, nil];
    
    actionSheet.tag = ClearAnimeListTag;
    [actionSheet showInView:self.view];
}

- (void)confirmClearMangaList {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will clear your local manga list. Use this only if you or your friend's manga list doesn't look right or updated. Proceed?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:@"Yes"
                                                    otherButtonTitles:nil, nil];
    
    actionSheet.tag = ClearMangaListTag;
    [actionSheet showInView:self.view];
}

- (void)confirmClearImageCache {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will clear all anime and manga posters. These will have to be downloaded again. Do you wish to continue?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:@"Yes"
                                                    otherButtonTitles:nil, nil];
    
    actionSheet.tag = ClearImageCacheTag;
    [actionSheet showInView:self.view];
}

- (void)enableGenreTagSupport {
    if(self.unofficialApiStatusFetched) {
        if(self.unofficialApiAvailable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will download additional information for your anime and manga lists. This may take a while. Do you wish to continue?"
                                                                     delegate:self
                                                            cancelButtonTitle:@"No"
                                                       destructiveButtonTitle:@"Yes"
                                                            otherButtonTitles:nil, nil];
            
            actionSheet.tag = EnableGenreTagSupportTag;
            [actionSheet showInView:self.view];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unofficial API Required"
                                                            message:@"Sorry, this feature requires the unofficial server to be available. Please try again later."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil, nil];
            
            [alert show];
        }
    }
}

- (void)downloadInfo {
    [AnimeService downloadInfo];
//    [MangaService downloadInfo];
}

- (void)clearImageCache {
    [[FICImageCache sharedImageCache] reset];
}

- (void)clearAnimeList {
    [AnimeService deleteAllAnime];
}

- (void)clearMangaList {
    [MangaService deleteAllManga];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case EnableGenreTagSupportTag:
            if(buttonIndex == 0)
                [self downloadInfo];
            break;
        case ClearImageCacheTag:
            if(buttonIndex == 0)
                [self clearImageCache];
            break;
        case ClearAnimeListTag:
            if(buttonIndex == 0)
                [self clearAnimeList];
            break;
        case ClearMangaListTag:
            if(buttonIndex == 0)
                [self clearMangaList];
            break;
        default:
            break;
    }
}

@end
