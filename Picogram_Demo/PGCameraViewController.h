//
//  CameraViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/1/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PGCameraViewController : UIViewController

//button outlets

@property (weak, nonatomic) IBOutlet UIView *frameForCaptureImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


// button actions

- (IBAction)takePhoto:(id)sender;
- (IBAction)frontCameraButtonAction:(id)sender;

@end
