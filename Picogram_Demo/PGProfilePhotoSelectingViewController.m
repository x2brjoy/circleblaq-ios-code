//  ProfilePhotoSelectingViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/17/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGProfilePhotoSelectingViewController.h"
#import "TWPhotoPickerController.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "Cloudinary/Cloudinary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FBLoginHandler.h"
#import "UIImageView+WebCache.h"
#import "Helper.h"
#import <AVFoundation/AVFoundation.h>
#import "TinderGenericUtility.h"
#import "AskingPermissonViewController.h"
#import "Helper.h"

@import FirebaseInstanceID;
@interface PGProfilePhotoSelectingViewController ()<FBLoginHandlerDelegate,CLUploaderDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WebServiceHandlerDelegate,UIActionSheetDelegate> {
    BOOL userNameLength;
    BOOL signUpByPhoneNumber;
    CLCloudinary *cloudinary;
    NSString *profilePicUrl;
    NSString *deviceId;
    NSDictionary *cloundinaryCreditinals;
    NSString * ThumbnailimagePath;
    
    BOOL updateFbImageOnlyFirstTime;
}

@property (strong,nonatomic) UIImagePickerController *imgpicker;
@end

int heightkboard;
@implementation PGProfilePhotoSelectingViewController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self changingThePhoneLogoImageHeightDependingOnDevice];
    [self addingPlaceHolderColorForTextfield];
    [self addingBoarderForButton];
    [self addingNotificationForTextFields];
    [self gettingDeviceid];
    
    //setting BackGroundColor For divider.
    _dividerViewOutlet.backgroundColor=[UIColor clearColor];
    //intially nextbutton must be enable.(beacuse intially there is no text in textfields.)
    [_nextButtonOutlet setEnabled:NO];
    //hiding activity view intially.
    self.activityVIewIndicatorOutlet.hidden = YES;
    //getting facebook id for registering.
    [self gettingCloudinaryCredntials];
    
    updateFbImageOnlyFirstTime = YES;
    
    NSString *token = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", token);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:mdeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
 }

-(void) gettingCloudinaryCredntials{
    cloundinaryCreditinals =[[NSUserDefaults standardUserDefaults]objectForKey:cloudinartyDetails];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.SignUpType = self.codeForSignUpType;
    self.emailForRegistration = self.userEnteredEmail;
    self.PhoneNumberForRegistration =self.userEnteredPhoneNumber;
    if (!self.PhoneNumberForRegistration ) {
        self.PhoneNumberForRegistration = @"9010";
    }
    if (!self.emailForRegistration) {
        self.emailForRegistration = @"bav";
    }
    if (!self.faceBookUniqueIdOfUserToRegister) {
         self.faceBookUniqueIdOfUserToRegister = @"802";
         self.faceBookEmailIdOfUserToRegister = @"bav";
}
    
    if ([self.SignUpType isEqualToString:@"1"] && updateFbImageOnlyFirstTime){
        [_profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:self.profilepicurlFb]];
         self.nameTextField.text = flStrForObj(self.fullNameFromGb);
        [self.view layoutIfNeeded];
        _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
        _profileImageViewOutlet.clipsToBounds = YES;
    }
}

/*--------------------------------------------*/
#pragma mark
#pragma mark - methodDefinationsInViewDidload
/*--------------------------------------------*/

-(void)changingThePhoneLogoImageHeightDependingOnDevice {
    if(CGRectGetHeight(self.view.frame) !=480 && CGRectGetHeight(self.view.frame) !=568) {
        _addProfileImageHeightConstraintOutlet.constant =175;
        _addProfileImageWidthConstraintOutlet.constant =175;
        _addProfileImageButtonWidthConstraintOutlet.constant =175;
        _addProfileImageButtonHeightConstraintOutlet.constant =175;
    }
}

-(void)addingPlaceHolderColorForTextfield {
    /**
     *   giving color for place holder text color for name and password textfields
     */
    [self.userNameTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                      forKeyPath:@"_placeholderLabel.textColor"];
    [self.passWordTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                          forKeyPath:@"_placeholderLabel.textColor"];
    [self.nameTextField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]
                      forKeyPath:@"_placeholderLabel.textColor"];
    
    _nextButtonOutlet.layer.cornerRadius = 5;
    _nextButtonOutlet.clipsToBounds = YES;
    
}
-(void)addingBoarderForButton {
    /**
     *  setting login button boareder and color for boarder.
     */
    [[_nextButtonOutlet layer] setBorderWidth:1.0f];
    [[_nextButtonOutlet layer] setBorderColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.13].CGColor];
    
}
-(void)addingNotificationForTextFields {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_userNameTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_passWordTextField];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullNameTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:_nameTextField];
    
    
}

