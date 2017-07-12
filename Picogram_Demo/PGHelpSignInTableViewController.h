//
//  HelpSignInTableViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/18/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGHelpSignInTableViewController : UITableViewController
- (IBAction)userNameButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *userNameButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *resetUsingFacebookButtonOutlet;
- (IBAction)resetUsingFacebookButtonAction:(id)sender;

@end
