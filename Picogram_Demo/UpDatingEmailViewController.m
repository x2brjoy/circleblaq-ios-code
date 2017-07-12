//
//  UpDatingEmailViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 05/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "UpDatingEmailViewController.h"
#import "TinderGenericUtility.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "FontDetailsClass.h"
#import "Helper.h"

@interface UpDatingEmailViewController ()<WebServiceHandlerDelegate>
{
    
    UIButton *navDoneButton;
    UIActivityIndicatorView *av;
}
@end

@implementation UpDatingEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavLeftButton];
    [self createNavRightButton];
    self.navigationItem.title =@"Email address";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
   // self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.emailTextField  becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    navDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navDoneButton setTitle:@"Done"
                   forState:UIControlStateNormal];
     [navDoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    navDoneButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:17];
    [navDoneButton setFrame:CGRectMake(0,0,50,30)];
    [navDoneButton addTarget:self action:@selector(doneButtonClicked)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navDoneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
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
 -(void)doneButtonClicked {
     
    if ([self validateEmail:[_emailTextField text]])
    {
    navDoneButton.hidden = YES;
    [self createActivityViewInNavbar];
    // Requesting For Post Api.(passing "token" as parameter)
    NSDictionary *requestDict = @{
                                  mauthToken :flStrForObj([Helper userToken]),
                                  mEmail :flStrForObj(self.emailTextField.text)
                                  };
    [WebServiceHandler RequestTypeEmailCheckEditProfile:requestDict andDelegate:self];
    }
    else {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter a Valid Email Id" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [aler show];
    }
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

/*---------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*---------------------------------*/

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
    if (requestType ==  RequestTypeEmailCheckInEditProfile ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passEmailData" object:[NSDictionary dictionaryWithObject:response[@"result"][0][@"email"] forKey:@"updatedEmailId"]];
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
                //failure response.
            case 23465: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 23467: {
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


@end
