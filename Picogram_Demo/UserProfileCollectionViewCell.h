//
//  UserProfileCollectionViewCell.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/30/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileCollectionViewCell : UICollectionViewCell

/**
 *  uiimageview outlet and it is in cell.
 */
@property (weak, nonatomic) IBOutlet UIImageView *postedImagesOutlet;

@property (weak, nonatomic) IBOutlet UIImageView *videoLoadingImage;

@end
