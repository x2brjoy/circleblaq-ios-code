
//
//  TabBar.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/26/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGTabBar.h"
#import "TGCameraNavigationController.h"
#import "HomeCameraViewController.h"
#import "CameraXib.h"
#import "HomeViewTableViewController.h"
#import "UserProfileViewController.h"

@interface PGTabBar ()<UITabBarDelegate,UITabBarControllerDelegate,shareViewDelegate>
{
    CameraXib *cameraNib;
}
@end
#define kTabBarHeight = 40;
@implementation PGTabBar

- (void)viewDidLoad {
    [super viewDidLoad];
  
     [self.tabBarController setSelectedIndex:0];
     [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0.9765 green:0.9765 blue:0.9765 alpha:1.0]];    
   //[[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@""]];
   [self.tabBarController setSelectedIndex:0];
}

- (void)viewWillLayoutSubviews {
    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    // if the device is 6s/6s plus or 6/6plus tabbar height is 50 and for remining device tabbar height is 40.
    if (CGRectGetHeight(self.view.frame) == 736 || CGRectGetHeight(self.view.frame) == 667 ) {
        tabFrame.size.height = 50;
        tabFrame.origin.y = self.view.frame.size.height - 50;
    }
    else {
        tabFrame.size.height = 40;
        tabFrame.origin.y = self.view.frame.size.height - 40;
    }
    self.tabBar.frame = tabFrame;
}
/* ------------------------------*/
#pragma mark
#pragma mark - tab bar buttons
/* ------------------------------*/

/*
 *  delegate method called when user taps on tab bar button.
 */
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    // tag for home --- 1
    // tag for search  --- 2
    // tag for camera -- 3
    // tag for activity -- 4
    // tag for user profile -- 5
    
    
    if(item.tag==1) {
        [self.tabBarController setSelectedIndex:0];
    }
    else if (item.tag == 5) {
        //when ever user clicked on last tab(profile tab) then only we need to show user profile details.
        // so then only we need to show user details and passing bool value to check user checking his/her own profile or others profile.
        
        UserProfileViewController *vc = [[UserProfileViewController alloc] init];
        vc.checkingFriendsProfile = NO;
    }
}

-(void)selectHomeScreen {
      [self.tabBarController setSelectedIndex:0];
}

-(void)cancelButtonClicked {
    [UIView animateWithDuration:0.5
                     animations:^{
                         [cameraNib removeFromSuperview];
                     }];
}

@end
