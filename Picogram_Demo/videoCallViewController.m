//
//  videoCallViewController.m
//  Sup
//
//  Created by MacMini on 28/02/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "videoCallViewController.h"
#import "RTCAVFoundationVideoSource.h"
#import "RTCLogging.h"
#import "ARDAppClient.h"
#import "ARDVideoCallView.h"
#import "soundHelper.h"
#import "PicogramSocketIOWrapper.h"
#import "Database.h"
//#import "Favorites.h"
#import "FavDataBase.h"
#import "UIImageView+AFNetworking.h"

static CGFloat const kButtonPadding = 16;
static CGFloat const kButtonSize = 48;
static CGFloat const kLocalVideoViewSize = 120;
static CGFloat const kLocalVideoViewPadding = 8;
static CGFloat const kStatusBarHeight = 20;

@interface videoCallViewController ()<ARDAppClientDelegate,ARDVideoCallViewDelegate,SocketWrapperDelegate,RTCEAGLVideoViewDelegate>
{
    UIButton *_cameraSwitchButton;
    UIButton *_hangupButton;
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
    BOOL _useRearCamera;
    soundHelper *sound;
    NSTimer *stopWatch;
    NSDate *startDate;
    int callAccept;
    BOOL isTapped;
    
     AVAudioSession *session;


}
@property PicogramSocketIOWrapper *socketIoClient;
@property (strong,nonatomic) FavDataBase *favDataBase;

@property(nonatomic, strong) RTCVideoTrack *localVideoTrack;
@property(nonatomic, strong) RTCVideoTrack *remoteVideoTrack;
@end

@implementation videoCallViewController {
    ARDAppClient *_client;
    RTCVideoTrack *_remoteVideoTrack;
    RTCVideoTrack *_localVideoTrack;
    
    NSTimer *ringingTimer;
    int ticks;
}
@synthesize infoDictionary;

- (void)initForRoom:(NSString *)room
                 isLoopback:(BOOL)isLoopback
                isAudioOnly:(BOOL)isAudioOnly {
        _client = [[ARDAppClient alloc] initWithDelegate:self];
        [_client connectToRoomWithId:room
                          isLoopback:isLoopback
                         isAudioOnly:isAudioOnly];
}

-(void)updateTimer
{
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.durationLabel.text = timeString;
}


- (void)updateViewConstraints {
    [super updateViewConstraints];
    
   // self.videoConstant.constant =
   // [UIScreen mainScreen].bounds.size.height > 480.0f ? 345 : 330;
    
}


#pragma mark - ARDAppClientDelegate

- (void)appClient:(ARDAppClient *)client
   didChangeState:(ARDAppClientState)state {
    switch (state) {
        case kARDAppClientStateConnected:
        {
//                [sound playAudioWithUrl:nil repeat:NO];
//                float pauseTimeinterval=0.0;
//                startDate = [NSDate date] ;
//                startDate = [startDate dateByAddingTimeInterval:((-1)*(pauseTimeinterval))];
//                stopWatch = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        }
            RTCLog(@"Client connected.");
            break;
        case kARDAppClientStateConnecting:
            RTCLog(@"Client connecting.");
            break;
        case kARDAppClientStateDisconnected:
            RTCLog(@"Client disconnected.");
           // [self hangup];
            break;
    }
}

- (void)appClient:(ARDAppClient *)client
didChangeConnectionState:(RTCICEConnectionState)state {
    RTCLog(@"ICE state changed: %d", state);
    __weak videoCallViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        videoCallViewController *strongSelf = weakSelf;
        if(state==RTCICEConnectionChecking)
        strongSelf.durationLabel.text=@"Connecting..";
        else if (state == RTCICEConnectionConnected)
        {
                            [sound playAudioWithUrl:nil repeat:NO];
                            float pauseTimeinterval=0.0;
                            startDate = [NSDate date] ;
                            startDate = [startDate dateByAddingTimeInterval:((-1)*(pauseTimeinterval))];
                            stopWatch = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        }
        else if (state == RTCICEConnectionDisconnected)
        {
            //[self hangup];
        }
       // strongSelf.videoCallView.statusLabel.text =
       // [strongSelf statusTextForState:state];
    });
}

- (void)appClient:(ARDAppClient *)client
didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    self.localVideoTrack = localVideoTrack;
}

