//
//  InstaVIdeoTableViewController.h
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 22/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
// Chat Start
#import "LRPageHomeViewController.h"
#import "PageContentViewController.h"
// Chat End

@interface InstaVIdeoTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableViewOutlet;

- (IBAction)likeButtonAction:(id)sender;

- (IBAction)CommentButtonAction:(id)sender;
- (IBAction)numberOfLikesButtonAction:(id)sender;

- (IBAction)moreButtonAction:(id)sender;

- (IBAction)viewAllCommentsButtonAction:(id)sender;

//checking list View For

@property NSString *showListOfDataFor;
@property NSDictionary *dataForListView;
@property NSInteger movetoRowNumber;
@property NSString *navigationBarTitle;
@property NSMutableArray *dataFromExplore;
@property NSString *postId;
@property NSString *controllerType;
@property NSString *postType;
@property NSString *activityUser;
@property NSString *UserNameForPostFromProfile;
@property NSString *profilePicForPostFromProfile;
@property NSString *category;
@property NSString *subcategory;
- (IBAction)firstCommentUserNameButtonActin:(id)sender;
- (IBAction)sendButtonAction:(id)sender;

- (IBAction)captionUserNameButtonAction:(id)sender;

- (IBAction)secondCommentButtonAction:(id)sender;

#define  ListViewForHashTag               @"ListViewForHashTags"
#define  ListViewForPostsByLocation       @"ListViewForPostsByLocation"
#define  ListViewForPhotosOfYou           @"ListViewForPhotosOfYou"
#define  ListViewForExplore               @"ListViewForExplore"
#define  ListViewForPostFromProfile       @"ListViewForPostFromProfile" 
#define  ListViewForPostFromActivity      @"ActivityProfile" 
#define  ListViewForPostFromSelfActivity  @"SelfActivityProfile"

// Chat Start
@property (strong) NSMutableArray *friendesList;
@property (strong, nonatomic) PageContentViewController *pageViewController;
// Chat End

@end
