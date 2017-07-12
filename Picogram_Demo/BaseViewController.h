//
//  BaseViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 26/08/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
+ (id)sharedInstance;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property BOOL allowToScroll;
@end