- (void)appClient:(ARDAppClient *)client
didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    self.remoteVideoTrack = remoteVideoTrack;
  //  _videoCallView.statusLabel.hidden = YES;
}

- (void)appClient:(ARDAppClient *)client
      didGetStats:(NSArray *)stats {
   // _videoCallView.statsView.stats = stats;
   // [self.view setNeedsLayout];
}

- (void)appClient:(ARDAppClient *)client
         didError:(NSError *)error {
    NSString *message =
    [NSString stringWithFormat:@"%@", error.localizedDescription];
    if([message length] > 0) {
       // [self showAlertWithMessage:message];
    }
   // [self hangup];
}

#pragma mark - ARDVideoCallViewDelegate

- (void)videoCallViewDidHangup:(ARDVideoCallView *)view {
   // [self hangup];
}

- (void)videoCallViewDidSwitchCamera:(ARDVideoCallView *)view {
    // TODO(tkchin): Rate limit this so you can't tap continously on it.
    // Probably through an animation.
   // [self switchCamera];
}

- (void)videoCallViewDidEnableStats:(ARDVideoCallView *)view {
    _client.shouldGetStats = YES;
   // _videoCallView.statsView.hidden = NO;
}

#pragma mark - Private

- (void)setLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
   
    
    if (callAccept ==1) {
        
    if (self.isWithoutVideo ==YES) {
        return;
    }
    
    if (_localVideoTrack == localVideoTrack) {
        return;
    }
    [_localVideoTrack removeRenderer:self.localVideoView];
    _localVideoTrack = nil;
    [self.localVideoView renderFrame:nil];
    _localVideoTrack = localVideoTrack;
    [_localVideoTrack addRenderer:self.localVideoView];
    
    }else{
    
        if (self.isWithoutVideo ==YES) {
            return;
        }
    
        if (_localVideoTrack == localVideoTrack) {
            return;
        }
        [_localVideoTrack removeRenderer:self.callerVideoView];
        _localVideoTrack = nil;
        [self.callerVideoView renderFrame:nil];
        _localVideoTrack = localVideoTrack;
        //CGAffineTransform t = CGAffineTransformMakeScale(-1.0f, -1.0f);
       // _localVideoView.transform = t;
        
        [_localVideoTrack addRenderer:self.callerVideoView];
        
        
    }
    
    CGAffineTransform t = CGAffineTransformMakeScale(-1.0f, 1.0f);
    _localVideoView.transform = t;
    
}

- (void)setRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
    
    
    if (callAccept ==0) {
      //  _localVideoView.hidden = YES;
//        if (self.isWithoutVideo ==YES) {
//            return;
//        }
//        
//        if (_remoteVideoTrack == remoteVideoTrack) {
//            return;
//        }
//        
//        self.videoScopeLabel.hidden=YES;
//        [_remoteVideoTrack removeRenderer:self.localVideoView];
//        _remoteVideoTrack = nil;
//        [self.localVideoView renderFrame:nil];
//        _remoteVideoTrack = remoteVideoTrack;
//        [_remoteVideoTrack addRenderer:self.localVideoView];
        
        if (self.isWithoutVideo ==YES) {
            return;
        }
        
        if (_remoteVideoTrack == remoteVideoTrack) {
            return;
        }
        
        self.videoScopeLabel.hidden=YES;
        [_remoteVideoTrack removeRenderer:self.localVideoView];
        _remoteVideoTrack = nil;
        [self.localVideoView renderFrame:nil];
        _remoteVideoTrack = remoteVideoTrack;
        [_remoteVideoTrack addRenderer:self.localVideoView];
        
       // CGAffineTransform t = CGAffineTransformMakeScale(-1.0f, 1.0f);
        //_localVideoView.transform = t;
        
    }
    else{
        
    
        if (self.isWithoutVideo ==YES) {
            return;
        }
        
        if (_remoteVideoTrack == remoteVideoTrack) {
            return;
        }
        
        self.videoScopeLabel.hidden=YES;
        [_remoteVideoTrack removeRenderer:self.localVideoView];
        _remoteVideoTrack = nil;
        [self.callerVideoView renderFrame:nil];
        _remoteVideoTrack = remoteVideoTrack;
        [_remoteVideoTrack addRenderer:self.callerVideoView];
        
        CGAffineTransform t = CGAffineTransformMakeScale(-1.0f,1.0f);
        _callerVideoView.transform = t;
        
    }
    
    CGAffineTransform t = CGAffineTransformMakeScale(1.0f,1.0f);
    _callerVideoView.transform = t;
    
    
