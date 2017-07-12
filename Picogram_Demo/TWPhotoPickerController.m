//
//  TWPhotoPickerController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "TWPhotoPickerController.h"
#import "TWPhotoCollectionViewCell.h"
#import "TWImageScrollView.h"
#import "PGShareViewController.h"
#import "CLImageEditor.h"
#import "_CLImageEditorViewController.h"
#import "WebServiceConstants.h"
#import "FontDetailsClass.h"
#import "VideoFilterViewController.h"
#import "CameraViewController.h"
#import "PGTagPeopleViewController.h"
#import "TWPhotoPickerController.h"
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FiltersViewController.h"
#import "CLImageEditor.h"
#import "WebServiceConstants.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Cloudinary/Cloudinary.h"
#import "VideoFilterViewController.h"
#import <SCRecorder/SCRecorder.h>
#import <SCRecorder/SCRecorderToolsView.h>
#import <SCRecorder/SCRecordSession.h>
#import <SCRecorder/SCAssetExportSession.h>
#import <SCRecorder/SCRecordSessionSegment.h>
#import "SCAudioTools.h"
#import "SCRecorder.h"
#import <SCRecorder/SCRecordSessionSegment.h>
#import "SCRecordSessionManager.h"
#import "ProgressIndicator.h"
#import <SCRecorder/SCImageView.h>
#import  <Photos/Photos.h>
#import "AlbumSelectionViewController.h"

@interface TWPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate,CLImageEditorDelegate,UIScrollViewDelegate,albumsSelected>
{
    CGFloat beginOriginY;
    PHAsset* choosen;
}
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIImageView *maskView;
@property (strong, nonatomic) TWImageScrollView *imageScrollView;

@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) UICollectionView *collectionView;

@property UIButton *navRightButton;

@property UIButton *navTitleButton;





///custom picker

@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsFetchResultsAssets;
@property (strong) NSArray *collectionsFetchResultsTitles;
@property (strong) PHCachingImageManager *imageManager;
@property (strong) PHFetchResult *assetsFetchResults;

@end

@implementation TWPhotoPickerController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.topView];
    [self.view insertSubview:self.collectionView belowSubview:self.topView];
}
-(void)viewDidAppear:(BOOL)animated
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageManager = [[PHCachingImageManager alloc] init];
    UIWindow *window1 = [[UIWindow alloc] initWithFrame:CGRectMake(0, 100/*self.view.bounds.size.height-44*/,44, self.view.bounds.size.width)];
    window1.backgroundColor = [UIColor whiteColor];
    window1.windowLevel = UIWindowLevelNormal;
    [self.collectionView bringSubviewToFront:window1];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES
    //                                       withAnimation:UIStatusBarAnimationFade];
    
    // Do any additional setup after loading the view.
    [self loadPhotos];
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    self.navigationController.navigationBarHidden =YES;
    [[NSUserDefaults standardUserDefaults]setValue:@"Lib" forKey:kController];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSMutableArray *)assets {
    if (_assets == nil) {
        _assets = [[NSMutableArray alloc] init];
    }
    return _assets;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

-(void)itemSelected:(PHFetchResult *)selctedPhotosAssests andHeaderTitle:(NSString *)headerTitle {
    [self.navTitleButton setTitle:headerTitle forState:UIControlStateNormal];
    self.assetsFetchResults = selctedPhotosAssests;
    choosen=[self.assetsFetchResults objectAtIndex:0];
    if (choosen.mediaType == PHAssetMediaTypeImage)  {
        [self.imageManager requestImageForAsset:choosen
                                     targetSize:PHImageManagerMaximumSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      [self.imageScrollView displayImage:result];
                                  }];
    }
    else  if (choosen.mediaType == PHAssetMediaTypeVideo) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:choosen options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  if ([asset isKindOfClass:[AVURLAsset class]]) {
                      NSURL *URL = [(AVURLAsset *)asset URL];
                      [self.imageScrollView displayVideo:URL h:100  w:100];
                  }
              });
        }];
    }
    [self.collectionView reloadData];
}


