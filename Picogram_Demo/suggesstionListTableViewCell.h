//
//  suggesstionListTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 05/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol suggestListTBDelegate;
@interface suggesstionListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *friendsImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *fullNameLbl;
@property (strong, nonatomic) IBOutlet UIImageView *selectBtn;


@property (strong, nonatomic) NSDictionary *userDetails;
@property (weak, nonatomic) id <suggestListTBDelegate> delegate;
@end
@protocol suggestListTBDelegate <NSObject>

-(void)cell:(suggesstionListTableViewCell*)cell button:(UIButton*)btn withObject:(NSDictionary *)dic;

@end
