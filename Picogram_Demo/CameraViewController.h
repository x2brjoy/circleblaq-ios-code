//
//  CameraViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 4/21/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGShareViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define CAPTURE_FRAMES_PER_SECOND		20

@interface CameraViewController : UIViewController<UIScrollViewDelegate>

{
    BOOL WeAreRecording;
    
}
@property (retain) AVCaptureVideoPreviewLayer *PreviewLayer;



@property (nonatomic, strong) NSTimer *timer;

@property  int counter;


@property (weak, nonatomic) IBOutlet UIButton *libraryButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *photoButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *videoButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *frontCameraButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *takeVideoButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButtonOutlet;

- (IBAction)libraryButtonAction:(id)sender;
- (IBAction)photoButtonAction:(id)sender;
- (IBAction)videoButtonAction:(id)sender;
- (IBAction)frontCameraButtonAction:(id)sender;
- (IBAction)closeButtonAction:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)flashButtonAction:(id)sender;

-(IBAction)takeVideo:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *frameForCaptureImage;

@property(weak,nonatomic) UIImage *selectedImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;




@property UIImageView *previewView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

#define VIDEO_FILE @"test.mov"

@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;

- (IBAction)nextButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButtonOutlet;
- (IBAction)deleteButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonsView;
@property (weak, nonatomic) IBOutlet UIView *PressandholdTorecordMessageView;
@property (weak, nonatomic) IBOutlet UIView *viewWhenCameraPermissonDenied;
- (IBAction)enableCameraAccessButtonAction:(id)sender;

@end
