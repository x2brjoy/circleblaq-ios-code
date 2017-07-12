//
//  CameraXib.m
//  Picogram
//
//  Created by Rahul Sharma on 4/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "CameraXib.h"
#import "TWPhotoPickerController.h"

@implementation CameraXib

AVCaptureSession *sesion;
AVCaptureStillImageOutput * stilImageOutput;
@synthesize delegate;


- (instancetype)init {
    
    self = [super init];
    self = [[[NSBundle mainBundle] loadNibNamed:@"CameraViewXib"
                                          owner:self
                                        options:nil] firstObject];
    
    [self photoStarted];
    
    
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    
    photoPicker.cropBlock = ^(UIImage *image)
    
    {
        [self.profileImage setImage:image];
        
    };
    
    return self;
}

#pragma mark
#pragma mark - image picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    NSData *dataimage = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1);
    UIImage *im =[[UIImage alloc] initWithData:dataimage];
    [self.profileImage setImage:im];
    [self.imgpicker dismissViewControllerAnimated:YES completion:nil];
}


- (void)cameraView:(UIWindow *)window {
    
    self.frame = window.frame;
    [window addSubview:self];
    [self layoutIfNeeded];
  }

- (IBAction)cancelButon:(id)sender {
    [delegate cancelButtonClicked];
}
- (IBAction)photoButtonAction:(id)sender {
   
    
}

#pragma mark
#pragma mark - buttons

- (IBAction)takePhoto:(id)sender
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stilImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    [stilImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if (imageDataSampleBuffer)
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *image = [UIImage imageWithData:imageData];
            // self.imageView.image = image;
         }
     }];
 }

-(void)photoStarted
{
    sesion =[[AVCaptureSession alloc] init];
    [sesion setSessionPreset:AVCaptureSessionPresetPhoto];
    AVCaptureDevice *inputDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceinput =[AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if([sesion canAddInput:deviceinput])
    {
        [sesion addInput:deviceinput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:sesion];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootlayer =[self layer];
    [rootlayer setMasksToBounds:YES];
    CGRect frame =self.frameForCaptureImage.frame;
    [previewLayer setFrame:frame];
    [rootlayer insertSublayer:previewLayer atIndex:0 ];
    stilImageOutput =[[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outPutSettings =[[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    
    [stilImageOutput setOutputSettings:outPutSettings];
    [sesion addOutput:stilImageOutput];
    [sesion startRunning];
}


@end
