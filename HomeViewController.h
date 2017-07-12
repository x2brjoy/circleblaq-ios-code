//
//  HomeViewController.h
//  Picogram
//
//  Created by Govind on 10/3/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecordSession.h"

// Chat Start
#import "LRPageHomeViewController.h"
#import "PageContentViewController.h"
// Chat End

@interface HomeViewController : UIViewController 
@property (strong, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *viewWhenNoPostsOutlet;

- (IBAction)followPeopleButtonAction:(id)sender;
- (IBAction)firstCommentUserNameButtonAction:(id)sender;

- (IBAction)likeButtonAction:(id)sender;

- (IBAction)CommentButtonAction:(id)sender;
- (IBAction)numberOfLikesButtonAction:(id)sender;

- (IBAction)moreButtonAction:(id)sender;

- (IBAction)viewAllCommentsButtonAction:(id)sender;

- (IBAction)showTagsButtonAction:(id)sender;


/// details for video
@property SCRecordSession *recordsession;

@property bool startUpload;
@property NSString *pathOfVideo;


// for video uploading.
@property NSString *postedImagePath;
@property NSString *postedthumbNailImagePath;
@property NSString *imageForVideoThumabnailpath;

//other details for post
@property NSString  *taggedFriendsString;
@property NSString *taggedFriendStringPoistions;
@property NSString *caption;
@property NSString *hashTags;
@property NSString *location;
@property NSNumber *lat;
@property NSNumber *longi;
@property NSString *facebook;
@property NSString *twitter;
@property NSString *flickr;
@property NSString *tumblr;
@property NSString *business;
@property NSString *price;
@property NSString *currency;
@property NSString *productlink;
@property NSString *category;
@property NSString *subcategory;
@property NSString *productName;
@property NSData* dataVideo;

@property (weak, nonatomic) IBOutlet UIButton *followButtonOutlet;

#define messageWhenNoPosts  @"User and his followers have not posted anything"
- (IBAction)firstCommentUserNameButton:(id)sender;

- (IBAction)captionUserNameButtonAction:(id)sender;
- (IBAction)chatActionButton:(id)sender;

// Chat Start
@property (strong) NSMutableArray *friendesList;
@property (strong, nonatomic) PageContentViewController *pageViewController;
// Chat End

@end
