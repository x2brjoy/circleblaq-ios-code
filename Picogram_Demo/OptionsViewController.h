//
//  OptionsViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 8/4/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol senddataProtocol <NSObject>
-(void)sendPrivateStatusToUserProfileVc:(NSString *)newPrivateStatus;
@end



@interface OptionsViewController : UIViewController

@property NSString *token;
@property NSString *privateAccountState;

@property(nonatomic,assign)id delegate;

@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;
@end
