//
//  HomeViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/23/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGHomeViewController.h"

@interface PGHomeViewController ()<UITabBarControllerDelegate,UITabBarDelegate>

@end

@implementation PGHomeViewController

#pragma mark
#pragma mark - viewcontroller


- (void)viewDidLoad
 {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"discovery_people_navigation_bar" ] forBarMetrics:UIBarMetricsDefault];
     //[[UINavigationBar appearance] setBarTintColor:[UIColor yellowColor]];
     
     //[[UINavigationBar appearance] setBackgroundColor:[UIColor redColor]];
    
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_picogram_logo"]];
    self.navigationItem.hidesBackButton=YES;
    [self createNavRightButton];
 }

/**
 *  this method will call when view will appear.
 *
 *
 */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];   //it shows
}

/**
 *  this method will call when view will disappear.
 *
 *
 */

- (void)viewWillDisappear:(BOOL)animated
{
//    [super viewWillDisappear:animated];
//    
//    [self.navigationController setNavigationBarHidden:YES];    // it hides
    
}


#pragma mark
#pragma mark - navigation bar buttons

/**
 *  creating navigation bar button.
 */

- (void)createNavRightButton
 {
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"home_box_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"home_box_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    
    [navCancelButton setFrame:CGRectMake(-10,17,50,50)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    
   
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];

 }

- (void)backButtonClicked
 {
   
    NSLog(@"navigation bar right button clicked");
   
 }



#pragma mark
#pragma mark - button
/**
 *  this button action will perform when user taps findPeopleToFollow button and here the view changingto follow view controller.
 *
 *  @param sender <#sender description#>
 */


- (IBAction)findPeopleToFollowButtonAction:(UIButton *)sender

 {
    [self performSegueWithIdentifier:@"HomeToFollowViewSegue" sender:nil];
 }

@end
