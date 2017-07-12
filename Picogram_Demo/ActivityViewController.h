//
//  ActivityViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 4/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateAccountRequestTableViewCell.h"

@interface ActivityViewController : UIViewController<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *followingViewButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *YouViewOutlet;

- (IBAction)youButtonAction:(id)sender;
- (IBAction)followingButtonAction:(id)sender;


@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movableDividerLeadingConstraintOutlet;
- (IBAction)findPeopleToFollowButtonAction:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *followingActivityTable;
@property (strong, nonatomic) IBOutlet UITableView *selfActivityTable;
@property (strong, nonatomic) IBOutlet UIView *defaultSelfActivityTable;

#define imageForFollowButton @"activity_you_following_icon_unselector"
#define imageForFollowingButton @"activity_you_following_icon_selector"
#define imageForRequestedButton @"activity_you_requested_btn"
@end
