//
//  suggesstionListTableViewCell.m
//  Picogram
//
//  Created by Rahul Sharma on 05/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "suggesstionListTableViewCell.h"

@implementation suggesstionListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)userSelectedBtnAction:(id)sender {
    
    NSLog(@"selected User");
    
    if (_delegate && [_delegate respondsToSelector:@selector(cell:button:withObject:)])
    {
        [_delegate cell:self button:sender withObject:self.userDetails];
    }
}


@end
