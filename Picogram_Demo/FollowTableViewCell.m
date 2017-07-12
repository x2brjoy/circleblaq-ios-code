//
//  FollowTableViewCell.m
//  Picogram
//
//  Created by Rahul Sharma on 7/23/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "FollowTableViewCell.h"
#import "UserProfileViewController.h"
#import "FontDetailsClass.h"

@implementation FollowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)usernameAction:(id)sender {

    if (_delegate && [_delegate respondsToSelector:@selector(cell:button:withObject:)]) {
        [_delegate cell:self button:sender withObject:self.userdetails];
        
        
    }

}
- (IBAction)postClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cell:postbutton: ofpostType:withpostid:andUserName:)]) {
        [_delegate cell:self postbutton:sender ofpostType:self.postType withpostid:self.postID andUserName:self.actitvtyUserName];
        
    }
}


+(NSMutableAttributedString*)customisedActivityStmt:(NSString*)username seconUserName:(NSString *)secondUserName  timeForPost:(NSString *)time : (NSString*)statment {
    
    
    NSString *testString= statment;
    
    NSRange range = [testString rangeOfString:username];
    
    NSRange seconUserNameRage = [testString rangeOfString:secondUserName];
    
    NSRange rangeForTime = [testString rangeOfString:time];
    
    
    NSMutableAttributedString * attributtedComment = [[NSMutableAttributedString alloc] initWithString:statment];
    
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                               range:range];
    
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:RobotoMedium size:14]
                               range:range];
    
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                               range:seconUserNameRage];
    
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:RobotoMedium size:14]
                               range:seconUserNameRage];
    
    
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                               range:rangeForTime];
    
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:RobotoMedium size:14]
                               range:rangeForTime];
    
    return attributtedComment;
}


@end
