//
//  FollowTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 7/23/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FollowTableViewCellDelegate;
@interface FollowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendProfileImage;
//@property (strong, nonatomic) IBOutlet UIView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)postClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;
- (IBAction)usernameAction:(id)sender;
@property (nonatomic, strong) UIButton *nameButton;
@property (weak, nonatomic) id <FollowTableViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *username;
@property(strong,nonatomic)NSDictionary *userdetails;
@property(strong,nonatomic)NSMutableArray *postdetails;
@property NSString *postID;
@property NSString *postType;
@property NSString *actitvtyUserName;
@end
@protocol FollowTableViewCellDelegate <NSObject>
-(void)cell:(FollowTableViewCell*)cell button:(UIButton*)button withObject:(NSDictionary*)object;
-(void)cell:(FollowTableViewCell*)cell postbutton:(UIButton*)button ofpostType:(NSString*)posttype withpostid:(NSString*)id andUserName:(NSString*)name;


@end
