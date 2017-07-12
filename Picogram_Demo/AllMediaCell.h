//
//  AllMediaCell.h
//  Sup
//
//  Created by Rahul Sharma on 2/4/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllMediaCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *mediaImg;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
- (IBAction)playBtn_Action:(id)sender;


@end
