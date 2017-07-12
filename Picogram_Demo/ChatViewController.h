//
//  ChatViewController.h
//  Sup
//
//  Created by Rahul Sharma on 1/11/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "SOMessagingViewController.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface ChatViewController : SOMessagingViewController

@property (strong, nonatomic) NSString *bid;

@property (strong, nonatomic) NSString *userName, *receiverName;
@property (strong,nonatomic) NSString *userStatus;
@property (strong,nonatomic) NSString *userImageStr;
@property (strong ,nonatomic) NSString *unreadMesgCount;
@property (strong,nonatomic) NSString *groupId;
@property (strong,nonatomic) NSString *gpCreatedBy;
@property (strong,nonatomic) NSArray *groupMems;
@property (strong ,nonatomic) NSArray *groupAdmin;
@property (strong,nonatomic)NSString *isRemoveFromgp;

@property (strong, nonatomic) CBLDocument *currentDocument;

@property (strong, nonatomic) NSDictionary *docDict;
@property (strong, nonatomic) NSDictionary *docDictNew;

@property (assign,nonatomic) BOOL isFirsttime;
@property (assign,nonatomic) BOOL isComingfromFav;
@property (weak, nonatomic) IBOutlet UIButton *userNavPic;


@property (strong, nonatomic) IBOutlet UILabel *navLastseen;

@property (strong, nonatomic) IBOutlet UIButton *navUserNameBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *navActivity;


@property (strong, nonatomic) IBOutlet UIButton *callBtn;

@property (strong,nonatomic) NSArray *fulldetail;

@property (assign,nonatomic) BOOL isFirsttimess;

@property (strong) NSMutableArray *friendesList;

- (IBAction)groupInfoAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *groupImageNav;
- (IBAction)navCallBtncliked:(id)sender;


- (IBAction)navUsernameCliked:(id)sender;
- (IBAction)userImageBtnCliked:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *navBarBackButton;
- (IBAction)backButtonAction:(id)sender;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailButtonPosition;



@end