-(void)gettingDeviceid {
    //getting userdeviceid
    
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        deviceId = [oNSUUID UUIDString];
    } else
    {
        deviceId = [oNSUUID UUIDString];
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:mDeviceId];
}

/*--------------------------------------*/
#pragma mark
#pragma mark - textfields
/*--------------------------------------*/



-(void)fullNameTextFieldChanged:(id)sender {
    
    if ([self checkForMandatoryField]) {
        [_nextButtonOutlet setEnabled:YES];
        [_nextButtonOutlet setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:1.0] forState:UIControlStateHighlighted];
    }
    else {
        [_nextButtonOutlet setEnabled:NO];
        [_nextButtonOutlet setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.2] forState:UIControlStateHighlighted];
    }

}

-(void)textFieldTextChanged:(id)sender {
    
    NSString *convertString = self.userNameTextField.text;
    self.userNameTextField.text = [convertString lowercaseString];
   
    if ([convertString containsString:@" "]) {
        if ([self.userNameTextField.text length] > 0) {
            self.userNameTextField.text = [self.userNameTextField.text substringToIndex:[self.userNameTextField.text length] - 1];
            NSString *addUnderScore = [self.userNameTextField.text stringByAppendingString:@"_"];
            self.userNameTextField.text = addUnderScore;
        }
    }
    
  
    if ([self checkForMandatoryField]) {
        [_nextButtonOutlet setEnabled:YES];
        [_nextButtonOutlet setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:1.0] forState:UIControlStateHighlighted];
    }
    else {
        [_nextButtonOutlet setEnabled:NO];
        [_nextButtonOutlet setTitleColor:[UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.2] forState:UIControlStateHighlighted];
    }
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!string.length) {
        userNameLength = NO;
    }
    else {
        userNameLength = YES;
    }

    if(textField == _userNameTextField) {
        if(_userNameTextField.text.length == 2) {
            if (range.location < 2 ) {
                _correctCheckmarkImgaeViewOutlet.image=nil;
                _refershImageViewOutlet.image=nil;
                _dividerViewOutlet.backgroundColor=[UIColor clearColor];
            }
        }
    }
    
    if(textField == _userNameTextField) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
        
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        if ([string isEqualToString:filtered]) {
            textField.tintColor = [UIColor blueColor];
        }
        else {
            textField.tintColor = [UIColor redColor];
        }
        return [string isEqualToString:filtered];
    }
    return YES;
}


/**
 *   this user defined method called by textField shouldChangeCharactersInRange delegate method and it is bool vale
 *  @return  yes if user enter any details in textfields and NO if the textfields nameTextField,passWordTextField are empty.
 */
- (BOOL)checkForMandatoryFieldForImage {
    if ( _userNameTextField.text.length < 1) {
        return NO;
    }
     return YES;
}
/**
 *   this user defined method called by textField shouldChangeCharactersInRange delegate method and it is bool vale
 *  @return  yes if user enter any details in textfields and NO if the textfields nameTextField,passWordTextField are empty.
 */
- (BOOL)checkForMandatoryField {
    if ( _passWordTextField.text.length != 0 && _userNameTextField.text.length !=0 && _nameTextField.text.length !=0 ) {
          return YES;
    }
    return NO;
}
/**
 *  dismissing the keyboard.
 */
-(void)dismissKeyboard {
    
    [UIView animateWithDuration:0.4 animations:
     ^ {
         
         [self.nameTextField resignFirstResponder];
         [self.userNameTextField resignFirstResponder];
         [self.passWordTextField resignFirstResponder];
         
         CGRect frameOfView = self.view.frame;
         frameOfView.origin.y = 0;
         self.view.frame = frameOfView;
        
     }];
}

