//
//  HomeViewController.h
//  Picogram
//
//  Created by Govind on 10/3/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *viewWhenNoPostsOutlet;

- (IBAction)followPeopleButtonAction:(id)sender;
- (IBAction)captionUserNameButtonAction:(id)sender;

- (IBAction)secondCommentUserNmaeButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;

#define messageWhenNoPosts  @"User and his followers have not posted anything"
@end
