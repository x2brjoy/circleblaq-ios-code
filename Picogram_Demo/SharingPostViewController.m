//
//  SharingPostViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 23/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "SharingPostViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WebServiceConstants.h"
#import "TinderGenericUtility.h"
#import "Helper.h"
#import "ProgressIndicator.h"
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
#import  <Social/Social.h>
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import <MessageUI/MessageUI.h>
#import "FontDetailsClass.h"

@interface SharingPostViewController ()<UITextViewDelegate>
{
    NSString *shortUrl;
    NSString *apiEndpoint;
    UILabel *errorMessageLabelOutlet;
    UIButton *navShareButton;
    BOOL insta;
    BOOL sharingActive;
    //UILabel *
}
@property (nonatomic, retain) UIDocumentInteractionController *dic;
@end

@implementation SharingPostViewController
@synthesize dic;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbNotification:)
                                                 name:@"facebookCancel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterNotification:)
                                                 name:@"TwitterLoginFailed" object:nil];

    _postCaption.text = @"Write a caption...";
    _postCaption.textColor = [UIColor lightGrayColor];
    _postCaption.delegate = self;
    
    [_postImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(_postDetailsDic[@"thumbnailImageUrl"])] placeholderImage:[UIImage imageNamed:@"defaultpp"]];
    errorMessageLabelOutlet = [[UILabel alloc]initWithFrame:CGRectMake(0, -80, [UIScreen mainScreen].bounds.size.width, 30)];
    
    
    errorMessageLabelOutlet.backgroundColor = [UIColor colorWithRed:108/255.0f green:187/255.0f blue:79/255.0f alpha:1.0];
    errorMessageLabelOutlet.textColor = [UIColor whiteColor];
    
    
    errorMessageLabelOutlet.textAlignment = NSTextAlignmentCenter;
    //  [self.view bringSubviewToFront:errorMessageLabelOutlet];
    [errorMessageLabelOutlet setHidden:YES];
    [self.view addSubview:errorMessageLabelOutlet];
    
    [self createNavRightButton];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- Facebook Sharing
/////////////////facebookBtnAction////////////////////
- (IBAction)fbBtnAction:(id)sender {
    
    if (self.fbBtnOutlet.selected) {
        self.fbBtnOutlet.selected = NO;
        sharingActive = NO;
        
    }
    else {
        self.fbBtnOutlet.selected = YES;
        sharingActive = YES;
        [Helper checkFbLogin];
        
    }
    
    [self enableShareButton];
    
}
   /* _facebookLbl.textColor = [UIColor lightGrayColor];
    NSLog(@"Post Detail :%@",_postDetailsDic);
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showMessage:@"Posting.." On:self.view];
    
    if ([flStrForObj(_postDetailsDic[@"postsType"])  isEqualToString:@"0"]) {
        // NSString *mediaLink = [self getWebLinkForFeed:feed];
        
        NSString *caption;// = NSLocalizedString(@"Checkout this cool app",nil);
        
        if ([_postCaption.text isEqualToString:@"Write a caption..."]) {
             caption = _postCaption.textColor;
        }
        else
            caption = @"";
        
        NSString *picturelink = [Helper getWebLinkForFeed:_postDetailsDic];// _postDetailsDic[@"mainUrl"];
        
        //NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:picturelink]];
        
        NSMutableDictionary *params1 = [NSMutableDictionary dictionaryWithCapacity:3L];
        
        //[params1 setObject:videoData forKey:@"video.mov"];
        [params1 setObject:[NSURL URLWithString:picturelink] forKey:@"link"];
        [params1 setObject:NSLocalizedString(@"Created from Picogram.",nil) forKey:@"title"];
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
                 _facebookLbl.textColor = [UIColor blackColor];
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
  
}*/

/**
 *  NPost the media with its description on facebook
 *
 *  @param params mediatype,caption,mediaLink
 */

/*- (void) makeFBPostWithParams:(NSDictionary*)params
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
            _facebookLbl.textColor = [UIColor blackColor];
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
                                                _facebookLbl.textColor = [UIColor blackColor];
                                           });
                                       }
                                   }];
        
    }
    
}
*/

