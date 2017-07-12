//
//  CallHistoryTableViewCell.h
//  Sup
//
//  Created by Rahul Sharma on 4/28/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallHistoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *mainNamelbl;
@property (weak, nonatomic) IBOutlet UILabel *timelbl;
@property (weak, nonatomic) IBOutlet UIButton *detailsIcon;
@property (weak, nonatomic) IBOutlet UILabel *typeCallLbl;

@end
