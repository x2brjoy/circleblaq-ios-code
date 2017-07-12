//
//  SignUpViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/15/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGSignUpViewController.h"
#import "FBLoginHandler.h"
#import "ProgressIndicator.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "PGProfilePhotoSelectingViewController.h"

@interface PGSignUpViewController ()<FBLoginHandlerDelegate,WebServiceHandlerDelegate>

@end

@implementation PGSignUpViewController

- (void)viewDidLoad {
     [super viewDidLoad];
     if(CGRectGetHeight(self.view.frame) !=480 && CGRectGetHeight(self.view.frame) !=568 &&CGRectGetHeight(self.view.frame) !=548)
     {
         _picogramHeightConstraintOutlet.constant =180;
         _picogramWidthConstraintOutlet.constant =180;
         _loginWithFbHeightConstraint.constant = 50;
     }
    
    _loginWithFacebbokButtonOutlet.layer.cornerRadius = 5;
}

#pragma mark
#pragma mark - navigation bar


/**
 *  method used to hide the status bar or not.
 *
 *  @return YES means it hides the status bar and if it is NO then shows status bar.
 */

- (BOOL)prefersStatusBarHidden {
    return YES;
 }

#pragma mark
#pragma mark - Button

/**
 *   this button action performed when user taps on signup button
 *
 *  @param sender changing  to previous view controller(login view controller).
 */

- (IBAction)signUpButtonAction:(id)sender

{
    [self.navigationController popViewControllerAnimated:YES];

 }

/**
 *   this button action performed when user taps on  SignupWithPhone button
 *
 *  @param sender changing  to signup with phone view controller.
 */

- (IBAction)SignupWithPhoneButtonAction:(id)sender
 {
     [self performSegueWithIdentifier:@"signupTophoneSegue" sender:nil];
 }

/**
 *   this button action performed when user taps on  LoginWithfacebook  button
 *
 *  @param sender changing  to signup with signup with facebook view controller.
 */

- (IBAction)LoginWithFbButtonAction:(id)sender

 {
   // [self performSegueWithIdentifier:@"SignUpToFBSegue" sender:nil];
     FBLoginHandler *handler = [FBLoginHandler sharedInstance];
     [handler loginWithFacebook:self];
     [handler setDelegate:self];
 }


/**
 *   this button action performed when user taps on  signIn button
 *
 *  @param sender changing  to signup with profile  view controller.
 */


- (IBAction)signInButtonAction:(id)sender
{
    [self performSegueWithIdentifier:@"profileToSignInSegue" sender:nil];
}
#pragma mark
#pragma mark - facebook

/**
 *  Facebook login is success
 *
 *  @param userInfo Userdict
 */
- (void)didFacebookUserLoginWithDetails:(NSDictionary*)userInfo {
    ProgressIndicator *loginPI = [ProgressIndicator sharedInstance];  [loginPI showPIOnView:self.view withMessage:@"Logging In"];
    //[self performSegueWithIdentifier:@"loginWithFbSegue" sender:nil];
    NSLog(@"FB Data =  %@", userInfo);
    
    
    NSDictionary *requestDict = @{mfaceBookLogin :@"1",
                                  mfaceBookId :userInfo[@"id"]
                                  };
    [WebServiceHandler logId:requestDict andDelegate:self];
    self.faceBookUniqueIdOfUser = userInfo[@"id"];
    self.faceBookUserEmailId  =userInfo[@"email"];
    self.faceBookUserEmailId  =  flStrForObj( userInfo[@"email"]);
    if (!(self.faceBookUserEmailId.length >1)) {
        NSString *UniqueMailId = [self.faceBookUniqueIdOfUser stringByAppendingString:@"@facebook.com"];
        self.faceBookUserEmailId = UniqueMailId;
    }
    self.profilepicurlFb = flStrForObj(userInfo[@"picture"][@"data"][@"url"]);
    
    //    [self facebookLogin:userInfo];
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


/*-----------------------------*/

#pragma mark - Webservice Handler

/*-----------------------------*/

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
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    //storing the response from server to dictonary.
    
    NSDictionary *responseDict = (NSDictionary*)response;
    //checking the request type and handling respective response code.
    if (requestType == RequestTypeLogin ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                // success response.
                NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:responseDict];
                [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:userDetailKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self performSegueWithIdentifier:@"loginWithFbSegue" sender:nil];
            }
                break;
                //failure response.
            case 1971: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1972: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1973: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1974: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 197: {
                [self performSegueWithIdentifier:@"signupToFbSegue" sender:self];
            }
            default:
                break;
        }
    }
}

- (void)errAlert:(NSString *)message {
    //creating alert for error message.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"signupToFbSegue"]) {
        PGProfilePhotoSelectingViewController *vc = [segue destinationViewController];
        vc.codeForSignUpType =@"1";
        //sending fb id for registering.
        vc.faceBookUniqueIdOfUserToRegister = self.faceBookUniqueIdOfUser;
        vc.faceBookEmailIdOfUserToRegister  = self.faceBookUserEmailId ;
        vc.profilepicurlFb = self.profilepicurlFb;
    }
}
@end
