//
//  AppDelegate.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 09/02/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "AppDelegate.h"
#import "PGTabBar.h"
#import "UIImageView+WebCache.h"
#import "WebServiceHandler.h"
#import "PicogramSocketIOWrapper.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "TinderGenericUtility.h"
// Chat Start
#import "MSReceive.h"
#import "MSReceive.h"
#import "ChatViewController.h"
#import "RTCPeerConnectionFactory.h"
#import "WebServiceConstants.h"
#import "AFNetworkReachabilityManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "PageContentViewController.h"
#import "AudioCallViewController.h"
#import "VideoFilterViewController.h"
#import "videoCallViewController.h"

#import "RTCPeerConnectionFactory.h"
#import "ARDVideoCallViewController.h"
#import "IncomingViewController.h"
#import "videoCallViewController.h"
#import "AudioCallViewController.h"

//#import "AGPushNoteView.h"
#import "ChatNavigationContollerClass.h"
#import "Helper.h"

#define storyBoard [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
// Chat End


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

#define TwitterApiKey             @"CkCIuqnLDhzohvaDWtWlAHat3"
#define TwitterApiSecret          @"uGjDBaD5SCG5tKsKflVfPg3dd299lo10nQFpZEuy9BXcyHLuaV"


@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;

@import GoogleMaps;
@interface AppDelegate ()<SDWebImageManagerDelegate,WebServiceHandlerDelegate,SocketWrapperDelegate,FIRMessagingDelegate>
{
    // Chat Start
    NSTimer *timer;
    NSTimer *reconnectTimer;
    // Chat End
}
@property (strong, nonatomic) PicogramSocketIOWrapper *client;
@end

#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif
@implementation AppDelegate
@synthesize client;
// Chat Start
@synthesize window,call_id;
@synthesize user_msisdn,isOngoingVideoCall,callType;
// Chat End


