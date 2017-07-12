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

#define kVideoPreset AVCaptureSessionPresetHigh

@interface CameraViewController ()<UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,CLImageEditorDelegate,CLUploaderDelegate,SCRecorderDelegate,SCPlayerDelegate,SCVideoOverlay,SCRecorderToolsViewDelegate,UIAlertViewDelegate>
{
    BOOL cancelCamera;
    CLCloudinary *cloudinary;
    
    //screcorder
    SCRecordSession *_recordSession;
    SCRecordSession *sessionTosend;
    NSTimer *recordTimer;
    int duration;
    UIImage *thumbimg;
    UIAlertView *alertTodeleteVideo;
}

@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong,nonatomic) UIImagePickerController *imgpicker;
@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

//screcorder
@property(nonatomic,strong)SCRecorder *recorder;
@property(nonatomic,strong)SCRecorderToolsView *focusView;
@end

@implementation CameraViewController
@synthesize PreviewLayer;
UIImage *image;
NSURL *outputURL;
NSString *videoPathUrl;
UIImage *videoThumbNailImage;
NSString *thumbnailImageforvideoPath;


- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    self.mainScrollView.pagingEnabled = YES;
    
    //starting capturing video and image.
    
    //intially creating new record session.

    self.videoButtonOutlet.selected = NO;
    self.photoButtonOutlet.selected = YES;
    
    [self checkCameraPermissionsStatus];
    
    //creating longTapGestureForVideoRecording
    [self creatingLongGestureForVideoButton];
    
    self.PressandholdTorecordMessageView.hidden = YES;
    
}




- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden =YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
}

-(void)viewDidAppear:(BOOL)animated {
    
}

-(void)makingPreViewViewForCapture {
    UIView *previewView = self.frameForCaptureImage;
    _recorder.previewView = previewView;
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    [previewView bringSubviewToFront:self.frontCameraButtonOutlet];
    [previewView bringSubviewToFront:self.flashButtonOutlet];
    [_recorder startRunning];
    
    if (![_recorder startRunning]) {
        NSLog(@"Something wrong there: %@", _recorder.error);
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    //if user clicks on next button after recording video then progressindicator will be hide.
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
    
    //unhiding navbar of next screen.
    NSString *key = [[NSUserDefaults standardUserDefaults]valueForKey:kController];
    if ([key isEqualToString:@"Lib"]) {
        self.navigationController.navigationBarHidden =YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:kController];
    }
    else
        self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    _recorder.flashMode = SCFlashModeOff;
}

-(void)viewDidDisappear:(BOOL)animated{
    @try {
        [self.focusView.recorder removeObserver:self forKeyPath:@"isAdjustingFocus"];
        [_recorder unprepare];
        [_recorder stopRunning];
    }
    @catch (NSException *exception) {
    }
}

/*-------------------------------------*/
#pragma mark
#pragma mark -ButtonAction
/*-------------------------------------*/

- (IBAction)frontCameraButtonAction:(id)sender {
    
    if (_recorder.device == AVCaptureDevicePositionBack) {
        _recorder.device = AVCaptureDevicePositionFront;
        [self.flashButtonOutlet setHidden:YES];
    } else {
        _recorder.device = AVCaptureDevicePositionBack;
        [self.flashButtonOutlet setHidden:NO];
    }
    
}

-(IBAction)takeVideo:(id)sender {
    [self showMessage];
}

-(void)showMessage {
    
    self.PressandholdTorecordMessageView.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideMessageView) userInfo:nil repeats:NO];
}
-(void)hideMessageView {
    self.PressandholdTorecordMessageView.hidden = YES;
}

