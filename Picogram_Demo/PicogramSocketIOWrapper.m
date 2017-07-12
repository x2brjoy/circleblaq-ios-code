//
//  PicogramSocketIOWrapper.m
//  Snapchat
//
//  Created by Rahul Sharma on 11/09/15.
//  Copyright (c) 2015 3Embed. All rights reserved.
//

#import "PicogramSocketIOWrapper.h"
#import "SIOClient.h"
#import "SIOConfiguration.h"
#import "WebServiceConstants.h"
#import "TinderGenericUtility.h"
#import "Helper.h"

// Chat Start

#import "ChatViewController.h"
#import "zlib.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "MessageStorage.h"
#import "AppDelegate.h"
#import "ChatHelper.h"
#import <FirebaseMessaging/FirebaseMessaging.h>

// Chat End

static PicogramSocketIOWrapper *shared = nil;
#define timeStamp [[NSDate date] timeIntervalSince1970]*1000

@interface PicogramSocketIOWrapper()<SIOClientDelegate>
@property SIOClient *socketIOClient;
// Start Chat
@property (nonatomic,strong) NSArray *contactArray ;
@property int num;
@property int currentNum;
// Start Chat
@end

@implementation PicogramSocketIOWrapper

@synthesize socketdelegate;


+(instancetype)sharedInstance
{
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[self alloc] init];
            
        });
    }
    return shared;
}

-(void)connectSocket {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [shared socketIOSetup];
    }];
}


-(void)socketIOSetup
{  //shared.socketIOClient =[[SIOClient alloc]init];
    SIOConfiguration *config = [SIOConfiguration defaultConfiguration];
    self.socketIOClient = [SIOClient sharedInstance];
    [self.socketIOClient setConfiguration:config];
    [self.socketIOClient setDelegate:self];
    [self.socketIOClient connect];
    self.channelsName = [[NSMutableArray alloc] init];
    
}

- (void) sioClient:(SIOClient *)client  getFavorate:(NSString*)contacts{
    //NSLog(@"SIO getFavorate contacts %@", contacts);
}

-(void)sendHeartBeatForUser:(NSString*)userName withStatus:(NSString *)status andPushToken:(NSString *)pushToken {
    
    if (!pushToken) {
        pushToken = @"";
    }
    
    
    NSDictionary *dict = @{@"from":userName,
                           @"status":status,
                           @"pushtoken": pushToken,
                           @"device":@"ios"
                           };
    
    //  NSLog(@"heartbeat: %@", dict);
    
    [self.socketIOClient publishToChannel:@"Heartbeat" message:dict];
    
}

- (void) syncContacts:(NSString*)contacts
{
    // NSString *retrievedName = [[NSUserDefaults standardUserDefaults] objectForKey:@"USERNAME"];
    
    if(![self.channelsName containsObject:@"contactSync"])
    {
        [self.channelsName addObject:@"sendMessage"];
        [self.socketIOClient subscribeToChannels:@[@"sendMessage"]];
    }
    
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setValue:contacts forKey:@"contactNumbers"];
    [requestDict setValue:[Helper userName] forKey:@"username"];
    
    // NSLog(@"Publishing data:%@",contacts);
    
    [self.socketIOClient publishToChannel:@"contactSync" message:requestDict];
    //[self.socketIOClient subscribeToChannels:@[@"FavContacts"]];
}




- (void) sioClient:(SIOClient *)client didConnectToHost:(NSString*)host {
    NSLog(@"SIO connect to %@", host);
    
    // NSDictionary *dict = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"PROFILE_KEY"];
    
    if (self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(didConnect)]) {
        [socketdelegate didConnect];
    }
    
    if(![self.channelsName containsObject:@"contactSync"])
    {
        [self.channelsName addObject:@"contactSync"];
        [self.socketIOClient subscribeToChannels:@[@"contactSync"]];
    }
    
    // Chat Start
    [self.socketIOClient subscribeToChannels:@[@"getCallStatus"]];
    [[NSUserDefaults standardUserDefaults]setValue:@"True" forKey:@"getCallStatus"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(didSubscribetoOnlineStatus)]) {
        
        [socketdelegate didSubscribetoOnlineStatus];
    }
    if (self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(sendLastgropcreatTime)]) {
        [socketdelegate sendLastgropcreatTime];
    }
    
    if (self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(getGroupMesgs)]) {
        
        [socketdelegate getGroupMesgs];
    }
    
    if ([self.channelsName containsObject:@"GetMessages"]) {
        
        if (self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(didSubscribeToHistory)]) {
            [self.socketdelegate didSubscribeToHistory];
        }
    }
    
    
    
    if (![self.channelsName containsObject:@"getUpdateduserDetails"]) {
        [self.channelsName addObject:@"getUpdateduserDetails"];
        [self.socketIOClient
         subscribeToChannels:@[@"getUpdateduserDetails"]];
    }
    
    if (![self.channelsName containsObject:@"group"]) {
        [self.channelsName addObject:@"group"];
        [self.socketIOClient subscribeToChannels:@[@"group"]];
        [self callMethodTogetadduserwhileOffline];
    }
    
    if (![self.channelsName containsObject:@"uploadFile"]) {//to upload file to socket
        [self.channelsName addObject:@"uploadFile"];
        [self.socketIOClient subscribeToChannels:@[@"uploadFile"]];
    }
    
    
    if (![self.channelsName containsObject:@"GetMessageAcks"]) {
        
        if (self.socketdelegate && [self.socketdelegate
                                    respondsToSelector:@selector(didSubscribeToGetMessageAcks)]) {
            [self.socketdelegate didSubscribeToGetMessageAcks];
        }
        
    }
    if (![self.channelsName containsObject:@"giveToFav"]) {
        [self.channelsName addObject:@"giveToFav"];
    }
    
    if(![self.channelsName containsObject:@"Message"])
    {
        [self.channelsName addObject:@"Message"];
        [self.socketIOClient subscribeToChannels:@[@"Message"]];
    }
    if (![self.channelsName containsObject:@"MessageRes"]) {
        [self.channelsName addObject:@"MessageRes"];
        [self.socketIOClient subscribeToChannels:@[@"MessageRes"]];
    }
    if(![self.channelsName containsObject:@"FavContacts"])
    {
        [self.channelsName addObject:@"FavContacts"];
        [self.socketIOClient subscribeToChannels:@[@"FavContacts"]];
    }
    if(![self.channelsName containsObject:@"subscribe"])
    {
        [self.channelsName addObject:@"subscribe"];
        [self.socketIOClient subscribeToChannels:@[@"subscribe"]];
    }
    if(![self.channelsName containsObject:@"Heartbeat"])
    {
        [self.channelsName addObject:@"Heartbeat"];
        [self.socketIOClient subscribeToChannels:@[@"Heartbeat"]];
    }
    
    if(![self.channelsName containsObject:@"GetMessages"])
    {
        [self.channelsName addObject:@"GetMessages"];
        [self.socketIOClient subscribeToChannels:@[@"GetMessages"]];
    }
    
    if(![self.channelsName containsObject:@"GetFavorite"])
    {
        [self.channelsName addObject:@"GetFavorite"];
        [self.socketIOClient subscribeToChannels:@[@"GetFavorite"]];
    }
    
    if(![self.channelsName containsObject:@"GetContacts"])
    {
        [self.channelsName addObject:@"GetContacts"];
        [self.socketIOClient subscribeToChannels:@[@"GetContacts"]];
    }
    
    if(![self.channelsName containsObject:@"MessageStatusUpdate"])
    {
        [self.channelsName addObject:@"MessageStatusUpdate"];
        [self.socketIOClient subscribeToChannels:@[@"MessageStatusUpdate"]];
    }
    
    if (![self.channelsName containsObject:@"GetMessageAcks"]) {
        [self.channelsName addObject:@"GetMessageAcks"];
        [self.socketIOClient subscribeToChannels:@[@"GetMessageAcks"]];
    }
    if (![self.channelsName containsObject:@"typing"]) {
        [self.channelsName addObject:@"typing"];
        [self.socketIOClient subscribeToChannels:@[@"typing"]];
    }
    
    if (![self.channelsName containsObject:@"getCurrentTimeStatus"]) {
        [self.channelsName addObject:@"getCurrentTimeStatus"];
        [self.socketIOClient subscribeToChannels:@[@"getCurrentTimeStatus"]];
    }
    if (![self.channelsName containsObject:@"ChangeOnlineStatus"]) {
        [self.channelsName addObject:@"ChangeOnlineStatus"];
        [self.socketIOClient subscribeToChannels:@[@"ChangeOnlineStatus"]];
    }
    if (![self.channelsName containsObject:@"broadCastProfile"]) {
        [self.channelsName addObject:@"broadCastProfile"];
        [self.socketIOClient subscribeToChannels:@[@"broadCastProfile"]];
    }
    
    if (![self.channelsName containsObject:@"getCallStatus"]) {
        [self.channelsName addObject:@"getCallStatus"];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"userName"]) {
            [self PublishToGetCallStatusEvent:[NSDictionary dictionary]];
        }
        
    }
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        if (socketdelegate && [socketdelegate respondsToSelector:@selector(getofflineDataWhenagainAdd)]) {
            [socketdelegate getofflineDataWhenagainAdd];
        }
    }];
    
    
    // Chat End
    
    
}