#pragma mark - TwitterSharing
/////////////////EmailAddresAction////////////////////
- (IBAction)twitterBtnAction:(id)sender {
    
    /*
    if (self.twitterBtnOutlet.selected) {
        self.twitterBtnOutlet.selected = NO;
        sharingActive = NO;
       
    }
    else {
        self.twitterBtnOutlet.selected =YES;
        sharingActive = YES;
        [Helper chkTwitterLogin];
    }
    
    [self enableShareButton];
    
    _twitterLbl.textColor = [UIColor lightGrayColor];
    NSString *mediaLink =[Helper getWebLinkForFeed:_postDetailsDic];//[@"mainUrl"];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                SLRequest *postRequest = nil;
                NSLog(@"Twitter Login User:%@",twitterAccount.username);
                NSLog(@"Twitter AccountType:%@",twitterAccount.accountType);
                
                // Post Text
                
                NSString *posttext = [NSString stringWithFormat:@"Shared via @Yayway %@",mediaLink];
                
                NSDictionary *message = @{@"status": posttext, @"wrap_links": @"true"};
                
                // URL
                NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                
                // Request
                postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:message];
                
                // Set Account
                postRequest.account = twitterAccount;
                
                // Post
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSLog(@"Twitter HTTP response: %li", (long)[urlResponse statusCode]);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                         _twitterLbl.textColor = [UIColor blackColor];
                            [self donePosting];
                        
                    });
                    
                }];
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"There is no Twitter account configured" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _twitterLbl.textColor = [UIColor blackColor];
                        [self donePosting];
                   
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
               
                    [self donePosting];
               
            });
        }
    }];
     */

}

- (IBAction)instagramButtonAction:(id)sender {
    if (self.instgramButtonOutlet.selected) {
        self.instgramButtonOutlet.selected = NO;
        sharingActive = NO;
        
    }
    else {
        self.instgramButtonOutlet.selected = YES;
        sharingActive = YES;
        [self instaAvailabilty];
    }
    
    [self enableShareButton];
}

-(void)enableShareButton {
    
    if (self.instgramButtonOutlet.selected || self.fbBtnOutlet.selected || self.twitterBtnOutlet.selected) {
        navShareButton.enabled = YES;
    }
    else {
        navShareButton.enabled = NO;
    }
}

#pragma mark
#pragma mark - navigation bar next button

- (void)createNavRightButton {
    
    navShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navShareButton setTitle:@"Share"
                    forState:UIControlStateNormal];
    [navShareButton setTitleColor:[UIColor colorWithRed:56/255.0f green:121/255.0f blue:240/255.0f alpha:1.0]
                         forState:UIControlStateNormal];
    
    [navShareButton setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateDisabled];
    
    [navShareButton setTitleColor:[UIColor colorWithRed:56/255.0f green:121/255.0f blue:240/255.0f alpha:1.0]
                         forState:UIControlStateHighlighted];
    
    navShareButton.titleLabel.font = [UIFont fontWithName:RobotoMedium size:18];
    [navShareButton setFrame:CGRectMake(0,0,50,30)];
    [navShareButton addTarget:self action:@selector(navshareButtonAction:)
             forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navShareButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
    
    navShareButton.enabled = NO;
}