/**
 *  the method  will called when user taps keyboard return button.
 *  when user taps retirn button the next textfield will respond and at last textfield the keyboard will hide after clicking on return button.
 *
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
        if (textField == _nameTextField) {
            [_nameTextField resignFirstResponder];
            [_userNameTextField becomeFirstResponder];
            float maxY = CGRectGetMaxY(_passWordTextField.frame) +heightkboard ;
            float reminder = CGRectGetHeight(self.view.frame) - maxY;
            if (reminder < 0) {
                [UIView animateWithDuration:0.4 animations:
                 ^ {
                CGRect frameOfView = self.view.frame;
                frameOfView.origin.y = reminder ;
                self.view.frame = frameOfView;
                     

                 }];
            }
        }
        else if (textField == _userNameTextField) {
            [_userNameTextField resignFirstResponder];
            [_passWordTextField becomeFirstResponder];
            float maxY = CGRectGetMaxY(_nextButtonOutlet.frame) +heightkboard ;
            float reminder = CGRectGetHeight(self.view.frame) - maxY;
            if (reminder < 0) {
                [UIView animateWithDuration:0.4 animations:
                 ^ {
                     CGRect frameOfView = self.view.frame;
                     frameOfView.origin.y = reminder ;
                     self.view.frame = frameOfView;
                     
                 }];
            }
        }
        else if (textField ==_passWordTextField) {
            
            [UIView animateWithDuration:0.4 animations:
             ^ {
                 
                 CGRect frameOfView = self.view.frame;
                 frameOfView.origin.y = 0;
                 frameOfView.origin.x=0;
                 self.view.frame = frameOfView;
                 
                 [_passWordTextField resignFirstResponder];

                 
             }];
        }
    return YES;
}

/*--------------------------------------*/
#pragma mark
#pragma mark - button actions.
/*--------------------------------------*/
/**
 *  this button action performed when user taps on image select  and here the button action is showing gallery.
 */
- (IBAction)imageSelectButtonAction:(id)sender {
    
    [self dismissKeyboard];
        UIActionSheet *acctionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Import from Facebook",@"Take Photo",@"Choose From Library", nil];
   [acctionSheet showInView:self.view];
}
/**
 *  this button action performed when user taps on signIn button  and view changing to signin view controller.
 */
