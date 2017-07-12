//
//  CameraViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/1/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//


#import "PGCameraViewController.h"

@interface PGCameraViewController ()

@end

@implementation PGCameraViewController

AVCaptureSession *session;
AVCaptureStillImageOutput * stillImageOutput;


#pragma mark
#pragma mark - view controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    session =[[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    AVCaptureDevice *inputDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceinput =[AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];

   if([session canAddInput:deviceinput])
   {
       [session addInput:deviceinput];
   }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootlayer =[[self  view] layer];
    [rootlayer setMasksToBounds:YES];
    CGRect frame =self.frameForCaptureImage.frame;
    [previewLayer setFrame:frame];
    [rootlayer insertSublayer:previewLayer atIndex:0 ];
    stillImageOutput =[[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outPutSettings =[[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    
    [stillImageOutput setOutputSettings:outPutSettings];
    [session addOutput:stillImageOutput];
    [session startRunning];
}


#pragma mark
#pragma mark - buttons

- (IBAction)takePhoto:(id)sender
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
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
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
    {
        if (imageDataSampleBuffer)
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            self.imageView.image = image;
        }
    }];
}


-(IBAction)frontCameraButtonAction:(id)sender

{
    
}


@end
