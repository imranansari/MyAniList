//
//  MangaDetailsViewController.m
//  AniList
//
//  Created by Corey Roberts on 6/23/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#import "MangaDetailsViewController.h"
#import "Manga.h"
#import "MALHTTPClient.h"

@interface MangaDetailsViewController ()

@end

@implementation MangaDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateManga:) name:kMangaDidUpdate object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.manga) {
        self.titleLabel.text = self.manga.title;
        
        self.type.text = [self mangaTypeText];
        
        self.seriesStatus.text = [self publishText];
        [self.seriesStatus sizeToFit];
        
        // This block of text requires data.
        if([self.manga hasAdditionalDetails]) {
            [self displayDetailsViewAnimated:NO];
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.manga.image_url]];
        
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
    self.score.text = [NSString stringWithFormat:@"Score: %0.02f", [self.manga.average_score doubleValue]];
    self.totalPeopleScored.text = [NSString stringWithFormat:@"(by %d people)", [self.manga.average_count intValue]];
    self.rank.text = [NSString stringWithFormat:@"Rank: #%d", [self.manga.rank intValue]];
    self.popularity.text = [NSString stringWithFormat:@"Popularity: #%d", [self.manga.popularity_rank intValue]];
    
    [super displayDetailsViewAnimated:animated];
}

#pragma mark - UILabel Management Methods

- (NSString *)publishText {
    NSString *text = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, yyyy";
    
    NSString *startDate = [dateFormatter stringFromDate:self.manga.date_start];
    NSString *finishDate = [dateFormatter stringFromDate:self.manga.date_finish];
    
    if(self.manga.date_start) {
        text = [text stringByAppendingFormat:@"Started publishing on %@ ", startDate];
    }
    
    if(self.manga.date_finish) {
        text = [text stringByAppendingFormat:@"and finished on %@", finishDate];
    }
    else if([self.manga.status intValue] == MangaPublishStatusCurrentlyPublishing) {
        text = [text stringByAppendingString:@"and is still in publication"];
    }
    
    if(self.manga.date_start && self.manga.date_finish && [self.manga.date_start timeIntervalSince1970] == [self.manga.date_finish timeIntervalSince1970]) {
        if([self.manga.status intValue] == MangaPublishStatusFinishedPublishing) {
            text = [NSString stringWithFormat:@"Published on %@", startDate];
        }
        else if([self.manga.status intValue] == MangaPublishStatusNotYetPublished) {
            text = [NSString stringWithFormat:@"Will be published on %@", startDate];
        }
    }
    
    if(!self.manga.date_start && !self.manga.date_finish) {
        text = @"Date of publication unknown";
    }
    
    return text;
}

- (NSString *)mangaTypeText {
    return [Manga stringForMangaType:[self.manga.type intValue]];
}

#pragma mark - NSNotification Methods

- (void)updateManga:(NSNotification *)notification {
    BOOL didUpdate = [((NSNumber *)notification.object) boolValue];
    
    if(didUpdate) {
        [self displayDetailsViewAnimated:YES];
    }
    else {
        if([self.manga hasAdditionalDetails]) {
            [self displayDetailsViewAnimated:YES];
        }
        else {
            [self displayErrorMessage];
        }
    }
}


@end
