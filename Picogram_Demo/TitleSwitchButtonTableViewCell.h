//
//  TitleSwitchButtonTableViewCell.h
//  Picogram
//
//  Created by Rahul Sharma on 8/6/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleSwitchButtonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *switchButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
