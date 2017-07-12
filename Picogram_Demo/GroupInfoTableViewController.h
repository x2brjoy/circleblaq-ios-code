//
//  GroupInfoTableViewController.h
//  Sup
//
//  Created by Rahul Sharma on 5/18/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface GroupInfoTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableViewInfo;

@property (nonatomic,strong) NSString *groupId;
@property (strong,nonatomic)NSString *groupName;
@property (strong,nonatomic)NSString *groupPic;
@property (strong,nonatomic)NSString *groupCreatedBy;
@property (strong,nonatomic) NSString *tempStorePic;
@property (strong,nonatomic)NSString *documentID;
@property (strong,nonatomic)NSArray *groupMembers;
@property(strong,nonatomic) NSArray *groupAdmins;
@property (strong,nonatomic)NSString *isRemoveFromgp;
@property (strong,nonatomic)NSString *stringForuserDetails;

@property (nonatomic,copy)void(^OncompleteChangeInGpData)(NSString *groupName,NSString *grouPpic,NSArray *gpMem,NSArray* gpAdmins,NSString *isRemoveFromgp);

@property (strong) NSMutableArray *friendesList;
@property (strong) NSMutableArray *dataToShow;

@end
