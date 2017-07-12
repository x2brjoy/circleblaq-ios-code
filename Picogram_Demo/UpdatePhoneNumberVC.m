//
//  UpdatePhoneNumberVC.m
//  Picogram
//
//  Created by Rahul Sharma on 7/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "UpdatePhoneNumberVC.h"
#import "TinderGenericUtility.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "CountryListViewController.h"
#import "ConfirmationCodeViewController.h"
#import "FontDetailsClass.h"
#import "Helper.h"

@interface UpdatePhoneNumberVC ( )<WebServiceHandlerDelegate>
{
   
    UIButton *nextButton;
    UIActivityIndicatorView *av;
}
@end

@implementation UpdatePhoneNumberVC
-(void)viewDidLoad {
   self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [self createNavRightButton];
    [self createNavLeftButton];
    self.navigationItem.title =@"Phone Number";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [self.phoneNumberTextField becomeFirstResponder];
}


/*-------------------------------------------*/
#pragma mark
#pragma mark - navigation bar buttons
/*-------------------------------------------*/

- (void)createNavLeftButton {
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    // UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

//method for creating navigation bar right button.
- (void)createNavRightButton {
   nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setTitle:@"Next"
                   forState:UIControlStateNormal];
      [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:17];
    [nextButton setFrame:CGRectMake(0,0,50,30)];
    [nextButton addTarget:self action:@selector(nextButtonClicked)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)nextButtonClicked {
    if ([self validatePhone:_phoneNumberTextField.text]) {
        nextButton.hidden = YES;
        [self createActivityViewInNavbar];
        // Requesting For Post Api.(passing "token" as parameter)
        
        NSString *removePlusSignFromCountryCode = self.countryCodeLabel.text ;
        //[self.countryCodeLabel.text  stringByReplacingOccurrencesOfString:@"+" withString:@""];
        _phoneNumberWithCountryCode  = [removePlusSignFromCountryCode stringByAppendingString:self.phoneNumberTextField.text ];
       
       
        NSDictionary *requestDict = @{
                                      mauthToken :flStrForObj([Helper userToken]),
                                      mphoneNumber :flStrForObj(_phoneNumberWithCountryCode)
                                      };
        [WebServiceHandler RequestTypePhoneNumberCheckEditProfile:requestDict andDelegate:self];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Incorrect number.please enter a correct number." delegate:self  cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
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

//method for creating activityview in  navigation bar right.
- (void)createActivityViewInNavbar {
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [av setFrame:CGRectMake(0,0,50,30)];
    [self.view addSubview:av];
    av.tag  = 1;
    [av startAnimating];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:av];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

/*-------------------------------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*-------------------------------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    [av stopAnimating];
    [self createNavRightButton];
    
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
    if (requestType ==  RequestTypePhoneNumberCheckEditProfile ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                _otpRecieved = @"";
                //response[@"data"][0][@"node.otp"];
                [self performSegueWithIdentifier:@"otpVerificationSegue" sender:nil];
            }
                break;
                //failure response.
            case 23465: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 23456: {
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
    //creating alert for error message.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}

- (IBAction)countrySelectionButton:(id)sender {
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:NULL];
}

- (void)didSelectCountry:(NSDictionary *)country {
    NSLog(@"%@", country);
    _countryCodeLabel.text =[country objectForKey:@"dial_code"];
    NSString *Name =[country objectForKey:@"code"];
   
   // self.countryNameLabel.text= countryNameWithCode ;
    [_countryNameLabel setTitle:Name forState:UIControlStateNormal];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([segue.identifier isEqualToString:@"otpVerificationSegue"]) {
        ConfirmationCodeViewController *confirmCodeVc  = [segue destinationViewController];
        confirmCodeVc.otp = _otpRecieved;
        if (_controllerName) {
            confirmCodeVc.controllerName = _controllerName;
        }
        confirmCodeVc.phoneNumberWithCode =_phoneNumberWithCountryCode;
    }
}

@end
