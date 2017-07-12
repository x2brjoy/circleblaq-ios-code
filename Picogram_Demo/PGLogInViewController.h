//
//  ViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/15/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface PGLogInViewController : UIViewController <UITextFieldDelegate>
@property NSString *faceBookUniqueIdOfUser;
@property NSString *faceBookUserEmailId;
@property NSString *profilepicurlFb;
@property NSString *fullNameForFb;

//textField outlets
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;

//button outlets
@property (weak, nonatomic) IBOutlet UIButton *loginbutton;

//constarints outlets
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picogramLogoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picoGramWidthConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picogramLogoTopSpaceConstaraint;


//button actions
/**
 *  signup button action
 *
 *  @param sender it will present signup viewController.
 */

- (IBAction)signUpButtonAction:(id)sender;
/**
 *  login with fb Button Action
 *
 *  @param sender it will present loginwith facebook viewController.
 */
- (IBAction)LogInWithFbButtonAction:(id)sender;
/**
 *    login Button Action
 *
 *  @param sender it will present loginbutton action.
 */

- (IBAction)logInButtonAction:(id)sender;
/**
 *  get Help Sign In Button Action
 *
 *  @param sender it will present helpSignin VIewController.
 */
- (IBAction)getHelpSignInButtonAction:(id)sender;
/**
 *  Response from Facebook
 *
 *  @param dictionary Details dict
 */
- (void)facebookLogin:(NSDictionary *)dictionary;


//outlet for activity view indicator.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityViewOutlet;


//constraint for height and space between textFields..etc.


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginWithFbHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldBottomSpaceToPasswordTextFieldConstraint;

@property NSTimer *timerIvar;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageViewOutlet;

@end

