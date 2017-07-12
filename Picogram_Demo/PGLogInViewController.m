
//  ViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/15/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGLogInViewController.h"
#import "FBLoginHandler.h"
#import "PGTabBar.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "ProgressIndicator.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PGProfilePhotoSelectingViewController.h"
#import "pop/POP.h"
#import "TinderGenericUtility.h"
#import "Helper.h"

@interface PGLogInViewController ()<FBLoginHandlerDelegate,UIGestureRecognizerDelegate,WebServiceHandlerDelegate>
@end

@implementation PGLogInViewController

/*--------------------------------------*/
#pragma mark
#pragma mark - viewcontroller delegates.
/*--------------------------------------*/

- (void)viewDidLoad {
    [super viewDidLoad];
     /**
     *  Method to hide the navigation bar.
     *  YES - To hide the navigation bar
     *  NO  - To show the navigation bar
     */
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self loginButtonDetails];
    [self addTapGestureForDismissKeyBoard];
    [self textFiledPlaceHolderColor];
    [self hidingActivityViewController];
    [self addingNotificationForTextfieldContentChange];
    //hiding status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                           withAnimation:UIStatusBarAnimationFade];
    
    //self.activityViewOutlet.tintColor = [UIColor whiteColor];
}

//login button will be anbled intially.
-(void)viewWillAppear:(BOOL)animated {
    self.loginbutton.titleLabel.hidden = NO;
}

/*-----------------------------------------------*/
#pragma mark
#pragma mark - viewDidLoad methods defination.
/*-----------------------------------------------*/

-(void)textFiledPlaceHolderColor {
    /**
     *   giving color for place holder text color for name and password textfields
     */
    [self.nameTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                      forKeyPath:@"_placeholderLabel.textColor"];
    [self.passWordTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                          forKeyPath:@"_placeholderLabel.textColor"];
}

-(void)hidingActivityViewController {
    //hiding progress indicators after getting response.
    self.activityViewOutlet.hidden = YES;
    self.loginbutton.titleLabel.hidden = NO;
}

-(void)addingNotificationForTextfieldContentChange {
    // it will notify whenever textfield is modified or start editing.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:_nameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:_passWordTextField];
}

-(void)loginButtonDetails {
    /**
     *  intially keeping login  button in disable state and if user enter details changing into enable  state.
     */
    
    [_loginbutton setEnabled:NO];
    
    /**
     *  setting login button border and color for boarder.
     */
    
    _loginbutton.layer.cornerRadius = 5; // this value vary as per your desire
    _loginbutton.clipsToBounds = YES;
    
    [[_loginbutton layer] setBorderWidth:1.0f];
    [[_loginbutton layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor];
}



-(void)addTapGestureForDismissKeyBoard {
    /**
     *    method to hide the key board when you click out side
     *    and its calling dismisskeyboard method
     */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

-(void)textFieldChanged:(NSNotification *)notification {
    
    //if any text is there in textField then we are enabling the login button otherwise we are disabling the login button.
    // checkForMandatoryField method we are using to check any text is there intextFields.
    // checkForMandatoryField will return  YES if any text is there otherWise it will return NO.
    
    if ([self checkForMandatoryField]) {
        [_loginbutton setEnabled:YES];
        [_loginbutton setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:1.0] forState:UIControlStateHighlighted];
    }
    else {
        [_loginbutton setEnabled:NO];
        [_loginbutton setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.2] forState:UIControlStateHighlighted];
    }
}

/*-----------------------------------*/
#pragma mark
#pragma mark - textfield Delegates.
/*-----------------------------------*/

