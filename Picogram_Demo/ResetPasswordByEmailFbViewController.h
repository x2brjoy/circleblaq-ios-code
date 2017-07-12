//
//  ResetPasswordByEmailFbViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 8/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordByEmailFbViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
- (IBAction)donthaveAcessButtonAction:(id)sender;
- (IBAction)sendPasswordEmail:(id)sender;
- (IBAction)resetUsingFaceBook:(id)sender;
@end