//    if (self.isWithoutVideo ==YES) {
//        return;
//    }
//    
//    if (_remoteVideoTrack == remoteVideoTrack) {
//        return;
//    }
//    
//    self.videoScopeLabel.hidden=YES;
//    [_remoteVideoTrack removeRenderer:self.localVideoView];
//    _remoteVideoTrack = nil;
//    [self.callerVideoView renderFrame:nil];
//    _remoteVideoTrack = remoteVideoTrack;
//    [_remoteVideoTrack addRenderer:self.callerVideoView];
    
    
    
   // CGAffineTransform t = CGAffineTransformMakeScale(-1.0f, 1.0f);
    //_localVideoView.transform = t;

}

- (void)hangup {
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"ComignfromRecive"];
   // [[NSUserDefaults standardUserDefaults]objectForKey:@"ComignfromRecive"];
    
    [stopWatch invalidate];
    stopWatch=nil;
    
    self.remoteVideoTrack = nil;
    self.localVideoTrack = nil;
    [_client disconnect];
    
    NSURL *endTone = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"end_of_call" ofType:@"wav"]];
    [sound playAudioWithUrl:endTone repeat:NO];
    
    if (![self isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
}

- (void)switchCamera {
    RTCVideoSource* source = self.localVideoTrack.source;
    if ([source isKindOfClass:[RTCAVFoundationVideoSource class]]) {
        RTCAVFoundationVideoSource* avSource = (RTCAVFoundationVideoSource*)source;
        avSource.useBackCamera = !avSource.useBackCamera;
        self.localVideoView.transform = avSource.useBackCamera ?
        CGAffineTransformIdentity : CGAffineTransformMakeScale(-1, 1);
    }
}

- (NSString *)statusTextForState:(RTCICEConnectionState)state {
    switch (state) {
        case RTCICEConnectionNew:
        case RTCICEConnectionChecking:
            return @"Connecting...";
        case RTCICEConnectionConnected:
        case RTCICEConnectionCompleted:
        case RTCICEConnectionFailed:
        case RTCICEConnectionDisconnected:
        case RTCICEConnectionClosed:
        case RTCICEConnectionMax:
            return nil;
    }
}

- (void)showAlertWithMessage:(NSString*)message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(NSString *) randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void)viewWillDisappear:(BOOL)animated
{
   // self.socketIoClient.chatDelegate = nil;
     [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"ComignfromRecive"];
    [_localVideoTrack removeRenderer:self.localVideoView];
    _localVideoTrack = nil;
    [self.localVideoView renderFrame:nil];
    
    [EAGLContext setCurrentContext:nil];
    
    [_remoteVideoTrack removeRenderer:self.localVideoView];
    _remoteVideoTrack = nil;
    [self.callerVideoView renderFrame:nil];
    
    //[[NSNotificationCenter defaultCenter]removeObserver:@"callingNotification"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"callingNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isTapped = YES;
    callAccept = 0;
    
    _callerName.hidden = YES;
    _durationLabel.hidden = YES;
    _localVideoView.hidden = YES;
    NSNumber *val = [[NSUserDefaults standardUserDefaults]objectForKey:@"ComignfromRecive"];
    if (val.boolValue == YES) {
        callAccept = 1;
        _userImagView.hidden = YES;
        _userName.hidden = YES;
        _statusLbl.hidden = YES;
        _callerName.hidden = NO;
        _durationLabel.hidden = NO;
        _localVideoView.hidden = NO;
        //callAccept =1;
        [_remoteVideoTrack removeRenderer:self.localVideoView];
        [_localVideoTrack removeRenderer:self.callerVideoView];
        
        [_localVideoTrack addRenderer:self.localVideoView];
        [_remoteVideoTrack addRenderer:self.callerVideoView];

    }
    
    // Do any additional setup after loading the view.
    /* Setup the socket */
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseFromChanne:) name:@"callingNotification" object:nil];
    self.socketIoClient = [PicogramSocketIOWrapper sharedInstance];
    //self.socketIoClient.chatDelegate = self;
    
    _favDataBase = [FavDataBase sharedInstance];
    
    self.localVideoView.layer.cornerRadius=5.0f;
    //self.localVideoView.layer.borderWidth=1.0f;
   // self.localVideoView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.localVideoView.clipsToBounds=YES;
    
    self.userImagView.layer.cornerRadius = 40.0f;
    self.userImagView.clipsToBounds =YES;
    
    self.callerName.text=self.infoDictionary[@"to"];
    self.userName.text = self.callerName.text;
   // NSLog(@"number =%@",self.infoDictionary);
   
   // self.localVideoView.delegate = self;
   // self.callerVideoView.delegate = self;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
    self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    
    NSManagedObject *friend = [self getNameFromDb:[NSString stringWithFormat:@"%@",self.infoDictionary[@"to"]]];
    
    if([friend valueForKey:@"memberFullName"])
    {
        self.callerName.text =  [friend valueForKey:@"memberFullName"];
    }
    else
        self.callerName.text =  [friend valueForKey:@"memberName"];
        self.userName.text = self.callerName.text;
    
    NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",[self.infoDictionary objectForKey:@"to"]];
    NSArray *allFav = [_favDataBase getDataFavDataFromDB];
    NSArray *matchNum = [allFav filteredArrayUsingPredicate:predi];
    
    
    if (matchNum.count>0) {
        
        NSDictionary *fav = [matchNum firstObject];
        self.callerName.text = fav[@"fullName"];
        self.userName.text = self.callerName.text;
         [self getUserImage:fav[@"image"]];
    }
    
    
   //  [self layoutSubviews];
    
