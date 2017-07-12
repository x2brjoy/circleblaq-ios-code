//
//  ListOfTagFriendsTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 5/23/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListOfTagFriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *hashNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPostsLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *tagFriendsTableCellContent;
@property (weak, nonatomic) IBOutlet UIView *hashTagTableCellContentView;
@end