-(void)fetchPhotosFromLibrary {
    //All album: Sorted by descending creation date.
    NSMutableArray *allFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *allFetchResultLabel = [[NSMutableArray alloc] init];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResult;
    
    if([_viewFromProfileSelector isEqualToString:@"itisForProfilePhoto"]) {
        assetsFetchResult = [PHAsset  fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    }
    else {
        assetsFetchResult = [PHAsset  fetchAssetsWithOptions:options];
        //assetsFetchResult = [PHAsset  fetchAssetsWithOptions:options];
    }
    
    [allFetchResultArray addObject:assetsFetchResult];
    [allFetchResultLabel addObject:@"All photos"];
    
    self.assetsFetchResults = assetsFetchResult;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // This block will be executed asynchronously on the main thread.
        [self.collectionView reloadData];
        [self.navTitleButton setTitle:@"Select" forState:UIControlStateNormal];
        
        choosen=[self.assetsFetchResults objectAtIndex:0];
        if (choosen.mediaType == PHAssetMediaTypeImage)  {
            
            [self.imageManager requestImageForAsset:choosen
                                         targetSize:PHImageManagerMaximumSize
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          
                                          // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                          [self.imageScrollView displayImage:result];
                                      }];
        }
        else  if (choosen.mediaType == PHAssetMediaTypeVideo){
            [[PHImageManager defaultManager] requestAVAssetForVideo:choosen options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([asset isKindOfClass:[AVURLAsset class]]) {
                        NSURL *URL = [(AVURLAsset *)asset URL];
                        [self.imageScrollView displayVideo:URL h:100  w:100];
                    }
                });
             
            }];
        }
    });
}

- (void)loadPhotos {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status ==  PHAuthorizationStatusDenied) {
        [self createCustomViewWhenGalleryPermissionDenied];
        self.navTitleButton.enabled = NO;
    }
    if (status ==  PHAuthorizationStatusAuthorized) {
        [self fetchPhotosFromLibrary];
    }
    if (status ==PHAuthorizationStatusNotDetermined) {
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                [self fetchPhotosFromLibrary];
            }
            
            else {
                // Access has been denied.
                [self createCustomViewWhenGalleryPermissionDenied];
                self.navTitleButton.enabled = NO;
            }
        }];
    }
    if (status == PHAuthorizationStatusRestricted) {
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                dispatch_async(dispatch_get_main_queue(), ^{
                    // This block will be executed asynchronously on the main thread.
                    [self fetchPhotosFromLibrary];
                });
            }
            else {
                // Access has been denied.
                dispatch_async(dispatch_get_main_queue(), ^{
                    // This block will be executed asynchronously on the main thread.
                    [self createCustomViewWhenGalleryPermissionDenied];
                    self.navTitleButton.enabled = NO;
                });
            }
        }];
    }
}