//    NSURL *callingTone = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"calling" ofType:@"wav"]];
//    sound=[[soundHelper alloc]init];
//    [sound playAudioWithUrl:callingTone repeat:YES];
    sound=[[soundHelper alloc]init];

    [[UIScreen mainScreen] setWantsSoftwareDimming:NO];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
   // [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    if(self.isDialing)
    {
        
        NSURL *callingTone = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"calling" ofType:@"wav"]];
        
//        NSError *error = nil;
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
//        [session setActive: YES error:nil];
//        [session  overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
      
        self.durationLabel.text=@"Connecting..";
        //Play Calling sound if user is dialing
        [sound playAudioWithUrl:callingTone repeat:YES];
        
        
        // Adding timer to end the call if user does not respond within 1 minute
        float pauseTimeinterval=0.0;
        NSDate *startDate_Timer = [NSDate date] ;
        startDate_Timer = [startDate_Timer dateByAddingTimeInterval:((-1)*(pauseTimeinterval))];
        ringingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRingingTimer) userInfo:nil repeats:YES];

    }
    
    self.isSpeakerMode=YES;
   // [sound switchSpeakerMode:@"Receiver"];
    [sound switchSpeakerMode:@"Receiver" isMute:NO];
    
    PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
    [client subscribeToCallEvent];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCliked:)];
    [tap setNumberOfTapsRequired:1];
    [_callerVideoView addGestureRecognizer:tap];
    
    
    
    CGAffineTransform t = CGAffineTransformMakeScale(-1.0f, 1.0f);
    _localVideoView.transform = t;
    
    

    CGAffineTransform t1 = CGAffineTransformMakeScale(-1.0f, 1.0f);
    _callerVideoView.transform = t1;
   
}

-(NSManagedObject *)getNameFromDb :(NSString *)memberId
{
    for (int i=0; i<[_friendesList count]; i++) {
        
        NSManagedObject *friend = [self.friendesList objectAtIndex:i];
        
        if([[friend valueForKey:@"memberid"] isEqualToString:memberId])
        {
            
            
            return friend;
        }
    }
    return Nil;
}


- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)tapCliked:(UITapGestureRecognizer*)tap{
    
    if (isTapped == YES) {
        
        [UIView animateWithDuration:0.5 animations:^{
             CGRect fram = _buttonMainView.frame;
            fram.origin.y = 528;
            self.localVideoviewYconstant.constant =5;//366;
            
        } completion:^(BOOL finished) {
            
            _endCallButton.hidden = YES;
            _muteButton.hidden = YES;
            _cameraButton.hidden = YES;
            _switchBtn.hidden = YES;
            _callerName.hidden = YES;
            _durationLabel.hidden = YES;
            isTapped = NO;
            _backBtn.hidden = YES;
           
        }];
        
        
    }else{
        
        
        [UIView animateWithDuration:0.4 animations:^{
             self.localVideoviewYconstant.constant = 40;
        } completion:^(BOOL finished) {
            isTapped = YES;
            _endCallButton.hidden = NO;
            _muteButton.hidden = NO;
            _cameraButton.hidden = NO;
            _switchBtn.hidden = NO;
            _callerName.hidden = NO;
            _durationLabel.hidden = NO;
            _backBtn.hidden = NO;
        }];
        
       
    }
}