- (IBAction)closeButtonAction:(id)sender {
    if (self.counter) {
        alertTodeleteVideo = [[UIAlertView alloc] initWithTitle:@"Discard Video" message:@"if you close the camera now,your video will be discarded." delegate:self cancelButtonTitle:@"Discard" otherButtonTitles:@"Keep", nil];
        [alertTodeleteVideo show];
    }
    else {
        
        NSString *controllerType = [[NSUserDefaults standardUserDefaults]valueForKey:@"CameraControllerType"];
        
        if ([controllerType isEqualToString:@"directChaT"]) {
            // [self dismissViewControllerAnimated:YES completion:nil];
            self.navigationController.navigationBarHidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CameraControllerType"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else{
            [self.tabBarController setSelectedIndex:0];
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == alertTodeleteVideo) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            [self.tabBarController setSelectedIndex:0];
            [self resetRecord];
        }
    }
}

- (IBAction)flashButtonAction:(id)sender {
    //    NSString *flashModeString = nil;
    //    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
    //        switch (_recorder.flashMode) {
    //            case SCFlashModeAuto:
    //                flashModeString = @"Flash : Off";
    //                _recorder.flashMode = SCFlashModeOff;
    //                break;
    //            case SCFlashModeOff:
    //                flashModeString = @"Flash : On";
    //                _recorder.flashMode = SCFlashModeOn;
    //                break;
    //            case SCFlashModeOn:
    //                flashModeString = @"Flash : Light";
    //                _recorder.flashMode = SCFlashModeLight;
    //                break;
    //            case SCFlashModeLight:
    //                flashModeString = @"Flash : Auto";
    //                _recorder.flashMode = SCFlashModeAuto;
    //                break;
    //            default:
    //                break;
    //        }
    //    } else {
    //        switch (_recorder.flashMode) {
    //            case SCFlashModeOff:
    //                flashModeString = @"Flash : On";
    //                _recorder.flashMode = SCFlashModeLight;
    //                break;
    //            case SCFlashModeLight:
    //                flashModeString = @"Flash : Off";
    //                _recorder.flashMode = SCFlashModeOff;
    //                break;
    //            default:
    //                break;
    //        }
    //    }
    if (self.flashButtonOutlet.selected) {
        [self turnTorchOn:NO];
        self.flashButtonOutlet.selected = NO;
    }
    else {
        [self turnTorchOn:YES];
        self.flashButtonOutlet.selected = YES;
    }
    
}


- (IBAction)nextButtonAction:(id)sender {
    if (self.counter > 5 ) {
        ProgressIndicator *loginPI = [ProgressIndicator sharedInstance];
        [loginPI showPIOnView:self.view withMessage:@"processing.."];
        
        [_recorder pause:^{
            [self saveAndShowSession:_recorder.session];
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Record video atleast 5 seconds." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)enablePhotoButton {
   self.takePhotoButtonOutlet.enabled = YES;
}

- (IBAction)takePhoto:(id)sender {
    self.takePhotoButtonOutlet.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(enablePhotoButton) userInfo:nil repeats:NO];
    
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            if (_recorder.device == AVCaptureDevicePositionBack)
            {
                [self imageCaptured:image];
            }
            else
            {
                UIImage *flippedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
                [self imageCaptured:flippedImage];
            }}
        else {
        }
    }];
    
    
}



