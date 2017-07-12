//
//  DiscoverPeopleTableViewCell.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGDiscoverPeopleTableViewCell : UITableViewCell

//imageView outlets

@property (weak, nonatomic) IBOutlet UIImageView *imageViewOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *nextIndicatorImageViewoutlet;

//label outlets
@property (weak, nonatomic) IBOutlet UILabel *TitleLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabelOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTitleHeightConstraint;

@end
