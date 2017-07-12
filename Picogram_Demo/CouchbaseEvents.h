//
//  CouchbaseEvents.h
//  CouchbaseDb
//
//  Created by Bhavuk Jain on 02/11/15.
//  Copyright (c) 2015 Bhavuk Jain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"


@protocol CouchBaseEventsDelegate <NSObject>

-(void)newDocumentCreatedID:(NSString *)docID;

@end

@interface CouchbaseEvents : NSObject

-(BOOL)helloCBL;

- (CBLView *)getView;

-(NSString *)createDocument:(CBLDatabase *)database forReceivingUser:(NSString *)receivingUser andSendingUser:(NSString *)sendingUser withMessages:(NSArray *)messagesArray newMessageCount:(NSString*)newMessagecount;

- (BOOL) updateDocument:(CBLDatabase *) database documentId:(NSString *) documentId withMessages:(NSArray *)messagesArray;

-(BOOL)updateDoc:(CBLDatabase*)database documentId:(NSString*)documentId withmessage:(NSArray *)messagesArray;
-(BOOL)updateDocumentForGroupData:(CBLDatabase *)database documentId:(NSString *)documentId data:(NSDictionary*)responseDict;

//groupChat
-(void)createDocForGroupChat:(CBLDatabase *)database sendingUser:(NSString *)sendingUser withMessages:(NSArray*)messagesArray groupID:(NSString *)groupID  groupName:(NSString*)groupName groupPic:(NSString*)groupPic groupMems:(NSArray*)groupArray groupAdmin:(NSString *)groupAdmin ;

@property (weak, nonatomic) id<CouchBaseEventsDelegate> delegate;

@end