+(AppDelegate*)sharedAppDelegate{
    return  (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
//coudnaryKey:GbeMWncZR1Oct34h8PFc5ZXr_Z4,api_key:258613241318198

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    application.applicationIconBadgeNumber = 0;
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) )
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        //if( option != nil )
        //{
        //    NSLog( @"registerForPushWithOptions:" );
        //}
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }
    
    
    //    [NSThread sleepForTimeInterval:5.0];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    
    [GMSServices provideAPIKey:@"AIzaSyAmbn-8WGM5uBOHx-2165kOSyumnwFRXM4"];
    
    
    NSDictionary *userDatawhileRegistration;
    NSDictionary *userData;
    NSString *userToken;
    
    userDatawhileRegistration =[[NSUserDefaults standardUserDefaults]objectForKey:@"userDetailWhileRegistration"];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:userDetailKey];
    userData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    
    //connect Firebase and initialize
    
    /*if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
     // iOS 7.1 or earlier. Disable the deprecation warnings.
     #pragma clang diagnostic push
     #pragma clang diagnostic ignored "-Wdeprecated-declarations"
     UIRemoteNotificationType allNotificationTypes =
     (UIRemoteNotificationTypeSound |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeBadge);
     [application registerForRemoteNotificationTypes:allNotificationTypes];
     #pragma clang diagnostic pop
     } else {
     if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
     UIUserNotificationType allNotificationTypes =
     (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
     UIUserNotificationSettings *settings =
     [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
     [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
     } else {
     // iOS 10 or later
     #if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
     UNAuthorizationOptions authOptions =
     UNAuthorizationOptionAlert
     | UNAuthorizationOptionSound
     | UNAuthorizationOptionBadge;
     [[UNUserNotificationCenter currentNotificationCenter]
     requestAuthorizationWithOptions:authOptions
     completionHandler:^(BOOL granted, NSError * _Nullable error) {
     }
     ];
     
     // For iOS 10 display notification (sent via APNS)
     [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
     // For iOS 10 data message (sent via FCM)
     //  [[FIRMessaging messaging] setRemoteMessageDelegate:self];
     #endif
     }
     
     [[UIApplication sharedApplication] registerForRemoteNotifications];
     // [END register_for_notifications]
     }
     */
    [FIRMessaging messaging].remoteMessageDelegate = self;
    [FIRApp configure];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    
    
    //if user first time login(registration) then userData dictonary will be empty and user login then userData will contain data.
    
    if (userData[@"token"]) {
        userToken = userData[@"token"];
    }
    else if(userDatawhileRegistration[@"response"][@"authToken"]){
        userToken = userDatawhileRegistration[@"response"][@"authToken"];
    }
    else {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    [self connectToSocket];
    
    if (userToken) {
        
        //        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"loginToHomeViewController"];
        //        self.window.rootViewController = rootController;
        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"pageContentViewController"];
        self.window.rootViewController = rootController;
        
    }
    else {
        
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    
    [WebServiceHandler getCloudinaryCredintials:@"" andDelegate:self];
    
    [self requestForCloundinaryDetails];
    
    [NSTimer scheduledTimerWithTimeInterval:30.0*60
                                     target:self
                                   selector:@selector(requestForCloundinaryDetails)
                                   userInfo:nil
                                    repeats:NO];
    
    [Fabric with:@[[Crashlytics class]]];
    
    
    
    NSString *token = [[FIRInstanceID instanceID] token];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:mdeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self handlePushNotificationWithLaunchOption:launchOptions];
    
    // Chat Start
    
    
    
    [reconnectTimer invalidate];
    reconnectTimer = nil;
    
    NSLog(@"Saved Token:%@",[[NSUserDefaults standardUserDefaults]objectForKey:mdeviceToken]);
    
    _manager = [CBLManager sharedInstance];
    NSError *error;
    _database  = [_manager databaseNamed:@"couchbasenew" error:&error];
    
    
    BOOL iscomingFromPush = NO;
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [[NSUserDefaults standardUserDefaults] setBool:iscomingFromPush forKey:@"isComingfromPush"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"callMethodeFirstTimeOnly"];
    //  NSLog(@"App not Open from push =%d",iscomingFromPush);
    
    if (notification ) {
        iscomingFromPush = YES;
        //  NSLog(@"App Open from push =%d",iscomingFromPush);
        [[NSUserDefaults standardUserDefaults] setBool:iscomingFromPush forKey:@"isComingfromPush"];
    }
    
    
    //    [self updateLocation];
    /////////push for layer
    
    // Checking if app is running iOS 8
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        // Register device for iOS8
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        // Register device for iOS7
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    }
    
    
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    /* Initialisations to get the webrtc working */
    [RTCPeerConnectionFactory initializeSSL];
    
    
    
    /////////push for layer
    [Fabric with:@[[Crashlytics class]]]; ///commented
    
    [self setNavigationBarBckgrroundImage];
    [self addNoInternetConnectionView];
    _internetConnectionErrorView.hidden = YES;
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [[[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Network appears to be offline" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isNetworkAvailable"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _internetConnectionErrorView.hidden = NO;
            [window bringSubviewToFront:_internetConnectionErrorView];
            
            
            //put timer to connect sockect in interval
            reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(connectToSocket) userInfo:nil repeats:YES];
            
            
            NSDictionary *dict = @{
                                   @"message":@"NO"
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"observeNetworkStatus" object:nil userInfo:dict];
        }
        else
        {
            
            _internetConnectionErrorView.hidden = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNetworkAvailable"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //stop timer to reconnect to socket
            [reconnectTimer invalidate];
            reconnectTimer = nil;
            
            NSDictionary *dict = @{
                                   @"message":@"YES"
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"observeNetworkStatus" object:nil userInfo:dict];
            
        }
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    _isConnected = NO;
    
    
    // Chat End
    
    
    
    return YES;
}



-(void)requestForCloundinaryDetails{
    [WebServiceHandler getCloudinaryCredintials:@"" andDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Chat Start
    
    [self userIsoffline];
    [self sendHeartBeatStatus:@"0"];
    
    // Chat End
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Chat Start
    
    [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"appTerminated"];
    [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"getCallStatus"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"AppEnterInBackground"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self userIsoffline];
    [self sendHeartBeatStatus:@"0"];
    
    
    // Send Event To let the other user know that he moved video call to background
    if(isOngoingVideoCall)
    {
        self.client = [PicogramSocketIOWrapper sharedInstance];
        // The User accepts the call, Call the socket and accept the call
        NSDictionary *data = @{@"to" : self.user_msisdn,
                               @"status":@"background"};
        [self.client sendEvent:data];
    }
    
    // Chat End
    
    [[FIRMessaging messaging] disconnect];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"phoneContacts"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //Chat Start
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"callMethodeFirstTimeOnly"];
    
    if (_isConnected) {
        [self didSubscribetoOnlineStatus];
        [self sendHeartBeatStatus:@"1"];
        //[self didSubscribeToHistory];
    }
    
    
    if(isOngoingVideoCall)
    {
        self.client = [PicogramSocketIOWrapper sharedInstance];
        // The User accepts the call, Call the socket and accept the call
        NSDictionary *data = @{@"to" : self.user_msisdn,
                               @"status":@"foreground"};
        [self.client sendEvent:data];
    }
    
    //Chat End
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //Chat Start
    self.client = [PicogramSocketIOWrapper sharedInstance];
    [client callMethodTogetadduserwhileOffline];
    [client getofflineDataForAnotherTimeAddtoGroup];
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    if (_isConnected) {
        [self didSubscribetoOnlineStatus];
        [self sendHeartBeatStatus:@"1"];
        [self didSubscribeToHistory];
        [self didSubscribeToGetMessageAcks];
        [self didSubscribeToGroupMsgHistory];
        [[PicogramSocketIOWrapper sharedInstance]callMethodTogetadduserwhileOffline];
    }
    
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"appTerminated"]==nil)
    {
        self.client = [PicogramSocketIOWrapper sharedInstance];
        NSDictionary *data = @{};
        if([[NSUserDefaults standardUserDefaults] valueForKey:@"userId"])
            [self.client PublishToGetCallStatusEvent:data];
    }
    
    //Chat End
    
    [self connectToFcm];
}

