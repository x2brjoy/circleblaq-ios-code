//
//  ForgotPasswordViewController.h
//  Picogram
//
//  Created by Rahul_Sharma on 04/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *toggleButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *sendLoginLinkButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *loginWithFacebookOutlet;
- (IBAction)backToLogInButtonAction:(id)sender;

- (IBAction)toggleButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *countryCodeButtonOutlet;
- (IBAction)countryCodeButtonaction:(id)sender;
- (IBAction)sendLoginLinkButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property int heighOfKeyBoard;
@property NSString *selectedCountryCode;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
