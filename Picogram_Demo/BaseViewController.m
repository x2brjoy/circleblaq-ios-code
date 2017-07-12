//
//  BaseViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 26/08/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "BaseViewController.h"
#import "CameraViewController.h"
#import "ProgressIndicator.h"

@interface BaseViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>
{
    CameraViewController *cam;
    //TGCameraViewController *tgCam;
    BOOL pageIsAnimating;
     NSMutableArray *controllerIds;
    NSMutableArray *viewcontrollers;
    
}

@property NSUInteger pageIndex;
@property (nonatomic,assign) BOOL shouldBounce;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

static BaseViewController *baseController;
@implementation BaseViewController

#pragma mark - ShareInstaceDeclaration

+(id)sharedInstance
{
    if(baseController)
    {
        baseController = [[self alloc]init];
    }
    return baseController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    baseController = self;
    controllerIds = [[NSMutableArray alloc]init];
    self.navigationController.navigationBarHidden = YES;
     [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    pageIsAnimating = NO;
    // Create page view controller
    for (UIView *view in self.view.subviews) {
                if ([view isKindOfClass:[UIScrollView class]]) {
                    ((UIScrollView *)view).delegate = self;
                    break;
                }
            }
    
    [self createPageviewController];
   
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePostFromNotification:) name:@"AllowToScroll" object:nil];

}

-(void)deletePostFromNotification :(NSNotification *)noti {
    
    NSString *permissionForScroll = noti.object[@"permissionForScroll"][@"allowScrol"];
    
    if ([permissionForScroll isEqualToString:@"yes"]) {
        self.allowToScroll = YES;
        self.pageViewController.delegate = nil;
        
    }
    else {
         self.allowToScroll = NO;
        self.pageViewController.delegate = self;
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
     [[ProgressIndicator sharedInstance] hideProgressIndicator];
}
-(void)createPageviewController
{
    if(!self.pageViewController)
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
//    for (UIView *view in self.view.subviews) {
//        if ([view isKindOfClass:[UIScrollView class]]) {
//            ((UIScrollView *)view).delegate = self;
//            break;
//        }
//    }
    
    for (UIView *vw in self.pageViewController.view.subviews)
    {
        if ([vw isKindOfClass:[UIPageControl class]])
        {
            [vw removeFromSuperview];
            vw.hidden = YES;
        }
    }
    cam.hidesBottomBarWhenPushed = YES;
    cam = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraStoryBoardID"];

     [self.pageViewController setViewControllers:@[cam] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - ScrollViewDelegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_pageIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    } else if (_pageIndex == [viewcontrollers count]-1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_pageIndex == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    } else if (_pageIndex == [viewcontrollers count]-1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

#pragma mark- PageViewControllerDatasource

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([controllerIds count] == 0) || (index >= [controllerIds count])) {
        return nil;
    }
    
    if (index == 0) {
        BaseViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraStoryBoardID"];
        pageContentViewController.hidesBottomBarWhenPushed = YES;
        pageContentViewController.pageIndex = index;
        if ([viewcontrollers count]) {
            [viewcontrollers replaceObjectAtIndex:0 withObject:pageContentViewController];
        }
        return pageContentViewController;
    }
    else
    {
        BaseViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"vc2"];
        fvc.pageIndex = index;
        if ([viewcontrollers count]) {
            [viewcontrollers replaceObjectAtIndex:0 withObject:fvc];
        }
        return fvc;
    }
    
}

-(NSUInteger)indexofViewController
{
    UIViewController *currentView = [self.pageViewController.viewControllers objectAtIndex:0];
    
    if ([currentView isKindOfClass:[cam class]]) {
        return 1;
    }
    else{
        return 0;
    }
    
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
   ///    for (UIView *view in self.view.subviews) {
//        if ([view isKindOfClass:[UIScrollView class]]) {
//            self.scrollView = (UIScrollView *)view;
//            
//        }
//    }
//    self.scrollView.bounces = NO;
    if ([viewController isKindOfClass:[CameraViewController class]] )
    {
                   {
                 
                cam = [self.storyboard instantiateViewControllerWithIdentifier:@"TWPhotoPickerStoryBoardID"];
//                
                return  nil;
            
                   }
        return  nil;
    }
    else
        return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexofViewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == [controllerIds count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
@end
