//
//  ConfirmationCodeViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 7/23/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol senddataProtocol <NSObject>
-(void)sendPhoneNumberToEditScreen:(NSString *)updatedPhoneNumber;
@end

@interface ConfirmationCodeViewController : UIViewController
@property(nonatomic,assign)id delegate;
@property (weak, nonatomic) IBOutlet UITextField *confirmationCodeTextField;
@property NSString *otp;
@property NSString *phoneNumberWithCode;
- (IBAction)resendButtonAction:(id)sender;
- (IBAction)changeItButtonAction:(id)sender;
@property (weak, nonatomic) NSString *controllerName;
@property (weak, nonatomic) IBOutlet UILabel *enterNumberLabelOutlet;


@end