-(void)createCustomViewWhenGalleryPermissionDenied {
    
    self.navRightButton.hidden = YES;
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0,44,self.view.frame.size.width,self.view.frame.size.height/2)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,10,self.view.frame.size.width,40)];
    title.text = @"Please Allow Access to your photos";
    title.numberOfLines = 0;
    title.textAlignment =  NSTextAlignmentCenter;
    [title setFont:[UIFont fontWithName:RobotoMedium size:15]];
    title.textColor = [UIColor lightGrayColor];
    
    UILabel *messageForPermissionDenied = [[UILabel alloc] initWithFrame:CGRectMake(20,60,self.view.frame.size.width-40,60)];
    messageForPermissionDenied.text = @"This allows Picogram to share photos from your library and save photos to your camera roll.";
    messageForPermissionDenied.numberOfLines = 0;
    messageForPermissionDenied.textAlignment =  NSTextAlignmentCenter;
    [messageForPermissionDenied setFont:[UIFont fontWithName:RobotoRegular size:15]];
    messageForPermissionDenied.textColor = [UIColor lightGrayColor];
    
    UIButton *enableButton = [[UIButton alloc] initWithFrame:CGRectMake(0,130,self.view.frame.size.width,20)];
    [enableButton setTitle:@"Enable Gallery Access" forState:UIControlStateNormal];
    [enableButton addTarget:self action:@selector(enableButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [enableButton setTitleColor:[UIColor colorWithRed:40/255.0 green:140/255.0 blue:240/255.0 alpha:1.0f] forState:UIControlStateNormal];
    [enableButton.titleLabel setFont:[UIFont fontWithName:RobotoMedium size:15]];
    
    customView.center = self.view.center;
    
    
    
    [customView addSubview:title];
    [customView addSubview:enableButton];
    [customView addSubview:messageForPermissionDenied];
    [self.view addSubview:customView];
}

-(void)enableButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIView *)topView {
    if (_topView == nil) {
        CGFloat handleHeight = 44.0f;
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)+handleHeight);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.clipsToBounds = YES;
        
        rect = CGRectMake(0, 0, CGRectGetWidth(self.topView.bounds), handleHeight);
        UIView *navView = [[UIView alloc] initWithFrame:rect];//26 29 33
        navView.backgroundColor = [UIColor colorWithRed:247.0/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1];
        //[UIColor colorWithRed:30.0f/255.0f green:36.0f/255.0f blue:52.0f/255.0f alpha:1.0]; //[[UIColor colorWithRed:247.0/255 green:29.0/255 blue:33.0/255 alpha:1] colorWithAlphaComponent:.8f];
        [self.topView addSubview:navView];
        
        rect = CGRectMake(0, 0, 60, CGRectGetHeight(navView.bounds));
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:backBtn];
        
        rect = CGRectMake((CGRectGetWidth(navView.bounds)-200)/2, 0,200, CGRectGetHeight(navView.bounds));
        self.navTitleButton = [[UIButton alloc] initWithFrame:rect];
        [self.navTitleButton setBackgroundColor:[UIColor clearColor]];
        [self.navTitleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.navTitleButton.titleLabel setFont:[UIFont fontWithName:RobotoRegular size:16]];
        self.navTitleButton.titleLabel.minimumScaleFactor = 0.5f;
        self.navTitleButton.titleLabel.numberOfLines = 1;
        self.navTitleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.navTitleButton addTarget:self action:@selector(selectAlbumAction:) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:self.navTitleButton];
        
        
        rect = CGRectMake(CGRectGetWidth(navView.bounds)-80, 0, 80, CGRectGetHeight(navView.bounds));
        self.navRightButton = [[UIButton alloc] initWithFrame:rect];
        [self.navRightButton setTitle:@"Ok" forState:UIControlStateNormal];
        [self.navRightButton.titleLabel setFont:[UIFont fontWithName:RobotoRegular size:16]];
        [self.navRightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.navRightButton addTarget:self action:@selector(cropAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:self.navRightButton];
        
        rect = CGRectMake(0, 0, 100, CGRectGetHeight(navView.bounds));
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:rect];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont fontWithName:RobotoRegular size:16]];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelbuttonaction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:cancelButton];
        
        
        rect = CGRectMake(0, CGRectGetHeight(self.topView.bounds)-handleHeight, CGRectGetWidth(self.topView.bounds), handleHeight);
        UIView *dragView = [[UIView alloc] initWithFrame:rect];
        dragView.backgroundColor = [UIColor clearColor];//colorWithRed:26.0/255 green:29.0/255 blue:33.0/255 alpha:1] colorWithAlphaComponent:.8f];//navView.backgroundColor;
        dragView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.topView addSubview:dragView];
        
        UIImage *img = [UIImage imageNamed:@"cameraroll-picker-grip"];
        rect = CGRectMake((CGRectGetWidth(dragView.bounds)-img.size.width)/2, (CGRectGetHeight(dragView.bounds)-img.size.height)/2, img.size.width, img.size.height);
        UIImageView *gripView = [[UIImageView alloc] initWithFrame:rect];
        gripView.image = img;
        [dragView addSubview:gripView];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [dragView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [dragView addGestureRecognizer:tapGesture];
        
        [tapGesture requireGestureRecognizerToFail:panGesture];
        
        rect = CGRectMake(0, handleHeight, CGRectGetWidth(self.topView.bounds), CGRectGetHeight(self.topView.bounds)-handleHeight-1);
        self.imageScrollView = [[TWImageScrollView alloc] initWithFrame:rect];
        [self.topView addSubview:self.imageScrollView];
        [self.topView sendSubviewToBack:self.imageScrollView];
        
        self.maskView = [[UIImageView alloc] initWithFrame:rect];
        self.maskView.image = [UIImage imageNamed:@"straighten-grid"];
        self.maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.maskView.contentMode = UIViewContentModeCenter;
        [self.topView insertSubview:self.maskView aboveSubview:self.imageScrollView];
    }
    return _topView;
}
-(void)cancelbuttonaction
{
    NSString *controllerType = [[NSUserDefaults standardUserDefaults]valueForKey:@"CameraControllerType"];
    
    if ([controllerType isEqualToString:@"directChaT"]) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CameraControllerType"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
        [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
    
    if (choosen.mediaType == PHAssetMediaTypeVideo) {
        [self.imageScrollView dealloci];
    }
    
    //    if([[choosen valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
    //        [self.imageScrollView dealloci];
    //    }
}

-(void)selectAlbumAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    AlbumSelectionViewController *newView = [storyboard instantiateViewControllerWithIdentifier:@"albumSelectionVc"];
    newView.delegate =self;
    newView.titleText = [self.navTitleButton titleForState:UIControlStateNormal];
    newView.selectedAlbumFor = self.viewFromProfileSelector;
    UINavigationController *navBar =[[UINavigationController alloc]initWithRootViewController:newView];
    [self presentViewController:navBar animated:YES completion:nil];
    [navBar.navigationBar setTranslucent:NO];
    [self.navigationController presentViewController:navBar animated:YES completion:nil];
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat colum = 4.0, spacing = 2.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
        
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = CGSizeMake(value, value);
        layout.sectionInset                 = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing      = spacing;
        layout.minimumLineSpacing           = spacing;
        
        CGRect rect = CGRectMake(0, CGRectGetMaxY(self.topView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.topView.bounds));
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[TWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"TWPhotoCollectionViewCell"];
        
        //        rect = CGRectMake(0, 0, 60, layout.sectionInset.top);
        //        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        backBtn.frame = rect;
        //        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        //        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        //        [_collectionView addSubview:backBtn];
        //
        //        rect = CGRectMake((CGRectGetWidth(_collectionView.bounds)-140)/2, 0, 140, layout.sectionInset.top);
        //        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
        //        titleLabel.text = @"CAMERA ROLL";
        //        titleLabel.textAlignment = NSTextAlignmentCenter;
        //        titleLabel.backgroundColor = [UIColor clearColor];
        //        titleLabel.textColor = [UIColor whiteColor];
        //        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        //        [_collectionView addSubview:titleLabel];
    }
    return _collectionView;
}

