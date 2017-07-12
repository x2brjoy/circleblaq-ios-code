//
//  PicogramSocketIOWrapper.h
//  Snapchat
//
//  Created by Rahul Sharma on 11/09/15.
//  Copyright (c) 2015 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIOClient.h"
#import "SIOConfiguration.h"

@protocol SocketWrapperDelegate <NSObject>
@optional
-(void)responseFromChannels:(NSDictionary *)responseDictionary;
//-(void)messageSentSuccessfullyForMessageID:(NSString *)messageID;
-(void)didConnect;
-(void)didDisconnect;
-(void)messageSentSuccessfullyForMessageID:(NSMutableDictionary *)messageID;
-(void)ackReceivedForMessageID:(NSMutableArray *)messageID;
-(void)didSubscribeToHistory;
-(void)didSubscribToAck;

// chat Start

-(void)responseFromChannels1:(NSDictionary *)responseDictionary;
-(void)didSubscribeToGetMessageAcks;
-(void)didSubscribetoOnlineStatus;
-(void)sendLastgropcreatTime;
-(void)getGroupMesgs;
-(void)getofflineDataWhenagainAdd;
// Chat End

@required


@end

typedef NS_ENUM(NSUInteger, SocketMessageType) {
     SocketMessageTypeText,
    SocketMessageTypePhoto,
    SocketMessageTypeVideo,
    // Start Chat
    
    SocketMessageTypeLocation,
    SocketMessageTypeContact,
    SocketMessageTypeVoiceRec,
    SocketMessageTypePost,
    
    // Start Chat
};


@interface PicogramSocketIOWrapper : NSObject
@property (nonatomic, weak) id<SocketWrapperDelegate> socketdelegate;

+(instancetype) sharedInstance;
-(void)connectSocket;
-(void)disconnectSocket;
//- (void) syncContacts:(NSArray*)contacts;
- (void) syncContacts:(NSString*)contacts;
-(void)sendHeartBeatForUser:(NSString*)userName withStatus:(NSString *)status andPushToken:(NSString *)pushToken;

@property (nonatomic, strong) NSMutableArray *channelsName;

// Chat Start

-(void)callChannelFirstTimeonly:(NSString *)type memNumber:(NSString*)number;

-(void)socketIOSetup;

-(void)callChannelFirstTimeonly:(NSString *)type memNumber:(NSString*)number;

-(void)sendMessage:(NSData *)message fromUser:(NSString *)fromUserName toUser:(NSString *)toUserName withDocId:(NSString *)docID currentDate:(NSDate *)currentDate withTpe:(SocketMessageType)socketMessageType;

-(void)sendMessagetoGroup:(NSData*)message fromUser:(NSString *)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDate:(NSDate *)currentDate  withTpe:(SocketMessageType)socketMessageType groupName:(NSString*)groupName;

-(void)sendMessageAgain:(NSString *)message fromUser:(NSString*)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDateId:(NSString*)currentID withType:(SocketMessageType)socketMessageType;

//-(void)sendReceivedAcknowledgement:(NSString *)fromUser withMessageID:(NSString *)messageID;
-(void)sendReceivedAcknowledgement:(NSString *)fromUser withMessageID:(NSString *)messageID ToReciver:(NSString*)toReciver docID:(NSString*)documentID messegStatus:(NSString *)msgStatus;

-(void)sendRequestToleaveGroup:(NSString *)fromUser withGroupId:(NSString*)groupId documentID:(NSString*)documentID;
-(void)sendRequestToUpdateGroupName:(NSString*)groupName groupId:(NSString*)groupID documentId:(NSString*)documentID;

-(void)getMessageHistorySender:(NSString *)fromUser receiver:(NSString*)toUser;
-(void)getMessageAckHistorySender:(NSString *)fromUser receiver:(NSString*)toUser;


-(void)sendHeartBeatContinue:(NSString *)userName withStatus:(NSString *)status andPushToken:(NSString*)pushToken;

