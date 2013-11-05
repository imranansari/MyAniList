//
//  Constants.h
//  AniList
//
//  Created by Corey Roberts on 6/2/13.
//  Copyright (c) 2013 SpacePyro Inc. All rights reserved.
//

#ifndef AniList_Constants_h
#define AniList_Constants_h

typedef void (^HTTPSuccessBlock)(NSURLRequest *operation, id response);
typedef void (^HTTPFailureBlock)(NSURLRequest *operation, NSError *error);

#define kAnimeDidUpdate @"kAnimeDidUpdate"
#define kMangaDidUpdate @"kMangaDidUpdate"
#define kMenuButtonTapped @"kMenuButtonTapped"
#define kRelatedAnimeDidUpdate @"kRelatedAnimeDidUpdate"
#define kRelatedMangaDidUpdate @"kRelatedMangaDidUpdate"
#define kAnimeDownloadProgress @"kAnimeDownloadProgress"
#define kMangaDownloadProgress @"kMangaDownloadProgress"
#define kDownloadProgress @"kDownloadProgress"

// Defaults
#define MAX_ATTEMPTS 5

#define kNoSynopsisString @"Unable to get synopsis. Please try again later."
#define kEnterUsernameString @"Enter a username..."

#define kTopAnimeDownErrorMessage @"MyAnimeList's Top Anime service is currently down. Please try again later."
#define kPopularAnimeDownErrorMessage @"MyAnimeList's Popular Anime service is currently down. Please try again later."

// Dictionary values for fetching data
#define kID                     @"id"
#define kTitle                  @"title"
#define kOtherTitles            @"other_titles"
#define kSynopsis               @"synopsis"
#define kType                   @"type"
#define kRank                   @"rank"
#define kPopularityRank         @"popularity_rank"
#define kImage                  @"image"
#define kImageURL               @"image_url"
#define kChapters               @"chapters"
#define kVolumes                @"volumes"
#define kEpisodes               @"episodes"
#define kAirStatus              @"status"
#define kAirStartDate           @"start_date"
#define kAirEndDate             @"end_date"
#define kSeriesStatus           @"status"
#define kSeriesStartDate        @"series_start"
#define kSeriesEndDate          @"series_end"
#define kGenres                 @"genres"
#define kTag                    @"tags"
#define kClassicication         @"classification"
#define kMembersScore           @"members_score"
#define kMembersCount           @"members_count"
#define kFavoritedCount         @"favorited_count"
#define kAnimeAdaptations       @"anime_adaptations"
#define kMangaAdaptations       @"manga_adaptations"
#define kRelatedManga           @"related_manga"
#define kRelatedAnime           @"related_anime"
#define kPrequels               @"prequels"
#define kSequels                @"sequels"
#define kSideStores             @"side_stories"
#define kParentStory            @"parent_story"
#define kCharacterAnime         @"character_anime"
#define kSpinOffs               @"spin_offs"
#define kSummaries              @"summaries"
#define kAlternativeVersions    @"alternative_versions"
#define kListedAnimeID          @"listed_anime_id"
#define kUserWatchedEpisodes    @"watched_episodes"
#define kUserChaptersRead       @"chapters_read"
#define kUserVolumesRead        @"volumes_read"
#define kUserScore              @"score"
#define kUserWatchedStatus      @"watched_status"
#define kUserReadStatus         @"read_status"
#define kUserStartDate          @"user_start_date"
#define kUserEndDate            @"user_end_date"
#define kUserRewatchingStatus   @"user_rewatching_status"
#define kUserRewatchingEpisode  @"user_rewatching_episode"
#define kUserRereadingStatus    @"user_rereading_status"
#define kUserRereadingChapter   @"user_rereading_chapter"
#define kUserRereadingVolume    @"user_rereading_volume"
#define kUserLastUpdated        @"user_last_updated"
#define kAnimeStats             @"anime_stats"
#define kMangaStats             @"manga_stats"
#define kSynonyms               @"synonyms"
#define kEnglishTitles          @"english"
#define kJapaneseTitles         @"japanese"
#define kUserCompleted          @"user_completed"
#define kUserDaysSpentWatching  @"user_days_spent_watching"
#define kUserDropped            @"user_dropped"
#define kUserOnHold             @"user_onhold"
#define kUserPlanToWatch        @"user_plantowatch"
#define kUserWatching           @"user_watching"
#define kUserPlanToRead         @"user_plantoread"
#define kUserReading            @"user_reading"

// Google Analytics

// Screens
#define kLoginScreen                @"Login"
#define kAnimeListScreen            @"Anime_List"
#define kMangaListScreen            @"Manga_List"
#define kAnimeDetailsScreen         @"Anime_Details"
#define kMangaDetailsScreen         @"Manga_Details"
#define kAnimeEditUserInfoScreen    @"Anime_Edit_User_Info"
#define kMangaEditUserInfoScreen    @"Manga_Edit_User_Info"
#define kTopAnimeScreen             @"Top_Anime"
#define kPopularAnimeScreen         @"Popular_Anime"
#define kAnimeTagsScreen            @"Anime_Tags"
#define kAnimeGenresScreen          @"Anime_Genres"
#define kFriendsScreen              @"Friends"
#define kFriendDetailsScreen        @"Friend_Details"
#define kCompareDetailsScreen       @"Compare_Details"
#define kSearchScreen               @"Search"
#define kSettingsScreen             @"Settings"
#define kNotificationsScreen        @"Notifications"
#define kReportIssueScreen          @"Report_Issue"

// Actions
#define kLoginButtonPressed     @"Login_Button_Pressed"
#define kSaveAnimeDetailsPressed    @"Save_Anime"



static const BOOL UI_DEBUG = NO;



#endif
