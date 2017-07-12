//
//  UserProfileViewTableViewCell.h
//  
//
//  Created by Rahul Sharma on 4/6/16.
//
//

#import <UIKit/UIKit.h>
#import  "KILabel.h"

@interface UserProfileViewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabelOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;

/**
 *   postedImageViewOutlet is an imageview outlet.
 */
@property (weak, nonatomic) IBOutlet UIImageView *postedImageViewOutlet;

/**
 *  moreButtonOutlet is an nutton outlet.
 */
@property (weak, nonatomic) IBOutlet UIButton *moreButtonOutlet;

@property (weak, nonatomic) IBOutlet UIButton *likeButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *commentButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *commentLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *commentLabelTwo;

@property (weak, nonatomic) IBOutlet UILabel *personsLikedinfoLabelOutlet;
@property (weak, nonatomic) IBOutlet KILabel *userNameLabel;


@property (weak, nonatomic) IBOutlet UIButton *viewAllCommentsButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *listOfPeopleLikedThePostButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButtonOutlet;


//constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewHeightConstriant;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameWithCaptionLabelHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstCommentHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeInfoViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewAllCommentsButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLablelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionAndCommentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TotalLikeCommentAndCaptionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondCommentHeightConstraint;


// new layout constraints.






@end
