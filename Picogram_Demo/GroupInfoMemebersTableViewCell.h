//
//  GroupInfoMemebersTableViewCell.h
//  Sup
//
//  Created by Rahul Sharma on 5/19/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupInfoMemebersTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagePic;
@property (weak, nonatomic) IBOutlet UILabel *mainLbl;
@property (weak, nonatomic) IBOutlet UILabel *subLbl;

@property (weak, nonatomic) IBOutlet UILabel *addmemLbl;
@property (weak, nonatomic) IBOutlet UILabel *groupAdminlbl;

@end
