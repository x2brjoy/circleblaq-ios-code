//
//  YouTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 7/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YouTableViewCellDelegate;
@interface YouTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *FriendProfileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *particularPostImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButtonOutlet;
@property (strong,nonatomic) NSDictionary *userdetails;
- (IBAction)postButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *postButtonOutlet;
@property (weak, nonatomic) id <YouTableViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *usernameBtn;
@property (weak, nonatomic) IBOutlet UILabel *descrptionLabel;
- (IBAction)userNameAction:(id)sender;
@property NSString *postID;
@property NSString *postType;
@property NSString *actitvtyUserName;
@end

@protocol YouTableViewCellDelegate <NSObject>
-(void)ownActivitycell:(YouTableViewCell*)cell button:(UIButton*)button withObject:(NSDictionary*)object;
-(void)selfCell:(YouTableViewCell*)cell postbutton:(UIButton*)button ofpostType:(NSString*)posttype withpostid:(NSString*)id andUserName:(NSString*)userName;
@end
