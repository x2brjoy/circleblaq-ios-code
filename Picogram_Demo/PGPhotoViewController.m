//
//  PhotoViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/1/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGPhotoViewController.h"
#import "TWPhotoPickerController.h"

@interface PGPhotoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate >
@property (strong,nonatomic) UIImagePickerController *imgpicker;
@end

@implementation PGPhotoViewController

#pragma mark
#pragma mark - viewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    
    photoPicker.cropBlock = ^(UIImage *image)
    {
        [self.profileImage setImage:image];
        
    };
    
    [self showViewController:photoPicker sender:nil];
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
@end