/*--------------------------------------------------*/
#pragma mark - Scrollview Delegate
/*-------------------------------------------------*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.mainScrollView])
    {
        scrollView.bounces = NO;
        CGPoint offset = scrollView.contentOffset;
        
        
        if (offset.x < 0) {
            // image picker //
            TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
            photoPicker.cropBlock = ^(UIImage *image) {
                [self.profileImage setImage:image];
            };
            
            //photoPicker.viewFromProfileSelector = @"ViewFromCamera";
            //[self presentViewController:photoPicker animated:NO completion:nil];
        }
        else if(offset.x <= CGRectGetWidth(self.view.frame) /2 ) {
            //photo is selected.
            self.libraryButtonOutlet.selected = NO;
            self.photoButtonOutlet.selected = YES;
            self.videoButtonOutlet.selected = NO;
            
            self.titleLabel.text = @"Photo";
            if (_recorder.device == AVCaptureDevicePositionFront) {
                self.flashButtonOutlet.hidden = YES;
            }
            else
                self.flashButtonOutlet.hidden = NO;
            self.nextButtonOutlet.hidden= YES;
        }
        else
        {
            //video is selected.
            self.libraryButtonOutlet.selected = NO;
            self.photoButtonOutlet.selected = NO;
            self.videoButtonOutlet.selected = YES;
            
            self.nextButtonOutlet.hidden= NO;
            
            self.progressBar.progress = 0.01;
            
            self.titleLabel.text = @"Video";
            self.flashButtonOutlet.hidden = YES;
        }
        
        //        float widthOfView = CGRectGetWidth(self.view.frame);
        //        /***********************************************/
        //        CGFloat minOffsetX = 0;
        //        CGFloat maxOffsetX = widthOfView;
        //
        //        // Check if current offset is within limit and adjust if it is not
        //
        //        if (offset.x < minOffsetX) offset.x = minOffsetX;
        //        if (offset.x > maxOffsetX) offset.x = maxOffsetX;
        
        // Set offset to adjusted value
        scrollView.contentOffset = offset;
    }
}

- (void)showPhoto:(UIImage *)photo {
    [self gotoImageEditor:photo];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


/*---------------------------------*/
#pragma mark - Video Capturing
/*---------------------------------*/

-(void)captureForVideo {
    
    self.viewWhenCameraPermissonDenied.hidden = YES;
    
    
    //it is creating screcorder to record the video.
    
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.device = AVCaptureDevicePositionFront;//AVCaptureDevicePositionBack;
    //maximum record session time is 60 secs and after 60 secs video will not record and saveAndShowSession
    _recorder.maxRecordDuration = CMTimeMake(60, 1);
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO;
    _recorder.mirrorOnFrontCamera = YES;
    _recorder.videoConfiguration.sizeAsSquare = YES;
    _recorder.flashMode = SCFlashModeOff;
    
    if (!_recorder) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        });
        return;
    }
    
    if (_recorder.device == AVCaptureDevicePositionFront) {
        [self.flashButtonOutlet setHidden:YES];
    }
    else
        [self.flashButtonOutlet setHidden:NO];
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
    
    
    _recorder.SCImageView.scaleAndResizeCIImageAutomatically = NO;
    _recorder.SCImageView.frame = self.frameForCaptureImage.frame;
}


-(void)checkCameraPermissionsStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        [self captureForVideo];
         [self resetRecord];
        [self makingPreViewViewForCapture];
    }
    else if(status == AVAuthorizationStatusDenied){ // denied
        // [self cameraPermissionDenied];
        self.viewWhenCameraPermissonDenied.hidden = NO;
        [self.view bringSubviewToFront:self.viewWhenCameraPermissonDenied];
    }
    else if(status == AVAuthorizationStatusRestricted){ // restricted
        
        
    }
    else if(status == AVAuthorizationStatusNotDetermined){ // not determined
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){ // Access has been granted ..do something
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // This block will be executed asynchronously on the main thread.
                    [self captureForVideo];
                    [self resetRecord];
                    [self makingPreViewViewForCapture];
                });
               
            } else { // Access denied ..do something
                dispatch_async(dispatch_get_main_queue(), ^{
                    // This block will be executed asynchronously on the main thread.
                    self.viewWhenCameraPermissonDenied.hidden = NO;
                    [self.view bringSubviewToFront:self.viewWhenCameraPermissonDenied];
                });
              
            }
        }];
    }
}

- (void) prepareCamera {
    //it will create new record session if any recorded video is not there.
    if (_recorder.session == nil) {
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        _recorder.session = session;
    }
}

/*-----------------------------*/
#pragma mark -
#pragma mark - LongGesture
/*-----------------------------*/

