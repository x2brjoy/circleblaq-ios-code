//
//  ApproveOrRejectPrivateRequestTableViewCell.h
//  Picogram
//
//  Created by Rahul_Sharma on 06/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApproveOrRejectPrivateRequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageviewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *rejectButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *acceptButtonOutlet;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *acceptActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rejectActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *viewForAcceptRejectButton;
@property (weak, nonatomic) IBOutlet UIButton *followButtonOutlet;
-(void)needToShowAcceptRejectView:(NSString *)necessaryToShowAcceptRejectView;
-(void)updateFollowButtonTitle :(NSInteger )row andStatus:(NSString *)followStatus;
@end
