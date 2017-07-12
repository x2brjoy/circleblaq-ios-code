//
//  FeddBackViewController.m
//  Picogram
//
//  Created by Rahul_Sharma on 19/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "FeddBackViewController.h"
#import "Helper.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "UITextView+Placeholder.h"

@interface FeddBackViewController ()<WebServiceHandlerDelegate,UITextViewDelegate>
{
    UIButton *navNextButton;
}
@end

@implementation FeddBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    navNextButton.enabled = NO;
    [self.textViewOutlet becomeFirstResponder];
    self.textViewOutlet.delegate = self;
    // [self createNavLeftButton];
    [self createNavSettingButton];
    [self createNavLeftButton];
    self.title = @"Feedback";
    self.textViewOutlet.placeholder = @"Write a caption..";
    self.textViewOutlet.placeholderColor = [UIColor lightGrayColor];
}


- (void)createNavLeftButton {
    self.navigationController.navigationItem.hidesBackButton =  YES;
    UIButton  *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark - navigation bar buttons

//careting navigation bar left button.



- (void)createNavSettingButton {
    navNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navNextButton setTitle:@"Send" forState:UIControlStateNormal];
    
    [navNextButton addTarget:self action:@selector(SettingButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [navNextButton setTitleColor:[UIColor blueColor]
                        forState:UIControlStateNormal];
    
    [navNextButton setTitleColor:[UIColor lightGrayColor]
                        forState:UIControlStateDisabled];
    
    [navNextButton setFrame:CGRectMake(-10,17,45,45)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navNextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)SettingButtonAction:(id)sender {
    NSDictionary *requestDict = @{
                                  mauthToken :[Helper userToken],
                                  mfeature:@"general",
                                  mproblemExplaination:flStrForObj(self.textViewOutlet.text)
                                  };
    [WebServiceHandler feedback:requestDict andDelegate:self];
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.textViewOutlet.text  isEqual: @"Bio"]) {
        [textView setText:@""];
        textView.textColor = [UIColor blackColor];
    }
}

-(void)adjustContentSize:(UITextView*)tv{
    CGFloat deadSpace = ([tv bounds].size.height - [tv contentSize].height);
    CGFloat inset = MAX(0, deadSpace/2.0);
    tv.contentInset = UIEdgeInsetsMake(inset, tv.contentInset.left, inset, tv.contentInset.right);
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(self.textViewOutlet.text.length >0) {
        navNextButton.enabled = YES;
    }
    else {
        navNextButton.enabled = NO;
    }
}


-(void)textViewDidChangeSelection:(UITextView *)textView
{
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    
}


/*---------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*---------------------------------*/

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
    
    //storing the response from server to dictonary.
    NSDictionary *responseDict = (NSDictionary*)response;
    //checking the request type and handling respective response code.
    if (requestType == RequestTypeFeedBack ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 9477: {
                self.textViewOutlet.text = @"";
                navNextButton.enabled = NO;
                [self errAlert:responseDict[@"message"]];
            }
                break;
                //failure response.
            case 198: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 400: {
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
