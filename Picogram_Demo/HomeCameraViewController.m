

//
//  TGInitialViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/9/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeCameraViewController.h"
#import "TGCamera.h"
#import "TGCameraViewController.h"
#import "TGCameraColor.h"
#import "PGTagPeopleViewController.h"

static HomeCameraViewController *obj = nil;

@interface HomeCameraViewController ()<TGCameraDelegate>
{
    BOOL cancelCamera;
}
@property (strong, nonatomic) IBOutlet UIImageView *photoView;

- (IBAction)takePhotoTapped;

- (void)clearTapped;


@end

@implementation HomeCameraViewController

#pragma mark
#pragma mark - viewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // save image at album
    [TGCamera setOption:kTGCameraOptionSaveImageToAlbum value:[NSNumber numberWithBool:YES]];
    
    // hidden toggle button
    //[TGCamera setOption:kTGCameraOptionHiddenToggleButton value:[NSNumber numberWithBool:YES]];
    //[TGCameraColor setTintColor: [UIColor greenColor]];
    
    // hidden album button
    //[TGCamera setOption:kTGCameraOptionHiddenAlbumButton value:[NSNumber numberWithBool:YES]];
    
    // hide filter button
    //[TGCamera setOption:kTGCameraOptionHiddenFilterButton value:[NSNumber numberWithBool:YES]];
    
    
    _photoView.clipsToBounds = YES;
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(clearTapped)];
    
    self.navigationItem.rightBarButtonItem = clearButton;
    
    
//    [self photo];
    
   
}

/**
 *  this method called when view will appear.
 *
 *
 */



-(void)viewWillAppear:(BOOL)animated
{
    if (cancelCamera) {
        NSLog(@"return back from camera");
//        HomeCameraViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewStoryBoardId"];
//        UINavigationController *navBar =[[UINavigationController alloc]initWithRootViewController:homeVC];
//        [self presentViewController:navBar animated:YES completion:nil];
        [self.tabBarController setSelectedIndex:0];
        cancelCamera = NO;
    }
    else{
    [self photo];
    }
}



#pragma mark -
#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    cancelCamera = YES;
    
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    _selectedImage = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    PGShareViewController *ShareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"photoSelected"];
    ShareVC.image2 = _selectedImage;
    
    UINavigationController *navBar =[[UINavigationController alloc]initWithRootViewController:ShareVC];
    
    [navBar.navigationBar setBarTintColor:[UIColor blackColor]];
   
//    navBar.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor yellowColor]};
    navBar.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
  
    
    [self presentViewController:navBar animated:YES completion:nil];
}



-(void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    
    _selectedImage = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];

    
    PGShareViewController *ShareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"photoSelected"];
    ShareVC.image2 = _selectedImage;
    
    UINavigationController *navBar =[[UINavigationController alloc]initWithRootViewController:ShareVC];
    [self presentViewController:navBar animated:YES completion:nil];
  
}

#pragma mark -
#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL
{
    
    NSLog(@"%s album path: %@", __PRETTY_FUNCTION__, assetURL);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
    
}

#pragma mark -
#pragma mark - Actions


- (IBAction)takePhotoTapped
{
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)photo
{
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark -
#pragma mark - Private methods

- (void)clearTapped
{
    _photoView.image = nil;
}

@end
