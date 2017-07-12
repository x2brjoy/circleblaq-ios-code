//
//  ApprovePrivateRequestViewController.h
//  Picogram
//
//  Created by Rahul_Sharma on 06/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApprovePrivateRequestViewController : UIViewController
- (IBAction)acceptButtonAction:(id)sender;
- (IBAction)rejectButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *privateRequestTableview;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarOutlet;

- (IBAction)followButtonAction:(id)sender;

@end
