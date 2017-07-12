//
//  SignupWithPhoneViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/15/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGSignupWithPhoneViewController.h"
#import "PGPrivacyPolicyViewController.h"
#import "PGOtpConformationViewController.h"
#import "CountryListViewController.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"

@interface PGSignupWithPhoneViewController ()<CountryListViewDelegate,WebServiceHandlerDelegate,UIGestureRecognizerDelegate> {
}
@end

NSString *countryCodeNumber =@"+91";
int HeightOfkeyboard;

@implementation PGSignupWithPhoneViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //hide activity view intially
    self.activityViewOutlet.hidden = YES;
    [self changingThePhoneLogoImageHeightDependingOnDevice];
    [self addingPlaceHolderColorForPhoneNumberTextfield];
    [self addingNotificationForKeyBoardOpen];
    [self addingBoarderColorAndDisableModeForNextButton];
    [self addingTapGestureForDismissingKeyBoard];
    [self makingTextFieldviewAsRoundCorner];
}

-(void) makingTextFieldviewAsRoundCorner{
    
    _phoneNumberTextFieldViewOutlet.layer.cornerRadius = 5; // this value vary as per your desire
    _phoneNumberTextFieldViewOutlet.clipsToBounds = YES;
    
    _nextButtonOutlet.layer.cornerRadius = 5;
    _nextButtonOutlet.clipsToBounds = YES;
    
}
-(void)viewWillDisappear:(BOOL)animated {
    [_phoneNumberTextField resignFirstResponder];
}

#pragma mark
#pragma mark - methodDefinationsInViewDidload

-(void)changingThePhoneLogoImageHeightDependingOnDevice {
    // height of 4s is 480 and 5/5s/5c is 568.
    if(CGRectGetHeight(self.view.frame) !=480 && CGRectGetHeight(self.view.frame) !=568) {
        _addPhoneImageHeightConstraintOutlet.constant =175;
        _addPhoneImageWidthConstraintOutlet.constant =175;
    }
}
-(void)addingPlaceHolderColorForPhoneNumberTextfield {
    /**
     *  setting color for phoneNumber textfield placeholder.
     */
    
    [self.phoneNumberTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                             forKeyPath:@"_placeholderLabel.textColor"];
}

-(void)addingNotificationForKeyBoardOpen {
    //when keyboard appears this will  notifiy.
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_phoneNumberTextField];
}

-(void)addingBoarderColorAndDisableModeForNextButton {
    /**
     *  setting next button boareder and color for boarder.
     */
    [[_nextButtonOutlet layer] setBorderWidth:1.0f];
    [[_nextButtonOutlet layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.13].CGColor];

    /**
     *  intially keeping next  button in disable state and if user enter details changing into enable state.
     */
    [_nextButtonOutlet setEnabled:NO];
    [_nextButtonOutlet setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.2] forState:UIControlStateHighlighted];
    
}
-(void)addingTapGestureForDismissingKeyBoard {
    /**
     *    method to hide the key board when you click out side
     *    and its calling dismisskeyboard method
     */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

#pragma mark
#pragma mark -TextField Delgates.

-(void)textFieldTextChanged:(id)sender {
    if ([self checkForMandatoryField]) {
        [_nextButtonOutlet setEnabled:YES];
        [_nextButtonOutlet setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:1.0] forState:UIControlStateHighlighted];
    }
    else {
        [_nextButtonOutlet setEnabled:NO];
        [_nextButtonOutlet setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.2] forState:UIControlStateHighlighted];
    }
}


/**
 *   this user defined method called by textField shouldChangeCharactersInRange delegate method and it is bool vale
 *  @return  yes if user enter any details in textfields and NO if the textfields nameTextField,passWordTextField are empty.
 */
- (BOOL)checkForMandatoryField {
    if (_phoneNumberTextField.text.length != 0 ) {
        return YES;
    }
    return NO;
}
/**
 *  this  method is called by uigesture when user clicks out side of textfield and this method also doing changing the position of view
 to original.
 */
