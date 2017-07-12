//
//  TagPeopleTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 5/2/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagPeopleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userIdLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageViewoutlet;

@end
