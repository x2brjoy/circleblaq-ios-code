//
//  GroupInfoTableViewCell.h
//  Sup
//
//  Created by Rahul Sharma on 5/19/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *maintitleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *gpImage;
@property (weak, nonatomic) IBOutlet UIButton *gpName;
@property (weak, nonatomic) IBOutlet UILabel *upperLine;
@property (weak, nonatomic) IBOutlet UILabel *lowerLine;
@property (strong, nonatomic) IBOutlet UILabel *groupNameOutlet;

@end
