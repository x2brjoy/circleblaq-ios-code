//
//  SaloonInfoViewController.m
//  Zuri
//
//  Created by Rahul_Sharma on 24/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "SaloonInfoViewController.h"
#import "FontDetailsClass.h"
#import "Helper.h"
#import "Helper.h"

@interface SaloonInfoViewController ()

@end

@implementation SaloonInfoViewController
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.stylistAddressTextField.hidden = YES;
    self.captionTextField.hidden = YES;
    [self createNavRightButton];
    [self createNavLeftButton];
    self.title = @"Purchase link";
    [self.stylistNameTextField setValue:[UIColor colorWithRed:209.0f/255.0f green:207.0f/255.0f blue:207.0f/255.0f alpha:1.0]
                            forKeyPath:@"_placeholderLabel.textColor"];
    //self.stylistNameTextField.borderStyle = UITextBorderStyleNone;
    self.stylistNameTextField.placeholder = @"Enter purchase Link";
    //self.stlishNameTextFieldSuperView.layer.borderWidth = 1.0;
//    self.stlishNameTextFieldSuperView.backgroundColor = self.stylistNameTextField.backgroundColor;
//    self.stlishNameTextFieldSuperView.layer.cornerRadius = 1.0;
//    self.stlishNameTextFieldSuperView.clipsToBounds = YES;
//    self.stlishNameTextFieldSuperView.layer.borderColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1.0].CGColor;
    
    [self.stylistNameTextField addTarget:self
                              action:@selector(purchaseLinktextFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
    
    
    if ([self.selectedProduct isEqualToString:@""]) {
        self.stylistNameTextField.text = @"https://www.";
    }
    else {
        self.stylistNameTextField.text = self.selectedProduct;
    }
    
    [self setUpNavigationBar];
}



-(void)purchaseLinktextFieldDidChange:(UITextField *)theTextField {
    NSString *convertString = self.stylistNameTextField.text;
    if ([convertString containsString:@" "]) {
        if ([ self.stylistNameTextField.text length] > 0) {
             self.stylistNameTextField.text = [ self.stylistNameTextField.text substringToIndex:[ self.stylistNameTextField.text length] - 1];
            NSString *removeSpace = [ self.stylistNameTextField.text stringByAppendingString:@""];
             self.stylistNameTextField.text = removeSpace;
        }
    }
}

-(void)setUpNavigationBar {
    //setting nav bar background color.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9753 green:0.9753 blue:0.9753 alpha:1.0];
    //hiding nav bar backbutton.
    [self.navigationItem setHidesBackButton:YES];
    //seeting nav bar tittle as TAG PEOPLE
    self.navigationItem.title = @"Purchase link";
    //calling createNavRightButton method to create nav bar right button.
    [self createNavRightButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*---------------------------------------------------*/
#pragma mark
#pragma mark - navigation bar  buttons
/*---------------------------------------------------*/
/*----------------------------------------------------*/
#pragma mark
#pragma mark - navigation bar buttons
/*-----------------------------------*/

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

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createNavRightButton {
    //creating navigation bar button.
    UIButton *navDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navDoneButton setTitle:@"Save"
                   forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor colorWithRed:0.2196 green:0.5922 blue:0.9412 alpha:1.0]
                        forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor colorWithRed:0.2196 green:0.5922 blue:0.9412 alpha:1.0]
                        forState:UIControlStateHighlighted];
    navDoneButton.titleLabel.font = [UIFont fontWithName:RobotoMedium size:16];
    
    
    
    [navDoneButton setFrame:CGRectMake(0,0,50,30)];
    //craeting button action for navigation bar button.
    [navDoneButton addTarget:self action:@selector(saveButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navDoneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}


- (void)saveButtonAction:(UIButton *)sender {
    if (self.stylistNameTextField.text.length >0) {
        if ([Helper validateUrl:self.stylistNameTextField.text]) {
            [delegate saloondetalis:self.stylistNameTextField.text address:self.stylistAddressTextField.text caption:self.captionTextField.text];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Invalid Purchase link" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter Purchase Link" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

@end
