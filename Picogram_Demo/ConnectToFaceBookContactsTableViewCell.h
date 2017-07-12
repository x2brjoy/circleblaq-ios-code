//
//  ConnectToFaceBookContactsTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 5/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectToFaceBookContactsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *button2ForImage;
@property (weak, nonatomic) IBOutlet UIButton *button1ForImage;
@property (weak, nonatomic) IBOutlet UIButton *button3ForImage;
@property (weak, nonatomic) IBOutlet UIButton *button4ForImage;
@property (weak, nonatomic) IBOutlet UILabel *messageLabelWhenNoPostsAvailable;

@property (weak, nonatomic) IBOutlet UIView *viewWhenNoPostsAvailable;

@property (weak, nonatomic) IBOutlet UIButton *buttonToshowImage;
@property (weak, nonatomic) IBOutlet UIImageView *contactUserImageViewOutlet;
@property (weak, nonatomic) IBOutlet UIButton *followButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *imagesSuperViewOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageSuperViewHeightConstraint;


@property (weak, nonatomic) IBOutlet UIImageView *postedImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *postedImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *postedImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *postedImageView4;

-(void)showImagesForContacts:(NSMutableArray *)arrayOfReceivedContactDetails forIndex:(NSInteger )rowAt;
-(void)showImagesForFb:(NSMutableArray *)arrayOfReceivedContactDetails forIndex:(NSInteger )rowAt;
-(void)updateFollowButtonTitle:(NSString *)followstatus andIndexPath:(NSInteger )row;
@end