// Chat Start

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"pushToken"];
    NSString *model = [[UIDevice currentDevice] model];
    if ([model isEqualToString:@"iPhone Simulator"])
    {
        //device is simulator
        //        [[NSUserDefaults standardUserDefaults]setObject:@"123" forKey:KDAgetPushToken];
    }
    
    //    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// Chat End

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeUnknown];
    NSLog(@"FIR device token :%@",deviceToken);
    
    NSString *token = [[FIRInstanceID instanceID] token];
    NSLog(@"%@ token ",token);
    
    // Chat Start
    
    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@", dt);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"pushToken"];
    NSString *model = [[UIDevice currentDevice] model];
    if ([model isEqualToString:@"iPhone Simulator"]) {
        //device is simulator
        //        [[NSUserDefaults standardUserDefaults]setObject:@"123" forKey:KDAgetPushToken];
    }
    else {
        //        [[NSUserDefaults standardUserDefaults]setObject:dt forKey:KDAgetPushToken];
    }
    
    //Chat End
    
    
    
}
-(void)handlePushNotificationWithLaunchOption:(NSDictionary*)launchOptions
{
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    NSLog(@"/////////////////////////////////////////////////////////////////////");
    NSLog(@"FCM Message = %@",userInfo);
    NSLog(@"/////////////////////////////////////////////////////////////////////");
    NSLog(@"FCM Message = %@",userInfo);
    NSData *data = [userInfo[@"body"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:Nil];
    
    NSLog(@"%@",jsonResponse[@"isGroup"]);
    if(![jsonResponse objectForKey:@"isGroup"]) {
        /* Open the calling screen here */
       
//        self.call_id = [NSString stringWithFormat:@"%@", jsonResponse [@"call_id"]];
//        self.user_msisdn = [NSString stringWithFormat:@"%@", jsonResponse [@"call_from"]];
//        self.callType=[NSString stringWithFormat:@"%@", jsonResponse [@"callType"]];
        
//        UIViewController* homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
//        
//        //        ChatNavigationContollerClass *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
//        
//        PageContentViewController * pgController = [PageContentViewController sharedInstance];
//        [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
//            if (finished) {
//                
//            }
//        }];
        
    }
    else{
        
        
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            
            NSNumber *val =[[NSUserDefaults standardUserDefaults]objectForKey:@"AppEnterInBackground"];
            if (val.boolValue ==YES) {
                [self handelPushwhenAppinBackgroup:userInfo];
            }else{
                // [self handelPushNotification:userInfo];
//                [self handelPushNotification:userInfo];
            }
            
            
        }
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Chat Start
    //    NSString *
    //    if(userInfo[@"data"][@"isGroup"])
    
    // Chat End
    NSLog(@"/////////////////////////////////////////////////////////////////////");
    NSLog(@"FCM Message = %@",userInfo);
    NSDictionary *userIn = userInfo[@"body"];
    NSData *data = [userInfo[@"body"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:Nil];
    
    NSLog(@"%@",jsonResponse[@"isGroup"]);
    if(![jsonResponse objectForKey:@"isGroup"]  && [jsonResponse count] > 0) {
        /* Open the calling screen here */
        self.call_id = [jsonResponse valueForKey:@"call_id"];
        self.user_msisdn = [jsonResponse valueForKey:@"call_from"];
        self.callType=[jsonResponse valueForKey:@"callType"];
        
         [self performSelector:@selector(openIncomingCallScreen) withObject:nil afterDelay:1.0f];
        
    }
    else if([jsonResponse count] > 0){
        
        
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            
            NSNumber *val =[[NSUserDefaults standardUserDefaults]objectForKey:@"AppEnterInBackground"];
            if (val.boolValue ==YES) {
                [self handelPushwhenAppinBackgroup:userInfo[@"body"]];
            }else{
                // [self handelPushNotification:userInfo];
                [self handelPushNotification:userInfo[@"body"]];
            }
            
            
        }
    }
    
    if([[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"title"]] isEqualToString:@"PICOGRAM"]) {
        
        UIViewController* homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
        
        //        ChatNavigationContollerClass *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
        
        PageContentViewController * pgController = [PageContentViewController sharedInstance];
        [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            if (finished) {
                
            }
        }];
        
        
    }
    else {
        // No joy...
        
    }
    
    
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    NSLog(@"app is in foreground");
    // Pring full message.
    NSLog(@"%@", userInfo);
    
    NSLog(@"Type: %@", userInfo[@"type"]);
}

