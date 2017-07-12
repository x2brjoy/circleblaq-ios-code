//
//  PostSharingViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 19/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PostSharingViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TinderGenericUtility.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareVideo.h>
#import <FBSDKShareKit/FBSDKShareOpenGraphContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareVideoContent.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKShareKit/FBSDKShareAPI.h>
#import <FBSDKShareKit/FBSDKSharePhotoContent.h>
#import "UIImageView+AFNetworking.h"
#import "UIImage+GIF.h"
#import "ProgressIndicator.h"


@interface PostSharingViewController ()

@end

@implementation PostSharingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [_postImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(_postDetailsDic[@"profilePicUrl"])] placeholderImage:[UIImage imageNamed:@"defaultpp"]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fbBtnAction:(id)sender {
   
    NSLog(@"Post Detail :%@",_postDetailsDic);
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showMessage:@"Posting.." On:self.view];
    
    if ([flStrForObj(_postDetailsDic[@"postsType"])  isEqualToString:@"0"]) {
        // NSString *mediaLink = [self getWebLinkForFeed:feed];
        
        NSString *caption = @"";//NSLocalizedString(@"Checkout this cool app",nil);
        
        // NSString *description;
        
        NSString *picturelink = _postDetailsDic[@"mainUrl"];
        
        //NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:picturelink]];
        
        NSMutableDictionary *params1 = [NSMutableDictionary dictionaryWithCapacity:3L];
        
        //[params1 setObject:videoData forKey:@"video.mov"];
        [params1 setObject:[NSURL URLWithString:picturelink] forKey:@"link"];
        [params1 setObject:caption forKey:@"title"];
        [params1 setObject:caption forKey:@"description"];
        
        
        [self makeFBPostWithParams:params1];
    }
    else{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock = ^(NSURL *newURL, NSError *error) {
            if (error)
            {
                NSLog( @"Error writing image with metadata to Photo Library: %@", error );
            }
            else
            {
                NSLog(@"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
                
                FBSDKShareVideo* video = [FBSDKShareVideo videoWithVideoURL:newURL];
                
                FBSDKShareVideoContent* content = [[FBSDKShareVideoContent alloc] init];
                content.video = video;
                [FBSDKShareAPI shareWithContent:content delegate:nil];
            }
        };
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Downloading Started");
            NSString *urlToDownload = _postDetailsDic[@"mainUrl"];
            NSURL  *url = [NSURL URLWithString:urlToDownload];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
                
                
                
                
                //saving is done on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:filePath atomically:YES];
                    NSLog(@"File Saved !");
                    
                    
                    NSURL *videoURL = [NSURL URLWithString:filePath];
                    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL])
                    {
                        [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:videoWriteCompletionBlock];
                    }
                    
                    
                });
            }
            
        });
        
        
    }

    
    
    
}
- (IBAction)emailAdressAction:(id)sender {
}

- (IBAction)copyLinkAction:(id)sender {
}

- (IBAction)flickerBtnAction:(id)sender {
}


-(void)shareToFacebook:(NSInteger )selectedSection {
    NSLog(@"SHAREtO FB of index :%ld ",(long)selectedSection);
    
   // NSDictionary *dic = responseData[selectedSection];
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showMessage:@"Posting.." On:self.view];
    
    if ([flStrForObj(_postDetailsDic[@"postsType"] )isEqualToString:@"0"]) {
        // NSString *mediaLink = [self getWebLinkForFeed:feed];
        
        NSString *caption = @"";//NSLocalizedString(@"Checkout this cool app",nil);
        
        // NSString *description;
        
        NSString *picturelink = _postDetailsDic[@"mainUrl"];
        
        //NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:picturelink]];
        
        NSMutableDictionary *params1 = [NSMutableDictionary dictionaryWithCapacity:3L];
        
        //[params1 setObject:videoData forKey:@"video.mov"];
        [params1 setObject:[NSURL URLWithString:picturelink] forKey:@"link"];
        [params1 setObject:caption forKey:@"title"];
        [params1 setObject:caption forKey:@"description"];
        
        
        [self makeFBPostWithParams:params1];
    }
    else{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock = ^(NSURL *newURL, NSError *error) {
            if (error)
            {
                NSLog( @"Error writing image with metadata to Photo Library: %@", error );
            }
            else
            {
                NSLog(@"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
                
                FBSDKShareVideo* video = [FBSDKShareVideo videoWithVideoURL:newURL];
                
                FBSDKShareVideoContent* content = [[FBSDKShareVideoContent alloc] init];
                content.video = video;
                [FBSDKShareAPI shareWithContent:content delegate:nil];
            }
        };
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Downloading Started");
            NSString *urlToDownload = _postDetailsDic[@"mainUrl"];
            NSURL  *url = [NSURL URLWithString:urlToDownload];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
                
                
                
                
                //saving is done on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:filePath atomically:YES];
                    NSLog(@"File Saved !");
                    
                    
                    NSURL *videoURL = [NSURL URLWithString:filePath];
                    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL])
                    {
                        [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:videoWriteCompletionBlock];
                    }
                    
                    
                });
            }
            
        });
        
        
    }
    
}


/**
 *  NPost the media with its description on facebook
 *
 *  @param params mediatype,caption,mediaLink
 */

- (void) makeFBPostWithParams:(NSDictionary*)params
{
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:params[@"link"]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
            sharePhoto.caption = params[@"title"]; //@"Test Caption";
            sharePhoto.image = image;//[UIImage imageNamed:@"BGI.jpg"];
            FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
            content.photos = @[sharePhoto];
            
            [FBSDKShareAPI shareWithContent:content delegate:nil];
        });
        
    }
    else{
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithPublishPermissions:@[@"publish_actions"]
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           NSLog(@"Process error");
                                       } else if (result.isCancelled)
                                       {
                                           NSLog(@"Cancelled");
                                       }
                                       else
                                       {
                                           NSLog(@"Logged in");
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
                                               sharePhoto.caption = params[@"title"]; //@"Test Caption";
                                               sharePhoto.image = image;//[UIImage imageNamed:@"BGI.jpg"];
                                               
                                               
                                               FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
                                               content.photos = @[sharePhoto];
                                               
                                               [FBSDKShareAPI shareWithContent:content delegate:nil];
                                           });
                                       }
                                   }];
        
    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
