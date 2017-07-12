//
//  ProfilePhotoSelectingViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/17/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGProfilePhotoSelectingViewController : UIViewController<UITextFieldDelegate>

@property NSString *faceBookUniqueIdOfUserToRegister;
@property NSString *faceBookEmailIdOfUserToRegister;
@property(nonatomic) NSString *codeForSignUpType;
@property(nonatomic) NSString *SignUpType;
@property(nonatomic) NSString *userEnteredEmail;
@property(nonatomic) NSString *emailForRegistration;
@property(nonatomic) NSString *userEnteredPhoneNumber;
@property(nonatomic) NSString *PhoneNumberForRegistration;
//textField outlets

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;

//button outlet

@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;

//imageView outlets
@property (weak, nonatomic) IBOutlet UIView *dividerViewOutlet;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *refershImageViewOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *correctCheckmarkImgaeViewOutlet;

//button actions

- (IBAction)imageSelectButtonAction:(id)sender;
- (IBAction)tapGestureAction:(id)sender;
- (IBAction)signInButtonAction:(id)sender;
- (IBAction)nextButtonAction:(id)sender;

- (IBAction)refreshButtonAction:(id)sender;

// constraints outlets

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addProfileImageHeightConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addProfileImageWidthConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addProfileImageButtonHeightConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addProfileImageButtonWidthConstraintOutlet;

//activity indicator view.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityVIewIndicatorOutlet;
@property (weak, nonatomic) IBOutlet UIView *popViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *popAlertLabelOutlet;
@property NSString *profilepicurlFb;
@property NSString *fullNameFromGb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *viewWhenPermissionsAreDenied;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintOfPermissionsView;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyAgreedBUttonOutlet;
- (IBAction)checkBoxAction:(id)sender;
- (IBAction)ppWebViewAction:(id)sender;

@end