/**
 *  giving implementation to key board return button.
 *
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameTextField) {
        [_nameTextField resignFirstResponder];
        [_passWordTextField becomeFirstResponder];
        float maxY = CGRectGetMaxY(_passWordTextField.frame) +300 ;
        float reminder = CGRectGetHeight(self.view.frame) - maxY;
        if (reminder < 0) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 
                                 CGRect frameOfView = self.view.frame;
                                 frameOfView.origin.y = reminder ;
                                 self.view.frame = frameOfView;
                                                             }];
        }
    }
    else if (textField ==_passWordTextField)
    {
        if ([self checkForMandatoryField]) {
          [self LoginButtonSelected];
        }
    }
    return YES;
}

/*  This delegate method is calling checkForMandatoryField to check textfields contain any details or not.
 *  this method is called when user enter input.
 *  this method is used to check user entered any details or not if user enter any details then login button changed to enable state from disable state.
 *  here
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

/**
 *   this user defined method called by textField shouldChangeCharactersInRange delegate method and it is bool vale
 *  @return  yes if user enter any details in textfields and NO if the textfields nameTextField,passWordTextField are empty.
 */
- (BOOL)checkForMandatoryField {
    // checkForMandatoryField method we are using to check any text is there in textFields.
    // checkForMandatoryField will return  YES if any text is there otherWise it will return NO.
    if (_nameTextField.text.length != 0 && _passWordTextField.text.length != 0) {
        return YES;
    }
    return NO;
}

/**
 *   this delegate method is called when  user starts  edit  textfield.
 *  here this method scrolls the view to upside to show the login button.
 otherwise the login button is hided by keyboard.
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(_passWordTextField.text.length == 0) {
        [_loginbutton setEnabled:NO];
    }
    float maxY = CGRectGetMaxY(_passWordTextField.frame) + 320;
    float reminder = CGRectGetHeight(self.view.frame) - maxY;
    if (reminder < 0) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect frameOfView = self.view.frame;
                             frameOfView.origin.y = reminder;
                             self.view.frame = frameOfView;
                                                    }];
    }
}

/**
 *  this  method is called by uigesture when user clicks out side of textfield and this method also doing changing the position of view
 to oroginal position.
 */
- (void)dismissKeyboard {
    /**
     *  methdos used to dismiss key board.
     */
    [self.nameTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
    /**
     *  here we are changing the position of view to (0,0) by giving view x,y postions view to zero.
     */
    [UIView animateWithDuration:0.2
                     animations:^{
                         CGRect frameOfView = self.view.frame;
                         frameOfView.origin.y = 0;
                         frameOfView.origin.x=0;
                         self.view.frame = frameOfView;
                     }];
    
    
}

/*----------------------------------------*/
#pragma mark
#pragma mark - status bar
/*---------------------------------------*/

/**
 *  method used to hide the status bar or not.
 *
 *  @return YES means it hides the status bar and if it is NO then shows status bar.
 */
- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*-----------------------------*/
#pragma mark
#pragma mark - Button Actions
/*-----------------------------*/

/*
 login button action
 */
- (IBAction)logInButtonAction:(id)sender {
    [self LoginButtonSelected];
}

-(void)LoginButtonSelected {
    //removing button title beacuse we need to show activity view instead button of title.
    
    [self.loginbutton setTitle:@"" forState:UIControlStateNormal];
    [self.loginbutton.titleLabel setHidden:YES];
    
    //animating activity view(progress bar).
    [self.activityViewOutlet startAnimating];
    self.activityViewOutlet.hidden = NO;
    
    // login api requesting.
    NSDictionary *requestDict = @{mUserName    : _nameTextField.text,
                                  mPswd :_passWordTextField.text ,
                                  mpushToken   :flStrForObj([Helper deviceToken]),
                                  };
    [WebServiceHandler logId:requestDict andDelegate:self];
}

/**
 *  signup button action and if you click this button the signup screen will open.
 *  "LogInToSignUpSegue" is a segue used to move   to signup view from login .
 *
 */
- (IBAction)signUpButtonAction:(id)sender{
    [self performSegueWithIdentifier:@"LogInToSignUpSegue" sender:nil];
}

/**
 *  login with facebook button action and if you click this button the facebook login details screen will come.
 *
 *    "LogInToFBSegue" is a segue used to move   to facebook login details  view from login .
 */

- (IBAction)LogInWithFbButtonAction:(id)sender {
    //request for fb.
    FBLoginHandler *handler = [FBLoginHandler sharedInstance];
    [handler loginWithFacebook:self];
    [handler setDelegate:self];
}

/**
 *  this  is called when user taps getHelpSignIn Button
 *
 *  @param sender changing to help signin view controller.
 */
- (IBAction)getHelpSignInButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"GetHelpSignInSegue" sender:nil];
}

