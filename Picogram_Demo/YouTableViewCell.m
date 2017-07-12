//
//  YouTableViewCell.m
//  Picogram
//
//  Created by Rahul Sharma on 7/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "YouTableViewCell.h"

@implementation YouTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [_usernameBtn addTarget:self action:@selector(userNameAction:) forControlEvents:UIControlEventTouchUpInside];
   return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)followButtonAction:(id)sender {
    
   

}
- (IBAction)userNameAction:(id)sender {

    if (_delegate && [_delegate respondsToSelector:@selector(ownActivitycell:button:withObject:)]) {
        [_delegate ownActivitycell:self button:sender withObject:self.userdetails];
      }
}
- (IBAction)postButtonAction:(id)sender {

        if (_delegate && [_delegate respondsToSelector:@selector(selfCell:postbutton:ofpostType:withpostid:andUserName:)]) {
            [_delegate selfCell:self postbutton:sender ofpostType:self.postType withpostid:self.postID andUserName:self.actitvtyUserName];
            
        }

}


@end