- (void)userLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    //if user clicks continously then video will record and after removing finger on record video button then recording video will be pause.
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSDictionary *requestDict = @{ @"allowScrol" :@"yes"
                                       };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AllowToScroll" object:[NSDictionary dictionaryWithObject:requestDict forKey:@"permissionForScroll"]];
        
        [_recorder record];
        self.videoButtonOutlet.selected = YES;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(incrementCounter) userInfo:nil repeats:YES];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.videoButtonOutlet.selected = NO;
        [_recorder pause];
        [self.timer invalidate];
        if (self.counter > 1 ) {
            self.nextButtonOutlet.enabled = YES;
        }
        else {
            self.nextButtonOutlet.enabled = NO;
        }
        NSLog(@"total time video recorded is :%d",self.counter);
        if(self.counter) {
            [UIView animateWithDuration:0.4
                             animations:^{
                                 _bottomButtonsView.constant = -50;
                                 [self.view layoutIfNeeded];
                                 self.mainScrollView.scrollEnabled = NO;
                                 
                             }];
        }
    }
}

/*-----------------------------------*/
#pragma mark -
#pragma mark -ProgressBar For Video
/*-----------------------------------*/

- (void)incrementCounter {
    self.counter++;
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(makeMyProgressBarMoving)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void)makeMyProgressBarMoving {
    if (self.progressBar.progress < 1) {
        //it will progress of 0.016666666666 for every sec.(value for 60 secs.)(1/60)
        self.progressBar.progress =  self.progressBar.progress + 0.016666666666;
    }
    else if (self.progressBar.progress == 1){
        
    }
}

/*----------------------------------------*/
#pragma mark
#pragma mark screcorder delegate methods
/*----------------------------------------*/
- (void)recorderDidStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

- (void)recorderDidEndFocus:(SCRecorder *)recorder {
    [self.focusView hideFocusAnimation];
}

- (void)recorderWillStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

//this method will call after recording and after 60 secs (it depends on requirement).

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
    [self saveAndShowSession:recordSession];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    _recordSession = recordSession;
    
    // Merge all the segments into one file using an AVAssetExportSession
    [recordSession mergeSegmentsUsingPreset:AVAssetExportPresetHighestQuality completionHandler:^(NSURL *url, NSError *error) {
        if (error == nil) {
            // Easily save to camera roll
            [url saveToCameraRollWithCompletion:^(NSString *path, NSError *saveError) {
                videoPathUrl = path;
                thumbimg = [self gettingThumbnailImage:path];
                [self performSegueWithIdentifier:@"videoPLayersegue" sender:nil];
            }];
        }
        else {
            NSLog(@"Bad things happened: %@", error);
            [[ProgressIndicator sharedInstance] hideProgressIndicator];
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Not saved to camera roll" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (error == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

/*---------------------------------------------------*/
#pragma mark
#pragma mark - converting video to thumbnail image
/*---------------------------------------------------*/

-(UIImage *)gettingThumbnailImage :(NSString *)url {
    NSURL *videoURl = [NSURL fileURLWithPath:url];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    
    UIImage *img = [[UIImage alloc] initWithCGImage:imgRef];
    return img;
}

/*---------------------------------*/
#pragma mark
#pragma mark - image picker
/*---------------------------------*/

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    NSData *dataimage = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1);
    UIImage *selectedProfileImage =[[UIImage alloc] initWithData:dataimage];
    [self.profileImage setImage:selectedProfileImage];
    [self.imgpicker dismissViewControllerAnimated:YES completion:nil];
}

/*--------------------------------------------------------*/
#pragma mark
#pragma mark - Bottom Library,Video,Photo Button Actions.
/*--------------------------------------------------------*/


- (IBAction)libraryButtonAction:(id)sender {
    
    // image picker from library.
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    photoPicker.cropBlock = ^(UIImage *image) {
        [self.profileImage setImage:image];
    };
    
    photoPicker.viewFromProfileSelector = @"ViewFromCamera";
    [self presentViewController:photoPicker animated:NO completion:nil];
}

- (IBAction)photoButtonAction:(id)sender {
    
    CGRect frame = self.mainScrollView.bounds;
    frame.origin.x = 0;
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    
    self.libraryButtonOutlet.selected = NO;
    self.photoButtonOutlet.selected = YES;
    self.videoButtonOutlet.selected = NO;
}

- (IBAction)videoButtonAction:(id)sender {
    CGRect frame = self.mainScrollView.bounds;
    frame.origin.x = CGRectGetWidth(self.view.frame);
    
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    self.libraryButtonOutlet.selected = NO;
    self.photoButtonOutlet.selected = NO;
    self.videoButtonOutlet.selected = YES;
}

/*-----------------------------*/
#pragma mark -
#pragma mark - ImageFilters
/*-----------------------------*/

-(void)gotoImageEditor:(UIImage *)data {
    UIImage *img = data;
    
    [[CLImageEditorTheme theme] setBackgroundColor:[UIColor blackColor]];
    [[CLImageEditorTheme theme] setToolbarColor:[UIColor darkGrayColor]];
    [[CLImageEditorTheme theme] setToolbarTextColor:[UIColor whiteColor]];
    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:img delegate:self];
    
    CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:NO];
    tool.available = NO;
    
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
    
    //sending image to image filters view controller.
    [self.navigationController pushViewController:editor animated:YES];
}

