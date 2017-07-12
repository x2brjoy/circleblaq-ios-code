//
//  PrivacyPolicyViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/17/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGPrivacyPolicyViewController.h"

@interface PGPrivacyPolicyViewController ()<UIWebViewDelegate>
{
    UIActivityIndicatorView *avForCollectionView;
}
@end

@implementation PGPrivacyPolicyViewController

#pragma mark
#pragma mark - viewcontroller


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://www.ywy.io/page/privacy-policy"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestURL];
    self.webView.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    [self createNavLeftButton];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"Privacy Policy";
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.9704 green:0.9703 blue:0.9704 alpha:1.0]];
    
    [self addingActivityIndicatorToCollectionViewBackGround];
}


/**
 *  this method will call when view will appear.
 *
 *  here navigation bar is unhiding when will apaear.
 */

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];   //it hides

}

/**
 *  this method will call when view will disappear
 *
 *  here navigation bar is hiding when will disappear.
 */
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];    // it shows
}


#pragma mark
#pragma mark - navigation bar buttons

//careting navigation bar left button.

- (void)createNavLeftButton
{
    
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [navCancelButton setImage:[UIImage imageNamed:@"home_a_back_icon_off"]
//                     forState:UIControlStateNormal];
//    [navCancelButton setImage:[UIImage imageNamed:@"home_a_back_icon_on"]
//                     forState:UIControlStateSelected];
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

// hiding navigation bar and changing to previous controloler.

- (void)backButtonClicked
{
   
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark
#pragma mark - StautsBar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [avForCollectionView stopAnimating];
}
    
    

-(void)addingActivityIndicatorToCollectionViewBackGround {
    avForCollectionView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    avForCollectionView.frame =CGRectMake(self.view.frame.size.width/2 -12.5, self.view.frame.size.height/2 -12.5, 25,25);
    avForCollectionView.tag  = 1;
    [self.view addSubview:avForCollectionView];
    [avForCollectionView startAnimating];
}

@end