-(void)handelPushwhenAppinBackgroup:(NSDictionary*)dict{
    
    NSData *data = [dict[@"body"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:Nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isComingfromPush"];
    if (jsonResponse[@"isGroup"]) {
        
        [[NSUserDefaults standardUserDefaults]setObject:[dict objectForKey:@"isGroup"] forKey:@"StoredocIdFromPush"];
        [[NSUserDefaults standardUserDefaults]setObject:[dict objectForKey:@"groupId"] forKey:@"StoreGroupIdFromPush"];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:[dict objectForKey:@"from"] forKey:@"StoredocIdFromPush"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"data coming from push dict background =%@",dict);
    
    UIViewController* homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
    
    
    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
    
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UITabBarController *tabBarViewCont = [story instantiateViewControllerWithIdentifier:@"tabbarVC"];
//    [tabBarViewCont setSelectedIndex:0];
//    [self.window setRootViewController:tabBarViewCont];
}
-(void)handelPushNotification:(NSDictionary *)dict{
    
    NSData *data = [dict[@"body"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:Nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isComingfromPush"];
    if (jsonResponse[@"isGroup"]) {
        
        [[NSUserDefaults standardUserDefaults]setObject:[dict objectForKey:@"isGroup"] forKey:@"StoredocIdFromPush"];
        [[NSUserDefaults standardUserDefaults]setObject:[dict objectForKey:@"groupId"] forKey:@"StoreGroupIdFromPush"];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:[dict objectForKey:@"from"] forKey:@"StoredocIdFromPush"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"data coming from push dict background =%@",dict);
    
    UIViewController* homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
    
    
    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}


//FireBase Notification
-(void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage
{
    NSLog(@"/////////////////////////////////////////////////////////////////////");
    NSLog(@"FCM Message = %@",remoteMessage.appData);
    if([remoteMessage.appData valueForKey:@"call_id"]) {
        /* Open the calling screen here */
        //self.call_id = [userInfo valueForKey:@"call_id"];
        //self.user_msisdn = [userInfo valueForKey:@"call_from"];
        //self.callType=[userInfo valueForKey:@"callType"];
        
 
        
    }
    else{
        
        
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            
            NSNumber *val =[[NSUserDefaults standardUserDefaults]objectForKey:@"AppEnterInBackground"];
            if (val.boolValue ==YES) {
                [self handelPushwhenAppinBackgroup:(NSDictionary *)remoteMessage.appData];
            }else{
                // [self handelPushNotification:userInfo];
                [self handelPushNotification:(NSDictionary *)remoteMessage.appData];
            }
            
            
        }
    }
}

- (void)tokenRefreshNotification:(NSNotification *)notification {
    
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    [[NSUserDefaults standardUserDefaults] setObject:refreshedToken forKey:mdeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self connectToFcm];
    
}

// Chat Start

-(void)openIncomingCallScreen
{
    IncomingViewController *incomingVC = [storyBoard instantiateViewControllerWithIdentifier:@"incomingCallViewController"];
    incomingVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController *vc = [self topViewController];
    [vc presentViewController:incomingVC animated:YES completion:nil];
}

// Chat End



- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}

// Chat Start
-(void)handelPushNotification:(NSDictionary *)dict localPush:(BOOL)islocalPush{
    
    
    if (islocalPush == NO) {
        [[NSUserDefaults standardUserDefaults]setObject:[dict objectForKey:@"from"] forKey:@"StoredocIdFromPush"];
        // NSLog(@"data coming from push dict =%@",dict);
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"chatNotificationCame" object:nil userInfo:nil];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarViewCont = [story instantiateViewControllerWithIdentifier:@"tabbarVC"];
        [tabBarViewCont setSelectedIndex:0];
        [self.window.rootViewController presentViewController:tabBarViewCont animated:YES completion:nil];
        
        ChatNavigationContollerClass *homeVC = [story instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
        
        PageContentViewController * pgController = [PageContentViewController sharedInstance];
        [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
            if (finished) {
                
            }
        }];
    }
    else{
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isComingfromPush"];
        
        [[NSUserDefaults standardUserDefaults]setObject:[dict objectForKey:@"from"] forKey:@"StoredocIdFromPush"];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarViewCont = [story instantiateViewControllerWithIdentifier:@"pageContentViewController"];
        [tabBarViewCont setSelectedIndex:0];
        [self.window setRootViewController:tabBarViewCont];
        
        
        
        ChatNavigationContollerClass *homeVC = [story instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
        
        PageContentViewController * pgController = [PageContentViewController sharedInstance];
        [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
            if (finished) {
                
            }
        }];
        
        
        
        
    }
    
}

#pragma mark - push sound notification
-(void)playNotificationSound{
    
    // play sound
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    // CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("sms-received"), CFSTR("wav"), NULL);
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("supcalling"), CFSTR("mp3"), NULL);
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundId);
    AudioServicesPlaySystemSound(soundId);
    CFRelease(soundFileURLRef);
}

