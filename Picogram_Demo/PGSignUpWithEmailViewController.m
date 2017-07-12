//
//  SignUpWithEmailViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/16/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGSignUpWithEmailViewController.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "PGProfilePhotoSelectingViewController.h"

@interface PGSignUpWithEmailViewController ()<WebServiceHandlerDelegate>

@end

int keyboardHeit;
@implementation PGSignUpWithEmailViewController



#pragma mark
#pragma mark - viewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(CGRectGetHeight(self.view.frame) !=480 && CGRectGetHeight(self.view.frame) !=568)
    {
        _addEmailImageHeightConstraintOutlet.constant =175;
        _addEmailImageWidthConstraintOutlet.constant =175;
    }
    
     [_nextButton setEnabled:NO];
    [_nextButton setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.2] forState:UIControlStateHighlighted];
    
    /**
     *  setting login button boareder and color for boarder.
     */
    [[_nextButton layer] setBorderWidth:1.0f];
    [[_nextButton layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.13].CGColor];
      [self.emailTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                             forKeyPath:@"_placeholderLabel.textColor"];
    
    
    /**
     *    method to hide the key board when you click out side
     *   and its calling dismisskeyboard method
     */
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_emailTextField];
    self.activityViewOutlet.hidden = YES;
    
    
    _nextButton.layer.cornerRadius = 5;
    _nextButton.clipsToBounds = YES;
}

-(void)textFieldTextChanged:(id)sender {
    if ([self checkForMandatoryField]) {
        [_nextButton setEnabled:YES];
        [_nextButton setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:1.0] forState:UIControlStateHighlighted];
    }
    else {
        [_nextButton setEnabled:NO];
        [_nextButton setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.2] forState:UIControlStateHighlighted];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
  [_emailTextField resignFirstResponder];
}

#pragma mark
#pragma mark - TextFields

/**this delegate method is calling checkForMandatoryField to check textfields contain any details or not.
 *  this method is called when user enter input.
 */

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

/**
 *   this user defined method called by textField shouldChangeCharactersInRange delegate method and it is bool vale
 *  @return  yes if user enter any details in textfields and NO if the textfields nameTextField,passWordTextField are empty.
 */
- (BOOL)checkForMandatoryField
{
    if (_emailTextField.text.length != 0 ) {
        return YES;
    }
    return NO;
}

/**
 *   this user defined method called by textField textFieldDidEndEditing delegate method and it is bool vale
 *  @return  yes if user enter any details in textfields and NO if the textfields nameTextField,passWordTextField are empty.
 */

- (BOOL)checkForMandatoryFieldAfterEditing {
    if (_emailTextField.text.length != 0 ) {
        return NO;
    }
    return YES;
}
/**
 *  this  method is called by uigesture when user clicks out side of textfield and this method also doing changing the position of view
 and changing position to original.
 */

-(void)dismissKeyboard {
    [self.emailTextField resignFirstResponder];
    [UIView animateWithDuration:0.4 animations: ^ {
    CGRect frameOfView = self.view.frame;
    frameOfView.origin.y = 0;
    frameOfView.origin.x=0;
    self.view.frame = frameOfView;
   
     }];
 }
/**
 *  this delegate method will call when user clicks return button of keyboard.
 *

 *  here when user taps return button then keyboard will hide.
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.4 animations: ^ {
         CGRect frameOfView = self.view.frame;
         frameOfView.origin.y = 0;
         frameOfView.origin.x=0;
         self.view.frame = frameOfView;
      
     }];
    return YES;
}

#pragma mark
#pragma mark - Button
/**
 *  this button action is performed when user taps signup with email
 *
 *  signup with email view controller will open.
 */

- (IBAction)signupWithEmailButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *  this button action performed when user taps signinbutton
 *
 *  here the view controller changing to signin view controller.
 */

