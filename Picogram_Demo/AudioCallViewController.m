//
//  AudioCallViewController.m
//  Sup
//
//  Created by Mac on 23/02/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "AudioCallViewController.h"
#import "soundHelper.h"
#import "RTCLogging.h"
#import "PicogramSocketIOWrapper.h"
#import "Database.h"
//#import "Favorites.h"
#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import "ChatViewController.h"
#import "FavDataBase.h"

@interface AudioCallViewController ()<ARDAppClientDelegate,SocketWrapperDelegate>
{
    soundHelper *sound;
    ARDAppClient *_client;
    NSTimer *stopWatch;
    NSDate *startDate;
    NSTimer *ringingTimer;
    int ticks;
    
    AVAudioSession *session;
    
}
@property PicogramSocketIOWrapper *socketIoClient;
@property FavDataBase *favDataBase;

@end

@implementation AudioCallViewController
@synthesize dataDictionary;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseFromChanne:) name:@"callingNotification" object:nil];
    _favDataBase = [FavDataBase sharedInstance];
    /* Setup the socket */
    self.socketIoClient = [PicogramSocketIOWrapper sharedInstance];
   // self.socketIoClient.chatDelegate = self;

   // self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
   // self.profileImageView.clipsToBounds=YES;

    self.navigationController.navigationBarHidden = YES;
    
    if(dataDictionary[@"to"])
    {
//    self.userNameLabel.text=dataDictionary[@"to"];
   
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
        self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
        
        
        NSManagedObject *friend = [self getNameFromDb:[NSString stringWithFormat:@"%@",dataDictionary[@"to"]]];
        
        if(![[friend valueForKey:@"memberFullName"]isEqualToString:@"<null>"])
        {
            self.userNameLabel.text =  [friend valueForKey:@"memberFullName"];
        }
        else
            self.userNameLabel.text =  [friend valueForKey:@"memberName"];
        
        
        NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",[self.dataDictionary objectForKey:@"to"]];
        
        NSArray *allFav = [_favDataBase getDataFavDataFromDB];
        NSArray *matchNum = [allFav filteredArrayUsingPredicate:predi];
        [self getUserImage:[friend valueForKey:@"memberImage"]];
    
    if (matchNum.count>0) {
        NSDictionary *fav = [matchNum firstObject];
        self.userNameLabel.text = fav[@"fullName"];
        [self getUserImage:fav[@"image"]];
    }
    }
    
    self.durationLabel.text=@"Connecting..";
    sound=[[soundHelper alloc]init];
    [[UIScreen mainScreen] setWantsSoftwareDimming:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if(self.isDialing)
    {
        NSURL *callingTone = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"calling" ofType:@"wav"]];

        //Play Calling sound if user is dialing
        [sound playAudioWithUrl:callingTone repeat:YES];
   
        // Adding timer to end the call if user does not respond within 1 minute
        float pauseTimeinterval=0.0;
        NSDate *startDate_Timer = [NSDate date] ;
        startDate_Timer = [startDate_Timer dateByAddingTimeInterval:((-1)*(pauseTimeinterval))];
        ringingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRingingTimer) userInfo:nil repeats:YES];
    }

    self.isSpeakerMode=NO;
    

//    NSError *error = nil;
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
//    [session setActive: YES error:nil];
//    [session  overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    
    
    PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
    [client subscribeToCallEvent];
    
    
    
    [self.audioView setBackgroundColor:[UIColor colorWithRed:(74.0/255.0) green:(72.0/255.0) blue:(73.0/255.0) alpha:1]];
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

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    self.endBtnHeightContstant.constant =
    [UIScreen mainScreen].bounds.size.height > 480.0f ? 85 : 10;
    
    self.imageCont.constant =
    [UIScreen mainScreen].bounds.size.height > 480.0f ? 40 : 10;
    
    
    if ([UIScreen mainScreen].bounds.size.height == 568.0f) {
     
        self.endBtnHeightContstant.constant = 65;
    }
    
}



-(void)updateRingingTimer
{
        ticks+=1;
      //  NSLog(@"Ticks = %i",ticks);
        if(ticks>60)
        {
            ticks=0;
            [ringingTimer invalidate];
            ringingTimer=nil;
            //end call commented added /*en  //[self endMyCall:nil];*/
            [self endMyCall:nil];
        }
}