-(void)sendReadMessageStatus:(NSString *)msgStatus fromUser:(NSString*)fromUser toUser:(NSString*)toUser withMessageID:(NSString*)messageID;

-(void)sendOnlineStatustoServer:(NSString*)userName reciver:(NSString*)reciverName status:(NSString*)status currentDt:(NSString*)dt;
-(void)sendRequestTORemoveFromGroup:(NSString *)groupID memNumber:(NSString *)memNUmber documentID:(NSString*)documentID;

-(void)sendLastcreatedGrouptime:(NSString *)userName ;
-(void)sendAckToserverForGroupUpdatedDataRecive:(NSString *)groupID groupType:(NSString*)groupType;
-(void)sendReceivedAcknowledgementForGroup:(NSString*)fromUser withMessageID:(NSString*)messageID groupID:(NSString*)groupID messageStatus:(NSString*)msgStatus;

-(void)sendPostToGroup:(NSArray*)message fromUser:(NSString *)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDate:(NSDate *)currentDate  withTpe:(SocketMessageType)socketMessageType groupName:(NSString*)groupName;

-(void)callTypeElevenToRemoveUser:(NSString*)Usnumber groupID:(NSString*)groupID;

-(void)creatNewGroup:(NSString*)groupName groupMembers:(NSArray*)groupMembers groupId:(NSString*)groupID groupPic:(NSString*)groupPic type:(NSString *)type;

-(void)addMembersFirstTimetoGroupChat:(NSArray*)groupMembers groupId:(NSString*)groupID type:(NSString*)type;

-(void)addMembersToGroup:(NSString*)contacNum groupId:(NSString*)groupID type:(NSString*)type groupName:(NSString *)groupName groupPic:(NSString*)groupPic gpCreatedBy:(NSString*)gpCreatedBy docId:(NSString*)documentID;
-(void)sendRequestToUpdateGroupPic:(NSString *)gpPicUrl groupId:(NSString *)groupID documentId:(NSString *)documentID;

-(void)sendRequestToMakeGroupAdmin:(NSString *)groupID memNumber:(NSString*)memNumber documentID:(NSString*)documentID;
-(void)sendTypeingStatustoServer:(NSString *)recevierName;
-(void)getLastseenFromServer:(NSString *)reciverName;

-(void)sendUserNumforaAnyUpdate:(NSMutableArray *)usersNumbers;
-(void)broadCastProfileToserver:(NSString *)username;
-(void)getofflineGroupMsg:(NSString *)userName;
-(void)callMethodTogetadduserwhileOffline;


/* uploadFileToSocket*/

-(void)uploadFiletoSocketgetUrl:(NSData *)message fromUser:(NSString *)fromUserName toUser:(NSString *)toUserName withDocId:(NSString *)docID currentDate:(NSDate *)currentDate withTpe:(SocketMessageType)socketMessageType thumData:(NSString*)thumdata;

-(void)uploadFiletoSockectForGroupChat:(NSData*)message fromUser:(NSString *)fromUserName toUser:(NSString*)toUserName withDocId:(NSString*)docID currentDate:(NSDate *)currentDate  withTpe:(SocketMessageType)socketMessageType groupName:(NSString*)groupName  thumData:(NSString *)thumdata;

/**
 *  @brief sending contacts to the socketIO
 *
 *  @param data Array containing the msisdn of the user to be called and the unique call id
 */
- (void) callUser:(NSDictionary *)data;
-(void)PublishToGetCallStatusEvent:(NSDictionary*)data;

/**
 *  @brief sending contacts to the socketIO
 *
 *  @param data Array containing the msisdn of the user to be called and the unique call id
 */
- (void) sendEvent:(NSDictionary *)data;
-(void) sendCallEndEvent:(NSDictionary*)data;
-(void)subscribeToCallEvent;
-(void)getofflineDataForAnotherTimeAddtoGroup;



// Chat End



@end
