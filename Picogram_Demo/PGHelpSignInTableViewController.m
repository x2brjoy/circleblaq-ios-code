//
//  HelpSignInTableViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/18/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGHelpSignInTableViewController.h"
#import "FontDetailsClass.h"

@interface PGHelpSignInTableViewController ()
@end

@implementation PGHelpSignInTableViewController

#pragma mark
#pragma mark - viewcontroller

- (void)viewDidLoad {
       [super viewDidLoad];
       [self navBarCustomization];
       [self createNavLeftButton];
}

-(void)navBarCustomization {
    self.navigationItem.title =@"SIGN-IN-HELP";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

/**
 *  method is called when view will appear.it is using for navigation bar hide/shows.
    setNavigationBarHidden if it is  YES then it hides navigation bar and if it is  NO  it shows navigation bar
 */
- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
     /**
      *  unhiding the navigation bar in next view controller.
      */
   [self.navigationController setNavigationBarHidden:NO];
 }
/**
 *  this method will call when view will disappear
*/

- (void)viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
     /**
      *  hiding the navigation bar in next view controller.
      */
   [self.navigationController setNavigationBarHidden:YES];    // it hides
 }

/*----------------------------------------------------*/
#pragma mark
#pragma mark - navigation bar buttons
/*----------------------------------------------------*/

//method for creating navigation bar left button.
- (void)createNavLeftButton {
   
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [navCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    navCancelButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:17];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,60,40)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

/*----------------------------------------------------*/
   #pragma mark
   #pragma mark - Button
/*----------------------------------------------------*/

/**
 *  this method is called by cancel button in navigation bar.
 */

- (void)backButtonClicked  {
     /**
      *  changing to previous view controller(signinviewcontroller).
      */
    [self.navigationController popViewControllerAnimated:YES];
 }

- (IBAction)userNameButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"resetPassWordSegue" sender:nil];
}

- (IBAction)resetUsingFacebookButtonAction:(id)sender {
     [self performSegueWithIdentifier:@"resetByFbSegue" sender:nil];
}
@end
