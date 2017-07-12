//
//  HashTagViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 6/1/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HashTagViewController : UIViewController

@property NSString *navTittle;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;

@property (weak, nonatomic) IBOutlet UIView *viewForNoPostsAvailable;
@property  NSString *requestType;
@property  NSString *category;
@property  NSString *subCategory;

@end
