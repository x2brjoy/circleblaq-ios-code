//
//  WebViewForDetailsVc.m
//  Picogram
//
//  Created by Rahul_Sharma on 21/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "WebViewForDetailsVc.h"
#import "Helper.h"
#import "FontDetailsClass.h"
#import "ProgressIndicator.h"

@interface WebViewForDetailsVc ()<UIWebViewDelegate>
{
   
    UIWebView *newwebview;
    BOOL pageloaded;
}
@end

@implementation WebViewForDetailsVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //https://help.instagram.com/155833707900388 -- insta private policy link.
    [self.webViewOutlet setBackgroundColor:[UIColor clearColor]];
    [self.webViewOutlet setOpaque:NO];
    
    [newwebview setBackgroundColor:[UIColor redColor]];
   
    
    NSURL *url ;
    if (_category.length > 1) {
        newwebview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.view addSubview:newwebview];
        
        NSString *urlSting;
        //= [NSString stringWithFormat:@"http://%@",_weburl];
        
        if ([urlSting containsString:@"http://"] || [urlSting containsString:@"https://"]) {
              urlSting = [NSString stringWithFormat:@"http://%@",_weburl];
        }
        else {
            urlSting
            = [NSString stringWithFormat:@"%@",_weburl];
        }
        
        urlSting = [urlSting lowercaseString];
       url = [NSURL URLWithString:urlSting];
       // [newwebview loadHTMLString:@"" baseURL:nil];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [newwebview loadRequest:requestObj];
        
        newwebview.delegate =self;
        self.navigationItem.hidesBackButton = YES;
    }
    else{
    if (self.showTermsAndPolicy) {
        if (self.showElu) {
            url = [NSURL URLWithString:@"http://yayway.com/eula"];
            self.navigationItem.title = @"EULA";
            [self createNavRightButton];
        }
        else {
            url = [NSURL URLWithString:@"http://www.ywy.io/page/terms-and-conditions"];
            self.navigationItem.title = @"Terms";
        }
    }
    else {
        url = [NSURL URLWithString:@"http://www.ywy.io/page/privacy-policy"];
        self.navigationItem.title = @"Privacy Policy";
        [self createNavRightButton];
    }
    

    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [self.webViewOutlet loadRequest:requestURL];
    
    self.webViewOutlet.delegate =self;
    self.navigationItem.hidesBackButton = YES;
    [self.webViewOutlet sizeToFit];
    }
   
    
     [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    [self createNavLeftButton];
    
    ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];
    [HomePI showPIOnView:self.view withMessage:@"Loading..."];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
}

/*---------------------------------------------------*/
#pragma mark
#pragma mark - navigation bar  buttons
/*---------------------------------------------------*/

- (void)createNavRightButton {
    //creating navigation bar button.
    UIButton *navDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navDoneButton setTitle:@"Agree"
                   forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor blackColor]
                        forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor blackColor]
                        forState:UIControlStateHighlighted];
    navDoneButton.titleLabel.font = [UIFont fontWithName:RobotoMedium size:16];
    
    
    
    [navDoneButton setFrame:CGRectMake(0,0,50,30)];
    //craeting button action for navigation bar button.
    [navDoneButton addTarget:self action:@selector(doneButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navDoneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void) doneButtonAction:(UIButton *)sender {
    //navbar right button action.
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    self.tabBarController.hidesBottomBarWhenPushed = YES;
}
-(void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.hidesBottomBarWhenPushed = NO;
    
    [newwebview setDelegate:nil];
    [self.webViewOutlet setDelegate:nil];
    [newwebview stopLoading];
    [self.webViewOutlet stopLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
    
    if ([[error localizedDescription] containsString:@"A server with the specified hostname could not be found"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
    }
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
   NSLog(@"WebView finished loading: %@", webView);
    if ([webView.request.URL.absoluteString isEqualToString:@"about:blank"]) {
        NSLog(@"  This is Blank. Ignoring as false event.");
        //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"unable to load page" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        //    [alert show];
    }
    else {
        
        NSLog(@"  This is a real url");
         [[ProgressIndicator sharedInstance] hideProgressIndicator];
        pageloaded = YES;
        
    }

    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)createNavLeftButton
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
}*/


- (void)createNavLeftButton
{
    
  
    
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
    
    
    if (_subcategory.length>1) {
        UILabel *titleLbl = [[UILabel alloc]init];
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"subcatecategoryIcon.png"];
        attachment.bounds = CGRectMake(0, 0, attachment.image.size.width, attachment.image.size.height);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@",_category]];
        [myString appendAttributedString:attachmentString];
        NSMutableAttributedString *myString1= [[NSMutableAttributedString alloc] initWithString:_subcategory];
        [myString appendAttributedString:myString1];
        
        titleLbl.attributedText = myString;
        [titleLbl sizeToFit];
        [titleLbl setTextColor:[UIColor blackColor]];
        self.navigationItem.titleView = titleLbl;
    }
    else
        self.title = _category;
}




// hiding navigation bar and changing to previous controloler.

- (void)backButtonClicked
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
//    if (pageloaded) {
//            if(_category.length > 1)
//            {
//            [[NSUserDefaults standardUserDefaults] setValue:@"backToHome" forKey:@"back"];
//            [[NSUserDefaults standardUserDefaults]synchronize];
//            }
//        [self.navigationController popViewControllerAnimated:YES];
//}
}


@end
