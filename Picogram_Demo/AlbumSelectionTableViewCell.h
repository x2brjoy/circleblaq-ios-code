//
//  AlbumSelectionTableViewCell.h
//  Zuri
//
//  Created by Rahul_Sharma on 15/02/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumSelectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAssestsAvailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbimageview;


@end
