//
//  SignUpViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/15/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGSignUpViewController : UIViewController


//button actions

- (IBAction)signUpButtonAction:(id)sender;
- (IBAction)SignupWithPhoneButtonAction:(id)sender;
- (IBAction)LoginWithFbButtonAction:(id)sender;

//constraint outlets

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picogramWidthConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picogramHeightConstraintOutlet;
@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebbokButtonOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginWithFbHeightConstraint;
@property NSString *faceBookUniqueIdOfUser;
@property NSString *faceBookUserEmailId;
@property NSString *profilepicurlFb;

@end
