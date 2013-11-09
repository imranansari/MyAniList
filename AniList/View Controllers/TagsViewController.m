//
//  TagsViewController.m
//  AniList
//
//  Created by Corey Roberts on 10/25/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "TagsViewController.h"
#import "TagView.h"
#import "TagListViewController.h"

#import "TagService.h"
#import "GenreService.h"

@interface TagsViewController ()
@property (nonatomic, strong) TagView *tagView;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
@end

@implementation TagsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.errorLabel.text = @"";
    self.errorLabel.alpha = 0.0f;
    
    self.tagView = [[TagView alloc] init];
    NSArray *tags = [NSArray array];
    NSString *title = @"";
    NSString *errorText = @"";
    
    switch (self.tagType) {
        case TagTypeTags:
            title = @"Tags";
            errorText = @"There don't seem to be any tags available. MyAnimeList's Tag Service may be down. Please try again later.";
            tags = [TagService allTags];
            break;
        case TagTypeGenres:
            title = @"Genres";
            errorText = @"There don't seem to be any genres available. MyAnimeList's Genre Service may be down. Please try again later.";
            tags = [GenreService allGenres];
            break;
        default:
            break;
    }
    
    self.title = title;

    [self.tagView createTags:[NSSet setWithArray:tags] withTitle:NO];
    
    [self.view addSubview:self.tagView];
    
    self.tagView.frame = CGRectMake(self.tagView.frame.origin.x, self.tagView.frame.origin.y + 20, self.tagView.frame.size.width, self.tagView.frame.size.height);
    self.tagView.delegate = self;
    
    if(tags.count == 0) {
        self.errorLabel.text = errorText;
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.errorLabel.alpha = 1.0f;
                         }];
    }
    
    if(![UIApplication is4Inch]) {
        self.errorLabel.frame = CGRectMake(self.errorLabel.frame.origin.x,
                                           self.errorLabel.frame.origin.y - 60,
                                           self.errorLabel.frame.size.width,
                                           self.errorLabel.frame.size.height);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    switch (self.tagType) {
        case TagTypeTags:
            [[AnalyticsManager sharedInstance] trackView:kTagListScreen];
            break;
        case TagTypeGenres:
            [[AnalyticsManager sharedInstance] trackView:kGenreListScreen];
            break;
        default:
            break;
    }
}

- (void)dealloc {
    self.tagView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TagViewDelegate Methods

- (void)tagTappedWithTitle:(NSString *)title {
    TagListViewController *vc = [[TagListViewController alloc] init];
    
    if(self.tagType == TagTypeTags)
        vc.tag = title;
    else if(self.tagType == TagTypeGenres)
        vc.genre = title;
    
    vc.isAnime = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