- (IBAction)signInButtonAction:(id)sender {
     //[self performSegueWithIdentifier:@"profileToSignInSegue" sender:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
/**
 *  this button action performed when user taps on next button  and view changing to profile  view controller.
 */

- (IBAction)nextButtonAction:(id)sender {
    if (self.privacyPolicyAgreedBUttonOutlet.selected) {
        [UIView animateWithDuration:0.2 animations:^ {
            CGRect frameOfView = self.view.frame;
            frameOfView.origin.y = 0;
            self.view.frame = frameOfView;
            [self.view layoutIfNeeded];
        }  completion:^(BOOL finished) {
            UIAlertView *alloc = [[UIAlertView alloc] initWithTitle:@"" message:@"Agree to our Terms and Privacy Policy" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alloc show];
        }
       ];
    }
    else {
        [self dismissKeyboard];
        
        [self enableOrDisAbleTextField:NO];
        [self.nextButtonOutlet setTitle:@"" forState:UIControlStateNormal];
        self.activityVIewIndicatorOutlet.hidden = NO;
        [self.activityVIewIndicatorOutlet startAnimating];
        
        if (ThumbnailimagePath) {
            [self uploadingImageToCloudinary:ThumbnailimagePath];
        }
        else {
            [self requestForSignUp];
        }
    }
}

-(void)enableOrDisAbleTextField:(BOOL)editStyle {
    [self.nameTextField setEnabled:editStyle];
    [self.userNameTextField setEnabled:editStyle];
    [self.passWordTextField setEnabled:editStyle];
    [self.privacyPolicyAgreedBUttonOutlet setEnabled:editStyle];
}

-(void)requestForSignUp {
    NSString *phoneNumberForRegistering =[[NSUserDefaults standardUserDefaults]
                                          stringForKey:@"phoneNumberOfUser"];
    
    [self.nextButtonOutlet setTitle:@"" forState:UIControlStateNormal];
    if([profilePicUrl length] ==0 ) {
        profilePicUrl = @"defaultUrl";
    }
    
    NSDictionary *requestDict;
    switch ([self.SignUpType integerValue]) {
        case 1:
        {
            requestDict = @{
                            mUserName    : _userNameTextField.text,
                            mfullName :_nameTextField.text,
                            mPswd        :_passWordTextField.text,
                            mDeviceType  :@"1",
                            mDeviceId    :deviceId,
                            mProfileUrl  :flStrForObj(_profilepicurlFb),
                            mSignUpType  :@"1",
                            mpushToken   :flStrForObj([Helper deviceToken]),
                            mfbuniqueid  : self.faceBookUniqueIdOfUserToRegister,
                            mEmail       : self.faceBookEmailIdOfUserToRegister,
                            };
        }
            break;
        case 2:
        {
            requestDict = @{
                            mUserName    : _userNameTextField.text,
                            mfullName :_nameTextField.text,
                            mPswd        :_passWordTextField.text,
                            mDeviceType  :@"1",
                            mDeviceId    :deviceId,
                            mProfileUrl  :profilePicUrl,
                            mSignUpType  :@"2",
                            mpushToken   :flStrForObj([Helper deviceToken]),
                            mEmail       :self.emailForRegistration
                            };
        }
            break;
            
        default:
        {
            requestDict = @{
                            mUserName    : _userNameTextField.text,
                            mfullName :_nameTextField.text,
                            mPswd        :_passWordTextField.text,
                            mDeviceType  :@"1",
                            mDeviceId    :deviceId,
                            mProfileUrl  :profilePicUrl,
                            mSignUpType  :@"3",
                            mpushToken   :flStrForObj([Helper deviceToken]),
                            mphoneNumber :phoneNumberForRegistering
                            };
        }
            break;
    }
    [WebServiceHandler newRegistration:requestDict andDelegate:self];
}

- (IBAction)refreshButtonAction:(id)sender {
    _userNameTextField.text=@"";
    _refershImageViewOutlet.image = nil;
    _correctCheckmarkImgaeViewOutlet.image = nil;
     _dividerViewOutlet.backgroundColor=[UIColor clearColor];
}

/*--------------------------------------*/
#pragma mark
#pragma mark -  action sheet
/*--------------------------------------*/

//uiaction sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Import from Facebook"]) {
        //request for fb.
        FBLoginHandler *handler = [FBLoginHandler sharedInstance];
        [handler loginWithFacebook:self];
        [handler setDelegate:self];
    }
    if ([buttonTitle isEqualToString:@"Take Photo"]) {
        [self checkCameraPermissionsStatus];
  }
    if ([buttonTitle isEqualToString:@"Choose From Library"]) {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            //NSLog(@"%zd", [group numberOfAssets]);
            
            [self openCustomLibrary];
            
        } failureBlock:^(NSError *error) {
            if (error.code == ALAssetsLibraryAccessUserDeniedError) {
                NSLog(@"user denied access, code: %zd", error.code);
                [self galleryPermissionDenied];
            } else {
                NSLog(@"Other error code: %zd", error.code);
            }
        }];
       }
    if ([buttonTitle isEqualToString:@"Cancel"]) {
    }
}

-(void)openCustomLibrary {
    TWPhotoPickerController *photoPickr = [[TWPhotoPickerController alloc] init];
     photoPickr.viewFromProfileSelector = @"itisForProfilePhoto";
    photoPickr.cropBlock = ^(UIImage *image) {
        
        updateFbImageOnlyFirstTime = NO;
        
        [self.profileImageViewOutlet setImage:image];
        
        UIImage  *selectedProfileThumbNailImage = [self imageWithImage:image scaledToSize:CGSizeMake(50,50)];
        
        NSString *imageName = [NSString stringWithFormat:@"%@%@.png",@"Image",[self getCurrentTime]];
        NSData *data = UIImagePNGRepresentation(image);
        //to get the image path.
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        [data writeToFile:imagePath atomically:NO];
        
        NSData *thumbNaildata = UIImagePNGRepresentation(selectedProfileThumbNailImage);
        NSString *thumbNailimageName = [NSString stringWithFormat:@"%@%@.png",@"ThumbnailImage",[self getCurrentTime]];
        //to get the image path.
        NSArray* Thumbnailpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* thumabNaildocumentsDirectory = [Thumbnailpaths objectAtIndex:0];
        ThumbnailimagePath = [thumabNaildocumentsDirectory stringByAppendingPathComponent:thumbNailimageName];
        [thumbNaildata writeToFile:ThumbnailimagePath atomically:NO];
        
        [self.view layoutIfNeeded];
        _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
        _profileImageViewOutlet.clipsToBounds = YES;
       
    };
    [self presentViewController:photoPickr animated:YES completion:NULL];
}