-(void)updateRingingTimer
{
        ticks+=1;
       // NSLog(@"Ticks = %i",ticks);
        if(ticks>60)
        {
            ticks=0;
            [ringingTimer invalidate];
            ringingTimer=nil;
            //end call commented added /*en  //[self onHangup:nil];;*/
            [self onHangup:nil];
        }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    
     [self initForRoom:infoDictionary[@"call_id"] isLoopback:NO isAudioOnly:NO];
    CGAffineTransform t = CGAffineTransformMakeScale(-1.0f, 1.0f);
    _localVideoView.transform = t;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark Socket Delegate
//-(void)responseFromChannels:(NSDictionary *)responseDictionary
//{
//    NSArray* status = [responseDictionary valueForKey:@"status"];
//    if([[status objectAtIndex:0] isEqualToString:@"Accept"]) {
//        /* Open the video call here */
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
//            
//        }];
//    } else if([[status objectAtIndex:0] isEqualToString:@"Reject"]) {
//        /* Show a error message and cancel the call */
//        dispatch_async(dispatch_get_main_queue(), ^{
//        [self hangup];
//        });
//    }
//}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
    
    NSLog(@"videoViewdidchanegVideoSizecalled =%f  -  %f",size.height,size.width);
    
    CGSize defaultAspectRatio = CGSizeMake(4, 3);
    CGFloat containerWidth = self.view.frame.size.width;
    CGFloat containerHeight = self.view.frame.size.height;

    if (videoView == self.localVideoView) {
        _localVideoSize = size;
        self.localVideoView.hidden = CGSizeEqualToSize(CGSizeZero, _localVideoSize);
    } else if (videoView == self.callerVideoView) {
        
        _remoteVideoSize = size;
        CGSize aspectRatio = defaultAspectRatio;//CGSizeEqualToSize(size, CGSizeZero) ? defaultAspectRatio : size;
        CGRect videoRect = self.view.bounds;
        CGRect videoFrame = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videoRect);
        
        [self.remoteViewTopConstraint setConstant:containerHeight/2.0f - videoFrame.size.height/2.0f];
        [self.remoteViewBottomConstraint setConstant:containerHeight/2.0f - videoFrame.size.height/2.0f];
        [self.remoteViewLeftConstraint setConstant:containerWidth/2.0f - videoFrame.size.width/2.0f];
        [self.remoteViewRightConstraint setConstant:containerWidth/2.0f - videoFrame.size.width/2.0f];

    }
    [self.view setNeedsLayout];
}