- (void) sioClient:(SIOClient *)client didSubscribeToChannel:(NSString*)channel {
    // Chat Start
    NSLog(@"SIO subscribe to %@", channel);
    if ([channel isEqualToString:@"GetMessages"]) {
        
        if (self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(didSubscribeToHistory)]) {
            [self.socketdelegate didSubscribeToHistory];
        }
    }
    
    // Chat End
}

- (void) sioClient:(SIOClient *)client didSendMessageToChannel:(NSString *)channel {
    NSLog(@"SIO message sent to %@", channel);
}

- (void) sioClient:(SIOClient *)client didRecieveMessage:(NSArray*)message onChannel:(NSString *)channel {
     NSLog(@"SIO message recieved %@ on %@", message, channel);
    
    
    
    if([channel isEqualToString:@"contactSync"])
    {
        NSArray * response = message;
        NSData *data = [response[0] dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //NSLog(@"private message:%@",json);
        
        if (json) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PrivateContacts" object:[NSDictionary dictionaryWithObject:(NSDictionary *)json forKey:@"contacts"]];
        }
        
        
        
        if(self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(responseFromChannels:)])
        {
            //NSLog(@"private messagInside Delegate");
            [self.socketdelegate responseFromChannels:(NSDictionary *)json];
        }
        
    }
    if ([channel isEqualToString:@"FavContacts"])
    {
        //NSLog(@"Favorites got...");
        NSArray * response = message;
        NSData *data = [response[0] dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //NSLog(@"DETAILS:%@",json);
        NSDictionary *responseDta = (NSDictionary *)json;
        if(responseDta[@"FriendsList"])
        {
            if(self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(responseFromChannels:)])
            {
                [self.socketdelegate responseFromChannels:(NSDictionary *)json];
            }
        }
    }
    
    // Chat Start
    
    if ([channel isEqualToString:@"Heartbeat"]) {
    }else if ([channel isEqualToString:@"ChangeOnlineStatus"])
    {}else{
        
    }
    
    NSLog(@"ChatSIO message recieved %@ on %@", message, channel);
    
    // [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([channel isEqualToString:@"Heartbeat"]) {
        
        NSMutableDictionary *dict = [[message lastObject] mutableCopy];
        NSString *errorNum =[NSString stringWithFormat:@"%@",dict[@"err"]];
        if ([errorNum isEqualToString:@"2"]) {
            
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [app gotoRootViewcontroller];
            });
            
        }
    }
    
    
    if ([channel isEqualToString:@"GetContacts"]) {
        NSError *jsonError;
        // NSString *dataStr = [self stringByRemovingControlCharacters:message[0]];
        // NSData *objectData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        //NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
        //   options:NSJSONReadingMutableContainers
        //     error:&jsonError];
        
        // NSLog(@"got response contact =%@",json);
        NSDictionary *json = message[0];
        
        if (message.count>0) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstResponseCameFromGetContact"];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gotoFavorite" object:nil userInfo:json];
        
        
        
        
        //send ack for getFav
        NSDictionary *responseDictionary = json;
        NSArray *responseArray = [[NSArray alloc] initWithArray:responseDictionary[@"Favorites"]];
        for (NSDictionary *responseDict in responseArray)
        {
            if (responseDict[@"needAck"]) {
                
                PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
                [client callChannelFirstTimeonly:@"2" memNumber:responseDict[@"msisdn"]];
            }
        }
        
    }
    
    
    if ([channel isEqualToString:@"Message"] || [channel isEqualToString:@"GetMessages"]) {
        
        NSMutableDictionary *msgDict = [[message lastObject] mutableCopy];
        NSString *encodedMsg = msgDict[@"payload"];
        encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *postMsg = msgDict[@"payload"];
        
        NSData *nsdataFromBase64String;
        if (encodedMsg) {
            nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:encodedMsg options:0];
        }
        
        
        switch ([msgDict[@"type"] integerValue]) {
            case SocketMessageTypeText:{
                NSString *originalMsg = [[NSString alloc]
                                         initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
                [msgDict setObject:originalMsg forKey:@"pl"];
            }
                break;
                
            case SocketMessageTypePhoto:{
                
                if (encodedMsg == nil) {
                    
                }else if ([encodedMsg isEqualToString:@"KG51bGwp"]){}
                else{
                    [msgDict setObject:encodedMsg forKey:@"pl"];
                }
                
            }
                break;
                
            case SocketMessageTypeVideo:{
                // nsdataFromBase64String = [self gzipInflate:nsdataFromBase64String];
                
                if (encodedMsg == nil) {
                    
                }else if ([encodedMsg isEqualToString:@"KG51bGwp"]){}
                else{
                    [msgDict setObject:encodedMsg forKey:@"pl"];
                }
                
            }
                break;
                
            case SocketMessageTypeLocation:{
                NSString *originalMsg = [[NSString alloc]
                                         initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
                if ([originalMsg containsString:@"(null)"]) {
                    
                }else{
                    [msgDict setObject:originalMsg forKey:@"pl"];
                }
            }
                break;
                
            case SocketMessageTypeContact:{
                
                NSString *originalMsg = [[NSString alloc]
                                         initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
                [msgDict setObject:originalMsg forKey:@"pl"];
                
            }
                break;
                
            case SocketMessageTypeVoiceRec:{
                
                //nsdataFromBase64String = [self gzipInflate:nsdataFromBase64String];
                // [msgDict setObject:nsdataFromBase64String forKey:@"pl"];
            }
            case SocketMessageTypePost:{
                // nsdataFromBase64String = [self gzipInflate:nsdataFromBase64String];
                
                //                if (encodedMsg == nil) {
                //
                //                }else if ([encodedMsg isEqualToString:@"KG51bGwp"]){}
                //                else{
                [msgDict setObject:postMsg forKey:@"pl"];
                //                }
                
            }
                break;
                
            default:
                break;
                
        }
        
        
        if ([msgDict objectForKey:@"pl"]) {
            
            if(self.socketdelegate && [self.socketdelegate respondsToSelector:@selector(responseFromChannels1:)])
            {
                [self.socketdelegate responseFromChannels1:[msgDict copy]];
            }
        }
        
    }
    
    if ([channel isEqualToString:@"MessageRes"]) {
        
        NSMutableDictionary *msgDict = [[message lastObject] mutableCopy];
        if (socketdelegate && [socketdelegate respondsToSelector:@selector(messageSentSuccessfullyForMessageID:)]) {
            [socketdelegate messageSentSuccessfullyForMessageID:msgDict];
        }
    }
    
    if ([channel isEqualToString:@"MessageStatusUpdate"]) {
        NSMutableDictionary *msgDict = [[message lastObject] mutableCopy];
        if (msgDict[@"err"]) {
        }else{
            if (socketdelegate && [socketdelegate respondsToSelector:@selector(messageSentSuccessfullyForMessageID:)]) {
                [socketdelegate messageSentSuccessfullyForMessageID:msgDict];
            }
        }
    }
    if ([channel isEqualToString:@"GetMessageAcks"]) {
        //   NSLog(@"GetMessageAcks,%@ +%@",message, channel);
        NSMutableDictionary *msgDict = [[message lastObject] mutableCopy];
        if (msgDict[@"err"]) {
        }else{
            
            if (socketdelegate && [socketdelegate respondsToSelector:@selector(messageSentSuccessfullyForMessageID:)]) {
                [socketdelegate messageSentSuccessfullyForMessageID:msgDict];}
            
            if ([msgDict[@"status"] isEqualToString:@"3"]) {
                [self removeGetMesgAckFromServer:msgDict];
            }
            
        }
        
    }
    
    if ([channel isEqualToString:@"typing"]) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:message forKey:@"message"] ;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"typingNotification" object:nil userInfo:dict];
    }
    
    if ([channel isEqualToString:@"getCurrentTimeStatus"]) {
        NSDictionary *dict =[NSDictionary dictionaryWithObject:message forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getOnlineorLastseenTime" object:nil userInfo:dict];
        
    }
    
    if ([channel isEqualToString:@"ChangeOnlineStatus"]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:message forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getOnlineStatusContiues" object:nil userInfo:dict];
    }
    if([channel isEqualToString:@"CallEvent"]){
        NSDictionary *data = @{@"status" : [message valueForKey:@"status"]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getResponseFromCallChannel" object:nil userInfo:data];
    }
    
    if ([channel isEqualToString:@"getUpdateduserDetails"]) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:message forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotResponseFromUpdatedDetails" object:nil userInfo:dict];
    }
    
    if ([channel isEqualToString:@"broadCastProfile"]) {
        NSDictionary *dict =[NSDictionary dictionaryWithObject:message forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavlistView" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatlistView" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateContclistView" object:nil userInfo:dict];
    }
    
    if ([channel isEqualToString:@"getCallStatus"]) {
        if([[[message firstObject] valueForKey:@"err"]integerValue]==0)
        {
            NSArray *array=[NSArray arrayWithObjects:@"live", nil];
            NSDictionary *data = @{@"status" : array, @"call_from":[[message firstObject] valueForKey:@"call_from"], @"call_id":[[message firstObject] valueForKey:@"call_id"], @"callType":[[message firstObject] valueForKey:@"callType"]};
            AppDelegate *appdel =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [appdel gotResponsefromCall:data];
            
            
        }
        
    }
    
    if ([channel isEqualToString:@"CallEvent2"]) {
        if ([[[message firstObject] valueForKey:@"err"]integerValue]==0) {
            NSDictionary *data = @{@"status" : [message valueForKey:@"status"]};
            [[NSNotificationCenter defaultCenter]postNotificationName:@"callingNotification" object:nil userInfo:data];
        }
    }
    
    
    if([channel isEqualToString:@"CallInit2"]){
        if([[[message firstObject] valueForKey:@"err"] integerValue]==1)
        {
            if([[[message firstObject] valueForKey:@"message"] isEqualToString:@"busy"])
            {
                NSArray *array=[NSArray arrayWithObjects:@"busy", nil];
                NSDictionary *data = @{@"status" : array};
                [[NSNotificationCenter defaultCenter]postNotificationName:@"callingNotification" object:nil userInfo:data];
            }
            else
            {
                NSArray *array=[NSArray arrayWithObjects:@"user not found", nil];
                NSDictionary *data = @{@"status" : array};
                [[NSNotificationCenter defaultCenter]postNotificationName:@"callingNotification" object:nil userInfo:data];
            }
            
        }
        
    }
    
    
    
    //upload image or video response from sockect
    if ([channel isEqualToString:@"uploadFile"]) {
        
        if ([[[message firstObject]valueForKey:@"err"]integerValue]==0) {
            
            // NSLog(@"channel =%@",message);
            if (message[0][@"groupType"]) {
                
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    //  NSLog(@"got respose from upload image =%@",message);
                    
                    [self sendMessagetoGroupWithUrl:message[0][@"Url"] fromUser:message[0][@"from"] toUser:message[0][@"to"]  withDocId:message[0][@"toDocId"] currentDate:message[0][@"id"] withTpe:message[0][@"type"]  groupName:message[0][@"userName"] thumData:message[0][@"dataSize"] thumbnail:message[0][@"thumbnail"]];
                }];
                
                
            }
            else{
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    // NSLog(@"got respose from upload image =%@",message);
                    [self sendMessageWithUrl:message[0][@"Url"] fromUser:message[0][@"from"] toUser:message[0][@"to"] withDocId:message[0][@"toDocId"] currentDate:message[0][@"id"] withTpe:message[0][@"type"] thumbnail:message[0][@"thumbnail"] dataSize:message[0][@"dataSize"]];
                }];
                
            }
            
        }
        
        
        
    }
    
    
    //Group chat handel
    if ([channel isEqualToString:@"group"]) {
        
        /*just for connect user to Room */
        
        if ([[[message firstObject]objectForKey:@"err"]integerValue] == 0 && [[[message firstObject] objectForKey:@"groupType"]integerValue]== 10) {
            [self sendFeedbacktoType:message];
            //            1000000
            
        }
        
        /*New group Created*/
        
        if ([[[message firstObject]objectForKey:@"err"]integerValue] == 0 && [[[message firstObject] objectForKey:@"groupType"]integerValue]== 1) {
            
            [[FIRMessaging messaging] subscribeToTopic:[[message firstObject]objectForKey:@"groupId"]];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[[message firstObject]objectForKey:@"timeStamp"] forKey:@"saveGrouptimeCreated"];
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
        }
        else if ([[[message firstObject]objectForKey:@"err"]integerValue] == 1 && [[[message firstObject] objectForKey:@"groupType"]integerValue]== 1)
        {
            
            NSDictionary *dict = @{@"userInfo":message};
            
            //            [[NSNotificationCenter defaultCenter]postNotificationName:@"PostChatCreate" object:nil userInfo:dict];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CreatNewGroup" object:nil userInfo:dict];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[[message firstObject]objectForKey:@"timeStamp"] forKey:@"saveGrouptimeCreated"];
            
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            
        }
        
        
        
        //message receive
        if ([[[message firstObject]objectForKey:@"err"]integerValue] == 0 && [[[message firstObject] objectForKey:@"groupType"]integerValue]==9) {
            
            NSMutableDictionary *msgDict = [[message lastObject] mutableCopy];
            if([msgDict[@"type"]integerValue] == 6 )
            {
                
                
                
                [msgDict setObject:msgDict[@"payload"] forKey:@"pl"];
                
                
                
            }
            else
            {
                NSString *encodedMsg = msgDict[@"payload"];
                encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                
                NSData *nsdataFromBase64String;
                if (encodedMsg) {
                    nsdataFromBase64String = [[NSData alloc]
                                              initWithBase64EncodedString:encodedMsg options:0];
                }
                
                
                
                switch ([msgDict[@"type"] integerValue]) {
                    case SocketMessageTypeText:{
                        NSString *originalMsg = [[NSString alloc]
                                                 initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
                        [msgDict setObject:originalMsg forKey:@"pl"];
                    }
                        break;
                        
                    case SocketMessageTypePhoto:{
                        
                        if (encodedMsg == nil) {
                            
                        }else{
                            [msgDict setObject:encodedMsg forKey:@"pl"];
                        }
                    }
                        break;
                        
                    case SocketMessageTypeVideo:{
                        
                        if (encodedMsg == nil) {
                        }else{
                            [msgDict setObject:encodedMsg forKey:@"pl"];
                        }
                        
                    }
                        break;
                        
                        
                        
                        
                    case SocketMessageTypeLocation:{
                        NSString *originalMsg = [[NSString alloc]
                                                 initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
                        if ([originalMsg containsString:@"(null)"]) {
                            
                        }else{
                            [msgDict setObject:originalMsg forKey:@"pl"];
                        }
                    }
                        break;
                        
                    case SocketMessageTypeContact:{
                        
                        NSString *originalMsg = [[NSString alloc]
                                                 initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
                        [msgDict setObject:originalMsg forKey:@"pl"];
                        
                    }
                        break;
                        
                    case SocketMessageTypeVoiceRec:{
                        
                        // nsdataFromBase64String = [self gzipInflate:nsdataFromBase64String];
                        // [msgDict setObject:nsdataFromBase64String forKey:@"pl"];
                    }
                        
                    default:
                        break;
                        
                }
                
            }
            
            if ([msgDict objectForKey:@"pl"])
            {
                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [app responseFromGroupChannel:[msgDict copy]];
            }
            
        }
        else if ([[[message firstObject]objectForKey:@"err"] integerValue] ==1 && [[[message firstObject] objectForKey:@"groupType"] integerValue] == 9){
            //message Res
            
            AppDelegate *appdel =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [appdel messageSentSuccessfullytoGroupForMessageID:[[message firstObject] mutableCopy]];
        }
        
        if ([[[message firstObject] objectForKey:@"err"] integerValue] ==3 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 8) {
            
            [[FIRMessaging messaging] unsubscribeFromTopic:[[message firstObject]objectForKey:@"groupId"]];

            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"LeaveGroup" object:self userInfo:[message firstObject]];
        }
        
        
        /*leave group response*/
        if ([[[message firstObject] objectForKey:@"err"]integerValue]==0 && [[[message firstObject] objectForKey:@"groupType"] integerValue] == 8) {
            
            AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            //            //call heartBeat when remove one member
            NSDictionary *dict = [message firstObject];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"lastRmvTym"]  forKey:@"lastRmvTym"];
            //            [self sendHeartBeatForUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] withStatus:@"1" andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
            
            
        }else if ([[[message firstObject] objectForKey:@"err"]integerValue]==1 && [[[message firstObject] objectForKey:@"groupType"] integerValue] == 8){
            
            AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            //            //call heartBeat when remove one member
            NSDictionary *dict = [message firstObject];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"lastRmvTym"]  forKey:@"lastRmvTym"];
            //            [self sendHeartBeatForUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] withStatus:@"1" andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
            
        }
        
        
        
        
        
        /*update GroupPic Response*/
        if ([[[message firstObject]objectForKey:@"err"] integerValue] ==0 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 2) {
            
            AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            
        }else if ([[[message firstObject]objectForKey:@"err"] integerValue] ==1 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 2){
            
            AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
        }
        
        
        /*update GroupMembers in group*/
        
        if ([[[message firstObject]objectForKey:@"err"] integerValue] ==0 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 5) {
            
            AppDelegate *app =(AppDelegate *) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            
            //            //call heartBeat when remove one member
            NSDictionary *dict = [message firstObject];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"newMemTym"]  forKey:@"newMemTym"];
            //            [self sendHeartBeatForUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] withStatus:@"1" andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
            
            
        }else if ([[[message firstObject]objectForKey:@"err"] integerValue] ==1 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 5){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addUsertoGroup" object:nil];
            AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            //            //call heartBeat when remove one member
            NSDictionary *dict = [message firstObject];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"newMemTym"]  forKey:@"newMemTym"];
            //            [self sendHeartBeatForUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] withStatus:@"1" andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
            
            
        }
        
        /*update GroupName */
        
        if ([[[message firstObject]objectForKey:@"err"] integerValue] ==0 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 6){
            
            AppDelegate *app =(AppDelegate *) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
        }else if ([[[message firstObject]objectForKey:@"err"] integerValue] ==1 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 6){
            
            AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
        }
        
        
        
        /*make Group Admin response*/
        if ([[[message firstObject]objectForKey:@"err"] integerValue] ==0 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 7){
            
            
            AppDelegate *app =(AppDelegate *) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            
        }else if ([[[message firstObject]objectForKey:@"err"] integerValue] ==1 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 7){
            
            AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            
        }
        
        
        
        /*remove from group response*/
        
        if ([[[message firstObject]objectForKey:@"err"] integerValue] ==0 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 4){
            
            
            AppDelegate *app =(AppDelegate *) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            //call heartBeat when remove one member
            NSDictionary *dict = [message firstObject];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"lastRmvTym"]  forKey:@"lastRmvTym"];
            // [self sendHeartBeatForUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] withStatus:@"1" andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
            
            
            
        }else if ([[[message firstObject]objectForKey:@"err"] integerValue] ==1 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 4){
            
            
            AppDelegate *app =(AppDelegate*) [UIApplication sharedApplication].delegate;
            [app responseFromGroupChannel:[message firstObject]];
            
            //call heartBeat when remove one member
            NSDictionary *dict = [message firstObject];
            [[NSUserDefaults standardUserDefaults] setObject:dict[@"lastRmvTym"]  forKey:@"lastRmvTym"];
            //[self sendHeartBeatForUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] withStatus:@"1" andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
            
        }
        
        
        
        
        /*add removed user to group*/
        
        if ([[[message firstObject]objectForKey:@"err"] integerValue] ==0 && [[[message firstObject] objectForKey:@"groupType"]integerValue] == 16){
            
            AppDelegate *app =(AppDelegate*)[UIApplication sharedApplication].delegate;
            
            NSString *docID =[ChatHelper getDocumentIDWithGroupID:[[message firstObject] objectForKey:@"groupId"] onDatabase:app.database];
            if (docID.length==0) {
                //creat new group
                NSMutableDictionary *dict = [[message firstObject] mutableCopy];
                [dict setValue:@"1" forKey:@"groupType"];
                [app responseFromGroupChannel:dict];
            }else{
                
                AppDelegate *app =(AppDelegate *) [UIApplication sharedApplication].delegate;
                [app responseFromGroupChannel:[message firstObject]];
                
            }
        }
    }
    
    // Chat End
    
}