-(void)checkCameraPermissionsStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(status == AVAuthorizationStatusAuthorized) { // authorized
        [self openCamera];
    }
    else if(status == AVAuthorizationStatusDenied){ // denied
        [self cameraPermissionDenied];
    }
    else if(status == AVAuthorizationStatusRestricted){ // restricted
        
        
    }
    else if(status == AVAuthorizationStatusNotDetermined){ // not determined
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){ // Access has been granted ..do something
                 [self openCamera];
            } else { // Access denied ..do something
                 [self cameraPermissionDenied];
            }
        }];
    }
}

-(void)cameraPermissionDenied {
    //askingPermissionVcStoryBoardId
    AskingPermissonViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"askingPermissionVcStoryBoardId"];
    newView.title = @"Take Photos With Picogram";
    newView.message = @"Allow access to your camera to start taking photos with the picogram app. ";
    newView.buttonTitle =@"Enable Camera Access";
    newView.navBarTitle = @"Photo";
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)galleryPermissionDenied {
    AskingPermissonViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"askingPermissionVcStoryBoardId"];
    newView.title = @"Please Allow Access to your photos";
    newView.message = @"This allows picogram to share photos from your library and save photos to your camera roll.";
    newView.navBarTitle = @"";
    newView.buttonTitle =@"Enable Library Access";
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)openCamera {
#if TARGET_IPHONE_SIMULATOR
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"IN SIMULATOR CAMERA IS NOT AVAILABLE" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#else
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Call UI related operations
        self.imgpicker = [[UIImagePickerController alloc] init];
        self.imgpicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imgpicker.delegate =self;
        [self presentViewController:self.imgpicker animated:YES completion:nil];
    });
#endif
}

/*-----------------------------------------*/
#pragma mark
#pragma mark - image picker(camera photo)
/*-----------------------------------------*/

