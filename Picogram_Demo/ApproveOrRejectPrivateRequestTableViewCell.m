//
//  ApproveOrRejectPrivateRequestTableViewCell.m
//  Picogram
//
//  Created by Rahul_Sharma on 06/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ApproveOrRejectPrivateRequestTableViewCell.h"
#import "Helper.h"
@implementation ApproveOrRejectPrivateRequestTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)needToShowAcceptRejectView:(NSString *)necessaryToShowAcceptRejectView {
    if ([necessaryToShowAcceptRejectView isEqualToString:@"yes"]) {
        self.viewForAcceptRejectButton.hidden = NO;
        self.followButtonOutlet.hidden = YES;
    }
    else {
        self.viewForAcceptRejectButton.hidden = YES;
        self.followButtonOutlet.hidden = NO;
    }
}

/*
 *  @return customized cell
 */
-(void)updateFollowButtonTitle :(NSInteger )row andStatus:(NSString *)followStatus{
    
    
   
    
    self.followButtonOutlet .layer.cornerRadius = 5;
    self.followButtonOutlet .layer.borderWidth = 1;
    
    
    //  if follow status is 0 ---> title as "Requested"
    //  if follow status is 1 ---> title as "Following"
    //  if follow status is nil ---> title as "Follow"
    
    
        
    if ([followStatus  isEqualToString:@"0"]) {
        [self.followButtonOutlet  setTitle:@" REQUESTED" forState:UIControlStateNormal];
       
        [self.followButtonOutlet setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
        [self.followButtonOutlet setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
        
        self.followButtonOutlet.backgroundColor = requstedButtonBackGroundColor;
        self.followButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
    }
    else if(([followStatus  isEqualToString:@"1"])) {
        [self.followButtonOutlet  setTitle:@" FOLLOWING" forState:UIControlStateNormal];
          [self.followButtonOutlet setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
        [self.followButtonOutlet setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
        self.followButtonOutlet.backgroundColor = followingButtonBackGroundColor;
        self.followButtonOutlet.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else {
        [self.followButtonOutlet  setTitle:@" FOLLOW" forState:UIControlStateNormal];
          [self.followButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
        self.followButtonOutlet.backgroundColor = followButtonBackGroundColor;
        [self.followButtonOutlet setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
        self.followButtonOutlet .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
        
        
    }
}

@end