- (void)dismissKeyboard {
   
    [UIView animateWithDuration:0.4 animations:
     ^ {
         [self.phoneNumberTextField resignFirstResponder];
         CGRect frameOfView = self.view.frame;
         frameOfView.origin.y = 0;
         frameOfView.origin.x=0;
         self.view.frame = frameOfView;
     }];
}

/**
 *  giving implementation to key board return button.
 *
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    /**
     *  method is resigning the textfield.
     */
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma mark - statusbar
/**
 *  method used to hide the status bar or not.
 *
 *  @return YES means it hides the status bar and if it is NO then view shows status bar.
 */

- (BOOL)prefersStatusBarHidden {
    return YES;
}
/**  The button action is performed when user taps signUpWithYourEmail Button.
 *   This method is used to transit between view controllers.
 *   If user click signUpWithYourEmail button then email  view controller  will display.
 */
#pragma mark
#pragma mark - Button actions.

- (IBAction)signUpWithYourEmailButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"signUpWithPhoneToSignUPWithEmailSegue" sender:nil];
}

/**  The button action is performed when user taps signIn Button.
 *   This method is used to transit between view controllers.
 *   If user click signUpWithYourEmail button then Signupwithphone  view controller  will display.
 */
- (IBAction)signInButtonAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
/**
 *   The button action is performed when user taps countrySelector Button.
 */
- (IBAction)countrySelectorButtonaCTION:(id)sender {
    
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:NULL];

}

- (void)didSelectCountry:(NSDictionary *)country {
    NSLog(@"%@", country);
    countryCodeNumber =[country objectForKey:@"dial_code"];
    NSString *Name =[country objectForKey:@"code"];
    NSString *countrynameWithSpace =[Name stringByAppendingString:@"   "];
    NSString *countryNameWithCode =[countrynameWithSpace  stringByAppendingString:[country objectForKey:@"dial_code"]];
    _countryCodeLabelOutlet.text= countryNameWithCode ;
}

/**  The button action is performed when user taps privacyPolicy Button.
 *   This method is used to transit between view controllers.
 *   If user click signUpWithYourEmail button then Conditions view controller  will display.
 */
- (IBAction)privacyPolicyButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"privacypolicyToConditionsSegue" sender:nil];
}

/**
 *  button action  is performed when is user  taps next
 *
 *   first it will entered  number is correct  valid or not
 */

- (IBAction)nextButtonAction:(id)sender {
    //first validating the number and if it is in correct format(means no alphbets and special charc...etc) then phoneNumberCheck service requesting.
     [self dismissKeyboard];
    if (![self validatePhone:[_phoneNumberTextField text]]  ) {
//        _phoneNumberTextField.text = @"";
        [self showingErrorAlertfromTop:@"Please enter a valid phone number"];
    }
    else {
        //service requesting(phoneNumber parameter is sending)
        [[NSUserDefaults standardUserDefaults] setObject:flStrForObj([countryCodeNumber stringByAppendingString:_phoneNumberTextField.text]) forKey:@"phoneNumberOfUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *phoneNumberForChecking =[[NSUserDefaults standardUserDefaults]
               stringForKey:@"phoneNumberOfUser"];;
      
        NSDictionary *requestDict = @{mphoneNumber    : phoneNumberForChecking
                                      };
        [WebServiceHandler phoneNumberCheck:requestDict andDelegate:self];
        [self.nextButtonOutlet setTitle:@"" forState:UIControlStateNormal];
        self.activityViewOutlet.hidden = NO;
        [self.activityViewOutlet startAnimating];
    }
}

#pragma markcountry
#pragma mark - prepareForSegue(sendingDataToOtherController.)

/**
 *  this method when we are performing push through segue and sending phone number data here to otp view controller.
 */

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"signUpwithPhoneToOtpConfirmationSegue"]) {
        PGOtpConformationViewController *OTPvc = [segue destinationViewController];
        OTPvc.numb = [countryCodeNumber stringByAppendingString:_phoneNumberTextField.text];
    }
}