- (void)cancelButtonSelected {
    if([_viewFromProfileSelector isEqualToString:@"itisForProfilePhoto"]) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }else {
        [self gotoImageEditor:self.imageScrollView.capture ];
    }
    if (choosen.mediaType == PHAssetMediaTypeVideo) {
        [self.imageScrollView dealloci];
    }
}

-(void)gotoImageEditor:(UIImage *)data
{
    UIImage *img = data;
    
    [[CLImageEditorTheme theme] setBackgroundColor:[UIColor blackColor]];
    [[CLImageEditorTheme theme] setToolbarColor:[UIColor darkGrayColor]];
    [[CLImageEditorTheme theme] setToolbarTextColor:[UIColor whiteColor]];
    
    //UIImage *image =  [UIImage imageWithContentsOfFile:_mediaPath];
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:img delegate:self];
    //CLImageEditor *editor = [[CLImageEditor alloc] initWithDelegate:self];
    
    
    NSLog(@"%@", editor.toolInfo);
    NSLog(@"%@", editor.toolInfo.toolTreeDescription);
    
    CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:NO];
    tool.available = NO;
    
    //         tool = [editor.toolInfo subToolInfoWithToolName:@"CLRotateTool" recursive:YES];
    //         tool.available = NO;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLHueEffect" recursive:YES];
    tool.available = NO;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLTextTool" recursive:YES];
    tool.available = NO;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLSplashTool" recursive:YES];
    tool.available = NO;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLEffectTool" recursive:YES];
    tool.available = NO;
    
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLEmoticonTool" recursive:YES];
    tool.available = NO;
    
    tool = [editor.toolInfo subToolInfoWithToolName:@"CLResizeTool" recursive:YES];
    tool.available = NO;
    
    
    UINavigationController *navBar =[[UINavigationController alloc]initWithRootViewController:editor];
    [self presentViewController:navBar animated:NO completion:nil];
}
-(NSString*)getCurrentTime {
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Set the dateFormatter format
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    [dateFormatter setDateFormat:@"EEEMMddyyyyHHmmss"];
    // Get the date time in NSString
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    //  //NSLog(@"%@", dateInStringFormated);
    return dateInStringFormated;
    // Release the dateFormatter
    //[dateFormatter release];
}
- (void)cropAction {
    // if ([[choosen valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
    if (choosen.mediaType == PHAssetMediaTypeImage) {
        if (self.cropBlock) {
            self.cropBlock(self.imageScrollView.capture);
        }
        [self cancelButtonSelected];
    }else    if (choosen.mediaType == PHAssetMediaTypeVideo) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        VideoFilterViewController *videoVC = (VideoFilterViewController*)[storyboard instantiateViewControllerWithIdentifier:@"VideoFilterStoryBoardId"];
        [self.imageScrollView dealloci];
        [[PHImageManager defaultManager] requestAVAssetForVideo:choosen options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            NSURL *url = [(AVURLAsset*)avAsset URL];
            // do what you want with it
            videoVC.pathOfVideo = url.absoluteString;
            NSData *videoData=[NSData dataWithContentsOfURL:url];
            videoVC.videoData= videoData;
            [self.imageManager requestImageForAsset:choosen targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                videoVC.videoimgthumb =  result;
            }];
            
             dispatch_async(dispatch_get_main_queue(), ^{
                 UINavigationController *navBar =[[UINavigationController alloc]initWithRootViewController:videoVC];
                 [self presentViewController:navBar animated:NO completion:nil];
             });
        }];

    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGRect topFrame = self.topView.frame;
            CGFloat endOriginY = self.topView.frame.origin.y;
            if (endOriginY > beginOriginY) {
                topFrame.origin.y = (endOriginY - beginOriginY) >= 20 ? 0 : -(CGRectGetHeight(self.topView.bounds)-20-44);
            } else if (endOriginY < beginOriginY) {
                topFrame.origin.y = (beginOriginY - endOriginY) >= 20 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 0;
            }
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            [UIView animateWithDuration:.3f animations:^{
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }];
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            beginOriginY = self.topView.frame.origin.y;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGesture translationInView:self.view];
            CGRect topFrame = self.topView.frame;
            topFrame.origin.y = translation.y + beginOriginY;
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            
            if (topFrame.origin.y <= 0 && (topFrame.origin.y >= -(CGRectGetHeight(self.topView.bounds)-20-44))) {
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    CGRect topFrame = self.topView.frame;
    topFrame.origin.y = topFrame.origin.y == 0 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 0;
    
    CGRect collectionFrame = self.collectionView.frame;
    collectionFrame.origin.y = CGRectGetMaxY(topFrame);
    collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
    [UIView animateWithDuration:.3f animations:^{
        self.topView.frame = topFrame;
        self.collectionView.frame = collectionFrame;
    }];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.assetsFetchResults.count;
    return count;
    //return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TWPhotoCollectionViewCell";
    
    TWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    //NSLog(@"Image manager: Requesting FILL image for iPhone");
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(100, 100)
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  
                                  // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                  [cell.imageView setImage:result];
                              }];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        cell.time.hidden=YES;
    }else     if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.time.hidden=NO;
        cell.time.text= [self getDurationWithFormat:asset.duration];
    }
    return cell;
}


