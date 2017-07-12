//
//  selectPostAsTableViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 10/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface selectPostAsTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UISearchBar *listSerachBar;

@property(nonatomic, assign) int titleStr;
@property NSMutableArray *subCategoryArray;
@property (nonatomic,copy) void (^callBack)(NSString *string,int type,NSArray *array);
@property (nonatomic,copy) void (^callBackOnlyCategory)(NSString *string,int type);
@end
