//
//  TableViewCell.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGTableViewCell : UITableViewCell

//label outlet


@property (weak, nonatomic) IBOutlet UILabel *userNameLabelOutlet;

//imageView outlets

@property (strong, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;

//button outlet

@property (weak, nonatomic) IBOutlet UIButton *cellFollowButtonOutlet;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabelOutlet;
-(void)updateFollowButtonTitleForFb:(NSString *)followstatus andIndexPath:(NSInteger )row;
-(void)updateFollowButtonTitleForContacts:(NSString *)followstatus andIndexPath:(NSInteger )row;

#define followButtonBackGroundColor [UIColor colorWithRed:30.0f/255.0f green:36.0f/255.0f blue:52.0f/255.0f alpha:1.0]

#define followingButtonBackGroundColor   [UIColor colorWithRed:234.0f/255.0f green:34.0f/255.0f blue:76.0f/255.0f alpha:1.0]

#define requstedButtonBackGroundColor [UIColor colorWithRed:54.0f/255.0f green:63.0f/255.0f blue:86.0f/255.0f alpha:1.0]
@end
