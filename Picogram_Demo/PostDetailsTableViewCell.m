//
//  PostDetailsTableViewCell.m
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 13/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PostDetailsTableViewCell.h"
#import "TinderGenericUtility.h"
#import "FontDetailsClass.h"
#import "Helper.h"

@implementation PostDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)showcomments:(NSArray *)dataArray and:(NSInteger)section andframe:(CGRect)frame {

    UILabel*firstCommentLbl=[[UILabel alloc]initWithFrame:self.firstCommentLabel.bounds];
    firstCommentLbl.font=self.firstCommentLabel.font;
    
    UILabel*secondCommentLbl=[[UILabel alloc]initWithFrame:self.secondCommentLabelOutlet.bounds];
    secondCommentLbl.font=self.secondCommentLabelOutlet.font;
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    
    CGRect firstCommentframe = firstCommentLbl.frame;
    firstCommentframe.size.width=frame.size.width - 20;
    firstCommentLbl.frame=firstCommentframe;
    
    CGRect secondCommentframe = secondCommentLbl.frame;
    secondCommentframe.size.width=frame.size.width - 20;
    secondCommentLbl.frame=secondCommentframe;
    
    NSArray *response =  dataArray[section][@"commentData"];
    
    firstCommentLbl.text = @"";
    secondCommentLbl.text = @"";
    [self.firstCommentUserNameButtonOutlet setTitle:@"" forState:UIControlStateNormal];
     [self.secondCommentButtonOutlet setTitle:@"" forState:UIControlStateNormal];
    
    self.secondCommentButtonOutlet.enabled = NO;
    self.firstCommentUserNameButtonOutlet.enabled = NO;
    
    NSString *countOfComments = flStrForObj(dataArray[section][@"totalComments"]);
    
    NSString *totalNumberOfComments = [countOfComments stringByAppendingString:@" comments"];
    
    NSString *titleForViewAllComments = [@"View all " stringByAppendingString:totalNumberOfComments];
    
    [self.viewAllCommentsButtonOutlet setTitle:titleForViewAllComments forState:UIControlStateNormal];
    
    if (response.count == 1) {
        NSString *commentedUser1 = flStrForObj(response[0][@"commentedByUser"]);
        NSString *commentedText1 = flStrForObj(response[0][@"commentBody"]);
        NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
        
        postcommentWithUserName1 = [postcommentWithUserName1 stringByTrimmingCharactersInSet:ws];
        
        firstCommentLbl.text =postcommentWithUserName1;
        self.firstCommentLabel.text = postcommentWithUserName1;
        
         [self.firstCommentUserNameButtonOutlet setTitle:commentedUser1 forState:UIControlStateNormal];
         self.firstCommentUserNameButtonOutlet.enabled = YES;
        
        
        //attributing the comment.
        
        NSRange range1 = [firstCommentLbl.text rangeOfString:commentedUser1];
        NSRange range2 = [firstCommentLbl.text rangeOfString:commentedText1];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:firstCommentLbl.text];
        
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RobotoBold size:14],NSForegroundColorAttributeName:[UIColor blackColor]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RobotoRegular size:14],NSForegroundColorAttributeName:[UIColor blackColor]}
                                range:range2];
        
        firstCommentLbl.attributedText = attributedText;
        self.firstCommentLabel.attributedText = attributedText;
    }
    else if (response.count >1) {
        
        NSString *commentedUser1 = flStrForObj(response[0][@"commentedByUser"]);
        NSString *commentedText1 = flStrForObj(response[0][@"commentBody"]);
        
        NSString *commentedUser2 = flStrForObj(response[1][@"commentedByUser"]);
        NSString *commentedText2 =  flStrForObj(response[1][@"commentBody"]);
        
        commentedText1 = [commentedText1 stringByTrimmingCharactersInSet:ws];
        commentedText2 = [commentedText2 stringByTrimmingCharactersInSet:ws];
        
          [self.firstCommentUserNameButtonOutlet setTitle:commentedUser1 forState:UIControlStateNormal];
          [self.secondCommentButtonOutlet setTitle:commentedUser2 forState:UIControlStateNormal];
        
        self.secondCommentButtonOutlet.enabled = YES;
        self.firstCommentUserNameButtonOutlet.enabled = YES;
        
        
        NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@" %@",commentedText1];
        
        postcommentWithUserName1 = [postcommentWithUserName1 stringByTrimmingCharactersInSet:ws];
        
        NSString *postcommentWithUserName2 = [commentedUser2 stringByAppendingFormat:@" %@",commentedText2];
        
        postcommentWithUserName2 = [postcommentWithUserName2 stringByTrimmingCharactersInSet:ws];
        
        
        
        firstCommentLbl.text = postcommentWithUserName1;
        self.firstCommentLabel.text = firstCommentLbl.text;
        
        
        secondCommentLbl.text =postcommentWithUserName2;
        self.secondCommentLabelOutlet.text =  secondCommentLbl.text;
        
        
        
        firstCommentLbl.text =postcommentWithUserName1;
        self.firstCommentLabel.text = postcommentWithUserName1;
        
        //attributing the second comment.
        
        NSRange range3 = [postcommentWithUserName2 rangeOfString:commentedUser2];
        NSRange range4 = [postcommentWithUserName2 rangeOfString:commentedText2];
        
        NSMutableAttributedString *attributedText2 = [[NSMutableAttributedString alloc] initWithString:secondCommentLbl.text];
        
        [attributedText2 setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RobotoBold size:14],NSForegroundColorAttributeName:[UIColor blackColor]}
                                 range:range3];
        [attributedText2 setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RobotoRegular size:14],NSForegroundColorAttributeName:[UIColor blackColor]}
                                 range:range4];
        
        secondCommentLbl.attributedText = attributedText2;
        self.secondCommentLabelOutlet.attributedText = attributedText2;
        
        //attributing the first comment.
        
        NSRange range1 = [firstCommentLbl.text rangeOfString:commentedUser1];
        NSRange range2 = [firstCommentLbl.text rangeOfString:commentedText1];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:firstCommentLbl.text];
        
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RobotoBold size:14],NSForegroundColorAttributeName:[UIColor blackColor]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RobotoRegular size:14],NSForegroundColorAttributeName:[UIColor blackColor]}
                                range:range2];
        
        firstCommentLbl.attributedText = attributedText;
        self.firstCommentLabel.attributedText = attributedText;
        
    }
    
    
    if (firstCommentLbl.text.length > 0) {
        self.firstCommentHeightConstr.constant =[Helper measureHieightLabel:firstCommentLbl] + 5 ;
    }
    else {
        self.firstCommentHeightConstr.constant = 0;
    }
    
    if (secondCommentLbl.text.length >0) {
       self.secondCommentHeightConstr.constant =[Helper measureHieightLabel:secondCommentLbl] + 5 ;
    }
    else
    {
        self.secondCommentHeightConstr.constant = 0;
    }
    
    if (self.firstCommentHeightConstr.constant >0 && self.secondCommentHeightConstr.constant > 0 ) {
        self.viewallcommentsHeight.constant = 25;
        self.viewAllCommentsButtonOutlet.hidden = NO;
        
    }
    else {
        self.viewallcommentsHeight.constant = 0;
        self.viewAllCommentsButtonOutlet.hidden = YES;
    }
}

