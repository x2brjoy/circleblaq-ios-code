//
//  ConnectToFaceBookContactsTableViewCell.m
//  Picogram
//
//  Created by Rahul Sharma on 5/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ConnectToFaceBookContactsTableViewCell.h"
#import "TinderGenericUtility.h"
#import "UIImageView+WebCache.h"
#import "Helper.h"

@implementation ConnectToFaceBookContactsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



-(void)showImagesForContacts:(NSMutableArray *)arrayOfReceivedContactDetails forIndex:(NSInteger )rowAt {
    
    NSMutableArray *numberOfuserPosts = arrayOfReceivedContactDetails[rowAt][@"postData"];
    
    if ([flStrForObj(numberOfuserPosts[0][@"thumbnailImageUrl"]) isEqualToString:@""]) {
        numberOfuserPosts = nil;
    }
    
    
    NSString *memberPrivateStatus = flStrForObj(arrayOfReceivedContactDetails[rowAt][@"memberPrivate"]);
    NSString *followStatus = flStrForObj(arrayOfReceivedContactDetails[rowAt][@"followRequestStatus"]);
   
    
    if ([followStatus isEqualToString:@"1"]) {
        if(numberOfuserPosts.count ==0) {
            //msg no posts are available.
            self.messageLabelWhenNoPostsAvailable.text = @"No photos or videos";
            self.viewWhenNoPostsAvailable.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0];
            self.messageLabelWhenNoPostsAvailable.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0];
            self.viewWhenNoPostsAvailable.hidden = NO;
        }
        else {
            self.viewWhenNoPostsAvailable.hidden = YES;
        }
    }
    else {
        if([memberPrivateStatus isEqualToString:@"1"]){
            //msg no posts are available.
            self.messageLabelWhenNoPostsAvailable.text = @"This account is private. Follow to see photos.";
            self.viewWhenNoPostsAvailable.hidden = NO;
            self.viewWhenNoPostsAvailable.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0];
            self.messageLabelWhenNoPostsAvailable.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0];
        }
        else {
            if(numberOfuserPosts.count ==0) {
                //msg no posts are available.
                self.messageLabelWhenNoPostsAvailable.text = @"No photos or videos";
                self.viewWhenNoPostsAvailable.hidden = NO;
                self.viewWhenNoPostsAvailable.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0];
                self.messageLabelWhenNoPostsAvailable.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0];
            }
            else {
                self.viewWhenNoPostsAvailable.hidden = YES;
            }
            
        }
    }
    
    
    if(numberOfuserPosts.count == 1)
    {
        if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][0][@"thumbnailImageUrl"])) {
            [self.postedImageView1 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][0][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
             }
             }
        else if (numberOfuserPosts.count  == 2) {
            if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][0][@"thumbnailImageUrl"])) {
                [self.postedImageView1 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][0][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
                 }
                 if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][1][@"thumbnailImageUrl"])) {
                     [self.postedImageView2 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][1][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
                      }
        }
    else if (numberOfuserPosts.count  == 3) {
        if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][0][@"thumbnailImageUrl"])){
            [self.postedImageView1 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][0][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][1][@"thumbnailImageUrl"])) {
        [self.postedImageView2 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][1][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][2][@"thumbnailImageUrl"])) {
        [self.postedImageView3 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][2][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
         }
        }
    else if (numberOfuserPosts.count > 3) {
        if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][0][@"thumbnailImageUrl"])) {
            [self.postedImageView1 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][0][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][1][@"thumbnailImageUrl"])) {
        [self.postedImageView2 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][1][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][2][@"thumbnailImageUrl"])) {
        [self.postedImageView3 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][2][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][3][@"thumbnailImageUrl"])) {
        [self.postedImageView4 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"postData"][3][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
         }
   }
}
         
-(void)showImagesForFb:(NSMutableArray *)arrayOfReceivedContactDetails forIndex:(NSInteger )rowAt {
                                                                          
    //NSArray *numberOfuserPosts =arrayOfReceivedContactDetails[rowAt][@"userPosts"];
    
    NSMutableArray *numberOfuserPosts =arrayOfReceivedContactDetails[rowAt][@"userPosts"];
    
    if ([flStrForObj(numberOfuserPosts[0][@"thumbnailImageUrl"]) isEqualToString:@""]) {
        numberOfuserPosts = nil;
    }
    
    if(numberOfuserPosts.count ==0){
        //msg no posts are available.
        self.viewWhenNoPostsAvailable.hidden = NO;
    }
    else {
        self.viewWhenNoPostsAvailable.hidden = YES;
    }
    
    if(numberOfuserPosts.count == 1)
    {
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][0][@"thumbnailImageUrl"])) {
        [self.postedImageView1 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][0][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
         }
    }
    else if (numberOfuserPosts.count  == 2) {
        if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][0][@"thumbnailImageUrl"])) {
            [self.postedImageView1 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][0][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
             }
             if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][1][@"thumbnailImageUrl"])) {
                 [self.postedImageView2 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][1][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
                  }
    }
    else if (numberOfuserPosts.count  == 3) {
        if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][0][@"thumbnailImageUrl"])){
            [self.postedImageView1 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][0][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
             }
             if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][1][@"thumbnailImageUrl"])) {
                 [self.postedImageView2 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][1][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
                  }
                  if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][2][@"thumbnailImageUrl"])) {
                      [self.postedImageView3 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][2][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
                       }
    }
    else if (numberOfuserPosts.count > 3) {
            if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][0][@"thumbnailImageUrl"])) {
                [self.postedImageView1 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][0][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][1][@"thumbnailImageUrl"])) {
            [self.postedImageView2 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][1][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][2][@"thumbnailImageUrl"])) {
        [self.postedImageView3 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][2][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    if(flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][3][@"thumbnailImageUrl"])) {
        [self.postedImageView4 sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[rowAt][@"userPosts"][3][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
        }
    }
}
                                                                      
-(void)updateFollowButtonTitle:(NSString *)followstatus andIndexPath:(NSInteger )row {
                                                                                                                                                
    //  if follow status is 0 ---> title as "Requested"
    //  if follow status is 1 ---> title as "Following"
    //  if follow status is nil ---> title as "Follow"
    
    
    
    self.followButtonOutlet.layer.cornerRadius = 3;
    self.followButtonOutlet .layer.borderWidth = 1;
    if ([followstatus  isEqualToString:@"0"]) {
        [self.followButtonOutlet  setTitle:@"REQUESTED" forState:UIControlStateNormal];
        [self.followButtonOutlet setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
        [self.followButtonOutlet setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
        
        [self.followButtonOutlet setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
        self.followButtonOutlet.backgroundColor = [UIColor lightGrayColor];
        self.followButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
    }
    else if ([followstatus  isEqualToString:@"1"]) {
        [self.followButtonOutlet  setTitle:@"FOLLOWING" forState:UIControlStateNormal];
         [self.followButtonOutlet setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
        [self.followButtonOutlet setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
        
        self.followButtonOutlet .backgroundColor = followingButtonBackGroundColor;
        self.followButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
    }
    else {
        [self.followButtonOutlet  setTitle:@"FOLLOW" forState:UIControlStateNormal];
         [self.followButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
        [self.followButtonOutlet setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
    [self.followButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
        self.followButtonOutlet  .backgroundColor= followButtonBackGroundColor;
        self.followButtonOutlet  .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    }
    self.followButtonOutlet.tag = 1000 + row;
}
                                                                      
@end
