//
//  ResetPasswordViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 5/6/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "FontDetailsClass.h"
#import "WebServiceHandler.h"
#import "FontDetailsClass.h"
#import "WebServiceConstants.h"
#import "Helper.h"

@interface ResetPasswordViewController ()<WebServiceHandlerDelegate>

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavLeftButton];
    [self createNavRightButton];
    [self navBarCustomization];
}

-(void)navBarCustomization {
    self.navigationItem.title =@"Reset Password";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

-(void)viewWillAppear:(BOOL)animated {
  self.navigationController.navigationBarHidden = NO;
}

#pragma mark
#pragma mark - navigation bar buttons

//method for creating navigation bar left button.
- (void)createNavLeftButton {
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    navCancelButton.titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [navCancelButton addTarget:self
                        action:@selector(CancelButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
 
    [navCancelButton setFrame:CGRectMake(0.0f,0.0f,30,30)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

//method for creating navigation bar right button.
- (void)createNavRightButton {
    UIButton *navDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navDoneButton setTitle:@"Search"
                   forState:UIControlStateNormal];
    navDoneButton.titleLabel.textColor = [UIColor colorWithRed:0.1569 green:0.1569 blue:0.1569 alpha:1.0];
    [navDoneButton setTitleColor:[UIColor colorWithRed:0.1569 green:0.1569 blue:0.1569 alpha:1.0] forState:UIControlStateNormal];
    navDoneButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:17];
    [navDoneButton setFrame:CGRectMake(0,0,60,30)];
    [navDoneButton addTarget:self action:@selector(SearchButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navDoneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

//action for navigation bar items (buttons).

- (void)CancelButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)SearchButtonAction:(UIButton *)sender {
    
    if (![Helper emailValidationCheck:[_userNameTextField text]]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Please enter a valid email"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];

    }
    else {
        NSDictionary *requestDict = @{
                                      mEmail:self.userNameTextField.text,
                                      };
        [WebServiceHandler resetPassword:requestDict andDelegate:self];
    }
}

#pragma mark - WebServiceDelegate

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
        if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    
    
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypemakeresetPassword ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
              [self errorAlert:responseDict[@"message"]];
            }
            break;
            case 1975: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 1976: {
                [self errorAlert:responseDict[@"message"]];
                
            }
                break;
            case 1977: {
                 [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 1978: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 2025: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)errorAlert:(NSString *)message {
    //showing error alert for failure response.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}

@end
