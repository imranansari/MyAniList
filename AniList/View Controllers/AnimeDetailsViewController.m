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
#import "MALHTTPClient.h"

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
    
    if(self.anime) {
        self.titleLabel.text = self.anime.title;
        
        self.type.text = [self animeTypeText];
        
        self.seriesStatus.text = [self airText];
        
        // This block of text requires data.
        if([self.anime hasAdditionalDetails]) {
            [self displayDetailsViewAnimated:NO];
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.anime.image_url]];

        UIImage *poster = [self.anime imageForAnime];
        
        if(!poster) {
            self.poster.alpha = 0.0f;
        }
        
        self.poster.image = poster;
        
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
            self.poster.image = image;
            [self updatePoster];
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
    
    [super displayDetailsViewAnimated:animated];
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

- (NSString *)animeTypeText {
    
    BOOL plural = [self.anime.total_episodes intValue] > 1;
    
    NSString *text = @"";
    
    NSString *episodeText = plural ? @"episodes" : @"episode";
    NSString *musicText = plural ? @"songs" : @"song";
    NSString *animeType = [Anime stringForAnimeType:[self.anime.type intValue]];
    int numberOfEpisodes = [self.anime.total_episodes intValue];
    
    switch([self.anime.type intValue]) {
        case AnimeTypeTV: {
            text = [NSString stringWithFormat:@"%@, %d %@", animeType, numberOfEpisodes, episodeText];
            break;
        }
        case AnimeTypeSpecial: {
            text = [NSString stringWithFormat:@"%@, %d %@", animeType, numberOfEpisodes, episodeText];
            break;
        }
        case AnimeTypeOVA: {
            text = [NSString stringWithFormat:@"%@, %d %@", animeType, numberOfEpisodes, episodeText];
            break;
        }
        case AnimeTypeONA: {
            text = [NSString stringWithFormat:@"%@, %d %@", animeType, numberOfEpisodes, episodeText];
            break;
        }
        case AnimeTypeMusic: {
            text = [NSString stringWithFormat:@"%@, %d %@", animeType, numberOfEpisodes, musicText];
            break;
        }
        case AnimeTypeMovie: {
            text = [NSString stringWithFormat:@"%@", animeType];
            break;
        }
        case AnimeTypeUnknown:
        default: {
            text = [NSString stringWithFormat:@"%@, %d %@", animeType, numberOfEpisodes, episodeText];
            break;
        }
    }
    
    return text;
}

#pragma mark - NSNotification Methods

- (void)updateAnime:(NSNotification *)notification {
    BOOL didUpdate = [((NSNumber *)notification.object) boolValue];
    
    if(didUpdate) {
        [self displayDetailsViewAnimated:YES];
    }
    else {
        if([self.anime hasAdditionalDetails]) {
            [self displayDetailsViewAnimated:YES];
        }
        else {
            [self displayErrorMessage];
        }
    }
}

@end
