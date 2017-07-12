//
//  AddContactsViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGFindContactsViewController.h"

@interface PGAddContactsViewController : UIViewController  <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *titleLabelOutlet;
@property (weak,nonatomic) NSString *greeting;

// button outlet

@property (weak, nonatomic) IBOutlet UIButton *followButtonOutlet;
@property (weak, nonatomic) NSString *contactsString;
@property (weak, nonatomic) NSDictionary *phoneContactsSyncResponseDataa;

//button action

- (IBAction)followButtonAction:(id)sender;


- (IBAction)nextButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *followContactsTableView;
@property (weak,nonatomic) NSString *syncContactsOf;
@property (weak, nonatomic) IBOutlet UILabel *numberOfContactsSyncedLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *topViewOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;



@end
