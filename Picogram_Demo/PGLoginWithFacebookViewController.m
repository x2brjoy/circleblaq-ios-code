//
//  LoginWithFacebookViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/15/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGLoginWithFacebookViewController.h"
#import <FBSDKLoginKit/FBSDKLoginManagerLoginResult.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import "FBLoginHandler.h"
#import "ProgressIndicator.h"

@interface PGLoginWithFacebookViewController () <FBLoginHandlerDelegate>

@end

@implementation PGLoginWithFacebookViewController



#pragma mark
#pragma mark - viewcontroller

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
        //////// //////////// //////////   METHODS RELEATED TO NAVIGATION BAR AND STATUS BAR  //////// //////////// //////////
    
    /**
        method is called when view will appear.it is using for navigation bar hide/shows.
        setNavigationBarHidden if it is  YES then it hides navigation bar and if it is  NO  it shows navigation bar
     */
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

/**
 *  method is called when view will appear.it is using for navigation bar hide/shows.
   setNavigationBarHidden if it is  YES then it hides navigation bar and if it is  NO  it shows navigation bar
 *
 *
 */

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];   //it hides
}

/**
 *  method is called when view will appear.it is using for navigation bar hide/shows.
 setNavigationBarHidden if it is  YES then it hides navigation bar and if it is  NO  it shows navigation bar
 *
 *
 */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];    // it shows
}



@end