-(void)customizingCaption:(NSArray *)dataArray and:(NSInteger)section andFrame:(CGRect )frame {

    
    UILabel*captionlbl=[[UILabel alloc]initWithFrame:self.captionLabelOutlet.bounds];
    captionlbl.font=self.captionLabelOutlet.font;
    
     NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    //alloting text for labels.
    NSString *postedUser = flStrForObj(dataArray[section][@"postedByUserName"]);
    NSString *caption = flStrForObj(dataArray[section][@"postCaption"]);
    NSString *captionWithUserName = [postedUser stringByAppendingFormat:@"  %@",caption];
    caption = [caption stringByTrimmingCharactersInSet:ws];
    
    
    
    [self.captionUserNameButtonOutlet setTitle:postedUser forState:UIControlStateNormal];
    
    
    captionWithUserName = [captionWithUserName stringByTrimmingCharactersInSet:ws];
    
    CGRect captionframe=captionlbl.frame;
    captionframe.size.width=frame.size.width - 20;
    captionlbl.frame=captionframe;
    
    
    if ([caption isEqualToString:@"null"]) {
        captionlbl.text = @"";
        self.captionLabelOutlet.text = @"";
        self.captionLabelHeightConstraint.constant = 0;
        [self.captionUserNameButtonOutlet setTitle:@"" forState:UIControlStateNormal];
        self.captionUserNameButtonOutlet.enabled = NO;
        
    }
    else {
        captionlbl.text = captionWithUserName;
        self.captionLabelOutlet.text = captionlbl.text;
        
        NSRange range1 = [captionlbl.text rangeOfString:postedUser];
        NSRange range2 = [captionlbl.text rangeOfString:caption];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:captionlbl.text];
        
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RobotoBold size:14],NSForegroundColorAttributeName:[UIColor blackColor]}
                                range:range1];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RobotoRegular size:14],NSForegroundColorAttributeName:[UIColor blackColor]}
                                range:range2];
        
        captionlbl.attributedText = attributedText;
        self.captionLabelOutlet.attributedText = attributedText;
        
        self.captionLabelHeightConstraint.constant =[Helper measureHieightLabel:captionlbl] + 5;
    }
}

-(void)showinNumberOfLikes:(NSInteger )numberOfLikes {
    if(numberOfLikes >0) {
        self.numberOfLikesViewHeightConstraint.constant = 25;
        if (numberOfLikes == 1) {
            [self.numberOfLikesButtonOutlet setTitle:[[NSString stringWithFormat:@"%ld",(long)numberOfLikes] stringByAppendingString:@" Like"] forState:UIControlStateNormal];
        }
        else {
            [self.numberOfLikesButtonOutlet setTitle:[[NSString stringWithFormat:@"%ld",(long)numberOfLikes] stringByAppendingString:@" Likes"] forState:UIControlStateNormal];
        }
    }
    else {
        self.numberOfLikesViewHeightConstraint.constant = 0;
        [self.numberOfLikesButtonOutlet setTitle:@"" forState:UIControlStateNormal];
    }
}

- (IBAction)listOfLikesButtonAction:(id)sender {
}
@end