- (void)navshareButtonAction:(UIButton *)sender {
    
    if ( sharingActive) {
        [[NSUserDefaults standardUserDefaults]setObject:@"posting" forKey:@"postKey"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    if (self.fbBtnOutlet.selected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper makeFBPostWithParams:_postDetailsDic];
        });
    }
    if (self.twitterBtnOutlet.selected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper twitterSharing:_postDetailsDic];
        });

    }
    if(self.instgramButtonOutlet.selected){
        
        if ([flStrForObj(_postDetailsDic[@"postsType"]) isEqualToString:@"0"]) {
            
          dispatch_async(dispatch_get_main_queue(), ^{
            NSString *path = [Helper instagramSharing:_postDetailsDic];
            
            dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
            dic.UTI = @"com.instagram.exclusivegram";
            dic.delegate = nil;
            
            dic.annotation = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Shared via @Picogram",nil) forKey:@"InstagramCaption"];
            [dic presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
              });
        }
        else
            [Helper videoOnInstagram:_postDetailsDic];
    }
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)emailAdressAction:(id)sender {
    
    MFMailComposeViewController *comp=[[MFMailComposeViewController alloc]init];
    [comp setMailComposeDelegate:self];
    if([MFMailComposeViewController canSendMail]) {
        [comp setToRecipients:[NSArray arrayWithObjects:@" ", nil]];
        [comp setSubject:NSLocalizedString(@"A message from Picogram",nil)];
        NSData *mediaData = nil;
        NSString *mediaFileLink =  _postDetailsDic[@"mainUrl"];
        //[comp setMessageBody:mediaFileLink isHTML:NO];
        [comp setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        if ([ flStrForObj(_postDetailsDic[@"postsType"]) isEqualToString:@"0"]) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaFileLink]]];
            mediaData = UIImageJPEGRepresentation(image, 1);
            
            if (mediaData) {
                [comp addAttachmentData:mediaData mimeType:@"image/jpeg" fileName:@"image.jpeg"];
            }
            else {
                [comp setMessageBody:mediaFileLink isHTML:NO];
                
            }
        }
        else {
            [comp setMessageBody:mediaFileLink isHTML:NO];
        }
        [self presentViewController:comp animated:YES completion:nil];
    }
    else {
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your device is not currently connected to an email account."delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alrt show];
    }
    
    
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //  ////NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //  ////NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            // ////NSLog(@"Mail not sent.");
            break;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - CopyLink
/////////////////copyLinkAction////////////////////
- (IBAction)copyLinkAction:(id)sender {
    [errorMessageLabelOutlet setHidden:NO];
    [self showingErrorAlertfromTop:@"Link copied to clipboard."];
    NSLog(@"copyShareURL :%@ ",_postDetailsDic[@"mainUrl"]);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *postId = [NSString stringWithFormat:@"%@",self.postDetailsDic[@"postId"]];
    NSString *copyWebUrl = [Helper makeWebPostLink:postId andUserName:self.postDetailsDic[@"postedByUserName"]];
    pasteboard.string = copyWebUrl;
}

#pragma mark-Fliker Sharing
/////////////////flickerBtnAction////////////////////
//- (IBAction)flickerBtnAction:(id)sender {
 -(void)instaAvailabilty
    { NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        insta = YES;
    }
    else
    {
        [Helper showAlertWithTitle:NSLocalizedString(@"Message",nil) Message:NSLocalizedString(@"You don't have Instagram installed. Download instagram app to get more functionality.",nil)];
        
        self.instgramButtonOutlet.selected = NO;
    }
    
}


#pragma mark - TextViewDelegates

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    if ([_postCaption.text isEqualToString:@"Write a caption..."]) {
        _postCaption.text = @"";
        _postCaption.textColor = [UIColor blackColor]; //optional
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    if ([_postCaption.text isEqualToString:@""]) {
        _postCaption.text = @"Write a caption...";
        _postCaption.textColor = [UIColor lightGrayColor]; //optional
    }
    
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
    return YES;
          }
    
    [textView resignFirstResponder];
    return NO;
}
-(void)donePosting
{
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
}

-(void)showingErrorAlertfromTop:(NSString *)message {
    [errorMessageLabelOutlet setHidden:NO];
    
    [errorMessageLabelOutlet setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    [self.view layoutIfNeeded];
    errorMessageLabelOutlet.text = message;
    
    /**
     *  changing the error message view position if user enter  wrong number
     */
    
    [UIView animateWithDuration:0.4 animations:
     ^ {
         // self.errorMessageViewTopConstraint.constant = -0;
         [self.view layoutIfNeeded];
     }];
    
    int duration = 2; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:
         ^ {
             [errorMessageLabelOutlet setFrame:CGRectMake(0, -100, [UIScreen mainScreen].bounds.size.width, 30)];
             [errorMessageLabelOutlet setHidden:YES];
             [self.view layoutIfNeeded];
         }];
    });
}


-(void)fbNotification:(NSNotification *)noti {
    self.fbBtnOutlet.selected = NO;
}

-(void)twitterNotification:(NSNotification *)noti {
    
    dispatch_async(dispatch_get_main_queue(), ^{
         self.twitterBtnOutlet.selected = NO;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"There is no Twitter account configured" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    });
}

@end
