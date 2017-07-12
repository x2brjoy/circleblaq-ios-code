//
//  SignupWithPhoneViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/15/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGOtpConformationViewController.h"

@interface PGSignupWithPhoneViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabelOutlet;

//textField outlets

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

//button outlets

@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;

//constraints outlets

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addPhoneImageHeightConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addPhoneImageWidthConstraintOutlet;


//button actions

- (IBAction)signUpWithYourEmailButtonAction:(id)sender;
- (IBAction)signInButtonAction:(id)sender;
- (IBAction)countrySelectorButtonaCTION:(id)sender;
- (IBAction)privacyPolicyButtonAction:(id)sender;
- (IBAction)nextButtonAction:(id)sender;

//outlet for activity view indicator.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityViewOutlet;

@property (weak, nonatomic) IBOutlet UIView *errorMessageViewOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMessageViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabelOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMessageViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *phoneNumberTextFieldViewOutlet;
@end

