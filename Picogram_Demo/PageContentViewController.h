//
//  PageContentViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 06/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRPageHomeViewController.h"

@interface PageContentViewController : UIPageViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

+ (id)sharedInstance;

@property (strong, nonatomic) LRPageHomeViewController *pageViewController;

-(void)goToChatViewController;
-(void)goToProfileViewController;

@end
