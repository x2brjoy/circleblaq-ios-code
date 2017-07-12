//
//  LikeViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 4/19/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikeTableViewCell.h"
@interface LikeViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property NSString *navigationTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak,nonatomic) NSString *getdetailsDetailsOfUserName;
@property NSString *postId;
@property NSString *postType;
@property (weak, nonatomic) IBOutlet UIView *progressIndicatorView;


@end
