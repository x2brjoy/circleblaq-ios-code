//
//  MessageStorage.h
//  ChatClient
//
//  Created by Bhavuk Jain on 02/01/16.
//  Copyright © 2016 Bhavuk Jain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CouchbaseEvents.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import "Message.h"
#import "ChatHelper.h"


@protocol MessageStorageDelegate <NSObject>

-(void)messageSentToServerWithID:(NSString *)messageID;

-(void)reloadMessagesAtIndex:(NSInteger) index;

-(void)reloadTableForMessageID:(NSString *)messageID andDocID:(NSString *)docID status:(NSString*)status;
-(void)receivedNewMessage:(Message *)msg forDocID:(NSString *)docID;
-(void)reloadGroupChatInfo:(NSString *)docID;

@end

@interface MessageStorage : NSObject

@property (strong, nonatomic) MessageStorage *messageStorage;
@property (weak, nonatomic) id<MessageStorageDelegate> delegate;
@property (strong, nonatomic) NSString *previousDocID;
@property (strong, nonatomic) NSMutableDictionary *docInfo;
@property (strong, nonatomic) NSMutableDictionary *mediaInfo;
@property (strong, nonatomic) NSMutableArray *medialist;

+(instancetype)sharedInstance;

-(CBLDocument *)getDocumentForID:(NSString *)docID;

-(NSDictionary *)getDocumentInfoForID:(NSString *)docID forDatabase:(CBLDatabase *)db ;

-(NSDictionary *)getDetailsForDocument:(CBLDocument *) document;

-(NSMutableArray *)createIntoSOMessagesfromMessages:(NSArray *)messages;
-(NSMutableArray *)createMediaListfromMessages:(NSArray *)messages;

-(Message *)sendMessage:(NSString *)message onDocument:(CBLDocument *)document groupId:(NSString*)groupId;

-(Message *)sendPost:(NSArray *)data onDocument:(CBLDocument *)document groupId:(NSString *)groupId;

-(Message *)sendImage:(UIImage *)image onDocument:(CBLDocument *)document groupId:(NSString *)groupId;

-(Message *)sendVideo:(NSString *)filePath withThumbnailImage:(UIImage *)thumbnailImage onDocument:(CBLDocument *)document groupId:(NSString *)groupId;

-(Message *)sendLocation:(NSString *)name address:(NSString *)address latlog:(NSString*)latlog onDocument:(CBLDocument*)document groupId:(NSString *)groupId;

-(Message *)sendContact:(NSDictionary *)contacdict onDocument:(CBLDocument*)document groupId:(NSString *)groupId;

-(Message *)sendVoiceRecorder:(NSString *)voicedict onDocument:(CBLDocument*)document groupId:(NSString *)groupId;

-(void)receiveMsgSentWithInfo:(NSDictionary *)msgInfo onDataBase:(CBLDatabase *)cblDB;
-(void)receiveGroupMsgSentWithInfo:(NSDictionary*)msgInfo onDataBase:(CBLDatabase *)cblDB;

-(void)receivedNewMsgWithInfo:(NSDictionary *)msgInfo onDataBase:(CBLDatabase *)cblDB;
-(void)receivedGroupNewMsgWithInfo:(NSDictionary *)responseDictionary onDataBase:(CBLDatabase *)cblDB;
-(void)updateGroupDataInDataBase:(NSDictionary *)responseDictionary onDataBase:(CBLDatabase*)cblDB;

-(NSMutableArray *)replaceMsgObjectWithID:(NSString *)messageID inMessages:(NSMutableArray *)messages status:(NSString*)status docID:(NSString *)documentID;

-(NSInteger)indexOfMessageWithID:(NSString *)messageID inMessages:(NSMutableArray *)messages;

-(void)updateDocument:(CBLDocument *)document withMessages:(NSMutableArray *)messages;

-(void)updateDocumentWithID:(NSString *)documentID withMessages:(NSMutableArray *)messages onDatabase:(CBLDatabase *)db;


-(void)updateDocForTickmark:(NSString*)documentID withMessages:(NSMutableArray*)messages onDatabase:(CBLDatabase*)db;
@end
