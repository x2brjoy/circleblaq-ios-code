//
//  IncomingViewController.m
//  Sup
//
//  Created by Rahul Sharma on 4/4/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "IncomingViewController.h"
#import "AppDelegate.h"
#import "PicogramSocketIOWrapper.h"
#import "Database.h"
//#import "Favorites.h"
#import "UIImageView+AFNetworking.h"
#import "FavDataBase.h"


@interface IncomingViewController ()<SocketWrapperDelegate>
{
    soundHelper *sound;
    NSTimer *stopWatch;
    NSDate *startDate;
}
@property PicogramSocketIOWrapper *socketIoClient;
@property (strong,nonatomic)FavDataBase *favDataBase;

@end

@implementation IncomingViewController
//extern AppDelegate *appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(responseFromCallChannel:) name:@"callingNotification" object:nil];
    
    _callerImageView.layer.cornerRadius = _callerImageView.frame.size.width/2;
    _callerImageView.clipsToBounds = YES;
    
    _favDataBase = [FavDataBase sharedInstance];
    self.navigationController.navigationBarHidden = YES;
    sound=[[soundHelper alloc]init];
    
    NSURL *ringtone = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"ringtone" ofType:@"wav"]];
    
    //Switch sound mode to speaker for ringtone
    //[sound switchSpeakerMode:@"Receiver"];
    [sound switchSpeakerMode:@"Receiver" isMute:NO];
    [sound playAudioWithUrl:ringtone repeat:YES];
    
    [self.callerImageView setImage:[UIImage imageNamed:@"contacts_info_image_frame"]];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(appDelegate.user_msisdn.length){
        self.callerName.text=appDelegate.user_msisdn;
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
        self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
        
        
        NSManagedObject *friend = [self getNameFromDb:[NSString stringWithFormat:@"%@",appDelegate.user_msisdn]];
        
        if([friend valueForKey:@"memberFullName"])
        {
            self.callerName.text =  [friend valueForKey:@"memberFullName"];
        }
        else
            self.callerName.text =  [friend valueForKey:@"memberName"];
        
        [self getUserImage:[friend valueForKey:@"memberImage"]];

        NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",appDelegate.user_msisdn];
        
        NSArray *allFav = [_favDataBase getDataFavDataFromDB];
        
        NSArray *matchNum = [allFav filteredArrayUsingPredicate:predi];
        
        if (matchNum.count>0) {
        NSDictionary *fav = [matchNum firstObject];
        self.callerName.text = fav[@"fullName"];
        [self getUserImage:fav[@"image"]];
        }
    }
    
   
    if ([appDelegate.callType isEqualToString:@"0"]) {
        _durationLabel.text = @"incoming voice call";
        _callTitleLbl.text = @"PICOGRAM VOICE CALL";
    }else{
        _durationLabel.text =@"incoming video call";
        _callTitleLbl.text = @"PICOGRAM VIDEO CALL";
    }
    
    PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
    [client subscribeToCallEvent];
    
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