//image picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    NSData *dataimage = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1);

    UIImage *selectedProfileImage =[[UIImage alloc] initWithData:dataimage];
    
    UIImage  *selectedProfileThumbNailImage = [self imageWithImage:selectedProfileImage scaledToSize:CGSizeMake(50,50)];
    
    NSData *data = UIImagePNGRepresentation(selectedProfileImage);
    NSString *imageName = [NSString stringWithFormat:@"%@%@.png",@"Image",[self getCurrentTime]];
    //to get the image path.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    [data writeToFile:imagePath atomically:NO];
    
    
    NSData *thumbNaildata = UIImagePNGRepresentation(selectedProfileThumbNailImage);
    NSString *thumbNailimageName = [NSString stringWithFormat:@"%@%@.png",@"ThumbnailImage",[self getCurrentTime]];
    //to get the image path.
    NSArray* Thumbnailpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* thumabNaildocumentsDirectory = [Thumbnailpaths objectAtIndex:0];
    ThumbnailimagePath = [thumabNaildocumentsDirectory stringByAppendingPathComponent:thumbNailimageName];
    [thumbNaildata writeToFile:ThumbnailimagePath atomically:NO];
    
    // storing the captured image to gallery.(optional)
    UIImage *storingImage = [[UIImage alloc] initWithData:data]; // if u want to store original captured image then keep dataimage instead of data.
    [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[storingImage CGImage] orientation:(ALAssetOrientation)[storingImage imageOrientation] completionBlock:nil];
    //uploading image to cloudinary.
    
    //setting image to the imageview and converting into rounded.
    [self.profileImageViewOutlet setImage:selectedProfileImage];
    [self.view layoutIfNeeded];
    _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
    _profileImageViewOutlet.clipsToBounds = YES;
    [self.imgpicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadingImageToCloudinary:(NSString *)imagePath {
    CLCloudinary *mobileCloudinary = [[CLCloudinary alloc] init];
    [mobileCloudinary.config setValue:cloundinaryCreditinals[@"response"][@"cloudName"] forKey:@"cloud_name"];
    CLUploader* mobileUploader = [[CLUploader alloc] init:mobileCloudinary delegate:self];
    
    [mobileUploader upload:imagePath options:@{
                                               @"signature":cloundinaryCreditinals[@"response"][@"signature"],
                                               @"timestamp": cloundinaryCreditinals[@"response"][@"timestamp"],
                                               @"api_key": cloundinaryCreditinals[@"response"][@"apiKey"],
                                               }];
    
}

/*--------------------------------------------*/
#pragma mark
#pragma mark - imageResizing.
/*--------------------------------------------*/

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

/*--------------------------------------------*/
#pragma mark
#pragma mark - cloudinaryImageUploadingDelegates.
/*--------------------------------------------*/

- (void) uploaderSuccess:(NSDictionary*)result context:(id)context {
    NSString* publicId = [result valueForKey:@"public_id"];
    NSLog(@"Upload success. Public ID=%@, Full result=%@", publicId, result);
    profilePicUrl = result[@"secure_url"];
    [self requestForSignUp];
}


-(void)uploaderError:(NSString*)result code:(NSInteger )code context:(id)context {
    NSLog(@"Upload error: %@, %ld", result, (long)code);
}

- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {
    NSLog(@"Upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
    
}

/*--------------------------------------*/
#pragma mark
#pragma mark - status bar
/*--------------------------------------*/

/**
 *  method used to hide the status bar or not.
 *
 *  @return YES means it hides the status bar and if it is NO then shows status bar.
 */
- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*--------------------------------------*/
#pragma mark
#pragma mark - tapGesture
/*--------------------------------------*/

- (IBAction)tapGestureAction:(id)sender {
    [self dismissKeyboard];
}
- (void)keyboardWillShown:(NSNotification*)notification {
    // Get the size of the keyboard.
    CGSize keyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Given size may not account for screen rotation
    heightkboard = MIN(keyboard.height,keyboard.width);
    [self viewMoveUp];
}

-(void)viewMoveUp {
    float maxY = CGRectGetMaxY(_nextButtonOutlet.frame) + heightkboard +3;
    float reminder = CGRectGetHeight(self.view.frame) - maxY;
    if (reminder < 0) {
        [UIView animateWithDuration:0.4 animations:
         ^ {
             CGRect frameOfView = self.view.frame;
             frameOfView.origin.y = reminder ;
             self.view.frame = frameOfView;
             
         }];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if(textField == _userNameTextField) {
        NSDictionary *requestDict = @{mUserName    : _userNameTextField.text
                                      };
        [WebServiceHandler userNameCheck:requestDict andDelegate:self];
        self.userNameTextField.tintColor = [UIColor blueColor];
    }
}

/*--------------------------------------*/
#pragma mark
#pragma mark - WebServiceDelegate
/*--------------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    if (requestType == RequestTypenewRegister) {
        [self enableOrDisAbleTextField:YES];
    }
    
    [self.nextButtonOutlet setTitle:@"NEXT" forState:UIControlStateNormal];
    self.activityVIewIndicatorOutlet.hidden = YES;
    [self.activityVIewIndicatorOutlet stopAnimating];
       if (error) {
        //getting error response .
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];//Send via SMS
        [alert show];
        return;
    }
    
 //if user registering with phone number then we will get this response.
 //storing response in dictonary(responseDict).
    
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypeUserNameCheck ) {
        
        switch ([responseDict[@"code"] integerValue]) {
              //success response.
            case 200: {
               _correctCheckmarkImgaeViewOutlet.image=[UIImage imageNamed:@"add_photo_check_mark_icon"];
                 _refershImageViewOutlet.image=[UIImage imageNamed:@"add_photo_completed_refresh_icon_on"];
                  _dividerViewOutlet.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
            }
                break;
             //error response.
            case 1992: {
                [self  movedownTheView:@"Mandatory username is missing"];
            }
                break;
            case 1993: {
                [self  movedownTheView:responseDict[@"message"]];
            }
            break;
            case 1994: {
                 [self  movedownTheView:@"Username is already registered"];
                _refershImageViewOutlet.image=[UIImage imageNamed:@"add_photo_completed_refresh_icon_on"];
                
            }
                break;
            default:
                break;
        }
    }
    //if user registering with phone number then we will get this response.
    if (requestType == RequestTypenewRegister ) {
        
        // Chat Start
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@",responseDict[@"userId"]] forKey:@"userId"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Chat End
        
        switch ([responseDict[@"code"] integerValue]) {
                //success response.
            case 200: {
                [[NSUserDefaults standardUserDefaults] setObject:responseDict forKey:userDetailkeyWhileRegistration];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //bussiness type 4 is for new register.
                NSString *type =@"4";
                [[NSUserDefaults standardUserDefaults] setValue:type forKey:@"BussinessAccountStatus" ];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                [self performSegueWithIdentifier:@"registerTofindFacebookContactsSegue" sender:nil];
                [self updateDeviceDetailsForAdmin];
                
            }
                break;
                //error response.
            case 1995: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 1996: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 1997: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 1998: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 1999: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 2000: {
                [self  movedownTheView:responseDict[@"message"]];
            }
            case 2001: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 2002: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 2003: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 2004: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 2005: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 1991: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            case 1988: {
                [self  movedownTheView:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
}

-(void)movedownTheView :(NSString *)message {
    [UIView animateWithDuration:0.2 animations:^ {
        CGRect frameOfView = self.view.frame;
        frameOfView.origin.y = 0;
        self.view.frame = frameOfView;
        [self.view layoutIfNeeded];
        [self dismissKeyboard];
        
    }  completion:^(BOOL finished) {
        [self showingErrorAlertfromTop:message];
    }
     ];
}

- (void)errrAlert:(NSString *)message {
    //alert for error response.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}

-(void)showingErrorAlertfromTop:(NSString *)message {
    self.popViewTopConstraint.constant = -50;
    [self.view layoutIfNeeded];
    _popAlertLabelOutlet.text = message;
    
    /**
     *  changing the error message view position if user enter  wrong number
     */
    
    [UIView animateWithDuration:0.4 animations:
     ^ {
         self.popViewTopConstraint.constant = 0;
         [self.view layoutIfNeeded];
     }];
    
    int duration = 2; // duration in seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:
         ^ {
             self.popViewTopConstraint.constant = -50;
             [self.view layoutIfNeeded];
         }];
    });
    
 
}

