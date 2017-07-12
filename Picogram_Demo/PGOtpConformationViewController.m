//
//  OtpConformationViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/18/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGOtpConformationViewController.h"
#import "PGSignupWithPhoneViewController.h"
#import "PGProfilePhotoSelectingViewController.h"
#import "WebServiceHandler.h"
#import "WebServiceConstants.h"

#define MAXLENGTH 4

@interface PGOtpConformationViewController ()<UIGestureRecognizerDelegate,WebServiceHandlerDelegate>
{
    NSString *receivedOTP;
}
@end
int heightKeyBoard;

@implementation PGOtpConformationViewController

#pragma mark
#pragma mark - view controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(CGRectGetHeight(self.view.frame) !=480 && CGRectGetHeight(self.view.frame) !=568) {
        _otpPhoneImageHeightConstraintOutlet.constant =175;
        _otpPhoneImageWidthConstraintOutlet.constant =175;
    }
    [_nextButtonOutlet setEnabled:NO];
    PGSignupWithPhoneViewController *otp;
    otp = [[PGSignupWithPhoneViewController alloc] init];

    /**
     *  setting login button boareder and color for boarder.
     */
    [[_nextButtonOutlet layer] setBorderWidth:1.0f];
    [[_nextButtonOutlet layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.13].CGColor];
    
    /**
     *    method to hide the key board when you click out side
     *   and its calling dismisskeyboard method
     */
    
    _phnNumbLabel.text = [_numb stringByAppendingString:@"."];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    [self.otpTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                      forKeyPath:@"_placeholderLabel.textColor"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_otpTextField];
    
    
    self.activityViewOutlet.hidden = YES;
    
    _nextButtonOutlet.layer.cornerRadius = 5;
    _nextButtonOutlet.clipsToBounds = YES;
}
-(void)viewWillAppear:(BOOL)animated {
    
    NSDictionary *requestDict = @{mphoneNumber    : self.numb
                                  };
    [WebServiceHandler generateOtp:requestDict andDelegate:self];
}

-(void)textFieldTextChanged:(id)semder {
    if ([self checkForMandatoryField]) {
        [_nextButtonOutlet setEnabled:YES];
    }
    else {
        [_nextButtonOutlet setEnabled:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger length = _otpTextField.text.length;
    if (length >= MAXLENGTH && ![string isEqualToString:@""]) {
        textField.text = [textField.text substringToIndex:MAXLENGTH];
        return NO;
    }
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

#pragma mark
#pragma mark - buttons
/**
 *  this button action performed when user taps on next button and here the button changing the view controller to profile view.
 *
 *  @param sender <#sender description#>
 */

- (IBAction)nextButtonAction:(id)sender {
    if ([_otpTextField.text isEqualToString:receivedOTP]) {
         [self performSegueWithIdentifier:@"otpToProfilePhotoSegue" sender:nil];
    }
    else {
        [self showingErrorAlertfromTop:@"Entered OTP code is Wrong"];
    }
}
/**
 *  this method when we are performing push through segue and sending phone number data here to otp view controller.
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"otpToProfilePhotoSegue"]) {
        PGProfilePhotoSelectingViewController *vc = [segue destinationViewController];
        vc.codeForSignUpType =@"3";
        
        vc.userEnteredPhoneNumber = self.numb;
    }
}

- (BOOL)checkForMandatoryField {
    if (_otpTextField.text.length == 4 ) {
        return YES;
    }
    return NO;
}
-(void)dismissKeyboard {
    [self.otpTextField resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:
     ^ {
         CGRect frameOfView = self.view.frame;
         frameOfView.origin.y = 0;
         frameOfView.origin.x=0;
         self.view.frame = frameOfView;
         
     }];
}

#pragma mark
#pragma mark - status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)keyboardWillShown:(NSNotification*)notification {
    // Get the size of the keyboard.
    CGSize keyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Given size may not account for screen rotation
    heightKeyBoard = MIN(keyboard.height,keyboard.width);
    [self viewMoveUp];
}
-(void)viewMoveUp {
    float maxY = CGRectGetMaxY(_nextButtonOutlet
                               .frame) + heightKeyBoard +3;
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
    //handling response.
    
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
    if (requestType == RequestTypeotpGeneration) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                receivedOTP =responseDict[@"data"];
                 //[_otpTextField setPlaceholder:responseDict[@"data"]];
            }
                break;
                // all these responses are error messages.
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
            default:
                break;
        }
    }
}

- (void)errAlert:(NSString *)message {
    //creating alert for error message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)resendButtonAction:(id)sender {
    
    NSDictionary *requestDict = @{mphoneNumber    : self.numb
                                  };
    [WebServiceHandler generateOtp:requestDict andDelegate:self];
    
//    NSString *alertMessage = @"OTP Resend Successfully";
//    [self showingErrorAlertfromTop:alertMessage];
}

-(void)showingErrorAlertfromTop:(NSString *)message {
    _popAlertLabelOutlet.text = message;
    [self.otpTextField endEditing:YES];
    [UIView animateWithDuration:0.4 animations:
     ^ {
         CGRect frameOfView = self.view.frame;
         frameOfView.origin.y = 20;
         frameOfView.origin.x=0;
         self.view.frame = frameOfView;
         [self.view layoutIfNeeded];
     }];
    int duration = 2; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:
         ^ {
             CGRect frameOfView = self.view.frame;
             frameOfView.origin.y = 0;
             frameOfView.origin.x=0;
             self.view.frame = frameOfView;
             [self.view layoutIfNeeded];
         }];
    });
}
@end
