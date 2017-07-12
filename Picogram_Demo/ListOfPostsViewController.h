//
//  ListOfPostsViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 8/5/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListOfPostsViewController : UIViewController
@property NSMutableArray *dataForListView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSInteger movetoRowNumber;
@property NSString *listViewForPostsOf;
@property NSDictionary *ListViewdata;
@property NSString *navTitle;
@end
