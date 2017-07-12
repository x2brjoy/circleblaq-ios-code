//
//  PostedPhotosCollectionViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/7/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewCell.h"
#import "PostedPhotoCollectionViewCell.h"

@interface PostedPhotosCollectionViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *PostedPhotocollectionView;
@property (weak,nonatomic) NSString *getDetailsOfUser;

@end