- (IBAction)signinButtonAction:(id)sender
{
      //[self performSegueWithIdentifier:@"sigupWithEmailTOsigninSegue" sender:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 *  this button action will perform when user taps nextbutton 
 *
 *  here if the email is not valid it will show popup otherwise profile photo view controller will open.
 */

- (IBAction)nextButtonAction:(id)sender {
    // if the entered email id is correct then we need to request for api otherwise need to show the error message.(Enter a valid emai)
    if (![self emailValidationCheck:[_emailTextField text]]) {
        _emailTextField.text = @"";
        [self dismissKeyboard];
        [self showingErrorAlertfromTop:@"Please enter a valid email"];
    }
    else {
        [self.nextButton setTitle:@"" forState:UIControlStateNormal];
        self.activityViewOutlet.hidden = NO;
        [self.activityViewOutlet startAnimating];
        NSDictionary *requestDict = @{mEmail    : _emailTextField.text
                                      };
        [WebServiceHandler emailCheck:requestDict andDelegate:self];
    }
}

/**
 *  this button is called when user taps privacyPolicyButton and here the view will change to privacypolicy controller.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)privacyPolicyButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"privacypolicyToConditionsSegue" sender:nil];
}

#pragma mark
#pragma mark - StautsBar
    
/**
 *  method used to hide the status bar or not.
 *
 *  @return yes means it hides the status bar and if it is no then view shows status bar.
 */

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"emailSignUpToProfilePhotoSegue"]) {
        PGProfilePhotoSelectingViewController *vc = [segue destinationViewController];
        vc.codeForSignUpType =@"2";
        vc.userEnteredEmail = self.emailTextField.text;
    }
}

#pragma mark
#pragma mark - Email validation

- (BOOL)validateEmail:(NSString *)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)emailValidationCheck:(NSString *)emailToValidate
{
    NSString *regexForEmailAddress = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexForEmailAddress];
    return [emailValidation evaluateWithObject:emailToValidate];
}


- (void)keyboardWillShown:(NSNotification*)notification {
    // Get the size of the keyboard.
    CGSize keyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    keyboardHeit = MIN(keyboard.height,keyboard.width);
    [self viewMoveUp];
}

-(void)viewMoveUp {
    float maxY = CGRectGetMaxY(_nextButton.frame) +keyboardHeit +3;
    
    float reminder = CGRectGetHeight(self.view.frame) - maxY;
    if (reminder < 0) {
        
        [UIView animateWithDuration:0.4 animations:
         ^ {
             
             CGRect frameOfView = self.view.frame;
             frameOfView.origin.y = reminder;
             self.view.frame = frameOfView;
            
         }];
    }
}



#pragma mark - WebServiceDelegate

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    self.activityViewOutlet.hidden = YES;
    [self.activityViewOutlet stopAnimating];
    [self.nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
   

    if (error) {
        [self errAlert:[error localizedDescription]];
        return;
    }
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypeEmailCheck ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200:
            {
                [self performSegueWithIdentifier:@"emailSignUpToProfilePhotoSegue" sender:nil];
            }
                break;
            case 1986:
            {
                [self showingErrorAlertfromTop:responseDict[@"message"]];
            }
                break;
            case 1987:
            {
                [self showingErrorAlertfromTop:responseDict[@"message"]];
            }
                break;
            case 1988:
            {
                [self showingErrorAlertfromTop:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
}


-(void)showingErrorAlertfromTop:(NSString *)message {
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        [self.emailTextField resignFirstResponder];
        
        CGRect frameOfView = self.view.frame;
        frameOfView.origin.y = 0;
        frameOfView.origin.x=0;
        self.view.frame = frameOfView;
    } completion:^(BOOL finished) {
        
        if (self.emailTextField.text.length >0) {
            [_nextButton setEnabled:YES];
        }
        else {
             [_nextButton setEnabled:NO];
        }
        
        self.errorMessageViewTopConstraint.constant = -100;
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
                 self.errorMessageViewTopConstraint.constant = - 100;
                 [self.view layoutIfNeeded];
             }];
        });
    }];
}

- (void)errAlert:(NSString *)message {
    //creating alert for error message.
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        
        [self.emailTextField resignFirstResponder];
        
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
