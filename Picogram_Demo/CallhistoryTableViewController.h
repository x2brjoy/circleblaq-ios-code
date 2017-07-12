//
//  CallhistoryTableViewController.h
//  Sup
//
//  Created by Rahul Sharma on 4/28/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallhistoryTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) IBOutlet UITableView *tableViewCall;

- (IBAction)segmentCliked:(UISegmentedControl *)sender;

@property (strong) NSMutableArray *friendesList;

@end