#pragma mark
#pragma mark - phone number validation

- (BOOL)validatePhone:(NSString *)enteredphoneNumber {
    NSString *phoneNumber = enteredphoneNumber;
    NSString *phoneRegex = @"[2356789][0-9]{6}([0-9]{3})?";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL matches = [test evaluateWithObject:phoneNumber];
    return matches;
}

- (void)dataFromController:(NSDictionary *)selectedDict {
    NSLog(@"%@",selectedDict);
}

#pragma mark
#pragma mark - KeyBoard Notification method.

- (void)keyboardWillShown:(NSNotification*)notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Given size may not account for screen rotation
    HeightOfkeyboard = MIN(keyboardSize.height,keyboardSize.width);
    [self viewMoveUp];
}

-(void)viewMoveUp {
    /**
     *  changing the position of view when user starts beging giving input.
     here we are checking the height of view with keyboard and if the key  board hiding the  next button then changing position otherwise the position
     of view is not changed.
     */
    float maxY = CGRectGetMaxY(_nextButtonOutlet.frame) + HeightOfkeyboard +3;
    float reminder = CGRectGetHeight(self.view.frame) - maxY;
    if (reminder < 0) {
        [UIView animateWithDuration:0.4 animations: ^ {
             CGRect frameOfView = self.view.frame;
             frameOfView.origin.y = reminder;
             self.view.frame = frameOfView;
           
         }];
    }
}

#pragma mark
#pragma mark - WebServiceDelegate

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    //handling response.
    
    //hiding activity view indicator and stooping animation.
    [self.activityViewOutlet stopAnimating];
    [self.activityViewOutlet setHidden:YES];
    [self.nextButtonOutlet setTitle:@"NEXT" forState:UIControlStateNormal];
    
    if (error) {
        [self errAlert:[error localizedDescription]];
        return;
    }
    //storing the response from server to dictonary(responseDict).
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypePhoneNumberCheck) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
              // 200 is for success.
              [self performSegueWithIdentifier:@"signUpwithPhoneToOtpConfirmationSegue" sender:nil];
            }
            break;
      // all these responses are error messages.
            case 1989: {
                [self showingErrorAlertfromTop:responseDict[@"message"]];
            }
            break;
            case 1990: {
                [self showingErrorAlertfromTop:responseDict[@"message"]];
            }
            break;
            case 1991: {
                [self showingErrorAlertfromTop:@"Phone number is already registered with other account"];
            }
            break;
            default:
            break;
        }
     }
}

- (void)errrAlert:(NSString *)message {
// [self dismissKeyboard];
    //creating alert for error message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}

-(void)showingErrorAlertfromTop:(NSString *)message {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        [self.phoneNumberTextField resignFirstResponder];
        
        CGRect frameOfView = self.view.frame;
        frameOfView.origin.y = 0;
        frameOfView.origin.x=0;
        self.view.frame = frameOfView;
    } completion:^(BOOL finished) {
        self.errorMessageViewTopConstraint.constant = -50;
        [self.view layoutIfNeeded];
        _errorMessageLabelOutlet.text = message;
        
        /**
         *  changing the error message view position if user enter  wrong number
         */
        
        [UIView animateWithDuration:0.4 animations:
         ^ {
             self.errorMessageViewTopConstraint.constant = -0;
             [self.view layoutIfNeeded];
         }];
        
        int duration = 2; // duration in seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:
             ^ {
                 self.errorMessageViewTopConstraint.constant = -50;
                 [self.view layoutIfNeeded];
             }];
        });
    }];
}

- (void)errAlert:(NSString *)message {
    //creating alert for error message.
    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveLinear  animations:^{
        [self.phoneNumberTextField resignFirstResponder];
        
        CGRect frameOfView = self.view.frame;
        frameOfView.origin.y = 0;
        frameOfView.origin.x=0;
        self.view.frame = frameOfView;
        
    } completion:^(BOOL finished) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
    }];
}
@end