-(void)viewWillAppear:(BOOL)animated
{
    
    NSError *error = nil;
    AVAudioSessionCategoryOptions nCurrentOptions = [AVAudioSession sharedInstance].categoryOptions | AVAudioSessionCategoryOptionAllowBluetooth;
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:nCurrentOptions
                   error:&error];
    
    [self initForRoom:dataDictionary[@"call_id"] isLoopback:NO isAudioOnly:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{

    //[[NSNotificationCenter defaultCenter]removeObserver:@"callingNotification"];
     [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"callingNotification" object:nil];
}

- (void)initForRoom:(NSString *)room
         isLoopback:(BOOL)isLoopback
        isAudioOnly:(BOOL)isAudioOnly {
    _client = [[ARDAppClient alloc] initWithDelegate:self];
    [_client connectToRoomWithId:room
                      isLoopback:isLoopback
                     isAudioOnly:isAudioOnly];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
          //  RTCLog(@"Client connected.");
            break;
        case kARDAppClientStateConnecting:
          //  RTCLog(@"Client connecting.");
            break;
        case kARDAppClientStateDisconnected:
          //  RTCLog(@"Client disconnected.");
           // [self hangup];
            break;
    }
}

- (void)appClient:(ARDAppClient *)client
didChangeConnectionState:(RTCICEConnectionState)state {
    RTCLog(@"ICE state changed: %d", state);
    __weak AudioCallViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        AudioCallViewController *strongSelf = weakSelf;
        if(state==RTCICEConnectionChecking)
            strongSelf.durationLabel.text=@"Connecting..";
        else if (state == RTCICEConnectionConnected)
        {
           // [sound switchSpeakerMode:@"Speaker"];
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
         didError:(NSError *)error {
    NSString *message =
    [NSString stringWithFormat:@"%@", error.localizedDescription];
    if([message length] > 0) {
        //[self showAlertWithMessage:message];
    }
    [self hangup];
}

- (void)showAlertWithMessage:(NSString*)message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
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

- (void)hangup {
    
    self.durationLabel.text=@"Ended";
    [stopWatch invalidate];
    stopWatch=nil;
    
    [_client disconnect];
    
    NSURL *endTone = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"end_of_call" ofType:@"wav"]];
    [sound playAudioWithUrl:endTone repeat:NO];
    
    if (![self isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}


-(void)responseFromChanne:(NSNotification*)notifi{
  
    //*added*/
    ticks=0;
    [ringingTimer invalidate];
    ringingTimer=nil;
    
    
    NSDictionary *responseDictionary = notifi.userInfo;
    NSArray* status = [responseDictionary valueForKey:@"status"];
    
    if ([status objectAtIndex:0] == [NSNull null]) {
        return;
    }
    
    if([[status objectAtIndex:0] isEqualToString:@"Accept"]) {
        /* Open the video call here */
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            //            ARDVideoCallViewController *videoCallViewController =
            //            [[ARDVideoCallViewController alloc] initForRoom:randomString
            //                                                 isLoopback:NO
            //                                                isAudioOnly:NO];
            //            videoCallViewController.modalTransitionStyle =
            //            UIModalTransitionStyleCrossDissolve;
            //            [self presentViewController:videoCallViewController
            //                               animated:YES
            //                             completion:nil];
        }];
    } else if([[status objectAtIndex:0] isEqualToString:@"Reject"]) {
        /* Show a error message and cancel the call */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hangup];
        });
    }
    else if ([[status firstObject] isEqualToString:@"busy"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.durationLabel.text=[NSString stringWithFormat:@"%@ is on Another Call", self.userNameLabel.text];
        });
    }
    else if ([[status firstObject] isEqualToString:@"user not found"])
    {
        self.durationLabel.text=@"User does not exist";
    }

    
    
}