/*------------------------------------------------*/
#pragma mark
#pragma mark - Prepare For Segue.
/*------------------------------------------------*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"loginWithFb"]) {
        PGProfilePhotoSelectingViewController *vc = [segue destinationViewController];
        vc.codeForSignUpType =@"1";
        //sending fb id for registering.
        vc.faceBookUniqueIdOfUserToRegister = self.faceBookUniqueIdOfUser;
        vc.faceBookEmailIdOfUserToRegister  = self.faceBookUserEmailId ;
        vc.profilepicurlFb = self.profilepicurlFb;
        vc.fullNameFromGb = self.fullNameForFb;
    }
}

/*--------------------------------------------*/
#pragma mark
#pragma mark - facebook handler
/*--------------------------------------------*/

/**
 *  Facebook login is success
 *
 *  @param userInfo Userdict
 */
- (void)didFacebookUserLoginWithDetails:(NSDictionary*)userInfo {
   
    NSDictionary *requestDict = @{mfaceBookLogin :@"1",
                                  mfaceBookId :userInfo[@"id"],
                                  mpushToken   :flStrForObj([Helper deviceToken]),
                                  };
    [WebServiceHandler logId:requestDict andDelegate:self];
    
    
    self.faceBookUniqueIdOfUser = userInfo[@"id"];
    self.faceBookUserEmailId  =  flStrForObj( userInfo[@"email"]);
    self.fullNameForFb = flStrForObj( userInfo[@"name"]);
    
    if (!(self.faceBookUserEmailId.length >1)) {
        NSString *UniqueMailId = [self.faceBookUniqueIdOfUser stringByAppendingString:@"@facebook.com"];
        self.faceBookUserEmailId = UniqueMailId;
    }
     NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", self.faceBookUniqueIdOfUser]];
    
    self.profilepicurlFb = flStrForObj(pictureURL.absoluteString);
}

/**
 *  Login failed with error
 *
 *  @param error error
 */
- (void)didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
/**
 *  User cancelled
 */
- (void)didUserCancelLogin {
    NSLog(@"USER CANCELED THE LOGIN");
}

/*-----------------------------------------------*/

#pragma mark - Webservice Handler

/*-----------------------------------------------*/

#pragma mark
#pragma mark - Facebook Methods

/**
 *  Response from Facebook
 *
 *  @param dictionary Details dict
 */

- (void)facebookLogin:(NSDictionary *)dictionary {
}