-(NSString*)getDurationWithFormat:(NSTimeInterval)duration
{
    NSInteger ti = (NSInteger)duration;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    //NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

- (NSString *)timeFormatted:(double)totalSeconds

{
    NSTimeInterval timeInterval = totalSeconds;
    long seconds = lroundf(timeInterval); // Modulo (%) operator below needs int or long
    int hour = 0;
    int minute = seconds/60.0f;
    int second = seconds % 60;
    if (minute > 59) {
        hour = minute/60;
        minute = minute%60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    }
    else{
        return [NSString stringWithFormat:@"%02d:%02d", minute, second];
    }
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    choosen=[self.assetsFetchResults objectAtIndex:indexPath.row];
    if (choosen.mediaType == PHAssetMediaTypeImage)  {
        
        [self.imageManager requestImageForAsset:choosen
                                     targetSize:PHImageManagerMaximumSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                      [self.imageScrollView displayImage:result];
                                  }];
    }
    else  if (choosen.mediaType == PHAssetMediaTypeVideo){
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:choosen options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    NSURL *URL = [(AVURLAsset *)asset URL];
                    [self.imageScrollView displayVideo:URL h:100  w:100];
                }
            });
        }];
    }
    
    if (self.topView.frame.origin.y != 0) {
        [self tapGestureAction:nil];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"velocity:%f", velocity.y);
    if (velocity.y >= 2.0 && self.topView.frame.origin.y == 0)
    {
        [self tapGestureAction:nil];
    }
}










- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate){
        if (scrollView==_collectionView) {
            CGRect topFrame = self.topView.frame;
            CGFloat endOriginY = self.topView.frame.origin.y;
            if (endOriginY > beginOriginY) {
                topFrame.origin.y = (endOriginY - beginOriginY) >= 20 ? 0 : -(CGRectGetHeight(self.topView.bounds)-20-44);
            } else if (endOriginY < beginOriginY) {
                topFrame.origin.y = (beginOriginY - endOriginY) >= 20 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 0;
            }
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            [UIView animateWithDuration:.3f animations:^{
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }];
        }
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView==_collectionView) {
        if (scrollView.contentOffset.y<=0) {
            CGRect topFrame = self.topView.frame;
            CGFloat endOriginY = self.topView.frame.origin.y;
            if (endOriginY > beginOriginY) {
                topFrame.origin.y = (endOriginY - beginOriginY) >= 20 ? 0 : -(CGRectGetHeight(self.topView.bounds)-20-44);
            } else if (endOriginY < beginOriginY) {
                topFrame.origin.y = (beginOriginY - endOriginY) >= 20 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 0;
            }
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            [UIView animateWithDuration:.3f animations:^{
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView==_collectionView) {
        if (scrollView.contentOffset.y<=0 && self.topView.frame.origin.y<0) {
            CGRect topFrame = self.topView.frame;
            topFrame.origin.y = -(scrollView.contentOffset.y) + topFrame.origin.y;
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            
            //            if (topFrame.origin.y <= 0 && (topFrame.origin.y >= -(CGRectGetHeight(self.topView.bounds)-20-44))) {
            self.topView.frame = topFrame;
            self.collectionView.frame = collectionFrame;
            //            }
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    beginOriginY=self.topView.frame.origin.y;
}
@end