#pragma mark Socket Delegate
-(void)responseFromChannels:(NSDictionary *)responseDictionary
{
    NSArray* status = [responseDictionary valueForKey:@"status"];
    if([[status objectAtIndex:0] isEqualToString:@"Accept"]) {
        /* Open the video call here */
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
//            ARDVideoCallViewController *videoCallViewController =
//            [[ARDVideoCallViewController alloc] initForRoom:randomString
//                                                 isLoopback:NO
//                                                isAudioOnly:NO];
//            videoCallViewController.modalTransitionStyle =
//            UIModalTransitionStyleCrossDissolve;
//            [self presentViewController:videoCallViewController
//                               animated:YES
//                             completion:nil];
        }];
    } else if([[status objectAtIndex:0] isEqualToString:@"Reject"]) {
        /* Show a error message and cancel the call */
        dispatch_async(dispatch_get_main_queue(), ^{
        [self hangup];
        });
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

- (IBAction)endMyCall:(id)sender {
   
       //Stop ringing timer
        ticks=0;
        [ringingTimer invalidate];
        ringingTimer=nil;
    
    
    self.socketIoClient = [PicogramSocketIOWrapper sharedInstance];
    /* The user is rejecting the call, Call the socket and reject the call */
    
    NSDictionary *data = @{@"to" : dataDictionary[@"to"],
                           @"status":@"Reject",@"call_id":dataDictionary[@"call_id"]};
    
    [self.socketIoClient sendEvent:data];
    
    // Send End Call event
    [self.socketIoClient sendCallEndEvent:data];
    [self.endCallButton setHighlighted:YES];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self hangup];
    });
   // [self hangup];

}

- (IBAction)muteMyCall:(id)sender {
    [self.muteButton setSelected:!self.muteButton.selected];
  
    //  NSError *error = nil;
   /*
    if (self.muteButton.selected) {
        BOOL success  =[[AVAudioSession sharedInstance] setActive:NO error:&error];
        if (!success) {
            NSLog(@"handel error");
        }
    }else
    {
        
        BOOL success  =[[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (!success) {
            NSLog(@"handel error");
        }
    }
    */
    
    
    if (self.isMute ==NO) {
    
        _muteLbl.textColor  =  [UIColor colorWithRed:(204.0/255.0) green:(204.0/255.0) blue:(204.0/255.0) alpha:1];
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
        
        _muteLbl.textColor  =  [UIColor whiteColor];//[UIColor colorWithRed:(79.0/255.0) green:(176.0/255.0) blue:(0.0/255.0) alpha:1];
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

- (IBAction)sendMessage:(id)sender {
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChatViewController *chat = [board instantiateViewControllerWithIdentifier:@"ChatViewController"];
    [self presentViewController:chat animated:YES completion:nil];
    
}


- (IBAction)enableLoudSpearker:(id)sender {
    [self.speakerButton setSelected:!self.speakerButton.selected];
    if(self.isSpeakerMode==NO)
    {
          _speakerLbl.textColor  =  [UIColor colorWithRed:(204.0/255.0) green:(204.0/255.0) blue:(204.0/255.0) alpha:1];
      
        self.isSpeakerMode=YES;
   // [sound switchSpeakerMode:@"Receiver"];
        NSLog(@"mute value =%d",_isMute);
    [sound switchSpeakerMode:@"Receiver" isMute:_isMute];
    [sound playAudioWithUrl:nil repeat:NO];
    }
    else
    {
        _speakerLbl.textColor  =  [UIColor whiteColor];//[UIColor colorWithRed:(79.0/255.0) green:(176.0/255.0) blue:(0.0/255.0) alpha:1];
        self.isSpeakerMode=NO;
       // [sound switchSpeakerMode:@"Speaker"];
         NSLog(@"mute value =%d",_isMute);
        [sound switchSpeakerMode:@"Speaker" isMute:_isMute];
        [sound playAudioWithUrl:nil repeat:NO];

    }
}


-(void)getUserImage:(NSString *)userImageStr{
    
    NSString *imageURL = userImageStr;
    if(imageURL==nil || imageURL==(id)[NSNull null] || [imageURL isEqualToString:@"(null)"]||imageURL.length ==0)
    {
       
        [self.profileImageView setImage:[UIImage imageNamed:@"contacts_info_image_frame"]];
        self.profileImageView.layer.cornerRadius = _profileImageView.frame.size.width / 2;
        self.profileImageView.clipsToBounds = YES;

    }
    else{
        
        NSURL *imageUrl =[NSURL URLWithString:imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"contacts_info_image_frame"];
        __weak typeof(self) weakSelf = self;
        [self.profileImageView setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  [weakSelf.profileImageView setImage:image];
                                                  weakSelf.profileImageView.layer.cornerRadius = _profileImageView.frame.size.width / 2;
                                                  weakSelf.profileImageView.clipsToBounds = YES;
                                                  
                                              } failure:nil];
    }
}


@end
