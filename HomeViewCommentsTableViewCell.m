//
//  HomeViewCommentsTableViewCell.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/4/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "HomeViewCommentsTableViewCell.h"
#import "TinderGenericUtility.h"
#import "Helper.h"

@implementation HomeViewCommentsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}





-(void)changeHeightOfCommentLabel:(NSString *)comment andFrame:(CGRect )frameOfView{
    
    UILabel*captionlbl=[[UILabel alloc]initWithFrame:self.commentLabelOutlet.bounds];
    captionlbl.font=self.commentLabelOutlet.font;
    
    NSString *commentWithUserName = flStrForObj(comment);
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    commentWithUserName = [commentWithUserName stringByTrimmingCharactersInSet:ws];
    
    
    CGRect frame=captionlbl.frame;
    frame.size.width= frameOfView.size.width - 65 ;
    captionlbl.frame=frame;
    
    captionlbl.text =commentWithUserName;
    
    
    CGFloat heightOfCaption;
    
    
    //claculating the height of text and if the text is empty directly making the respective label or button height as zero otherwise calculating height of text by using measureHieightLabel method.
    //+5 ids for spacing for the labels.
    
    if ([captionlbl.text  isEqualToString:@""]) {
        heightOfCaption = 0;
    }
    else {
        heightOfCaption = [Helper measureHieightLabel:captionlbl] + 5;
    }
    
    self.commentLabelHeightConstraint.constant = heightOfCaption;
}

@end
