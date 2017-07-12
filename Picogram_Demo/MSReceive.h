//
//  MSReceive.h
//  ChatClient
//
//  Created by Bhavuk Jain on 02/01/16.
//  Copyright © 2016 Bhavuk Jain. All rights reserved.
//

#import "MessageStorage.h"

@interface MSReceive : MessageStorage <CouchBaseEventsDelegate>


@property (strong, nonatomic) CBLDatabase *database;

-(NSString*)getDocumentIDWithSenderID:(NSString *)senderID;


@end
