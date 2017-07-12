//
//  LikeTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 4/19/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *NameLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *followButtonOutlet;

@end
