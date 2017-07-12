//
//  AppDelegate.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 09/02/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginManagerLoginResult.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginButton.h>

#import <CoreData/CoreData.h>
#import <SIOSocket/SIOSocket.h>
//#import "CoreLocationController.h"
#import "CouchbaseEvents.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import <UserNotifications/UserNotifications.h>  

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

// Chat Start

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) UIView *internetConnectionErrorView;
@property(nonatomic,assign)Float32 lat;
@property(nonatomic,assign)Float32 log;

@property(nonatomic,strong) SIOSocket *socket;
@property(nonatomic,strong) CBLDatabase *database;
@property(nonatomic,strong) CBLManager *manager;
@property (assign, nonatomic) BOOL isConnected;
@property(assign)BOOL isOngoingVideoCall;


/* Call ID and the participant id of the calling user - Used in webrtc */

@property (nonatomic,strong) NSString *callType;
@property (nonatomic,strong) NSString *call_id;
@property (nonatomic,strong) NSString *user_msisdn;


-(void)subscribeToSocket;
-(void)sendHeartBeatStatus:(NSString *)status ;
-(void)didSubscribeToGetMessageAcks;
-(void)didSubscribeToHistory;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)showVideoCallingScreen;
-(void)showAudioCallingScreen;

-(void)gotResponsefromCall:(NSDictionary*)responseDictionary;

-(void)gotoRootViewcontroller;
-(void)responseFromGroupChannel:(NSDictionary *)responseDictionary;
-(void)messageSentSuccessfullytoGroupForMessageID:(NSMutableDictionary*)msgInfo;

// Chat End




@end