// Chat End


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
}



//- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
//    // Print full message
//    NSLog(@"%@", [remoteMessage appData]);
//}
#endif


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Chat Start
    
    [[NSUserDefaults standardUserDefaults]setValue:@"yes" forKey:@"appTerminated"];
    [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"getCallStatus"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"AppEnterInBackground"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [RTCPeerConnectionFactory deinitializeSSL];
    [self userIsoffline];
    [self sendHeartBeatStatus:@"0"];
    [self saveContext];
    
    // Chat End
    
    
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}

/*-------------------------------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*------------------------------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    //storing the response from server to dictonary.
    
    NSDictionary *responseDict = (NSDictionary*)response;
    //checking the request type and handling respective response code.
    if (requestType == RequestTypeCloudinaryCredintials ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                // success response.
                [[NSUserDefaults standardUserDefaults] setObject:responseDict forKey:cloudinartyDetails];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
                break;
                
            default:
                break;
        }
    }
}
- (void)errAlert:(NSString *)message {
    //creating alert for error message.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}
/*------------------------------------------------------*/
#pragma mark - Socket
/*------------------------------------------------------*/
-(void)connectToSocket {
    
    
    client = [PicogramSocketIOWrapper sharedInstance];
    [client connectSocket];
    client.socketdelegate = self;
}

// Chat Start

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.3embed.Sup" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PicogramChat" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Sup.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
    // _managedObjectContext = [[NSManagedObjectContext alloc] init];
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

//setting the font size of title

- (void)setNavigationBarBckgrroundImage
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_bar.png"]
                                           forBarMetrics:UIBarMetricsDefault];
    }
    else{
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@""]
                                           forBarMetrics:UIBarMetricsDefault];
    }
    
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIColor clearColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Roboto-Bold" size:17.0], UITextAttributeFont,
      nil]];
}

#pragma mark - adding internet connection error view

- (void)addNoInternetConnectionView
{
    _internetConnectionErrorView = [[UIView alloc] initWithFrame:CGRectMake(0, 64,[UIScreen mainScreen].bounds.size.width, 20)];
    UILabel *internetConectionErrorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    internetConectionErrorLabel.text = @"No internet connection";
    //    [Helper setToLabel:internetConectionErrorLabel Text:@"No internet connection" WithFont:LATO_BOLD FSize:14.0 Color:[UIColor whiteColor]];
    internetConectionErrorLabel.textAlignment = NSTextAlignmentCenter;
    [_internetConnectionErrorView addSubview:internetConectionErrorLabel];
    _internetConnectionErrorView.backgroundColor = [UIColor redColor];
    [window addSubview:_internetConnectionErrorView];
}



-(void)gotoRootViewcontroller{
    
    //    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isHomeScreen"];
    //    UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
    //
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
    //                                @"Main" bundle:[NSBundle mainBundle]];
    //    SplashViewController *viewcontrolelr = [storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"];
    //
    //    //    nav.viewControllers = [NSArray arrayWithObjects:viewcontrolelr, nil];
    //
    //    [nav pushViewController:viewcontrolelr animated:YES];
    
}




-(void)responseFromChannels1:(NSDictionary *)responseDictionary {
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveMessage" object:nil userInfo:responseDictionary];
    
    MSReceive *msReceive = [MSReceive sharedInstance];
    CBLManager* bgMgr = [self.manager copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        @synchronized(self) {
            NSError *error;
            CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
            [msReceive receivedNewMsgWithInfo:responseDictionary onDataBase:bgDB];
        }
    });
    
    
}