-(void)imageSelected {
    [self performSegueWithIdentifier:@"cameraToFiltersViewControllerSegue" sender:nil];
}

/*--------------------------------------------*/
#pragma mark
#pragma mark prepareForSegue
/*--------------------------------------------*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //sending captured image to camera filters.
    if([segue.identifier isEqualToString:@"cameraToFiltersViewControllerSegue"]) {
        FiltersViewController *filterVC = [segue destinationViewController];
        filterVC.receivedImage = image;
    }
    //sending local path of video and record session(used to play the video) to video filtersVc.
    
    if([segue.identifier isEqualToString:@"videoPLayersegue"]) {
        VideoFilterViewController *videoVC = [segue destinationViewController];
        videoVC.pathOfVideo = videoPathUrl;
        videoVC.recordsession = _recordSession;
        videoVC.thumbnailimageForVideoPath = thumbnailImageforvideoPath;
        videoVC.videoimgthumb = thumbimg;
        videoVC.videoRecorded = @"VideoRecorded";
    }
}

- (void)dealloc {
    _recorder.previewView = nil;
}

- (IBAction)deleteButtonAction:(id)sender {
    [self resetRecord];
    
    NSDictionary *requestDict = @{ @"allowScrol" :@"no"
                                   
                                   };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AllowToScroll" object:[NSDictionary dictionaryWithObject:requestDict forKey:@"permissionForScroll"]];
    self.videoButtonOutlet.selected = YES;
    self.photoButtonOutlet.selected = NO;
}

-(void)resetRecord {
    
    self.progressBar.progress = 0.01;
    
    // if any recorded session is there then it will delete and will start new record session.
    SCRecordSession *recordSession = _recorder.session;
    if (recordSession != nil) {
        _recorder.session = nil;
        [recordSession cancelSession:nil];
    }
    
    [self prepareCamera];
    self.counter = 0;
    self.nextButtonOutlet.enabled = NO;
    
    
    //close delete button and show photo,video,library buttons.(animation)
    
    [UIView animateWithDuration:0.4 animations:^{
        self.mainScrollView.scrollEnabled = YES;
        
        _bottomButtonsView.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

-(void)creatingLongGestureForVideoButton {
    UILongPressGestureRecognizer *longpressGesture1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userLongPressed:)];
    longpressGesture1.delegate = self;
    longpressGesture1.minimumPressDuration =0.1;
    [self.takeVideoButtonOutlet addGestureRecognizer:longpressGesture1];
}

- (void) turnTorchOn: (bool) on {
    
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (on) {
                //[device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                //  [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

- (void) imageCaptured:(UIImage*)image {
    UIImage *squareImage = [self squareImageFromImage:image scaledToSize:320];
    [self showPhoto:squareImage];
}

- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)enableCameraAccessButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
