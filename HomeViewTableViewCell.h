//
//  HomeViewTableViewCell.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/31/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  "KILabel.h"
#import <SCPlayer.h>

@interface HomeViewTableViewCell : UITableViewCell

/**
 *   postedImageViewOutlet is an imageview outlet.
 */
@property (weak, nonatomic) IBOutlet UIImageView *postedImageViewOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;

/*
 *  moreButtonOutlet is an nutton outlet.
 */
@property (weak, nonatomic) IBOutlet UIButton *moreButtonOutlet;

@property (weak, nonatomic) IBOutlet UIButton *likeButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *commentButtonOutlet;

@property (weak, nonatomic) IBOutlet KILabel *commentLabelOne;

@property (weak, nonatomic) IBOutlet KILabel *commentLabelTwo;


@property (weak, nonatomic) IBOutlet UILabel *personsLikedinfoLabelOutlet;


@property (weak, nonatomic) IBOutlet UIButton *viewAllCommentsButtonOutlet;

@property (weak, nonatomic) IBOutlet UIButton *listOfPeopleLikedThePostButton;

@property (weak, nonatomic) IBOutlet UIButton *shareButtonOutlet;
@property (weak, nonatomic) IBOutlet KILabel *userNameWithCaptionOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameWithCaptionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstCommentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondCommentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionAndCommentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LikeViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewAllCommentsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewAllCommentsButtonHeightConstraint;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totallikeButtonsViewWithCommentsandCaptionViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *timeLabelOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeCommentShareButtonsViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *showTagsButtonOutlet;
@property (weak,nonatomic)NSString *postType;

@end