-(void)responseFromGroupChannel:(NSDictionary *)responseDictionary{
    
    MSReceive *msReceive = [MSReceive sharedInstance];
    CBLManager *bgMgr =[self.manager copy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        @synchronized(self) {
            NSError *error;
            CBLDatabase *bgDB = [bgMgr databaseNamed:@"couchbasenew" error:&error];
            
            if ([responseDictionary[@"groupType"] integerValue] == 1) {
                
                NSNumber *timeInterval = (NSNumber*)responseDictionary[@"timeStamp"];
                long long timeInt = [timeInterval longLongValue] /1000;
                NSDate *GMTdate = [NSDate dateWithTimeIntervalSince1970:timeInt];
                NSString *localDate = [self localDateFromGMTDate:GMTdate];
                NSArray *arr = @[
                                 @{@"text":@"",
                                   @"date":localDate,
                                   @"messageID":[NSString stringWithFormat:@"%ld",[responseDictionary[@"timeStamp"] longValue]],
                                   @"type":@"0",
                                   @"groupMessageTag":responseDictionary[@"mess"],
                                   @"fromNum":responseDictionary[@"from"],
                                   }];
                
                NSMutableArray *secondArray = [[NSMutableArray alloc]initWithArray:responseDictionary[@"groupMembers"] copyItems:YES];
                if(secondArray.count == 2)
                {
                    NSString *userNAME = [Helper userName];
                    NSArray *items = [[NSString stringWithFormat:@"%@",responseDictionary[@"groupName"]] componentsSeparatedByString:@","];
                    
                    NSString *image = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"userprofilePicUrl"]];
                    
                    NSArray *profilePic = [[NSString stringWithFormat:@"%@",responseDictionary[@"profilePic"]] componentsSeparatedByString:@","];
                    
                    for (int i=0; i<[items count]; i++) {
                        
                        if([[profilePic objectAtIndex:i]isEqualToString:image])
                        {
                            if(i == 0){
                                image = [profilePic objectAtIndex:1];
                                break;
                            }
                            else
                            {
                                image = [profilePic objectAtIndex:0];
                                break;
                            }
                        }
                    }
                    
                    for (int i=0; i<[items count]; i++) {
                        
                        if([[items objectAtIndex:i]isEqualToString:userNAME])
                        {
                            if(i == 0){
                                userNAME = [items objectAtIndex:1];
                                break;
                            }
                            else
                            {
                                userNAME = [items objectAtIndex:0];
                                break;
                            }
                        }
                    }
                    CouchbaseEvents *event = [[CouchbaseEvents alloc]init];
                    [event createDocForGroupChat:bgDB sendingUser:[NSString stringWithFormat:@"%@",responseDictionary[@"createdBy"]] withMessages:arr groupID:[NSString stringWithFormat:@"%@",responseDictionary[@"groupId"]] groupName: [NSString stringWithFormat:@"%@",userNAME] groupPic:image groupMems:responseDictionary[@"groupMembers"]  groupAdmin:responseDictionary[@"admin"] ];
                    
                }
                else
                {
                    CouchbaseEvents *event = [[CouchbaseEvents alloc]init];
                    [event createDocForGroupChat:bgDB sendingUser:[NSString stringWithFormat:@"%@",responseDictionary[@"createdBy"]] withMessages:arr groupID:[NSString stringWithFormat:@"%@",responseDictionary[@"groupId"]] groupName: [NSString stringWithFormat:@"%@",responseDictionary[@"groupName"]] groupPic:[NSString  stringWithFormat:@"%@",responseDictionary[@"profilePic"]] groupMems:responseDictionary[@"groupMembers"]  groupAdmin:responseDictionary[@"admin"] ];
                }
                
            }
            
            if ([responseDictionary[@"groupType"]integerValue] == 9) {
                [msReceive receivedGroupNewMsgWithInfo:responseDictionary onDataBase:bgDB];
            }
            if ([responseDictionary[@"groupType"]integerValue] == 2) {
                [msReceive updateGroupDataInDataBase:responseDictionary onDataBase:bgDB];
            }
            if ([responseDictionary[@"groupType"]integerValue] ==5) {
                [msReceive updateGroupDataInDataBase:responseDictionary onDataBase:bgDB];
            }
            if ([responseDictionary[@"groupType"]integerValue] == 6) {
                [msReceive updateGroupDataInDataBase:responseDictionary onDataBase:bgDB];
            }
            if ([responseDictionary[@"groupType"]integerValue] == 7) {
                [msReceive updateGroupDataInDataBase:responseDictionary onDataBase:bgDB];
            }
            if ([responseDictionary[@"groupType"]integerValue] == 4) {
                [msReceive updateGroupDataInDataBase:responseDictionary onDataBase:bgDB];
            }
            if ([responseDictionary[@"groupType"]integerValue] == 8) {
                [msReceive updateGroupDataInDataBase:responseDictionary onDataBase:bgDB];
            }
            if ([responseDictionary[@"groupType"]integerValue]==16) {
                [msReceive updateGroupDataInDataBase:responseDictionary onDataBase:bgDB];
            }
            
            
        }
        
    });
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"SharePost"];
    if ([savedValue isEqualToString:@"Yes"]) {
        
        [self performSelector:@selector(getGroupMesgs)
                   withObject:self
                   afterDelay:3.0];
        NSString *valueToSave = @"No";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"SharePost"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}


