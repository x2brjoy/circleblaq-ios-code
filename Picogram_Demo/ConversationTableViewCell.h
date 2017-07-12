//
//  ConversationTableViewCell.h
//  Sup
//
//  Created by Rahul Sharma on 10/24/15.
//  Copyright © 2015 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *fullNameGroupOrUserOutlet;
@property (strong, nonatomic) IBOutlet UILabel *senderNameInGroupChatOutlet;
@property (strong, nonatomic) IBOutlet UILabel *lastMessageOutlet;
@property (strong, nonatomic) IBOutlet UIImageView *groupOrUserImageOutlet;
@property (strong, nonatomic) IBOutlet UILabel *lastMessageTimingOutlet;
@property (strong, nonatomic) IBOutlet UILabel *batchCountLabelOutlet;
@property (strong, nonatomic) IBOutlet UIView *groupImageView;
@property (strong, nonatomic) IBOutlet UIImageView *groupImageTwo;
@property (strong, nonatomic) IBOutlet UIImageView *groupImageOne;

@end
