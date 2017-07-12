//
//  PrivacyPolicyViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/17/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PGPrivacyPolicyViewController : UIViewController\

@property (strong,nonatomic) NSString *weburl;

//webview outlet

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