- (void)layoutSubviews {

    NSLog(@"layoutSubView called here");
//    CGRect bounds = self.view.bounds;
//    if (_remoteVideoSize.width > 0 && _remoteVideoSize.height > 0) {
//        // Aspect fill remote video into bounds.
//        CGRect remoteVideoFrame =
//        AVMakeRectWithAspectRatioInsideRect(_remoteVideoSize, bounds);
//        CGFloat scale = 1;
//        if (remoteVideoFrame.size.width > remoteVideoFrame.size.height) {
//            // Scale by height.
//            scale = bounds.size.height / remoteVideoFrame.size.height;
//        } else {
//            // Scale by width.
//            scale = bounds.size.width / remoteVideoFrame.size.width;
//        }
//        remoteVideoFrame.size.height *= scale;
//        remoteVideoFrame.size.width *= scale;
//        self.callerVideoView.frame = remoteVideoFrame;
//        self.callerVideoView.center =
//        CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
//    } else {
//        self.callerVideoView.frame = bounds;
//    }
//    
//    if (_localVideoSize.width && _localVideoSize.height > 0) {
//        // Aspect fit local video view into a square box.
//        CGRect localVideoFrame =
//        CGRectMake(0, 0, kLocalVideoViewSize, kLocalVideoViewSize);
//        localVideoFrame =
//        AVMakeRectWithAspectRatioInsideRect(_localVideoSize, localVideoFrame);
//        
//        // Place the view in the bottom right.
//        localVideoFrame.origin.x = CGRectGetMaxX(bounds)
//        - localVideoFrame.size.width - kLocalVideoViewPadding;
//        localVideoFrame.origin.y = CGRectGetMaxY(bounds)
//        - localVideoFrame.size.height - kLocalVideoViewPadding;
//        _localVideoView.frame = localVideoFrame;
//    } else {
//        _localVideoView.frame = bounds;
//    }
    
    
    
    
    
    
    // Place stats at the top.
//    CGSize statsSize = [_statsView sizeThatFits:bounds.size];
//    _statsView.frame = CGRectMake(CGRectGetMinX(bounds),
//                                  CGRectGetMinY(bounds) + kStatusBarHeight,
//                                  statsSize.width, statsSize.height);
//    
//    // Place hangup button in the bottom left.
//    _hangupButton.frame =
//    CGRectMake(CGRectGetMinX(bounds) + kButtonPadding,
//               CGRectGetMaxY(bounds) - kButtonPadding -
//               kButtonSize,
//               kButtonSize,
//               kButtonSize);
//    
//    // Place button to the right of hangup button.
//    CGRect cameraSwitchFrame = _hangupButton.frame;
//    cameraSwitchFrame.origin.x =
//    CGRectGetMaxX(cameraSwitchFrame) + kButtonPadding;
//    _cameraSwitchButton.frame = cameraSwitchFrame;
//    
//    [_statusLabel sizeToFit];
//    _statusLabel.center =
//    CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

#pragma mark - Private

- (IBAction)onCameraSwitch:(id)sender {
   // [self switchCamera];
    [self.cameraButton setSelected:!self.cameraButton.selected];

    if (self.isMute ==NO) {
        
        self.isMute = YES;
        NSError *error = nil;
        session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        
        if (self.isSpeakerMode == YES ) {
            [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            [sound playAudioWithUrl:nil repeat:NO];
        }else{
            [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
            [sound playAudioWithUrl:nil repeat:NO];
        }
        [session setActive:YES error:nil];
        
        
    }else{
        
       
        self.isMute = NO;
        NSError *error = nil;
        session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        
        // [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
        if (self.isSpeakerMode == YES ) {
            [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            [sound playAudioWithUrl:nil repeat:NO];
        }else{
            [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
            [sound playAudioWithUrl:nil repeat:NO];
        }
        
        [session setActive:YES error:nil];
        //[session  overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        
    }
    
    
    
}

- (IBAction)onHangup:(id)sender {
    

      [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"ComignfromRecive"];
       //Stop ringing timer
        ticks=0;
        [ringingTimer invalidate];
        ringingTimer=nil;
    
    
    NSDictionary *data = @{@"to" : self.infoDictionary[@"to"],@"call_id":infoDictionary[@"call_id"]
                           };
    [self.socketIoClient sendCallEndEvent:data];
    [self.endCallButton setHighlighted:YES];
    [self hangup];
}


- (IBAction)muteButtonAction:(id)sender {
//    if(self.isSpeakerMode==NO)
//    {
//        self.isSpeakerMode=YES;
//        [sound switchSpeakerMode:@"Receiver"];
//        [sound playAudioWithUrl:nil repeat:NO];
//
//    }
//    else
//    {
//        self.isSpeakerMode=NO;
//        [sound switchSpeakerMode:@"Speaker"];
//        [sound playAudioWithUrl:nil repeat:NO];
//
//    }
    
//    [self switchCamera];
    
    
    
    if (callAccept ==0) {
        return;
    }
    
     [self.muteButton setSelected:!self.muteButton.selected];
    if(self.muteButton.selected)
    {
        [_muteButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    if(self.isWithoutVideo == NO) {
               self.isWithoutVideo=YES;
                [self.localVideoView renderFrame:nil];
                [_localVideoTrack removeRenderer:self.localVideoView];
                NSDictionary *data = @{@"to" : infoDictionary[@"to"],
                                       @"status":@"stopVideo",@"call_id":infoDictionary[@"call_id"]};
        
            _localVideoView.hidden =YES;
                [self.socketIoClient sendEvent:data];
            } else {
                    self.isWithoutVideo=NO;
                    [_localVideoTrack addRenderer:self.localVideoView];
                    NSDictionary *data = @{@"to" : infoDictionary[@"to"],
                                            @"status":@"startVideo",@"call_id":infoDictionary[@"call_id"]};
                 _localVideoView.hidden =NO;
                    [self.socketIoClient sendEvent:data];
            }
    

}

- (void)didTripleTap:(UITapGestureRecognizer *)recognizer {
    
    [self videoCallViewDidEnableStats:self];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)responseFromChanne:(NSNotification*)notifi{
    
    //Stop ringing timer
    ticks=0;
    [ringingTimer invalidate];
    ringingTimer=nil;
    
    NSDictionary *responseDictionary = notifi.userInfo;
    NSArray* status = [responseDictionary valueForKey:@"status"];
    if (status.count==0) {
        return;
    }
    if([[status objectAtIndex:0] isEqualToString:@"Accept"]) {
        /* Open the video call here */
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            _userImagView.hidden = YES;
            _userName.hidden = YES;
            _statusLbl.hidden = YES;
            _callerName.hidden = NO;
            _muteButton.enabled = YES;
            
            _durationLabel.hidden = NO;
            _localVideoView.hidden = NO;
            callAccept =1;
          //  NSLog(@"_remote =%@",_remoteVideoTrack);
          //  NSLog(@"local =%@",_localVideoTrack);
            [_remoteVideoTrack removeRenderer:self.localVideoView];
            [_localVideoTrack removeRenderer:self.callerVideoView];
            
            [_localVideoTrack addRenderer:self.localVideoView];
            [_remoteVideoTrack addRenderer:self.callerVideoView];

        }];
        
    } else if([[status objectAtIndex:0] isEqualToString:@"Reject"]) {
        /* Show a error message and cancel the call */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hangup];
        });
    }
    else if([[status objectAtIndex:0] isEqualToString:@"background"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoScopeLabel setHidden:NO];
        });
    }
    else if([[status objectAtIndex:0] isEqualToString:@"foreground"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoScopeLabel setHidden:YES];
        });
        
    }
    else if ([[status firstObject] isEqualToString:@"busy"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.durationLabel.text=[NSString stringWithFormat:@"%@ is on Another Call", self.callerName.text];
        });
    }
    
    else if ([[status firstObject] isEqualToString:@"stopVideo"]) {
               [self.callerVideoView renderFrame:nil];
                [_remoteVideoTrack removeRenderer:self.callerVideoView];
            }
    else if ([[status firstObject] isEqualToString:@"startVideo"])
            {
                    [_remoteVideoTrack addRenderer:self.callerVideoView];
            }
    
    else if ([[status firstObject] isEqualToString:@"user not found"])
    {
        self.durationLabel.text=@"User does not exist";
    }
    
    
}

