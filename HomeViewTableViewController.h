//
//  TLYTableViewController.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <SCRecorder/SCRecordSession.h>

@interface HomeViewTableViewController : UIViewController<UIActionSheetDelegate>
@property(nonatomic,assign)id delegate;
@property (nonatomic, assign) IBInspectable BOOL shortScrollView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewWhenNopostsAvailable;


- (IBAction)findPeopleToFollowButtonAction:(id)sender;

// for video uploading.
@property NSString *postedImagePath;
@property NSString *postedthumbNailImagePath;
@property NSString *pathOfVideo;
@property SCRecordSession *recordsession;
@property bool sharingVideo;
@property NSString *imageForVideoThumabnailpath;

//other details for post

@property NSString  *taggedFriendsString;
@property NSString *caption;
@property NSString *hashTags;
@property NSString *location;
@property NSNumber *lat;
@property NSNumber *longi;
@property bool startUpload;
@end
