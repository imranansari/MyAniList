//
//  AnimeDetailsViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "AnimeDetailsViewController.h"
#import "AnimeService.h"
#import "Anime.h"

@interface AnimeDetailsViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *poster;
@property (nonatomic, weak) IBOutlet UILabel *animeTitle;
@property (nonatomic, weak) IBOutlet UILabel *animeType;
@property (nonatomic, weak) IBOutlet UILabel *airing;

@property (nonatomic, weak) IBOutlet UIView *detailView;
@property (nonatomic, weak) IBOutlet UILabel *score;
@property (nonatomic, weak) IBOutlet UILabel *totalPeopleScored;
@property (nonatomic, weak) IBOutlet UILabel *rank;
@property (nonatomic, weak) IBOutlet UILabel *popularity;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation AnimeDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAnime:) name:kAnimeDidUpdate object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.indicator.alpha = 1.0f;
    self.detailView.alpha = 0.0f;
    
    self.poster.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.2f].CGColor;
    self.poster.layer.borderWidth = 1.0f;
    
    if(self.anime) {
        self.animeTitle.text = self.anime.title;
#warning - plural version needed.
        self.animeType.text = [NSString stringWithFormat:@"%@, %d episodes", [Anime stringForAnimeType:[self.anime.type intValue]], [self.anime.total_episodes intValue]];
        self.airing.text = [self airText];
        
        // This block of text requires data.
        
        if([self.anime.average_score doubleValue] > 0) {
            [self displayDetailsViewAnimated:NO];
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.anime.image]];
        
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
            self.poster.image = image;
        }];
        
        [operation start];
    }
    
    [self adjustLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIView Methods

- (void)displayDetailsViewAnimated:(BOOL)animated {
    self.score.text = [NSString stringWithFormat:@"Score: %0.02f", [self.anime.average_score doubleValue]];
    self.totalPeopleScored.text = [NSString stringWithFormat:@"(by %d people)", [self.anime.average_count intValue]];
    self.rank.text = [NSString stringWithFormat:@"Rank: #%d", [self.anime.rank intValue]];
    self.popularity.text = [NSString stringWithFormat:@"Popularity: #%d", [self.anime.popularity_rank intValue]];
    
    if(animated) {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.detailView.alpha = 1.0f;
                             self.indicator.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [self.indicator removeFromSuperview];
                         }];
    }
    else {
        self.detailView.alpha = 1.0f;
        [self.indicator removeFromSuperview];
    }
}

#pragma mark - UILabel Management Methods

- (NSString *)airText {    
    NSString *text = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, yyyy";

    if(self.anime.date_start) {
        NSString *startDate = [dateFormatter stringFromDate:self.anime.date_start];
        text = [text stringByAppendingFormat:@"Started airing on %@ ", startDate];
    }
    
    if(self.anime.date_finish) {
        NSString *finishDate = [dateFormatter stringFromDate:self.anime.date_finish];
        text = [text stringByAppendingFormat:@"and finished on %@", finishDate];
    }
    else if([self.anime.status intValue] == AnimeAirStatusCurrentlyAiring) {
        text = [text stringByAppendingString:@"and is still airing"];
    }
    
    return text;
}

- (void)adjustLabels {
    [self.animeTitle addShadow];
    [self.animeType addShadow];
    [self.airing addShadow];
    [self.score addShadow];
    [self.totalPeopleScored addShadow];
    [self.rank addShadow];
    [self.popularity addShadow];
}

#pragma mark - NSNotification Methods

- (void)updateAnime:(NSNotification *)notification {
    [self displayDetailsViewAnimated:YES];
}

@end