-(void)getUserImage:(NSString *)userImageStr{
    
    NSString *imageURL = userImageStr;
    if(imageURL==nil || imageURL==(id)[NSNull null] || [imageURL isEqualToString:@"(null)"])
    {
        [self.callerImageView setImage:[UIImage imageNamed:@"15stp"]];
    }
    else{
        
        NSURL *imageUrl =[NSURL URLWithString:imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"15stp"];
        __weak typeof(self) weakSelf = self;
        [self.callerImageView setImageWithURLRequest:request
                                    placeholderImage:placeholderImage
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 
                                                 [weakSelf.callerImageView setImage:image];
                                                 
                                             } failure:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
    //[[NSNotificationCenter defaultCenter] removeObserver:@"callingNotification"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"callingNotification" object:nil];
    
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



- (IBAction)endCallAction:(id)sender {
    
    [stopWatch invalidate];
    stopWatch=nil;
    
    [self.durationLabel setText:@"Ended"];
    
    NSURL *busyTone = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"busy" ofType:@"wav"]];
    [sound playAudioWithUrl:busyTone repeat:NO];
    
    [UIView beginAnimations:@"hideButtons" context:nil];
    [UIView setAnimationDuration:1.0f];
    // [self.acceptCallButton setCenter:self.view.center];
    // [self.rejectCallButton setCenter:self.view.center];
    // [self.acceptCallButton setAlpha:0.0];
    // [self.rejectCallButton setAlpha:0.0];
    // [self.acceptCallButton setEnabled:YES];
    //[self.rejectCallButton setEnabled:YES];
    [self.endCallButton setEnabled:NO];
    [self.endCallButton setAlpha:0.0f];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)acceptCallButtonAction:(id)sender {
   
    _acceptLbl.textColor = [UIColor lightGrayColor];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"ComignfromRecive"];
    [UIView beginAnimations:@"hideButtons" context:nil];
    [UIView setAnimationDuration:0.5f];
    [self.acceptCallButton setCenter:self.endCallButton.center];
    [self.rejectCallButton setCenter:self.endCallButton.center];
    [self.acceptCallButton setAlpha:0.0];
    [self.rejectCallButton setAlpha:0.0];
    [self.acceptCallButton setEnabled:NO];
    [self.rejectCallButton setEnabled:NO];
    [self.endCallButton setEnabled:YES];
    [self.endCallButton setAlpha:1.0f];
    [UIView commitAnimations];
    
    //Switch sound mode to normal and stop ringtone
    //[sound switchSpeakerMode:@"Speaker"];
    [sound switchSpeakerMode:@"Speaker" isMute:NO];
    [sound playAudioWithUrl:nil repeat:NO];
    
   // NSLog(@"Connect Call");
    self.socketIoClient = [PicogramSocketIOWrapper sharedInstance];
    
     AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // The User accepts the call, Call the socket and accept the call
    NSDictionary *data = @{@"to" : appDelegate.user_msisdn,
                           @"status":@"Accept",@"call_id":appDelegate.call_id};
    
    [self.socketIoClient sendEvent:data];
    
    //    float pauseTimeinterval=0.0;
    //    startDate = [NSDate date] ;
    //    startDate = [startDate dateByAddingTimeInterval:((-1)*(pauseTimeinterval))];
    //    stopWatch = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    
    
    //    NSDictionary *callData = @{@"to" : appDelegate.user_msisdn,
    //                           @"call_id":appDelegate.call_id};
    //
    //    videoCallViewController *videoCallViewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"videoCallViewController"];
    //    videoCallViewController.infoDictionary=callData;
    //    videoCallViewController.modalTransitionStyle =
    //    UIModalTransitionStyleCrossDissolve;
    //
    //    [self presentViewController:videoCallViewController
    //                       animated:YES
    //                     completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        //Dismiss incoming call screen and show video call screen from top view controller from app delegate
        if([appDelegate.callType isEqualToString:@"0"])
        {
            //Start Audio Call
            [appDelegate showAudioCallingScreen];
        }
        else
        {
            //Start Video Call
            [appDelegate showVideoCallingScreen];
        }
    }];
    
    // [self dismissViewControllerAnimated:NO completion:nil];
    
}


- (IBAction)rejectCallButtonAction:(id)sender {
    
    _rejectLbl.textColor = [UIColor lightGrayColor];
    [self.durationLabel setText:@"Disconnected"];
    
    NSURL *busyTone = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"busy" ofType:@"wav"]];
    [sound playAudioWithUrl:busyTone repeat:NO];
    
    self.socketIoClient = [PicogramSocketIOWrapper sharedInstance];
    //self.socketIoClient.chatDelegate = self;
    
    /* The user is rejecting the call, Call the socket and reject the call */
     AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary *data = @{@"to" : appDelegate.user_msisdn,
                           @"status":@"Reject",@"call_id":appDelegate.call_id};
    
    [self.socketIoClient sendEvent:data];
    [self.socketIoClient sendCallEndEvent:data];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)messageButtonAction:(id)sender {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)responseFromCallChannel:(NSNotification*)noti{
    
    NSDictionary *responseDictionary = noti.userInfo;
    NSArray* status = [responseDictionary valueForKey:@"status"];
    if([[status objectAtIndex:0] isEqualToString:@"Accept"]) {
        /* Open the video call here */
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            
        }];
    } else if([[status objectAtIndex:0] isEqualToString:@"Reject"]) {
        /* Show a error message and cancel the call */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        });
    }

    
}

@end
