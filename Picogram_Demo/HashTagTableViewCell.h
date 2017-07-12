//
//  HashTagTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 7/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HashTagTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *hashtagLabel;

@property (weak, nonatomic) IBOutlet UILabel *hashTagCountLabel;
@end
