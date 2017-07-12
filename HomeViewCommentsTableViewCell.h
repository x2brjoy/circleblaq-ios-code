//
//  HomeViewCommentsTableViewCell.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/4/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "kilabel.h"

@interface HomeViewCommentsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;
@property (weak, nonatomic) IBOutlet KILabel *usernameLabelOutlet;

@property (weak, nonatomic) IBOutlet KILabel *commentLabelOutlet;


@property (weak, nonatomic) IBOutlet UILabel *timeLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *userNameButtonOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePhotoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePhotoHeightConstraint;

-(void)changeHeightOfCommentLabel:(NSString *)comment andFrame:(CGRect )frameOfView;
@end
