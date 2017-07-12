//
//  PageContentViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 06/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PageContentViewController.h"
#import "HomeScreenTabBarController.h"
#import "ChatNavigationContollerClass.h"
//chatNavigationContollerClass
#import "HomeScreenNavigation.h"
#import "PGTabBar.h"
#import "HomeViewController.h"
//loginToHomeViewController
//homeScreenTabBarController
@interface PageContentViewController ()
{
    
    BOOL pageIsAnimating;
    PGTabBar *homeVC;
    HomeScreenTabBarController *chatVC;
}

@end
static PageContentViewController *baseController;
@implementation PageContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (id)sharedInstance {
    if (!baseController) {
        baseController  = [[self alloc] init];
    }
    return baseController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    baseController = self;
    pageIsAnimating = NO;
    [self createPageviewController];
}
-(void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createPageviewController
{
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewController2"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginToHomeViewController"];
    
    [self.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - Page View Controller Data Source

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    pageIsAnimating = YES;
    
    NSString *tabSellected = [[NSUserDefaults standardUserDefaults]stringForKey:@"TabSellected"];
                              
 
    
//    for (UIScrollView *view in self.pageViewController.view.subviews) {
//        
//        if ([view isKindOfClass:[UIScrollView class]]) {
//            NSString *tabSellected = [[NSUserDefaults standardUserDefaults]
//                                      stringForKey:@"TabSellected"];
//            
//            if(![tabSellected isEqualToString:@"0"])
//            {
//                view.scrollEnabled = NO;
//            }
//            else
//            {
//                view.scrollEnabled = YES;
//            }
//        }
//    }

}
- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed && finished)   // Turn is either finished or aborted
        pageIsAnimating = NO;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    //
//    NSString *tabSellected = [[NSUserDefaults standardUserDefaults]
//                              stringForKey:@"TabSellected"];
//    
//    if([tabSellected isEqualToString:@"0"])
//    {
    
        if (pageIsAnimating)
            return nil;
        if ([viewController isKindOfClass:[HomeScreenTabBarController class]]){
            if (!homeVC) {
                
                
                homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginToHomeViewController"];
            }
            return  homeVC;
            
        }
        
//    }
    //    else
    //         if ([viewController isKindOfClass:[PGTabBar class]]) {
    //
    //         if (!chatVC) {
    ////             [self.tabBarController.tabBar setHidden:YES];
    //             chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeScreenTabBarController"];
    //         }
    //
    //         return  chatVC;
    //     }
    
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
//    NSString *tabSellected = [[NSUserDefaults standardUserDefaults]
//                              stringForKey:@"TabSellected"];
//    
//    if([tabSellected isEqualToString:@"0"])
//    {
        
        if (pageIsAnimating)
            return nil;
        
        if ([viewController isKindOfClass:[PGTabBar class]]) {
            if (!chatVC) {
                
                chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeScreenTabBarController"];
            }
            
            return  chatVC;
            
        }
        //    else
        //      if ([viewController isKindOfClass:[HomeScreenTabBarController class]]){
        //      if (!homeVC) {
        //          homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginToHomeViewController"];
        //      }
        //      return  homeVC;
        //
//    }
    return nil;
}


-(void)goToChatViewController
{
    chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVcSID"];
    
    [self.pageViewController setViewControllers:@[chatVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}
-(void)goToProfileViewController
{
    homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
    
    [self.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    //
    //    BOOL isFromPush = [[NSUserDefaults standardUserDefaults] boolForKey:@"isComingFromPush"];
    //    if (isFromPush) {
    //        [self goToChatViewController];
    //    }
}

@end