// Chat Start

- (void) sioClient:(SIOClient *)client didDisconnectFromHost:(NSString*)host {
    [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"getCallStatus"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (socketdelegate && [socketdelegate respondsToSelector:@selector(didDisconnect)]) {
        [socketdelegate didDisconnect];
    }
    NSLog(@"SIO disconnect from %@", host);
}

- (void) sioClient:(SIOClient *)client gotError:(NSDictionary *)errorInfo {
    
    NSLog(@"SIO Error : %@", errorInfo);
}

-(void)disconnectSocket{
    
}

#pragma mark - Chat Socket Methods


-(void)sendMessage:(NSData *)message fromUser:(NSString *)fromUserName toUser:(NSString *)toUserName withDocId:(NSString *)docID currentDate:(NSDate *)currentDate withTpe:(SocketMessageType)socketMessageType {
    
    NSString *messageStr;
    if (socketMessageType == 0 || socketMessageType == 3 || socketMessageType == 4) {
        
        messageStr  =[message base64Encoding];
        // messageStr = [self encodeStringTo64:messageStr];
        
    }else{
        
        NSData *data1 = [self gzipDeflate:message];
        messageStr  = [data1 base64EncodedStringWithOptions:kNilOptions];
    }
    
    
    NSDictionary *dict = @{@"from":fromUserName,
                           @"timestamp":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"payload":messageStr,
                           @"to":toUserName,
                           @"id":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"type":[NSString stringWithFormat:@"%lu",(unsigned long)socketMessageType],
                           @"toDocId":docID ,
                           //                           @"userName":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Name"]]
                           };
    NSLog(@"sendMessage message sent to %@", dict);
    [self.socketIOClient publishToChannel:@"Message" message:dict];
    
}

-(void)sendMessageWithUrl:(NSString *)url fromUser:(NSString *)fromUserName toUser:(NSString *)toUserName withDocId:(NSString *)docID currentDate:(NSDate *)currentDate withTpe:(NSString *)socketMessageType thumbnail:(NSString*)thubnail dataSize:(NSString*)dataSize{
    
    //thubnail = @"";
    NSDictionary *dict = @{@"from":fromUserName,
                           @"timestamp":currentDate,
                           @"payload":[self encodeStringTo64:url],
                           @"to":toUserName,
                           @"id":currentDate,
                           @"type":[NSString stringWithFormat:@"%@",socketMessageType],
                           @"toDocId":docID ,
                           //                           @"userName":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Name"]],
                           @"thumbnail":thubnail,
                           @"dataSize":dataSize
                           };
    
    NSLog(@"send messga to server =%@",dict);
    [self.socketIOClient publishToChannel:@"Message" message:dict];
    
}


/* uploadFileToSocket*/

-(void)uploadFiletoSocketgetUrl:(NSData *)message fromUser:(NSString *)fromUserName toUser:(NSString *)toUserName withDocId:(NSString *)docID currentDate:(NSDate *)currentDate withTpe:(SocketMessageType)socketMessageType thumData:(NSString *)thumdata{
    
    NSString  *messageStr  = [message base64EncodedStringWithOptions:kNilOptions];
    NSString *dataLenth = [NSString stringWithFormat:@"%lu",(unsigned long)message.length];
    
    NSDictionary *dict = @{@"from":fromUserName,
                           @"timestamp":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"payload":messageStr,
                           @"to":toUserName,
                           @"id":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"type":[NSString stringWithFormat:@"%lu",(unsigned long)socketMessageType],
                           @"toDocId":docID ,
                           //                           @"userName":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Name"]],
                           @"thumbnail":thumdata,
                           @"dataSize":dataLenth
                           };
    
    NSLog(@"uplaod imahe =%@",dict);
    [self.socketIOClient publishToChannel:@"uploadFile" message:dict];
    
    
}


-(void)uploadFiletoSockectForGroupChat:(NSData*)message fromUser:(NSString *)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDate:(NSDate *)currentDate  withTpe:(SocketMessageType)socketMessageType groupName:(NSString*)groupName  thumData:(NSString *)thumdata{
    
    NSString  *messageStr  = [message base64EncodedStringWithOptions:kNilOptions];
    NSString *dataLenth = [NSString stringWithFormat:@"%lu",(unsigned long)message.length];
    
    
    NSDictionary *dict = @{@"from":fromUserName,
                           @"to":toUserName,
                           @"payload":messageStr,
                           @"toDocId":docID,
                           @"id":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"userName":groupName,
                           @"timestamp":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"groupType":@"9",
                           @"type":[NSString stringWithFormat:@"%lu",(unsigned long)socketMessageType],
                           @"thumbnail":thumdata,
                           @"dataSize":dataLenth,
                           };
    
    
    NSLog(@"uplaod imahe =%@",dict);
    [self.socketIOClient publishToChannel:@"uploadFile" message:dict];
    
    
}

-(void)sendMessagetoGroupWithUrl:(NSString*)url fromUser:(NSString *)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDate:(NSDate *)currentDate  withTpe:(NSString *)socketMessageType groupName:(NSString*)groupName  thumData:(NSString *)thumdata thumbnail:(NSString*)thubnail{
    
    
    NSDictionary *dict = @{@"from":fromUserName,
                           @"to":toUserName,
                           @"payload":[self encodeStringTo64:url],
                           @"toDocId":docID,
                           @"id":currentDate,
                           @"userName":groupName,
                           @"timestamp":currentDate,
                           @"groupType":@"9",
                           @"type":[NSString stringWithFormat:@"%@",socketMessageType],
                           @"thumbnail":thubnail,
                           @"dataSize":thumdata,
                           };
    
    
    NSLog(@"send mess to Group =%@",dict);
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}


-(void)sendMessagetoGroup:(NSData*)message fromUser:(NSString *)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDate:(NSDate *)currentDate  withTpe:(SocketMessageType)socketMessageType groupName:(NSString*)groupName{
    
    NSString *messageStr;
    if (socketMessageType ==0 ||socketMessageType ==3 || socketMessageType ==4 || socketMessageType ==6) {
        messageStr = [message base64Encoding];
    }else{
        
        NSData *data1 = [self gzipDeflate:message];
        messageStr  = [data1 base64EncodedStringWithOptions:kNilOptions];
    }
    
    NSDictionary *dict = @{@"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]],
                           @"to":toUserName,
                           @"payload":messageStr,
                           @"toDocId":docID,
                           @"id":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"userName":groupName,
                           @"timestamp":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"groupType":@"9",
                           @"type":[NSString stringWithFormat:@"%lu",(unsigned long)socketMessageType],
                           };
    
    NSLog(@"send mess to Group =%@",dict);
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}



-(void)sendPostToGroup:(NSArray*)message fromUser:(NSString *)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDate:(NSDate *)currentDate  withTpe:(SocketMessageType)socketMessageType groupName:(NSString*)groupName{
    
    //    NSString *messageStr;
    //    if (socketMessageType ==0 ||socketMessageType ==3 || socketMessageType ==4) {
    //        messageStr = [message base64Encoding];
    //    }else{
    //
    //        NSData *data1 = [self gzipDeflate:message];
    //        messageStr  = [data1 base64EncodedStringWithOptions:kNilOptions];
    //    }
    
    NSDictionary *dict = @{@"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]],
                           @"to":toUserName,
                           @"payload":message,
                           @"toDocId":docID,
                           @"id":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"userName":groupName,
                           @"timestamp":[NSString stringWithFormat:@"%.0f",[currentDate timeIntervalSince1970]*1000],
                           @"groupType":@"9",
                           @"type":[NSString stringWithFormat:@"%lu",(unsigned long)socketMessageType],
                           };
    
    NSLog(@"send mess to Group =%@",dict);
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}

-(void)sendMessageAgain:(NSString *)message fromUser:(NSString*)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDateId:(NSString*)currentID withType:(SocketMessageType)socketMessageType{
    
    
    NSDictionary *dict = @{@"from":fromUserName,
                           @"timestamp":[NSString stringWithFormat:@"%@",currentID],
                           @"payload":[self encodeStringTo64:message],
                           @"to":toUserName,
                           @"id":[NSString stringWithFormat:@"%@",currentID],
                           @"type":[NSString stringWithFormat:@"%lu",(unsigned long)socketMessageType],
                           @"toDocId":docID ,
                           @"userName":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Name"]]
                           };
    NSLog(@"sendMessage Again mess to Group =%@",dict);
    
    [self.socketIOClient publishToChannel:@"Message" message:dict];
    
}
-(void)sendHeartBeatContinue:(NSString *)userName withStatus:(NSString *)status andPushToken:(NSString*)pushToken{
    
    
    if (!pushToken) {
        pushToken = @"";
    }
    
    NSString *deviceIdsend = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceIdSave"]];
    
    
    NSDictionary *dict = @{@"from":userName,
                           @"status":status,
                           @"pushtoken": pushToken,
                           @"device": @"ios",
                           @"DeviceId":deviceIdsend,
                           @"heartType":@"1",
                           };
    NSLog(@"sendHeartBeatContinue =%@",dict);
    [self.socketIOClient publishToChannel:@"Heartbeat" message:dict];
    
}



-(void)sendReceivedAcknowledgement:(NSString *)fromUser withMessageID:(NSString *)messageID ToReciver:(NSString*)toReciver docID:(NSString*)documentID messegStatus:(NSString *)msgStatus{
    
    
    if (!documentID) {
        documentID= @"";
    }
    
    NSDictionary *dict = @{@"from":fromUser,
                           @"msgIds":@[messageID],
                           @"to":toReciver,
                           @"doc_id":documentID,
                           @"status":msgStatus
                           };
    
    NSLog(@"sendReceivedAcknowledgement =%@",dict);
    [self.socketIOClient publishToChannel:@"MessageAck" message:dict];
    
}

-(void)sendReadMessageStatus:(NSString *)msgStatus fromUser:(NSString*)fromUser toUser:(NSString*)toUser withMessageID:(NSString*)messageID{
    
    
    NSDictionary *dict =@{@"from":fromUser,
                          @"to":toUser,
                          @"msgId":@[messageID],
                          @"status":msgStatus
                          };
    
    NSLog(@"sendReadMessageStatus =%@",dict);
    
    [self.socketIOClient publishToChannel:@"MessageStatusUpdate" message:dict];
    
}

-(void)getMessageHistorySender:(NSString *)fromUser receiver:(NSString*)toUser {
    
    if (toUser.length==0) {
        toUser =@"";
    }
    
    NSDictionary *dict = @{@"msg_from":fromUser,
                           @"msg_to":toUser
                           };
    
    NSLog(@"getMessageHistorySender =%@",dict);
    
    
    [self.socketIOClient publishToChannel:@"GetMessages" message:dict];
    
}

-(void)getMessageAckHistorySender:(NSString *)fromUser receiver:(NSString*)toUser{
    
    if (toUser.length ==0) {
        toUser =@"";
    }
    NSDictionary *dict =@{
                          @"from":[NSString stringWithFormat:@"%@",toUser]
                          };
    
    NSLog(@"getMessageAckHistorySender =%@",dict);
    
    [self.socketIOClient publishToChannel:@"GetMessageAcks" message:dict];
    
}
-(void)sendOnlineStatustoServer:(NSString *)userName reciver:(NSString *)reciverName status:(NSString *)status currentDt:(NSString *)dt{
    if (userName.length ==0) {
        userName =@"";}
    NSDictionary *dict =@{
                          @"from":userName,
                          @"status":status,
                          @"DateTime":dt
                          };
    
    NSLog(@"sendOnlineStatustoServer =%@",dict);
    
    [self.socketIOClient publishToChannel:@"changeSt" message:dict];
}

-(void)sendTypeingStatustoServer:(NSString *)recevierName{
    
    NSString *userName =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSDictionary *dict =@{
                          @"to":recevierName,
                          @"from":userName
                          };
    
    NSLog(@"sendTypeingStatustoServer =%@",dict);
    
    [self.socketIOClient publishToChannel:@"typing" message:dict];
}

-(void)getLastseenFromServer:(NSString *)reciverName{
    
    if (reciverName.length==0) {
        return;
    }
    NSDictionary *dict = @{
                           @"to":reciverName
                           };
    
    NSLog(@"getLastseenFromServer =%@",dict);
    
    
    [self.socketIOClient publishToChannel:@"getCurrentTimeStatus" message:dict];
    
}

-(void)sendUserNumforaAnyUpdate:(NSMutableArray*)usersNumbers{
    
    NSDictionary *dict = @{
                           @"from":usersNumbers
                           };
    
    NSLog(@"sendUserNumforaAnyUpdate =%@",dict);
    
    [self.socketIOClient publishToChannel:@"getUpdateduserDetails" message:dict];
}

-(void)broadCastProfileToserver:(NSString *)username{
    
    username = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSDictionary *dict = @{
                           @"from":username
                           };
    
    NSLog(@"broadCastProfileToserver =%@",dict);
    
    [self.socketIOClient publishToChannel:@"broadCastProfile" message:dict];
}

#pragma Group Chat Socket Work

-(void)creatNewGroup:(NSString*)groupName groupMembers:(NSArray*)groupMembers groupId:(NSString*)groupID groupPic:(NSString*)groupPic type:(NSString *)type{
    
    NSDictionary *dict = @{
                           @"groupName":groupName,
                           @"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]],
                           @"groupId":groupID,
                           @"profilePic":groupPic,
                           @"groupMembers":groupMembers,
                           @"groupType":type,
                           };
    
    NSLog(@"creatNewGroup =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    // NSLog(@"creat group channel =%@",dict);
}

-(void)addMembersFirstTimetoGroupChat:(NSArray*)groupMembers groupId:(NSString*)groupID type:(NSString*)type{
    
    
    NSDictionary *dict = @{
                           @"memNum":groupMembers,
                           @"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]],
                           @"groupId":groupID,
                           @"groupType":type,
                           };
    
    NSLog(@"addMembersFirstTimetoGroupChat =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
    // NSLog(@"addMembersFirstTimetoGrou =%@",dict);
    
}

-(void)faltu{
    
    NSDictionary *dict = @{
                           
                           };
    [self.socketIOClient publishToChannel:@"test" message:dict];
    
    
}
-(void)addMembersToGroup:(NSString*)contacNum groupId:(NSString*)groupID type:(NSString*)type groupName:(NSString *)groupName groupPic:(NSString*)groupPic gpCreatedBy:(NSString*)gpCreatedBy docId:(NSString *)documentID{
    
    
    NSDictionary *dict = @{
                           @"memNum":contacNum,
                           @"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]],
                           @"groupId":groupID,
                           @"groupType":type,
                           @"groupName":groupName,
                           @"profilePic":groupPic,
                           @"createdBy":gpCreatedBy,
                           @"toDocId":documentID
                           };
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    NSLog(@"add new memebers to group =%@",dict);
    
}

-(void)sendFeedbacktoType:(NSArray *)message{
    
    NSString *groupId =  [NSString stringWithFormat:@"%@",[[message firstObject] objectForKey:@"groupId"]];
    NSString *gpDocId = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"groupId"]];
    
    
    if (gpDocId.length>0) {
        
        NSDictionary *dict = @{
                               @"groupId":[[message firstObject] objectForKey:@"groupId"],
                               @"groupType":@"10",
                               @"createdBy":[[message firstObject]objectForKey:@"createdBy"],
                               @"groupName":[[message firstObject]objectForKey:@"groupName"],
                               @"profilePic":[[message firstObject]objectForKey:@"profilePic"],
                               @"from":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                               @"timeStamp":[[message firstObject]objectForKey:@"timeStamp"],
                               @"groupMembers":[[message firstObject]objectForKey:@"groupMembers"],
                               @"admin":[[message firstObject]objectForKey:@"admin"],
                               @"isgroupalive":@"YES"
                               };
        
        NSLog(@"send feedBack =%@",dict);
        [self.socketIOClient publishToChannel:@"group" message:dict];
        
        
    }else{
        
        NSDictionary *dict = @{
                               @"groupId":[[message firstObject] objectForKey:@"groupId"],
                               @"groupType":@"10",
                               @"createdBy":[[message firstObject]objectForKey:@"createdBy"],
                               @"groupName":[[message firstObject]objectForKey:@"groupName"],
                               @"profilePic":[[message firstObject]objectForKey:@"profilePic"],
                               @"from":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                               @"timeStamp":[[message firstObject]objectForKey:@"timeStamp"],
                               @"groupMembers":[[message firstObject]objectForKey:@"groupMembers"],
                               @"admin":[[message firstObject]objectForKey:@"admin"]
                               };
        NSLog(@"send feedBack =%@",dict);
        [self.socketIOClient publishToChannel:@"group" message:dict];
        
    }
    
    
    
}

-(void)sendLastcreatedGrouptime:(NSString *)userName {
    
    NSString *lastgrouptime = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"saveGrouptimeCreated"]];
    if ([lastgrouptime isEqualToString:@"(null)"]) {
        lastgrouptime = @"0";
    }
    
    NSDictionary *dict = @{@"from":userName,
                           @"timeStamp":lastgrouptime,
                           @"groupType":@"14"
                           };
    
    NSLog(@"last Created =%@",dict);
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}

