//
//  ForgotPasswordViewController.m
//  Picogram
//
//  Created by Rahul_Sharma on 04/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "CountryListViewController.h"
#import "FontDetailsClass.h"
#import "WebServiceHandler.h"
#import "WebServiceConstants.h"
#import "TinderGenericUtility.h"

@interface ForgotPasswordViewController ()<CountryListViewDelegate,WebServiceHandlerDelegate>

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self sendLoginLinkButtonCustomizing];
    //[self customizeEmailTextField];
    //[self customizePhoneTextView];
    
    self.selectedCountryCode = @"91";
    self.phoneNumberTextField.textColor = [UIColor whiteColor];
    self.emailTextField.textColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
     [self addingTapGestureForDismissingKeyBoard];
    
    [self textFiledPlaceHolderColor];
}

- (void)keyboardWillShown:(NSNotification*)notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Given size may not account for screen rotation
    self.heighOfKeyBoard = MIN(keyboardSize.height,keyboardSize.width);
    [self viewMoveUp];
}

- (void)dismissKeyboard {
    
    [UIView animateWithDuration:0.4 animations:
     ^ {
         [self.phoneNumberTextField resignFirstResponder];
         [self.emailTextField resignFirstResponder];
         CGRect frameOfView = self.view.frame;
         frameOfView.origin.y = 0;
         frameOfView.origin.x=0;
         self.view.frame = frameOfView;
     }];
}

- (void)didSelectCountry:(NSDictionary *)country {
    NSLog(@"%@", country);
   
    NSString *Name = [country objectForKey:@"code"];
    self.selectedCountryCode =  [country objectForKey:@"dial_code"];
    NSString *countrynameWithSpace =[Name stringByAppendingString:@"   "];
    NSString *countryNameWithCode =[countrynameWithSpace  stringByAppendingString:[country objectForKey:@"dial_code"]];
    
    [self.countryCodeButtonOutlet setTitle:countryNameWithCode forState:UIControlStateNormal];
    
    
    
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
-(void)viewMoveUp {
    /**
     *  changing the position of view when user starts beging giving input.
     here we are checking the height of view with keyboard and if the key  board hiding the  next button then changing position otherwise the position
     of view is not changed.
     */
    float maxY = CGRectGetMaxY(self.sendLoginLinkButtonOutlet.frame) + self.heighOfKeyBoard +3;
    float reminder = CGRectGetHeight(self.view.frame) - maxY;
    if (reminder < 0) {
        [UIView animateWithDuration:0.4 animations: ^ {
            CGRect frameOfView = self.view.frame;
            frameOfView.origin.y = reminder;
            self.view.frame = frameOfView;
            
        }];
    }
}

-(void)textFiledPlaceHolderColor {
    
    [self.emailTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                      forKeyPath:@"_placeholderLabel.textColor"];
    [self.phoneNumberTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                          forKeyPath:@"_placeholderLabel.textColor"];
    
    self.phoneNumberView.layer.cornerRadius = 5;
    self.phoneNumberView.clipsToBounds = YES;
}

-(void)customizePhoneTextView {
    self.phoneNumberView.layer.cornerRadius = 5; // this value vary as per your desire
    self.phoneNumberView.clipsToBounds = YES;
    
    [[self.phoneNumberView layer] setBorderWidth:1.0f];
    [[self.phoneNumberView layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor];
}

-(void)customizeEmailTextField {
    self.emailTextField.layer.cornerRadius = 5; // this value vary as per your desire
    self.emailTextField.clipsToBounds = YES;
    
    [[self.emailTextField layer] setBorderWidth:1.0f];
    [[self.emailTextField layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor];
}

-(void)sendLoginLinkButtonCustomizing {
    
    
    self.sendLoginLinkButtonOutlet.layer.cornerRadius = 5; // this value vary as per your desire
    self.sendLoginLinkButtonOutlet.clipsToBounds = YES;
    
    [[self.sendLoginLinkButtonOutlet layer] setBorderWidth:1.0f];
    [[self.sendLoginLinkButtonOutlet layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2].CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)backToLogInButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleButtonAction:(id)sender {
    if (self.toggleButtonOutlet.selected) {
       self.messageLabel.text = @"Enter your username or email address and we'll send you a link to get back into your account.";
        self.phoneNumberView.hidden = YES;
        self.emailTextField.hidden = NO;
        self.toggleButtonOutlet.selected = NO;
    }
    else {
           self.messageLabel.text = @"Enter your phone number and we'll send you a password reset link to get back to your account.";
        self.phoneNumberView.hidden = NO;
        self.emailTextField.hidden = YES;
        self.toggleButtonOutlet.selected = YES;
    }
}

- (IBAction)countryCodeButtonaction:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:NULL];
}



- (IBAction)sendLoginLinkButtonAction:(id)sender {
    
    //type (0 : email, 1 : phoneNumber), email / phoneNumber
    
    if (self.toggleButtonOutlet.selected) {
       
        //phone number.
        //first validating the number and if it is in correct format(means no alphbets and special charc...etc) then phoneNumberCheck service requesting.
        if (![self validatePhone:[_phoneNumberTextField text]]  ) {
            [self errrAlert:@"Please enter a valid phone number"];
        }
        else {
            NSString *phoneNumberForChecking = flStrForObj([@"+" stringByAppendingString:[self.selectedCountryCode stringByAppendingString:self.phoneNumberTextField.text]]);
            
            NSDictionary *requestDict = @{@"type" :@"1",
                                          @"phoneNumber"    : phoneNumberForChecking
                                          };
            [WebServiceHandler   resetPassword:requestDict andDelegate:self];
        }
    }
    else {
         //username or email address.
        if (![self emailValidationCheck:[_emailTextField text]]) {
            
            [self errrAlert:@"Please enter a valid email"];
        }
        else {
            NSDictionary *requestDict = @{@"type" :@"0",
                                          mEmail    : _emailTextField.text
                                          };
            [WebServiceHandler resetPassword:requestDict andDelegate:self];
        }
    }
}

- (BOOL)emailValidationCheck:(NSString *)emailToValidate
{
    NSString *regexForEmailAddress = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexForEmailAddress];
    return [emailValidation evaluateWithObject:emailToValidate];
}

- (void)errrAlert:(NSString *)message {
    //[self dismissKeyboard];
    //creating alert for error message
 
    [UIView animateWithDuration:0.2 animations:^{
        [self.phoneNumberTextField resignFirstResponder];
        [self.emailTextField resignFirstResponder];
        CGRect frameOfView = self.view.frame;
        frameOfView.origin.y = 0;
        frameOfView.origin.x=0;
        self.view.frame = frameOfView;
    }  completion:^(BOOL finished) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];//Send via SMS
        [alert show];
    }];
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


#pragma mark
#pragma mark - WebServiceDelegate

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    //handling response.
    
    if (error) {
        [self errrAlert:[error localizedDescription]];
        return;
    }
    //storing the response from server to dictonary(responseDict).
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypemakeresetPassword) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
                // all these responses are error messages.
            case 19756: {
                [self errrAlert:@"Entered phone number is not registered"];
            }
                break;
            case 1976: {
                 [self errrAlert:@"Entered Email is not registered"];
            }
                break;
            case 1978: {
                 [self errrAlert:@"Something went wrong. please try again later."];
            }
                break;
            default:
                break;
        }
    }
}

@end