-(void)didConnect {
    
    
    // NSLog(@"didconnect to socket");
    _isConnected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didConnect" object:nil];
    [self sendHeartBeatStatus:@"1"];
    [self  didSubscribeToGetMessageAcks];
    [self didSubscribeToHistory];
    
}


-(void)didDisconnect {
    
    _isConnected = NO;
    [timer invalidate];
    timer = nil;
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didDisconnect" object:nil];
}



-(void)callmethode{
    
    static int i =0;
    // NSLog(@"callmethode  kkkkosfo =%d",i++);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        [[PicogramSocketIOWrapper sharedInstance] sendHeartBeatContinue:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]] withStatus:@"1" andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
    }
}

-(void)sendHeartBeatStatus:(NSString *)status {
    
    if ([status isEqualToString:@"1"]) {
        [timer invalidate];
        timer = nil;
        
        UIApplication *application = [UIApplication sharedApplication];
        BOOL appInactive = application.applicationState == UIApplicationStateActive;
        if (appInactive) {
            
            // timer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(callmethode) userInfo:nil repeats:YES];
        }
    }else{
        [timer invalidate];
        timer = nil;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        
        [[PicogramSocketIOWrapper sharedInstance] sendHeartBeatForUser:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]] withStatus:status andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
        //        [[NSUserDefaults standardUserDefaults]objectForKey:mdeviceToken]
    }
}



-(void)didSubscribeToHistory {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        [self getHistory];
    }
}

-(void)getHistory {
    
    [[PicogramSocketIOWrapper sharedInstance] getMessageHistorySender:@"" receiver:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
}

-(void)didSubscribeToGroupMsgHistory{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        [self getGroupMesgs];
    }
    
    
}
-(void)didSubscribeToGetMessageAcks{
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]);
    
    [[PicogramSocketIOWrapper sharedInstance] getMessageAckHistorySender:@"" receiver:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
    
}

-(void)didSubscribetoOnlineStatus{
    
    
    [[PicogramSocketIOWrapper sharedInstance] sendOnlineStatustoServer:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]] reciver:@"" status:@"1" currentDt:[NSString stringWithFormat:@"%@",[NSDate date]]];
    
}
-(void)userIsoffline{
    
    [[PicogramSocketIOWrapper sharedInstance] sendOnlineStatustoServer:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]] reciver:@"" status:@"0" currentDt:[NSString stringWithFormat:@"%@",[NSDate date]]];
    
}

-(void)getofflineDataWhenagainAdd{
    
    [[PicogramSocketIOWrapper sharedInstance]getofflineDataForAnotherTimeAddtoGroup];
    
}

