//
//  AskingPermissonViewController.m
//  Picogram
//
//  Created by Rahul_Sharma on 09/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "AskingPermissonViewController.h"

@interface AskingPermissonViewController ()

@end

@implementation AskingPermissonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = self.title;
    self.messageLabel.text = self.message;
    [self.permissionButton setTitle:self.buttonTitle forState:UIControlStateNormal];
    self.title = self.navBarTitle;
    [self createNavLeftButton];
    
     [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)permissionButonAction:(id)sender {
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

/*---------------------------------------------------------------*/
#pragma marks - Navigation Bar Methods
/*---------------------------------------------------------------*/
- (void)createNavLeftButton {
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
   [navCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
   [navCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    
   [navCancelButton setFrame:CGRectMake(10.0f,0.0f,60,40)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    
    // UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}
- (void)backButtonClicked {
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