/*-----------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*-----------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
  //handling response.
     //hiding activity view indicator and stooping animation.
    
    self.activityViewOutlet.hidden = YES;
    [self.activityViewOutlet stopAnimating];
    self.loginbutton.titleLabel.hidden = NO;
    [self.loginbutton setTitle:@"Log In" forState:UIControlStateNormal];
    if (error) {
        
         [self errAlert:[error localizedDescription] andTitle:@"Error" andCancelButtonTitle:@"Ok"];
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:[error localizedDescription]
//                                                       delegate:self
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil,nil];
//        [alert show];
        return;
    }
    //storing the response from server to dictonary.
    
    NSDictionary *responseDict = (NSDictionary*)response;
    //checking the request type and handling respective response code.
    if (requestType == RequestTypeLogin ) {
        
        // Chat Start
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@",responseDict[@"userId"]] forKey:@"userId"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        // Chat End
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
        // success response.
               
                NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:responseDict];
                [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:userDetailKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSData *dataSaveForBussiness = [NSKeyedArchiver archivedDataWithRootObject:responseDict];
                [[NSUserDefaults standardUserDefaults] setObject:dataSaveForBussiness forKey:userDetailForBussiness];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //BussinessAccountStatus
                NSString *type = flStrForObj(response[@"businessProfile"]);
                [[NSUserDefaults standardUserDefaults] setValue:type forKey:@"BussinessAccountStatus" ];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                [self updateDeviceDetailsForAdmin];
                [self performSegueWithIdentifier:@"loginToTabBar" sender:nil];
            }
                break;
        //failure response.
            case 1971: {
                [self errAlert:responseDict[@"message"] andTitle:@"Message" andCancelButtonTitle:@"Ok"];
            }
                break;
            case 1972: {
                 [self errAlert:responseDict[@"message"] andTitle:@"Message" andCancelButtonTitle:@"Ok"];
            }
                break;
            case 1973: {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
                    
                    [self.nameTextField resignFirstResponder];
                    [self.passWordTextField resignFirstResponder];
                    
                    //code with animation
                    CGRect frameOfView = self.view.frame;
                    frameOfView.origin.y = 0;
                    frameOfView.origin.x=0;
                    self.view.frame = frameOfView;
                    
                    
                } completion:^(BOOL finished) {
                    //code for completion
                    
                    
                    [self errAlert:@"The username you entered doesn't appear to belong to an account.Please check your username and tryagain." andTitle:@"Incorrect Username" andCancelButtonTitle:@"Try Again"];
                    
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Username"
//                                                                    message:@"The username you entered doesn't appear to belong to an account.Please check your username and tryagain."
//                                                                   delegate:self
//                                                          cancelButtonTitle:@"Try Again"
//                                                          otherButtonTitles:nil,nil];
//                    [alert show];
                }];
            }
            break;
            case 1974: {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
                    
                    [self.nameTextField resignFirstResponder];
                    [self.passWordTextField resignFirstResponder];
                    
                    //code with animation
                    CGRect frameOfView = self.view.frame;
                    frameOfView.origin.y = 0;
                    frameOfView.origin.x=0;
                    self.view.frame = frameOfView;
                    
                    
                } completion:^(BOOL finished) {
                    //code for completion
                    
                    NSString *titleForAlert = [@"Incorrect password For "  stringByAppendingString:self.nameTextField.text];
                    
                    
                     [self errAlert:@"The password you entered is incorrect.Please try again." andTitle:titleForAlert andCancelButtonTitle:@"Try Again"];
                    
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleForAlert
//                                                                    message:@"The password you entered is incorrect.Please try again."
//                                                                   delegate:self
//                                                          cancelButtonTitle:@"Try Again"
//                                                          otherButtonTitles:nil,nil];
//                    [alert show];
                }];
               
            }
                break;
            case 197: {
                [self performSegueWithIdentifier:@"loginWithFb" sender:self];
            }
            default:
                break;
        }
    }
    if (requestType == RequestTypelogDevice ) {
        
        
    }

    
}

- (void)errAlert:(NSString *)message andTitle:(NSString *)title  andCancelButtonTitle:(NSString *)cancelButtonTitle{
    //creating alert for error message.
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        
        [self.nameTextField resignFirstResponder];
        [self.passWordTextField resignFirstResponder];
        
        //code with animation
        CGRect frameOfView = self.view.frame;
        frameOfView.origin.y = 0;
        frameOfView.origin.x=0;
        self.view.frame = frameOfView;
        
        
    } completion:^(BOOL finished) {
        //code for completion
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil];
        [alert show];
    }];
}


#pragma mark-Owner Mobile Details
-(void)updateDeviceDetailsForAdmin {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //NSString build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString )kCFBundleVersionKey];
    //deviceName, deviceId, deviceOs, modelNumber, appVersion
    NSDictionary *requestDict = @{@"deviceName"    :flStrForObj([UIDevice currentDevice].name),
                                  @"deviceId" :flStrForObj([[[UIDevice currentDevice] identifierForVendor] UUIDString]),
                                  @"modelNumber" :flStrForObj([UIDevice currentDevice].model),
                                  @"deviceOs" :flStrForObj([[UIDevice currentDevice] systemVersion]),
                                  @"appVersion" :flStrForObj(version),
                                  @"token":flStrForObj([Helper userToken]),
                                  };
    [WebServiceHandler logDevice:requestDict andDelegate:self];
}
@end
