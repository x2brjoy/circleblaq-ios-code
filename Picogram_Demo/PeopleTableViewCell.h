//
//  PeopleTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 7/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;

@end
