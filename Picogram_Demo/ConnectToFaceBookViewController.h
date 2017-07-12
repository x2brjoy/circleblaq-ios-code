//
//  ConnectToFaceBookViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 5/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectToFaceBookContactsTableViewCell.h"
#import "FacebookNumberOfContactsTableViewCell.h"

@interface ConnectToFaceBookViewController : UIViewController

@property (nonatomic,weak) NSString *syncingContactsOf;
@property (weak, nonatomic) IBOutlet UITableView *contatctsTableView;
@property (weak,nonatomic) NSString *greeting;



@end
