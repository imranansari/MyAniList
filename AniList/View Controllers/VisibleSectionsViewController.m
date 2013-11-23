//
//  VisibleSectionsViewController.m
//  AniList
//
//  Created by Corey Roberts on 11/22/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "VisibleSectionsViewController.h"
#import "AniListTableView.h"
#import "SettingsCell.h"

@interface VisibleSectionsViewController ()
@property (nonatomic, weak) IBOutlet UIView *maskView;
@property (nonatomic, weak) IBOutlet AniListTableView *tableView;
@property (nonatomic, strong) NSArray *options;
@end

@implementation VisibleSectionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.options = @[@"Watching/Reading", @"Completed", @"On Hold", @"Dropped", @"Plan to Watch/Read"];
    }
    return self;
}

- (void)viewDidLoad {
    
    self.hidesBackButton = NO;
    
    [super viewDidLoad];
    
    self.title = @"Visible Sections";
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    
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
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.maskView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    gradient.startPoint = CGPointMake(0.0, 0.075f);
    gradient.endPoint = CGPointMake(0.0f, 0.10f);
    
    self.maskView.layer.mask = gradient;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[AnalyticsManager sharedInstance] trackView:kSettingsScreen];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SettingsCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SettingsCell" owner:self options:nil];
        cell = (SettingsCell *)nib[0];
        [(SettingsCell *)cell setup];
    }
    
    cell.tintColor = [UIColor whiteColor];
    cell.option.text = self.options[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
            cell.accessoryType = [UserProfile profile].displayWatching ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 1:
            cell.accessoryType = [UserProfile profile].displayCompleted ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 2:
            cell.accessoryType = [UserProfile profile].displayOnHold ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 3:
            cell.accessoryType = [UserProfile profile].displayDropped ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 4:
            cell.accessoryType = [UserProfile profile].displayPlanToWatch ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            [UserProfile profile].displayWatching = ![UserProfile profile].displayWatching;
            cell.accessoryType = [UserProfile profile].displayWatching ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 1:
            [UserProfile profile].displayCompleted = ![UserProfile profile].displayCompleted;
            cell.accessoryType = [UserProfile profile].displayCompleted ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 2:
            [UserProfile profile].displayOnHold = ![UserProfile profile].displayOnHold;
            cell.accessoryType = [UserProfile profile].displayOnHold ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 3:
            [UserProfile profile].displayDropped = ![UserProfile profile].displayDropped;
            cell.accessoryType = [UserProfile profile].displayDropped ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case 4:
            [UserProfile profile].displayPlanToWatch = ![UserProfile profile].displayPlanToWatch;
            cell.accessoryType = [UserProfile profile].displayPlanToWatch ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        default:
            break;
    }
}

@end
