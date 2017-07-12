//
//  PostDetailsTableViewCell.h
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 13/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kilabel.h"

@interface PostDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet KILabel *captionLabelOutlet;
@property (weak, nonatomic) IBOutlet KILabel *firstCommentLabel;
@property (weak, nonatomic) IBOutlet KILabel *secondCommentLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *postedTimeLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *viewAllCommentsButtonOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstCommentHeightConstr;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewallcommentsHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondCommentHeightConstr;
-(void)showcomments:(NSArray *)dataArray and:(NSInteger)section andframe:(CGRect)frame;
-(void)customizingCaption:(NSArray *)dataArray and:(NSInteger)section andFrame:(CGRect )frame;

-(void)showinNumberOfLikes:(NSInteger )numberOfLikes;

@property (weak, nonatomic) IBOutlet UIButton *viewAllCommentsButtonAction;

@property (weak, nonatomic) IBOutlet UIView *numberOfLikesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numberOfLikesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *numberOfLikesButtonOutlet;
- (IBAction)listOfLikesButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *firstCommentUserNameButtonOutlet;

@property (weak, nonatomic) IBOutlet UIButton *captionUserNameButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *secondCommentButtonOutlet;
@end
