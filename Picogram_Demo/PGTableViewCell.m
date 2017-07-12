//
//  TableViewCell.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGTableViewCell.h"
#import "TinderGenericUtility.h"
#import "Helper.h"


@implementation PGTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)updateFollowButtonTitleForContacts:(NSString *)followstatus andIndexPath:(NSInteger )row
{
    
    
    //  if follow status is 0 ---> title as "Requested"
    //  if follow status is 1 ---> title as "Following"
    //  if follow status is nil ---> title as "Follow"
    
    
    
    self.cellFollowButtonOutlet.layer.cornerRadius = 3;
    self.cellFollowButtonOutlet .layer.borderWidth = 1;
    if ([followstatus  isEqualToString:@"0"]) {
        [self.cellFollowButtonOutlet  setTitle:@" REQUESTED" forState:UIControlStateNormal];
        [self.cellFollowButtonOutlet setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
        [self.cellFollowButtonOutlet setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
        self.cellFollowButtonOutlet.backgroundColor = requstedButtonBackGroundColor;
        self.cellFollowButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
    }
    else if ([followstatus  isEqualToString:@"1"]) {
        [self.cellFollowButtonOutlet  setTitle:@" FOLLOWING" forState:UIControlStateNormal];
        [self.cellFollowButtonOutlet setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
        [self.cellFollowButtonOutlet setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
       
        self.cellFollowButtonOutlet .backgroundColor = followingButtonBackGroundColor;
        self.cellFollowButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
    }
    else {
        [self.cellFollowButtonOutlet  setTitle:@" FOLLOW" forState:UIControlStateNormal];
        [self.cellFollowButtonOutlet setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
        [self.cellFollowButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
        self.cellFollowButtonOutlet  .backgroundColor= followButtonBackGroundColor;
        self.cellFollowButtonOutlet  .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    }
    self.cellFollowButtonOutlet.tag = 1000 + row;
}


-(void)updateFollowButtonTitleForFb:(NSString *)followstatus andIndexPath:(NSInteger )row{
    
    self.cellFollowButtonOutlet .layer.cornerRadius = 3;
    self.cellFollowButtonOutlet .layer.borderWidth = 1;
    NSString *followStatus = flStrForObj(followstatus);
    
    if ([followStatus  isEqualToString:@"0"]) {
        [self.cellFollowButtonOutlet  setTitle:@"FOLLOW" forState:UIControlStateNormal];
        self.cellFollowButtonOutlet .selected = NO;
        self.cellFollowButtonOutlet  .backgroundColor=[UIColor whiteColor];
        [self.cellFollowButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
        self.cellFollowButtonOutlet  .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    }
    else if([followStatus  isEqualToString:@"1"]){
        [self.cellFollowButtonOutlet  setTitle:@"FOLLOWING" forState:UIControlStateSelected];
        [self.cellFollowButtonOutlet setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
        self.cellFollowButtonOutlet .selected = YES;
        self.cellFollowButtonOutlet .backgroundColor =[UIColor colorWithRed:0.4 green:0.7412 blue:0.1804 alpha:1.0];
        self.cellFollowButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    self.cellFollowButtonOutlet.tag = 1000 + row;
}
@end
