//
//  OtpConformationViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/18/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGSignupWithPhoneViewController.h"



@interface PGOtpConformationViewController : UIViewController

@property(nonatomic) NSString *numb;
 
//button outlet

@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;

//textField outlet

@property (weak, nonatomic) IBOutlet UITextField *otpTextField;

//label outlet

@property (weak, nonatomic) IBOutlet UILabel *phnNumbLabel;

//button action

- (IBAction)nextButtonAction:(id)sender;

//constraint outlets

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otpPhoneImageWidthConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otpPhoneImageHeightConstraintOutlet;

//ACTIVITY view.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityViewOutlet;
- (IBAction)backButtonAction:(id)sender;

- (IBAction)resendButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *popviewOutlet;

@property (weak, nonatomic) IBOutlet UILabel *popAlertLabelOutlet;

@end
