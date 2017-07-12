//
//  NearByPlacesTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 4/16/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearByPlacesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *locationImageViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *addressLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *subLocationAddressLabelOutlet;
@end
