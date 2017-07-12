//
//  WebViewForDetailsVc.h
//  Picogram
//
//  Created by Rahul_Sharma on 21/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewForDetailsVc : UIViewController
@property (nonatomic, assign) BOOL showTermsAndPolicy;
@property (nonatomic, assign) BOOL showElu;
@property (weak, nonatomic) IBOutlet UIWebView *webViewOutlet;
@property(nonatomic,strong)NSString *weburl;
@property(nonatomic,strong)NSString *category;
@property(nonatomic,strong)NSString *subcategory;
@end
