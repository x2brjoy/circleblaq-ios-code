//
//  businessSetupTableViewCell.m
//  Picogram
//
//  Created by Rahul Sharma on 07/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "businessSetupTableViewCell.h"
#import "FontDetailsClass.h"

@implementation businessSetupTableViewCell
{
    float w,h;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    w = [[UIScreen mainScreen]bounds].size.width;
    h = [[UIScreen mainScreen]bounds].size.height;

    
    self.iconTxT = [[UITextView alloc]initWithFrame:CGRectMake(50, 0,w-50,40)];
    self.iconTxT.textColor = [UIColor blackColor];
    self.iconTxT.scrollEnabled = NO;
    [self.iconTxT setFont:[UIFont fontWithName:RobotoRegular size:15]];
    [self.contentView addSubview:self.iconTxT];
    
    
    self.iconLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(self.iconTxT.frame) , w, 0.5)];
    self.iconLbl.backgroundColor = [UIColor colorWithRed:219/255.0f green:219/255.0f blue:219/255.0f alpha:1.0f];
    [self.contentView addSubview:self.iconLbl];

    
    self.iconDisplay = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    [self.contentView addSubview:self.iconDisplay];
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    
    
    
    CGSize size = self.iconTxT.contentSize;
    self.iconLbl.frame = CGRectMake(0, size.height, w, 0.5);
    
    
    
    
    
}

@end
