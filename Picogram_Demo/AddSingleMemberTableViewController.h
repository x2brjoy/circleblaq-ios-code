//
//  AddSingleMemberTableViewController.h
//  Sup
//
//  Created by Rahul Sharma on 5/23/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddSingleMemberTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tblView;

@property (strong,nonatomic) NSString *groupName;
@property(strong,nonatomic) NSArray *groupMembers;
@property (strong,nonatomic) NSString *groupId;
@property (strong,nonatomic) NSString *groupPic;
@property (strong,nonatomic) NSString *groupCreatBy;
@property (strong,nonatomic) NSString *documentId;

@property (strong) NSMutableArray *friendesList;

@end