- (IBAction)switchCamera:(id)sender {
  
    [self.switchBtn setSelected:!self.switchBtn.selected];
    [self switchCamera];
    
}
- (IBAction)backAction:(id)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"ComignfromRecive"];
    
    
    //Stop ringing timer
    ticks=0;
    [ringingTimer invalidate];
    ringingTimer=nil;
    
    NSDictionary *data = @{@"to" : self.infoDictionary[@"to"],@"call_id":infoDictionary[@"call_id"]
                           };
    [self.socketIoClient sendCallEndEvent:data];
    [self.endCallButton setHighlighted:YES];
    [self hangup];

    
    
}


-(void)getUserImage:(NSString *)userImageStr{
    
    NSString *imageURL = userImageStr;
    if(imageURL==nil || imageURL==(id)[NSNull null] || [imageURL isEqualToString:@"(null)"]||imageURL.length ==0)
    {
        [self.userImagView setImage:[UIImage imageNamed:@"contacts_info_image_frame"]];
        self.userImagView.layer.cornerRadius = _userImagView.frame.size.width / 2;
        self.userImagView.clipsToBounds = YES;
    }
    else{
        
        NSURL *imageUrl =[NSURL URLWithString:imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"contacts_info_image_frame"];
        __weak typeof(self) weakSelf = self;
        [self.userImagView setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  [weakSelf.userImagView setImage:image];
                                                  weakSelf.userImagView.layer.cornerRadius = _userImagView.frame.size.width / 2;
                                                  weakSelf.userImagView.clipsToBounds = YES;
                                                  
                                              } failure:nil];
    }
}




@end
