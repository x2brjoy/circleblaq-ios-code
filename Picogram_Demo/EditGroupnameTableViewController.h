//
//  EditGroupnameTableViewController.h
//  Sup
//
//  Created by Rahul Sharma on 5/24/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditGroupnameTableViewController : UITableViewController

@property (strong,nonatomic) NSString *groupName;

- (IBAction)cancelBtnCliked:(id)sender;
- (IBAction)saveBtncliked:(id)sender;

@end
