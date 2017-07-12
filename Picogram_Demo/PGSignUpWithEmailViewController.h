//
//  SignUpWithEmailViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/16/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PGSignUpWithEmailViewController : UIViewController<UITextFieldDelegate>


// textField outlets

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

// button outlets

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

//view outlets

@property (weak, nonatomic) IBOutlet UIView *popview;

//constraint outlets

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addEmailImageHeightConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addEmailImageWidthConstraintOutlet;

//button actions

- (IBAction)privacyPolicyButtonAction:(id)sender;
- (IBAction)signinButtonAction:(id)sender;
- (IBAction)nextButtonAction:(id)sender;
- (IBAction)signupWithEmailButtonAction:(id)sender;

//activity view controller.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityViewOutlet;

@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabelOutlet;


@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabelOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMessageViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *errorMeassgaeViewOutlet;

@end
