//
//  ImageViewTableViewCell.h
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 24/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOutlet;
-(void)loadImageForCell;
@property (strong,nonatomic) NSString *url;

@end
