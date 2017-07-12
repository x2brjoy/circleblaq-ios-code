//
//  LRPageViewController.m
//  TinderClone
//
//  Created by 3embed on 10/07/14.
//  Copyright (c) 2014 Rahul Sharma. All rights reserved.
//

#import "LRPageViewController.h"

@interface LRPageViewController () <UIGestureRecognizerDelegate>
{
    
}
@end

@implementation LRPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}



#pragma mark UIView Life Cycle -
/* ----------------------------------------------------------------------------------------------------------*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = (UIScrollView *)view;
            _scrollViewPanGestureRecognzier = [[UIPanGestureRecognizer alloc] init];
            _scrollViewPanGestureRecognzier.delegate = self;
            
            [scrollView addGestureRecognizer:_scrollViewPanGestureRecognzier];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        return YES;

    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _scrollViewPanGestureRecognzier)
    {
        CGPoint locationInView = [gestureRecognizer locationInView:self.view];
        if (locationInView.y < 44.0)
        {
            return YES;
        }
        return NO;
    }
    return NO;
}

@end