-(void)sendLastgropcreatTime{
    
    [[PicogramSocketIOWrapper sharedInstance]sendLastcreatedGrouptime:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
    
}

-(void)getGroupMesgs{
    [[PicogramSocketIOWrapper sharedInstance]getofflineGroupMsg:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
}

-(void)messageSentSuccessfullyForMessageID:(NSMutableDictionary *)msgInfo {
    
    MSReceive *msReceive = [MSReceive sharedInstance];
    
    CBLManager* bgMgr = [self.manager copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        @synchronized(self) {
            NSError *error;
            CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
            [msReceive receiveMsgSentWithInfo:msgInfo onDataBase:bgDB];
        }
    });
    
    
}

-(void)messageSentSuccessfullytoGroupForMessageID:(NSMutableDictionary*)msgInfo{
    
    MSReceive *msReceive = [MSReceive sharedInstance];
    CBLManager *bgMgr = [self.manager copy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @synchronized(self) {
            NSError *error;
            CBLDatabase *bgDB = [bgMgr databaseNamed:@"couchbasenew" error:&error];
            [msReceive receiveGroupMsgSentWithInfo:msgInfo onDataBase:bgDB];
        }
        
    });
    
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[alertView message] isEqualToString:@"Accept or Reject the Call"]) {
        
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        
        self.client = [PicogramSocketIOWrapper sharedInstance];
        self.client.socketdelegate = self;
        
        if (buttonIndex == [alertView cancelButtonIndex]) {
            /* The user is rejecting the call, Call the socket and reject the call */
            
            NSDictionary *data = @{@"to" : self.user_msisdn,
                                   @"status":@"Reject"};
            
            [self.client sendEvent:data];
        } else if(buttonIndex == 1) {
            /* The User accepts the call, Call the socket and reject the call */
            NSDictionary *data = @{@"to" : self.user_msisdn,
                                   @"status":@"Accept"};
            [self.client sendEvent:data];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([[alertView message] isEqualToString:@"Accept or Reject the Call"]) {
        if(buttonIndex == 1) {
            /* start the video call after sending the accept message */
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                ARDVideoCallViewController *videoCallViewController =
                [[ARDVideoCallViewController alloc] initForRoom:self.call_id
                                                     isLoopback:NO
                                                    isAudioOnly:NO];
                videoCallViewController.modalTransitionStyle =
                UIModalTransitionStyleCrossDissolve;
                UIViewController *vc = [self topViewController];
                [vc presentViewController:videoCallViewController
                                 animated:YES
                               completion:nil];
            }];
        }
    }
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

-(void)showVideoCallingScreen
{
    NSDictionary *callData = @{@"to" : self.user_msisdn,
                               @"call_id":self.call_id,@"callType":self.callType};
    videoCallViewController *videoCallViewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"videoCallViewController"];
    videoCallViewController.infoDictionary=callData;
    videoCallViewController.isDialing=NO;
    videoCallViewController.modalTransitionStyle =
    UIModalTransitionStyleCrossDissolve;
    UIViewController *vc = [self topViewController];
    [vc presentViewController:videoCallViewController
                     animated:YES
                   completion:nil];
    //
}

-(void)showAudioCallingScreen
{
    NSDictionary *callData = @{@"to" : self.user_msisdn,
                               @"call_id":self.call_id,@"callType":self.callType};
    AudioCallViewController *audioCallViewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AudioCallViewController"];
    audioCallViewController.dataDictionary=[NSMutableDictionary dictionaryWithDictionary:callData];
    audioCallViewController.isDialing=NO;
    audioCallViewController.modalTransitionStyle =
    UIModalTransitionStyleCrossDissolve;
    UIViewController *vc = [self topViewController];
    [vc presentViewController:audioCallViewController
                     animated:YES
                   completion:nil];
}

-(void)gotResponsefromCall:(NSDictionary*)responseDictionary{
    
    NSMutableString *call_id1 = [[NSUserDefaults standardUserDefaults] valueForKey:@"call_id"];
    
    if(!call_id1) {
        call_id1 = [NSMutableString stringWithFormat:@"invalid"];
    }
    
    /* Get the response from Channels here */
    NSArray* status = [responseDictionary valueForKey:@"status"];
    if([[status objectAtIndex:0] isEqualToString:@"live"]) {
        if(![call_id isEqualToString:[responseDictionary valueForKey:@"call_id"]]) {
            /* Open the audio/video call here */
            self.call_id = [responseDictionary valueForKey:@"call_id"];
            self.user_msisdn = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"call_from"]];
            self.callType = [responseDictionary valueForKey:@"callType"];
            
            /* Save the current call id in NSUserDefaults */
            [[NSUserDefaults standardUserDefaults]setValue:[responseDictionary valueForKey:@"call_id"] forKey:@"call_id"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(openIncomingCallScreen) withObject:nil afterDelay:1.0f];
            });
        }
    }
    
}








- (NSString *)localDateFromGMTDate:(NSDate *)gmtDate{
    
    //EEE - day(eg: Thu)
    //MMM - month (eg: Nov)
    // dd - date (eg 01)
    // z - timeZone
    
    //eg : @"EEE MMM dd HH:mm:ss z yyyy"
    
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        //        formatter.dateFormat = @"dd MMM yyyy";
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    });
    
    return [formatter stringFromDate:gmtDate];
}




#pragma mark - SupSocketIOClient delegate





-(void)getRequest{
    
    NSDictionary *requestDict = @{@"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]],
                                  };
    
    // [WebServiceHandler loginUsingPhoneNo:requestDict andDelegate:self];
    //    [WebServiceHandler getGroupChatData:requestDict andDelegate:self];
    
}

// Chat End

@end
