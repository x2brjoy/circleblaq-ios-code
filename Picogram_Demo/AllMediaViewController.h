//
//  AllMediaViewController.h
//  Sup
//
//  Created by Rahul Sharma on 2/4/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllMediaViewController : UIViewController<UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *mediaList;
@property (strong, nonatomic) NSMutableDictionary *mediaListInfo;
@property (strong, nonatomic) IBOutlet UIImageView *mediaImage;
@property (strong, nonatomic) IBOutlet UICollectionView *mediaCollection;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
- (IBAction)backAction:(id)sender;
@end
