//
//  TopTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 7/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameOutlet;

@property (weak, nonatomic) IBOutlet UILabel *fullNameOutlet;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;

@end
