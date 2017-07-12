//
//  ConfirmationCodeViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 7/23/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ConfirmationCodeViewController.h"
#import "TinderGenericUtility.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import  "FontDetailsClass.h"
#import "businessSetupViewController.h"
#import "Helper.h"

@interface ConfirmationCodeViewController ()<WebServiceHandlerDelegate,UITextFieldDelegate>
{
    
    
    UIButton *doneButton;
    UIActivityIndicatorView *av;
}
@end

@implementation ConfirmationCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    // Do any additional setup after loading the view.
    [self createNavRightButton];
    [self createNavLeftButton];
    self.confirmationCodeTextField.delegate =  self;
    [doneButton setEnabled:NO];
    //when keyboard appears this will  notifiy.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:self.confirmationCodeTextField];
     self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.navigationItem.title =@"Confirmation Code";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
    
    
    [self.confirmationCodeTextField becomeFirstResponder];
    //Enter the confirmation code that we sent to +9010315835. If you haven't received it, we can

    self.enterNumberLabelOutlet.text = [@"Enter the confirmation code that we sent to " stringByAppendingString:[_phoneNumberWithCode stringByAppendingString:@". If you haven't received it, we can"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    _confirmationCodeTextField.placeholder =[NSString stringWithFormat:@"%@",_otp];
    
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
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done"
                forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:17];
    [doneButton setFrame:CGRectMake(0,0,50,30)];
    [doneButton addTarget:self action:@selector(nextButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)nextButtonClicked {
    doneButton.hidden = YES;
    [self createActivityViewInNavbar];
    
    // Requesting For Post Api.(passing "token" as parameter)
    NSDictionary *requestDict = @{
                                  mauthToken :flStrForObj([Helper userToken]),
                                  mphoneNumber :_phoneNumberWithCode,
                                  motp :flStrForStr(self.confirmationCodeTextField.text)
                                  };
    [WebServiceHandler RequestTypeupdatePhoneNumber:requestDict andDelegate:self];
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
    if (requestType == RequestTypeupdatePhoneNumber ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passPhoneData" object:[NSDictionary dictionaryWithObject:response[@"result"][0][@"phoneNumber"] forKey:@"updatedPhoneNumber"]];
                [[NSUserDefaults standardUserDefaults]setObject:flStrForObj(response[@"result"][0][@"phoneNumber"]) forKey:@"ProfileContact"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                if (_controllerName) {
                    for (UIViewController* viewController in self.navigationController.viewControllers) {
                        
                        if ([viewController isKindOfClass:[businessSetupViewController class]] )
                        {
                            [self.navigationController popToViewController:viewController animated:YES];
                            return;
                        }
                    }
                }
                else
                    [self.navigationController popToRootViewControllerAnimated:YES];

            }
                break;
                //failure response.
            case 23462: {
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
    //creating alert for error message.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}

#pragma mark
#pragma mark -TextField Delgates.

-(void)textFieldTextChanged:(id)sender {
    if ([self checkForMandatoryField]) {
        [doneButton setEnabled:YES];
    }
    else {
        [doneButton setEnabled:NO];
       }
}
- (BOOL)checkForMandatoryField {
    if (_confirmationCodeTextField.text.length != 0 ) {
        return YES;
    }
    return NO;
}
- (IBAction)resendButtonAction:(id)sender {
    
    NSDictionary *requestDict = @{
                                  mauthToken :flStrForObj([Helper userToken]),
                                  mphoneNumber :flStrForObj(self.phoneNumberWithCode)
                                  };
    [WebServiceHandler RequestTypePhoneNumberCheckEditProfile:requestDict andDelegate:self];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Otp Resend Successfully"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait a momonet"
//                                                    message:@"We can only send you a new code every 60 seconds."
//                                                   delegate:self
//                                          cancelButtonTitle:@"Ok"
//                                          otherButtonTitles:nil,nil];
//    [alert show];
}

- (IBAction)changeItButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
