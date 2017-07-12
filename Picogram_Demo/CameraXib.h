//
//  CameraXib.h
//  Picogram
//
//  Created by Rahul Sharma on 4/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol shareViewDelegate <NSObject>
-(void)cancelButtonClicked;
@end

@interface CameraXib : UIView <UINavigationBarDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, weak) id <shareViewDelegate> delegate;
- (void)cameraView:(UIWindow *)window;

- (IBAction)cancelButon:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *frameForCaptureImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

// button actions

- (IBAction)takePhoto:(id)sender;
- (IBAction)frontCameraButtonAction:(id)sender;
- (IBAction)photoButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (strong,nonatomic) UIImagePickerController *imgpicker;
@end
