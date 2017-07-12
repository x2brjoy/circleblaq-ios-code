//
//  DiscoverPeopleViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PGDiscoverPeopleViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *discoverTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *discoverCollectionView;


#define textColorWhenNoFriendsAvailable 
#define textColorWhenFriendsAvailable

@end
