//
//  ResetPasswordByEmailFbViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 8/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ResetPasswordByEmailFbViewController.h"

@interface ResetPasswordByEmailFbViewController ()

@end

@implementation ResetPasswordByEmailFbViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navBarCustomization];
    [self createNavLeftButton];
    [self.view layoutIfNeeded];
     _profileImageViewOutlet.layer.cornerRadius =  _profileImageViewOutlet.frame.size.height/2;
     _profileImageViewOutlet.clipsToBounds = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//action for navigation bar items (buttons).
- (void)CancelButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)donthaveAcessButtonAction:(id)sender {
    NSLog(@"donthaveAcessButtonAction");
}

- (IBAction)sendPasswordEmail:(id)sender {
    NSLog(@"sendPasswordEmail");
}

- (IBAction)resetUsingFaceBook:(id)sender {
    NSLog(@"resetUsingFaceBook");
}

@end