-(void)sendRequestToUpdateGroupName:(NSString*)groupName groupId:(NSString*)groupID documentId:(NSString*)documentID{
    
    NSDictionary *dict = @{@"groupType":@"6",
                           @"groupId":groupID,
                           @"groupName":groupName,
                           @"toDocId":documentID,
                           @"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]
                           };
    
    NSLog(@"sendRequestToUpdateGroupName =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}

//Leave Group request
-(void)sendRequestToleaveGroup:(NSString *)fromUser withGroupId:(NSString*)groupId documentID:(NSString *)documentID{
    
    NSDictionary *dict = @{@"from":fromUser,
                           @"groupId":groupId,
                           @"groupType":@"8",
                           @"toDocId":documentID
                           };
    
    NSLog(@"sendRequestToleaveGroup =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}

-(void)sendRequestToUpdateGroupPic:(NSString *)gpPicUrl groupId:(NSString *)groupID documentId:(NSString *)documentID{
    
    //to update Group Pic
    NSDictionary *dict =@{@"groupType":@"2",
                          @"groupId":groupID,
                          @"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] ,
                          @"profilePic":gpPicUrl,
                          @"toDocId":documentID,
                          };
    NSLog(@"sendRequestToUpdateGroupPic =%@",dict);
    
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}

//publish to get offline group message
-(void)getofflineGroupMsg:(NSString *)userName{
    
    NSDictionary *dict = @{@"from":userName,
                           @"groupType":@"13",
                           };
    
    NSLog(@"getofflineGroupMsg =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    NSLog(@"type 13 =%@",dict);
}


//send recived msg ack
-(void)sendReceivedAcknowledgementForGroup:(NSString*)fromUser withMessageID:(NSString*)messageID groupID:(NSString*)groupID messageStatus:(NSString*)msgStatus{
    
    
    NSDictionary *dict= @{@"from":fromUser,
                          @"groupId":groupID,
                          @"status":msgStatus,
                          @"messId":@[messageID],
                          @"groupType":@"12"
                          };
    
    NSLog(@"send Recive msg =%@",dict);
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}

-(void)sendAckToserverForGroupUpdatedDataRecive:(NSString *)groupID groupType:(NSString*)groupType{
    //type
    NSLog(@"sendAckToserverForGroupUpdatedDataRecive =%@   %@",groupID,groupType);
    
    NSMutableDictionary *dict1 = [NSMutableDictionary new];
    [dict1 setObject:@"11" forKey:@"groupType"];
    [dict1 setObject:groupID forKey:@"groupId"];
    
    if ([groupType integerValue] == 2) {
        [dict1 setObject:@"1" forKey:@"getPpic"];
    }else if ([groupType integerValue] == 6){
        
        [dict1 setObject:@"1" forKey:@"getName"];
    }else if ([groupType integerValue] == 5){
        
        [dict1 setObject:@"1" forKey:@"getMem"];
    }
    else if ([groupType integerValue] == 7){
        
        [dict1 setObject:@"1" forKey:@"getAdmin"];
    }
    else if ([groupType integerValue] == 16){
        
        [dict1 setObject:@"1" forKey:@"getDelGrp"];
    }else if ([groupType integerValue] ==8)
    {
        NSString *lastTime= [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastRmvTym"]];
        [dict1 setObject:lastTime forKey:@"lastRmvTym"];
        [dict1 setObject:@"1" forKey:@"removeUser"];
    }
    else if ([groupType integerValue] == 4){
        
        NSString *lastTime= [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastRmvTym"]];
        [dict1 setObject:lastTime forKey:@"lastRmvTym"];
        [dict1 setObject:@"1" forKey:@"removeUser"];
    }
    
    [dict1 setObject:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"from"];
    
    //  NSLog(@"send Ack =%@",dict1);
    [self.socketIOClient publishToChannel:@"group" message:dict1];
}




-(void)sendRequestToMakeGroupAdmin:(NSString *)groupID memNumber:(NSString*)memNumber documentID:(NSString*)documentID{
    
    NSDictionary *dict = @{@"memNum":memNumber,
                           @"groupId":groupID,
                           @"groupType":@"7",
                           @"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]],
                           @"toDocId":documentID,
                           };
    
    NSLog(@"sendRequestToMakeGroupAdmin =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}

-(void)sendRequestTORemoveFromGroup:(NSString *)groupID memNumber:(NSString *)memNUmber documentID:(NSString*)documentID{
    
    NSDictionary *dict =@{@"groupId":groupID,
                          @"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]],
                          @"memNum":memNUmber,
                          @"toDocId":documentID,
                          @"groupType":@"4",
                          };
    
    NSLog(@"sendRequestTORemoveFromGroup =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}



//faltu calling this methode no use ...
-(void)callTypeElevenToRemoveUser:(NSString*)Usnumber groupID:(NSString*)groupID {
    
    NSDictionary *dict = @{@"removeUser":Usnumber,
                           @"groupId":groupID,
                           @"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]],
                           @"groupType":@"11"
                           };
    NSLog(@"callTypeElevenToRemoveUser =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
}

-(void)callChannelFirstTimeonly:(NSString*)type memNumber:(NSString *)number{
    
    NSDictionary *dict = @{@"from":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                           @"conType":type,
                           @"memNum":number,
                           };
    
    NSLog(@"call first time =%@",dict);
    
    [self.socketIOClient publishToChannel:@"giveToFav" message:dict];
    
}

-(void)callMethodTogetadduserwhileOffline{
    
    
    NSString *lastTime= [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastRmvTym"]];
    NSLog(@"last time =%@",lastTime);
    
    NSDictionary *dict = @{@"lastRmvTym":lastTime,
                           @"newMemTym":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"newMemTym"]],
                           @"msisdn":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                           @"groupType":@"15"
                           };
    
    NSLog(@"callMethodTogetadduserwhileOffline =%@",dict);
    
    [self.socketIOClient publishToChannel:@"group" message:dict];
    
    NSLog(@"type = 15 =%@",dict);
    
}

-(void)getofflineDataForAnotherTimeAddtoGroup{
    //grouptype 16 get offlien data when other time added
    
        NSDictionary *dict =@{@"msisdn":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                              @"groupType":@"16",
                              };
        [self.socketIOClient publishToChannel:@"group" message:dict];
        NSLog(@"type 16 call =%@",dict);
}


- (NSString *)stringByRemovingControlCharacters: (NSString *)inputString
{
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    NSRange range = [inputString rangeOfCharacterFromSet:controlChars];
    if (range.location != NSNotFound) {
        NSMutableString *mutable = [NSMutableString stringWithString:inputString];
        while (range.location != NSNotFound) {
            [mutable deleteCharactersInRange:range];
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return inputString;
}


//Copy Here

-(NSString*)encodeStringTo64:(NSString*)fromString
{
    NSData *plainData = [fromString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
    } else {
        base64String = [plainData base64Encoding];                              // pre iOS7
    }
    
    return base64String;
}
- (void)callUser:(NSDictionary *)data
{
    /* Update the online status of the user here, Sending of socket will not work without that */
    NSDictionary *requestDict1 = @{@"msisdn" : [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                                   @"Status" : @"1",
                                   @"DateTime" : @"2016-01-02 15:07:18"};
    
    [self.socketIOClient publishToChannel:@"UpdateOnlineStatus" message:requestDict1];
    NSLog(@"publish UpdateOnlineStatus =%@",requestDict1);
    
    /* Call the call init API here */
    NSDictionary *requestDict = @{@"from" : [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"],
                                  @"to" : [data valueForKey:@"to"],
                                  @"call_id" : [data valueForKey:@"call_id"],@"callType":data[@"callType"],
                                  @"userName" : [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Name"]]
                                  };
    
    NSLog(@"publish UpdateOnlineStatus =%@",requestDict);
    
    [self.socketIOClient publishToChannel:@"CallInit2" message:requestDict];
    
    /* Subscribe to the CallEventChannel */
    [self.socketIOClient subscribeToChannels:@[@"CallEvent2"]];
    
    ///Subscribe to CallInit as well
    [self.socketIOClient subscribeToChannels:@[@"CallInit2"]];
}

- (void) sendEvent:(NSDictionary *)data
{
    
    /* Update the online status of the user here, Sending of socket will not work without that */
    NSDictionary *requestDict1 = @{@"msisdn" :  [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                                   @"Status" : @"1",
                                   @"DateTime" : @"2016-01-02 15:07:18"};
    
    NSLog(@"publish sendEvent =%@",requestDict1);
    
    [self.socketIOClient publishToChannel:@"UpdateOnlineStatus" message:requestDict1];
    
    NSDictionary *requestDict = @{@"from" :[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"],
                                  @"to" : [data valueForKey:@"to"],
                                  @"status" : [data valueForKey:@"status"],
                                  @"call_id":[data valueForKey:@"call_id"]};
    
    NSLog(@"publish sendEvent =%@",requestDict);
    
    [self.socketIOClient publishToChannel:@"CallEvent2" message:requestDict];
}


/* TODO - make sure this event gets called every time the call gets end, else the busy status of the user will not get updated */
-(void) sendCallEndEvent:(NSDictionary*)data
{
    /* Update the online status of the user here, Sending of socket will not work without that */
    NSDictionary *requestDict1 = @{@"msisdn" : [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                                   @"Status" : @"1",
                                   @"DateTime" : @"2016-01-02 15:07:18"};
    
    [self.socketIOClient publishToChannel:@"UpdateOnlineStatus" message:requestDict1];
    
    /* TODO - Add call_id to this call */
    NSDictionary *requestDict = @{@"from" :[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"],
                                  @"to" : [data valueForKey:@"to"],@"call_id":data[@"call_id"]
                                  };
    [self.socketIOClient publishToChannel:@"callEnd" message:requestDict];
}


/*compress data*/
- (NSData *)gzipInflate:(NSData*)data
{
    if ([data length] == 0) return data;
    
    unsigned full_length = [data length];
    unsigned half_length = [data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = [data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

- (NSData *)gzipDeflate:(NSData*)data
{
    if ([data length] == 0) return data;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[data bytes];
    strm.avail_in = [data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm,Z_BEST_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = [compressed length] - strm.total_out;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}


-(void)removeGetMesgAckFromServer:(NSMutableDictionary *)msgDict{
    //remove message Ack fromserver send status 3
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[PicogramSocketIOWrapper sharedInstance] sendReadMessageStatus:@"3" fromUser:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]] toUser:msgDict[@"to"] withMessageID:msgDict[@"msgId"]];
    }];
    
}

-(void)PublishToGetCallStatusEvent:(NSDictionary*)data
{
    /* Update the online status of the user here, Sending of socket will not work without that */
    NSDictionary *requestDict1 = @{@"msisdn" : [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]],
                                   @"Status" : @"1",
                                   @"DateTime" : @"2016-01-02 15:07:18"};
    
    [self.socketIOClient publishToChannel:@"UpdateOnlineStatus" message:requestDict1];
    
    
    /* TODO - We need to pass only from to this socket call*/
    NSDictionary *requestDict = @{@"from" :[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]]
                                  };
    [self.socketIOClient publishToChannel:@"getCallStatus" message:requestDict];
    [self.socketIOClient subscribeToChannels:@[@"getCallStatus"]];
    [[NSUserDefaults standardUserDefaults]setValue:@"True" forKey:@"getCallStatus"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

-(void)subscribeToCallEvent
{
    /* Update the online status of the user here, Sending of socket will not work without that */
    NSDictionary *requestDict1 = @{@"msisdn" : [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]],
                                   @"Status" : @"1",
                                   @"DateTime" : @"2016-01-02 15:07:18"};
    
    [self.socketIOClient publishToChannel:@"UpdateOnlineStatus" message:requestDict1];
    [self.socketIOClient subscribeToChannels:@[@"CallEvent2"]];
    
}



// Chat End



@end
