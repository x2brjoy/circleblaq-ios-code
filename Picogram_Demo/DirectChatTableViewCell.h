//
//  DirectChatTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 05/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectChatTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *friendsImage;
@property (strong, nonatomic) IBOutlet UIImageView *postImage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *msgLbl;

@end