/*------------------------------------------------*/
#pragma mark
#pragma mark - facebook handler
/*-------------------------------------------------*/

/**
 *  Facebook login is success
 *  @param userInfo Userdict
 */
- (void)didFacebookUserLoginWithDetails:(NSDictionary*)userInfo {
    NSLog(@"FB Data =  %@", userInfo);
    
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",userInfo[@"id"]]];
    
    self.profilepicurlFb = pictureURL.absoluteString;
    profilePicUrl = self.profilepicurlFb;
    
    [_profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:self.profilepicurlFb]];
    _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
    _profileImageViewOutlet.clipsToBounds = YES;
    
    ThumbnailimagePath = nil;
}

/**
 *  Login failed with error
 *
 *  @param error error
 */
- (void)didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

/**
 *  User cancelled
 */

- (void)didUserCancelLogin {
    NSLog(@"USER CANCELED THE LOGIN");
}

- (IBAction)checkBoxAction:(id)sender {
    if (self.privacyPolicyAgreedBUttonOutlet.selected) {
        self.privacyPolicyAgreedBUttonOutlet.selected = NO;
    }
    else {
         self.privacyPolicyAgreedBUttonOutlet.selected = YES;
    }
}

- (IBAction)ppWebViewAction:(id)sender {
    [self performSegueWithIdentifier:@"registerToPrivacyPolicy" sender:nil];
}

#pragma mark-Owner Mobile Details
-(void)updateDeviceDetailsForAdmin {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //NSString build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString )kCFBundleVersionKey];
    //deviceName, deviceId, deviceOs, modelNumber, appVersion
    NSDictionary *requestDict = @{@"deviceName"    :flStrForObj([UIDevice currentDevice].name),
                                  @"deviceId" :flStrForObj([[[UIDevice currentDevice] identifierForVendor] UUIDString]),
                                  @"modelNumber" :flStrForObj([UIDevice currentDevice].model),
                                  @"deviceOs" :flStrForObj([[UIDevice currentDevice] systemVersion]),
                                  @"appVersion" :flStrForObj(version),
                                  @"token":flStrForObj([Helper userToken]),
                                  };
    [WebServiceHandler logDevice:requestDict andDelegate:self];
}

@end
