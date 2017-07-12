//
//  DiscoverTableViewCell2.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DiscoverTableViewPostedImagesCell : UITableViewCell

//imageView outlet

@property (weak, nonatomic) IBOutlet UIImageView *ImageViewOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideButtonWidthConstraint;

//button outlets

@property (weak, nonatomic) IBOutlet UICollectionView *discoverCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *followButtonOutlet;

@property (weak, nonatomic) IBOutlet UIButton *hideButtonOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *postedImage1;
@property (weak, nonatomic) IBOutlet UIImageView *postedImage2;
@property (weak, nonatomic) IBOutlet UIImageView *postedImage3;
@property (weak, nonatomic) IBOutlet UIButton *buttonForPostedImage1;
@property (weak, nonatomic) IBOutlet UIButton *buttonForPostedImage2;
@property (weak, nonatomic) IBOutlet UIButton *buttonForPostedImage3;

@property (weak, nonatomic) IBOutlet UIView *userPostedImagesSuperView;
@property (weak, nonatomic) IBOutlet UIView *viewWhenNoPostsAvailable;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *labelUnderUserNameOutelt;
@property (weak, nonatomic) IBOutlet UILabel *messageWhenNoPostsAvailableLabelOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *imageWhenNoPostsAvailable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintFollowButtonOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followButtonTrailingConstraint;

@end
