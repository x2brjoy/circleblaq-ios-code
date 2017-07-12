//
//  PhotocollectionViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/5/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionViewCell.h"

@interface PhotocollectionViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *NORMALtESTINGvIEW;

@property (weak, nonatomic) IBOutlet UIScrollView *scrlView;

@end
