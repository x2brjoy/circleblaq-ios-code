//
//  MSReceive.m
//  ChatClient
//
//  Created by Bhavuk Jain on 02/01/16.
//  Copyright © 2016 Bhavuk Jain. All rights reserved.
//

#import "MSReceive.h"
#import "PicogramSocketIOWrapper.h"
#import <AVFoundation/AVFoundation.h>
#import "Database.h"
//#import "Favorites.h"
//#import "FavDataBase.h"
#import "StoreIDs+CoreDataClass.h"

static MSReceive *msReceive = NULL;

@implementation MSReceive


+(instancetype)sharedInstance {
    
    if (!msReceive) {
        msReceive = [[MSReceive alloc] init];
    }
    
    return msReceive;
    
}

-(void)receiveMsgSentWithInfo:(NSDictionary *)msgInfo onDataBase:(CBLDatabase *)cblDB{
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    messageStorage.previousDocID = msgInfo[@"doc_id"];
    messageStorage.docInfo = [[self getDocumentInfoForID:msgInfo[@"doc_id"] forDatabase:cblDB] mutableCopy] ;
   // NSLog(@"fetching datafrom DB =%@",messageStorage.docInfo);
    
    /*if (![messageStorage.previousDocID isEqualToString:msgInfo[@"doc_id"]]) {
        messageStorage.previousDocID = msgInfo[@"doc_id"];
        messageStorage.docInfo = [[self getDocumentInfoForID:msgInfo[@"doc_id"] forDatabase:cblDB] mutableCopy] ;
    }
     */
   
    NSMutableArray *messages = [NSMutableArray new];
    NSString *msgID ;

    if (!msgInfo[@"id"]) {
       
        //for message ack draw read status
        if (msgInfo[@"msgId"]) {
            NSString  *msgiD = [NSString stringWithFormat:@"%@",msgInfo[@"msgId"]];
            NSMutableArray *tempTestArr = [[NSMutableArray alloc] initWithArray:messageStorage.docInfo[@"messages"]];
            messages = [self replaceMsgObjectWithID:msgiD inMessages:tempTestArr status:msgInfo[@"status"] docID:msgInfo[@"doc_id"]];
            
        }else{
        
            NSArray *arr =msgInfo[@"msgIds"];
            msgID = [arr firstObject];
            messages =[NSMutableArray new];
            NSMutableArray *tempTestArr = [[NSMutableArray alloc] initWithArray:messageStorage.docInfo[@"messages"]];
            messages = [self replaceMsgObjectWithID:[arr firstObject] inMessages:tempTestArr status:msgInfo[@"status"] docID:msgInfo[@"doc_id"]];
        }
        
    }else{
        
        NSMutableArray *tempTestArr = [[NSMutableArray alloc] initWithArray:messageStorage.docInfo[@"messages"]];
        messages = [self replaceMsgObjectWithID:msgInfo[@"id"] inMessages:tempTestArr status:msgInfo[@"status"] docID:msgInfo[@"doc_id"]];
        msgID = msgInfo[@"id"];
    }
   

    
    if (messages.count>0) {
       
        //[self updateDocForTickmark:msgInfo[@"doc_id"] withMessages:[messages mutableCopy] onDatabase:cblDB];
    
        messageStorage.docInfo[@"messages"] = messages;
        [self updateDocumentWithID:msgInfo[@"doc_id"] withMessages:[messages mutableCopy] onDatabase:cblDB];
        // NSLog(@"check document Updated or Not  =%@",[cblDB documentWithID:msgInfo[@"doc_id"]].properties);
        if (self.delegate && [self.delegate respondsToSelector:@selector(reloadTableForMessageID:andDocID:status:)]) {
            [self.delegate reloadTableForMessageID:msgID andDocID:msgInfo[@"doc_id"] status:msgInfo[@"status"]];
        }
    }
    
}


-(void)receiveGroupMsgSentWithInfo:(NSDictionary*)msgInfo onDataBase:(CBLDatabase *)cblDB{
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
   // messageStorage.previousDocID = msgInfo[@"groupId"];
    
    if (msgInfo[@"toDocId"]) {
    messageStorage.docInfo = [[self getDocumentInfoForID:msgInfo[@"toDocId"] forDatabase:cblDB] mutableCopy];
    }
    
     NSMutableArray *messages = [NSMutableArray new];
     NSMutableArray *tempTestArr = [[NSMutableArray alloc] initWithArray:messageStorage.docInfo[@"messages"]];
     messages = [self replaceMsgObjectWithID:msgInfo[@"id"] inMessages:tempTestArr status:msgInfo[@"deliver"] docID:msgInfo[@"toDocId"]];
    
    
    if (messages.count>0) {
        
        //[self updateDocForTickmark:msgInfo[@"doc_id"] withMessages:[messages mutableCopy] onDatabase:cblDB];
        
        messageStorage.docInfo[@"messages"] = messages;
        [self updateDocumentWithID:msgInfo[@"toDocId"] withMessages:[messages mutableCopy] onDatabase:cblDB];
        if (self.delegate && [self.delegate respondsToSelector:@selector(reloadTableForMessageID:andDocID:status:)]) {
            [self.delegate reloadTableForMessageID:msgInfo[@"id"] andDocID:msgInfo[@"toDocId"] status:msgInfo[@"deliver"]];
        }
    }
    
    
}

-(void)receivedNewMsgWithInfo:(NSDictionary *)msgInfo onDataBase:(CBLDatabase *)cblDB {
    
    CBLManager *manager = [CBLManager sharedInstance];
    NSError* error;
    self.database = [manager databaseNamed:@"db" error: &error];
    
        MessageStorage *messageStorage = [MessageStorage sharedInstance];
    
        NSString *docID = [self getDocumentIDWithSenderID:msgInfo[@"from"] onDatabase:cblDB];
       // NSLog(@"documentID from couchDb for message=%@",docID);
        Message *msg;
    
        if (docID) {
            
            if (![messageStorage.previousDocID isEqualToString:docID]) {
                messageStorage.previousDocID = docID;
                messageStorage.docInfo = [[self getDocumentInfoForID:docID forDatabase:cblDB] mutableCopy];
            }
            
            //put check for repeated messages
            BOOL isRepeat = [self checkForRepeatedMsg:messageStorage.docInfo[@"messages"] freshmsgInfo:msgInfo];
            if (isRepeat == YES){
                return ;
            }
            
           
            msg = [self addNewMessage:msgInfo withMessagesArray:messageStorage.docInfo[@"messages"] onDocID:docID onDatabase:cblDB];
            
        }else {
            
            // NSLog(@"new document created for chat =%@",msgInfo);
            msg = [self createNewDocForUser:msgInfo[@"from"] withMessage:msgInfo onDatabase:cblDB];
        }
    
    
    
    NSString *doc_id = [NSString stringWithFormat:@"%@",msgInfo[@"doc_id"]];
    if (doc_id.length ==0 || [doc_id isEqualToString:@"(null)"]) {
        doc_id = msgInfo[@"docId"];
    }
    
  
    [[NSUserDefaults standardUserDefaults] setObject:doc_id forKey:[NSString stringWithFormat:@"%@docID",msgInfo[@"from"]]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[PicogramSocketIOWrapper sharedInstance] sendReceivedAcknowledgement:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]] withMessageID:msgInfo[@"id"] ToReciver:msgInfo[@"from"] docID:doc_id messegStatus:@"2"];
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(receivedNewMessage:forDocID:)]) {
            
            if (docID) {
                
                [[PicogramSocketIOWrapper sharedInstance] sendReceivedAcknowledgement:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]] withMessageID:msgInfo[@"id"] ToReciver:msgInfo[@"from"] docID:doc_id messegStatus:@"3"];
                [self.delegate receivedNewMessage:msg forDocID:docID];
            }
        }
        
    }];
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [[ChatSocketIOClient sharedInstance] sendReceivedAcknowledgement:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] withMessageID:msgInfo[@"id"] ];
//        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(receivedNewMessage:forDocID:)]) {
//            if (docID) {
//                [self.delegate receivedNewMessage:msg forDocID:docID];
//            }
//        }
//
//    }];
    
//    });
}


-(void)receivedGroupNewMsgWithInfo:(NSDictionary *)responseDictionary onDataBase:(CBLDatabase *)cblDB{
    
    CBLManager *manager = [CBLManager sharedInstance];
    NSError* error;
    self.database = [manager databaseNamed:@"db" error: &error];
    
     MessageStorage *messageStorage = [MessageStorage sharedInstance];
    
    NSString *docID = [self getDocumentIDWithGroupID:responseDictionary[@"to"] onDatabase:cblDB];
    
     Message *msg;
    if (docID) {
        
        if (![messageStorage.previousDocID isEqualToString:docID]) {
            messageStorage.previousDocID = docID;
            messageStorage.docInfo = [[self getDocumentInfoForID:docID forDatabase:cblDB] mutableCopy];
        }
        
        
        
        BOOL isRepeat = [self checkForRepeatGroupMsg:messageStorage.docInfo[@"messages"] freshMSgInfo:responseDictionary];
        if (isRepeat == YES){
            return ;
        }

        
        msg = [self addNewMessage:responseDictionary withMessagesArray:messageStorage.docInfo[@"messages"] onDocID:docID onDatabase:cblDB];
    }
    
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[PicogramSocketIOWrapper sharedInstance] sendReceivedAcknowledgementForGroup:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]]withMessageID:responseDictionary[@"id"] groupID:responseDictionary[@"to"] messageStatus:@"2"];
    }];
    
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(receivedNewMessage:forDocID:)]) {
        
        if (docID) {
            [self.delegate receivedNewMessage:msg forDocID:docID];
        }
    }
    
    
   
    
}


/*store image to memory*/
-(NSData*)storeImageinMemeory:(NSData*)data messageID:(NSString*)messageID{
    
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageID];
    NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];

    NSLog(@"%@",moviePath);
    NSData *data1;
    
    if([data writeToFile:moviePath atomically:YES]) {
        // NSURL *url = [[NSURL alloc] initFileURLWithPath:moviePath];
        data1 = [moviePath dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return data1;
}

-(UIImage*)getImageFromMemory:(NSString*)messageID{
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageID];
    NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
    UIImage *image = [UIImage imageWithContentsOfFile:moviePath];
    
    return image;
}



-(Message *)createNewDocForUser:(NSString *)user withMessage:(NSDictionary *)messageDict onDatabase:(CBLDatabase *)db {
    
     UIImage *thumbnailImageForMap;
    NSMutableArray *messagesArray = [NSMutableArray new];
    NSNumber *timeInterval = messageDict[@"timestamp"];
    long long timeInt = [timeInterval longLongValue] / 1000;
    
    NSDate *GMTdate = [NSDate dateWithTimeIntervalSince1970:timeInt];
    NSString *localDate = [self localDateFromGMTDate:GMTdate];
    NSDateFormatter *df = [self DateFormatterProper];
    NSDate *currentDate = [df dateFromString:localDate];
    
    Message *msg = [[Message alloc] init];
    if ([messageDict[@"type"] integerValue] == SocketMessageTypeText) {
        msg.type = SOMessageTypeText;
        msg.text = messageDict[@"pl"];
        msg.date = currentDate;
        msg.fromNum = messageDict[@"from"];
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypePhoto) {
        
        NSString *encodedMsg = messageDict[@"thumbnail"];
        encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSData *originalData = [[NSData alloc] initWithBase64EncodedString:encodedMsg options:0];
        
        [self storeImageinMemeory:originalData messageID:messageDict[@"id"]];
        
        msg.type = SOMessageTypePhoto;
        msg.media = messageDict[@"pl"];
        msg.date = currentDate;
        msg.fromNum = messageDict[@"from"];
        msg.thumbnail =  [self getImageFromMemory:messageDict[@"id"]];//[UIImage imageWithData:originalData];
        msg.isUrlDownloaded = NO;
        msg.dataSize =messageDict[@"dataSize"];
        
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypeVideo) {
        //            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"Video:%@",timeInterval]];
        NSData *data =messageDict[@"pl"];
      
        NSString *encodedMsg = messageDict[@"thumbnail"];
        encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSData *originalData = [[NSData alloc] initWithBase64EncodedString:encodedMsg options:0];
        [self storeImageinMemeory:originalData messageID:messageDict[@"id"]];
        
        msg.thumbnail =  [self getImageFromMemory:messageDict[@"id"]]; //[UIImage imageWithData:originalData];
        msg.type = SOMessageTypeVideo;
        msg.postData = messageDict[@"pl"];
        msg.date = currentDate;
        msg.fromNum = messageDict[@"from"];
//        msg.dataSize = messageDict[@"dataSize"];
        msg.isUrlDownloaded = NO;

    }
    else if ([messageDict[@"type"] integerValue] == SocketMessageTypePost) {
        //            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"Video:%@",timeInterval]];
        NSData *data =messageDict[@"payload"];
        
        NSString *encodedMsg = messageDict[@"payload"][@"thumbnail"];
        encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSData *originalData = [[NSData alloc] initWithBase64EncodedString:encodedMsg options:0];
        [self storeImageinMemeory:originalData messageID:messageDict[@"id"]];
        
        msg.thumbnail =  [self getImageFromMemory:messageDict[@"id"]]; //[UIImage imageWithData:originalData];
        msg.type = SOMessageTypePost;
        msg.media = messageDict[@"pl"];
        msg.date = currentDate;
        msg.fromNum = messageDict[@"from"];
//        msg.dataSize = messageDict[@"dataSize"];
        msg.isUrlDownloaded = NO;
        
    }
    else if ([messageDict[@"type"]integerValue] == SocketMessageTypeLocation){
        
        
        NSString *_storeLocationStr;
        double latitude =0.0;
        double logitude = 0.0;

        _storeLocationStr=messageDict[@"pl"];
        NSArray *Arr = [_storeLocationStr componentsSeparatedByString:@"@@"];
        
        
     //   NSLog(@"location Str =%@",Arr);
        NSArray *subArr = [[Arr objectAtIndex:0] componentsSeparatedByString:@","];
      //  NSLog(@"subArr =%@",subArr);
        
        NSString *latitudeStr = [NSString stringWithFormat:@"%@",[subArr objectAtIndex:0]];
        latitudeStr = [latitudeStr substringFromIndex:1];
        NSString *logitudeStr = [NSString stringWithFormat:@"%@",[subArr objectAtIndex:1]];
        logitudeStr = [logitudeStr substringToIndex:[logitudeStr length] - 1];
        
        latitude = [latitudeStr doubleValue];
        logitude = [logitudeStr doubleValue];

        
        NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?markers=color:red|%f,%f&%@&sensor=true",latitude,logitude,@"zoom=10&size=270x200"];
        NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
       // thumbnailImageForMap  = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
        
        [self storeImageinMemeory:[NSData dataWithContentsOfURL:mapUrl] messageID:messageDict[@"id"]];
        thumbnailImageForMap = [self getImageFromMemory:messageDict[@"id"]];
        
        if (thumbnailImageForMap == nil) {
            thumbnailImageForMap = [UIImage imageNamed:@"default_568h"];
            [self storeImageinMemeory:UIImagePNGRepresentation(thumbnailImageForMap) messageID:messageDict[@"id"]];
            thumbnailImageForMap = [self getImageFromMemory:messageDict[@"id"]];
        }
        
        
        msg.type = SOMessageTypeLocation;
        msg.text = messageDict[@"pl"];
        msg.date = currentDate;
        msg.thumbnail = thumbnailImageForMap;
        msg.fromNum = messageDict[@"from"];

    }
    else if ([messageDict[@"type"]integerValue] == SocketMessageTypeContact){
        
        UIImage *thumbnailImageForContac = [[UIImage alloc] init];
        thumbnailImageForContac = [UIImage imageNamed:@"avatar_image_contac"];
        
        [self storeImageinMemeory:UIImagePNGRepresentation(thumbnailImageForContac) messageID:messageDict[@"id"]];
        thumbnailImageForContac = [self getImageFromMemory:messageDict[@"id"]];
        
        msg.type = SOMessageTypeContact;
        msg.text = messageDict[@"pl"];
        msg.date = currentDate;
        msg.thumbnail = thumbnailImageForContac;
        msg.fromNum = messageDict[@"from"];
    }
    else if ([messageDict[@"type"]integerValue] == SocketMessageTypeVoiceRec){
        
        UIImage *thumbnailImage = [[UIImage alloc]init];
        thumbnailImage  = [UIImage imageNamed:@"avatar_image_contac"];
        NSData *data = messageDict[@"pl"];
        msg.type = SocketMessageTypeVoiceRec;
        msg.media = data;
        msg.date = currentDate;
        msg.thumbnail = thumbnailImage;
        msg.fromNum = messageDict[@"from"];
    }
    msg.messageID = messageDict[@"id"];
    
    
    NSDictionary *dict;
    
    if ([messageDict[@"type"] integerValue] == SocketMessageTypePhoto) {
        // NSString *message = [messageDict[@"pl"] base64EncodedStringWithOptions:kNilOptions];
        NSString *message = [NSString stringWithFormat:@"%@",messageDict[@"pl"]];
        // UIImage *thum =[UIImage imageNamed:@"default_568h"];
        // NSData *thumbnailImageData = UIImagePNGRepresentation(thum);
        // NSString *thumbnailImage = [thumbnailImageData base64EncodedStringWithOptions:kNilOptions];
        
    
        //NSString *encodedMsg = messageDict[@"thumbnail"];
        //encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *encodedMsg = [ChatHelper encodeStringTo64:moviePath];
        
        dict = @{@"media":message,
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],//[NSString stringWithFormat:@"%ld",[responseDictionary[@"id"] longValue]],
                 @"type":@"1",
                 @"fromNum":messageDict[@"from"],
                 @"thumbnail":encodedMsg,
                 @"isUrlDownloaded":@"NO",
                 @"dataSize":messageDict[@"dataSize"]
                 };
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypeVideo) {
        NSString *message = [NSString stringWithFormat:@"%@",messageDict[@"pl"]];
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];
        
        dict = @{@"media":message,
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],//[NSString stringWithFormat:@"%ld",[responseDictionary[@"id"] longValue]],
                 @"type":@"2",
                 @"thumbnail":thumbnailImage,
                 @"fromNum":messageDict[@"from"],
                 @"dataSize":messageDict[@"dataSize"],
                 @"isUrlDownloaded":@"NO",
                 };

    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypePost) {
        NSString *message = [NSString stringWithFormat:@"%@",messageDict[@"pl"]];
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];
        
        dict = @{@"media":message,
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],//[NSString stringWithFormat:@"%ld",[responseDictionary[@"id"] longValue]],
                 @"type":@"2",
                 @"thumbnail":thumbnailImage,
                 @"fromNum":messageDict[@"from"],
                 @"dataSize":messageDict[@"dataSize"],
                 @"isUrlDownloaded":@"NO",
                 };
        
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypeText) {
        
        dict = @{@"text":messageDict[@"pl"],
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"fromNum":messageDict[@"from"],
                 @"messageID":messageDict[@"id"],//[NSString stringWithFormat:@"%ld",[responseDictionary[@"id"] longValue]],
                 @"type":@"0"};
    }
    else if ([messageDict[@"type"] integerValue] == SocketMessageTypeLocation){
        
        
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];
        
        dict = @{@"text":messageDict[@"pl"],
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],
                 @"type":@"3",
                 @"fromNum":messageDict[@"from"],
                 @"thumbnail":thumbnailImage,
                 };
    }
    else if ([messageDict[@"type"]integerValue] == SocketMessageTypeContact){
        
        
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];
        
        dict = @{@"text":messageDict[@"pl"],
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],
                 @"type":@"4",
                 @"fromNum":messageDict[@"from"],
                 @"thumbnail":thumbnailImage,
                 };
        
    }
    else if ([messageDict[@"type"]integerValue] == SocketMessageTypeVoiceRec){
        
         NSString *message = [messageDict[@"pl"] base64EncodedStringWithOptions:kNilOptions];
        NSData *thumbnailImageData = UIImagePNGRepresentation(msg.thumbnail);
        NSString *thumbnailImage = [thumbnailImageData base64EncodedStringWithOptions:kNilOptions];
        dict = @{@"text":message,
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],
                 @"type":@"5",
                 @"fromNum":messageDict[@"from"],
                 @"thumbnail":thumbnailImage,
                 };
    }
    
    [messagesArray addObject:dict];
    
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    NSMutableArray *msgs = [messageStorage.docInfo[@"messages"] mutableCopy];
    [msgs addObject:dict];
    
    
    messageStorage.docInfo[@"messages"] = msgs;

    
    //check userName is nil or not if don't creat document
    if (user.length>0) {
    CouchbaseEvents *cbEvents = [[CouchbaseEvents alloc] init];
    NSString *docID =  [cbEvents createDocument:db forReceivingUser:user andSendingUser: [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]] withMessages:messagesArray newMessageCount:@""] ;
        
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",1] forKey:docID];
    }
    
    return msg;
}


-(Message *)addNewMessage:(NSDictionary *)messageDict withMessagesArray:(NSArray *)messagesArray onDocID:(NSString *)docID onDatabase:(CBLDatabase *)db {
    
    UIImage *thumbnailImageForMap;
    NSMutableArray *msgsArray = [messagesArray mutableCopy];
    
    NSNumber *timeInterval = messageDict[@"timestamp"];
    long long timeInt = [timeInterval longLongValue]/1000;
    
    NSDate *GMTdate = [NSDate dateWithTimeIntervalSince1970:timeInt];
    NSString *localDate = [self localDateFromGMTDate:GMTdate];
    NSDateFormatter *df = [self DateFormatterProper];
    NSDate *currentDate = [df dateFromString:localDate];

    
    
    Message *msg = [[Message alloc] init];
    if ([messageDict[@"type"] integerValue] == SocketMessageTypeText) {
        msg.type = SOMessageTypeText;
        msg.text = messageDict[@"pl"];
        msg.date = currentDate;
        msg.fromNum = messageDict[@"from"];
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypePhoto) {

       
        NSString *encodedMsg = messageDict[@"thumbnail"];
        encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSData *originalData = [[NSData alloc] initWithBase64EncodedString:encodedMsg options:0];
        [self storeImageinMemeory:originalData messageID:messageDict[@"id"]];
        
       // NSString *encodedMsg = messageDict[@"thumbnail"];
       // encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
       // NSData *originalData = [[NSData alloc] initWithBase64EncodedString:encodedMsg options:0];
      
        
        msg.type = SOMessageTypePhoto;
        msg.media = messageDict[@"pl"];
        msg.date = currentDate;
        msg.fromNum = messageDict[@"from"];
        msg.thumbnail =  [self getImageFromMemory:messageDict[@"id"]];//[UIImage imageWithData:originalData];
        msg.isUrlDownloaded = NO;
        msg.dataSize =messageDict[@"dataSize"];
        if (messageDict[@"to"]) {
            msg.groupID = messageDict[@"to"];
        }
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypeLocation){
        //location recived
        
        NSString *_storeLocationStr;
        double latitude =0.0;
        double logitude = 0.0;
      //  NSLog(@"store location =%@",messageDict[@"pl"]);
        _storeLocationStr=messageDict[@"pl"];
        NSArray *Arr = [_storeLocationStr componentsSeparatedByString:@"@@"];
        

        NSArray *subArr = [[Arr objectAtIndex:0] componentsSeparatedByString:@","];
       // NSLog(@"subArr =%@",subArr);
        
        NSString *latitudeStr = [NSString stringWithFormat:@"%@",[subArr objectAtIndex:0]];
        latitudeStr = [latitudeStr substringFromIndex:1];
         NSString *logitudeStr = [NSString stringWithFormat:@"%@",[subArr objectAtIndex:1]];
        logitudeStr = [logitudeStr substringToIndex:[logitudeStr length] - 1];
        
        latitude = [latitudeStr doubleValue];
        logitude = [logitudeStr doubleValue];
        
        
        NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?markers=color:red|%f,%f&%@&sensor=true",latitude,logitude,@"zoom=10&size=270x200"];
        NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [self storeImageinMemeory:[NSData dataWithContentsOfURL:mapUrl] messageID:messageDict[@"id"]];
        thumbnailImageForMap = [self getImageFromMemory:messageDict[@"id"]];
        
        if (thumbnailImageForMap == nil) {
            thumbnailImageForMap = [UIImage imageNamed:@"default_568h"];
            [self storeImageinMemeory:UIImagePNGRepresentation(thumbnailImageForMap) messageID:messageDict[@"id"]];
            thumbnailImageForMap = [self getImageFromMemory:messageDict[@"id"]];
        }

        
        
        msg.type = SOMessageTypeLocation;
        msg.text = messageDict[@"pl"];
        msg.date = currentDate;
        msg.thumbnail = thumbnailImageForMap;
        msg.fromNum = messageDict[@"from"];
        
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypeContact){
        
        
        UIImage *thumbnailImageForContac = [[UIImage alloc] init];
        thumbnailImageForContac = [UIImage imageNamed:@"avatar_image_contac"];
        
        [self storeImageinMemeory:UIImagePNGRepresentation(thumbnailImageForContac) messageID:messageDict[@"id"]];
        thumbnailImageForContac = [self getImageFromMemory:messageDict[@"id"]];

        msg.type = SOMessageTypeContact;
        msg.text = messageDict[@"pl"];
        msg.date = currentDate;
        msg.thumbnail = thumbnailImageForContac;
        msg.fromNum = messageDict[@"from"];
        
    }
    else if ([messageDict[@"type"] integerValue] == SocketMessageTypeVideo) {
        NSString *encodedMsg = messageDict[@"thumbnail"];
        encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSData *originalData = [[NSData alloc] initWithBase64EncodedString:encodedMsg options:0];
        [self storeImageinMemeory:originalData messageID:messageDict[@"id"]];
        
        msg.thumbnail =  [self getImageFromMemory:messageDict[@"id"]];
        msg.type = SOMessageTypeVideo;
        msg.media = messageDict[@"pl"];
        msg.date = currentDate;
        msg.fromNum = messageDict[@"from"];
        msg.dataSize = messageDict[@"dataSize"];
        msg.isUrlDownloaded = NO;
        if (messageDict[@"to"]) {
            msg.groupID = messageDict[@"to"];
        }
    }
    else if ([messageDict[@"type"] integerValue] == SocketMessageTypePost) {
   
   
        /////////////////////////////////////////
        
//        NSString *encodedMsg = messageDict[@"pl"][@"thumbnailImageUrl"];
//        encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//        NSData *originalData = [[NSData alloc] initWithBase64EncodedString:encodedMsg options:0];
//        [self storeImageinMemeory:originalData messageID:messageDict[@"id"]];
        
        // NSString *encodedMsg = messageDict[@"thumbnail"];
        // encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        // NSData *originalData = [[NSData alloc] initWithBase64EncodedString:encodedMsg options:0];
        
        
        msg.type = SocketMessageTypePost;
       msg.postData = messageDict[@"pl"];
        msg.date = currentDate;
        msg.fromNum = messageDict[@"from"];
//        msg.thumbnail =  [self getImageFromMemory:messageDict[@"id"]];//[UIImage imageWithData:originalData];
//        msg.isUrlDownloaded = NO;
//        msg.dataSize =messageDict[@"dataSize"];
        if (messageDict[@"to"]) {
            msg.groupID = messageDict[@"to"];
        }
        
    }
    else if ([messageDict[@"type"]integerValue] == SocketMessageTypeVoiceRec){
        
        UIImage *thumbnailImage = [[UIImage alloc]init];
        thumbnailImage  = [UIImage imageNamed:@"avatar_image_contac"];
        NSData *data = messageDict[@"pl"];
        msg.type = SocketMessageTypeVoiceRec;
        msg.media = data;
        msg.date = currentDate;
        msg.thumbnail = thumbnailImage;
        msg.fromNum = messageDict[@"from"];
    }

    
    msg.messageID = messageDict[@"id"];
    NSDictionary *dict;
    
    if ([messageDict[@"type"] integerValue] == SocketMessageTypePhoto) {
       // NSString *message = [messageDict[@"pl"] base64EncodedStringWithOptions:kNilOptions];
        NSString *message = [NSString stringWithFormat:@"%@",messageDict[@"pl"]];
       // UIImage *thum =[UIImage imageNamed:@"default_568h"];
       // NSData *thumbnailImageData = UIImagePNGRepresentation(thum);
       // NSString *thumbnailImage = [thumbnailImageData base64EncodedStringWithOptions:kNilOptions];
        
        
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *encodedMsg = [ChatHelper encodeStringTo64:moviePath];
        
        

        NSString *groupID;
      //  NSString *encodedMsg = messageDict[@"thumbnail"];
       // encodedMsg = [encodedMsg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if (messageDict[@"to"]) {
            groupID = messageDict[@"to"];
        }else{
            groupID=@"";
        }
        
        dict = @{@"media":message,
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],//[NSString stringWithFormat:@"%ld",[responseDictionary[@"id"] longValue]],
                 @"type":@"1",
                 @"fromNum":messageDict[@"from"],
                 @"thumbnail":encodedMsg,   ///messageDict[@"thumbnail"],
                 @"isUrlDownloaded":@"NO",
                 @"dataSize":messageDict[@"dataSize"],
                 @"groupID":groupID,
                 };
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypeVideo) {
        
        NSString *message = [NSString stringWithFormat:@"%@",messageDict[@"pl"]];
        
        
        
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];
        
        
        NSString *groupID;
        if (messageDict[@"to"]) {
            groupID = messageDict[@"to"];
        }else{
            groupID=@"";
        }
        
        
        dict = @{@"media":message,
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],//[NSString stringWithFormat:@"%ld",[responseDictionary[@"id"] longValue]],
                 @"type":@"2",
                 @"thumbnail":thumbnailImage,
                 @"fromNum":messageDict[@"from"],
                 @"dataSize":messageDict[@"dataSize"],
                 @"isUrlDownloaded":@"NO",
                 @"groupID":groupID
                 };
    }
    else if ([messageDict[@"type"] integerValue] == SocketMessageTypePost) {
        
//        100000
        NSDictionary *message = messageDict[@"pl"];
        
        
        
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];
        
        
        NSString *groupID;
        if (messageDict[@"to"]) {
            groupID = messageDict[@"to"];
        }else{
            groupID=@"";
        }
        
        
        dict = @{@"media":message,
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],//[NSString stringWithFormat:@"%ld",[responseDictionary[@"id"] longValue]],
                 @"type":@"8",
                 @"thumbnail":thumbnailImage,
                 @"fromNum":messageDict[@"from"],
//                 @"dataSize":messageDict[@"dataSize"],
                 @"isUrlDownloaded":@"NO",
                 @"groupID":groupID
                 };
    }else if ([messageDict[@"type"] integerValue] == SocketMessageTypeText) {
        
        dict = @{@"text":messageDict[@"pl"],
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],//[NSString stringWithFormat:@"%ld",[responseDictionary[@"id"] longValue]],
                 @"type":@"0",
                 @"fromNum":messageDict[@"from"]
                 };
    }
    else if ([messageDict[@"type"]integerValue] == SocketMessageTypeLocation){
        
        
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];
        

        dict = @{@"text":messageDict[@"pl"],
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],
                 @"type":@"3",
                 @"thumbnail":thumbnailImage,
                 @"fromNum":messageDict[@"from"]
                 };
    }
    else if ([messageDict[@"type"] integerValue] == SocketMessageTypeContact){
        
        
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageDict[@"id"]];
        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];

        dict = @{@"text":messageDict[@"pl"],
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],
                 @"type":@"4",
                 @"thumbnail":thumbnailImage,
                 @"fromNum":messageDict[@"from"]
                 };
        
    }
    else if ([messageDict[@"type"]integerValue] == SocketMessageTypeVoiceRec){
        
        NSString *message = [messageDict[@"pl"] base64EncodedStringWithOptions:kNilOptions];
        NSData *thumbnailImageData = UIImagePNGRepresentation(msg.thumbnail);
         NSString *thumbnailImage = [thumbnailImageData base64EncodedStringWithOptions:kNilOptions];
        dict = @{@"text":message,
                 @"fromMe":@"NO",
                 @"date":localDate,
                 @"messageID":messageDict[@"id"],
                 @"type":@"5",
                 @"thumbnail":thumbnailImage,
                 @"fromNum":messageDict[@"from"]
                 };
    }
    
    [msgsArray addObject:dict];
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    NSMutableArray *msgs = [messageStorage.docInfo[@"messages"] mutableCopy];
    int storePriviousMsgCount = (int)msgs.count;
    [msgs addObject:dict];
    
    
    //NSLog(@"message =%@",msg);
    
    /*short msg based on time*/
    NSArray *notShortedArr =[msgs copy];
    NSArray *shortArr  = [notShortedArr sortedArrayUsingComparator:^(id a,id b){
        
        NSString *first = [a objectForKey:@"date"] ;
        NSString *second = [b objectForKey:@"date"] ;

         return [first compare:second];
        
    }];
    
   // NSLog(@"message =%@",shortArr);
    
    
    int currentMsgCount = (int)msgs.count;
    int unreadMsgNO = currentMsgCount -storePriviousMsgCount;
    int latestCount = [[[NSUserDefaults standardUserDefaults]objectForKey:docID] intValue];
    unreadMsgNO = latestCount +unreadMsgNO;
    
    if (unreadMsgNO >0) {
        if (unreadMsgNO == latestCount) {
        }else
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",unreadMsgNO] forKey:docID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
     [self changeDocIDpostion:docID];
    
  //  messageStorage.docInfo[@"messages"] = [msgs copy];
    messageStorage.docInfo[@"messages"] = [shortArr copy];
    
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       // [cbEvent updateDocument:db documentId:docID withMessages:msgsArray];
    [cbEvent updateDocument:db documentId:docID withMessages:[shortArr copy]];
        
//    }];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatListView" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatView" object:nil userInfo:nil];
    

    return msg;
}


-(NSString*)getDocumentIDWithSenderID:(NSString *)senderID onDatabase:(CBLDatabase *)db {
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name MATCHES %@",senderID];
        CBLView *productView = [db viewNamed:@"products"];
//    dispat    ch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        
        [productView setMapBlock:^(NSDictionary *doc, CBLMapEmitBlock emit) {
            emit(@"name", doc[@"receivingUser"]);
        }  version:@"3"];

//    });
    
        CBLQuery *query = [[db viewNamed:@"products"] createQuery];
        // we don't need the reduce here
        [query setMapOnly:YES];
    
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//    });
        CBLQueryEnumerator *result = [query run:nil];
        CBLQueryRow *filteredRow;
    
        for (CBLQueryRow *row in result) {
          //  NSLog(@"\n *****data base row value =%@ ->%@",row,senderID);
            
            if ([[row value] isEqualToString:senderID]) {
                filteredRow = row;
                break;
            }
            NSString *productName = [row value];
           // NSLog(@"Product name %@", productName);
        }

    return filteredRow.documentID;
}

-(NSString*)getDocumentIDWithGroupID:(NSString*)groupID onDatabase:(CBLDatabase*)db{
   /* temp commented try diffrent thing for group chat
    
    CBLView *productView = [db viewNamed:@"products"];
    [productView setMapBlock:^(NSDictionary *doc,CBLMapEmitBlock emit){
        emit(@"name",doc[@"groupID"]);
    }version:@"3"];
    
    
    CBLQuery *query = [[db viewNamed:@"products"] createQuery];
    [query setMapOnly:YES];
    
    CBLQueryEnumerator *result = [query run:nil];
    CBLQueryRow *filteredRow;
    
    for (CBLQueryRow *row in  result) {
        
        NSLog(@"\n *****data base row value =%@ ->%@",row,groupID);
        if ([[row value] isEqualToString:groupID]) {
          

            filteredRow = row;
            break;
        }
        NSString *productName = [row value];
        NSLog(@"value =%@",productName);
    }
    
    return filteredRow.documentID;
    
    */
    
 // NSString *docID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:groupID]];
    
    NSString *docID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupid == %@",[NSString stringWithFormat:@"%@",groupID]];
    NSArray *arr = [Database storeIdobjectWithMatchingStoreID:predicate];
    if (arr.count>0) {
        StoreIDs *store = [arr firstObject];
        docID = store.documentid;
    }
    
    
    return docID;
    
}


- (NSDateFormatter *)DateFormatterProper {
    
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
    });
    return formatter;
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



#pragma mark - CouchBase Event delegate
-(void)newDocumentCreatedID:(NSString *)docID {
    
    
}

-(void)changeDocIDpostion:(NSString *)docId{
    
    NSMutableArray *doc_IDArr =[[NSMutableArray alloc ] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:StorDocIDArray]];
    [doc_IDArr removeObject:docId];
    
    NSMutableArray *temp =[[NSMutableArray alloc]init];
    [temp addObject:docId];
    [temp addObjectsFromArray:[doc_IDArr copy]];
    [[NSUserDefaults standardUserDefaults]setObject:temp forKey:StorDocIDArray];
}


- (void) runBackground: (CBLManager*)bgMgr {
    NSError* error;
    CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
    // ... now use bgDB
}

-(BOOL)checkForRepeatedMsg:(NSArray *)allMessages freshmsgInfo:(NSDictionary*)msgInfo{
    
    for (int i=0;i<allMessages.count;i++){
    
        NSDictionary *dict = [allMessages objectAtIndex:i];
        NSString *old = [NSString stringWithFormat:@"%@",dict[@"messageID"]];
        NSString *new = [NSString stringWithFormat:@"%@",msgInfo[@"id"]];
        
        if ([old isEqualToString:new]) {
            return YES;
        }
    }
    return NO;
}


-(BOOL)checkForRepeatGroupMsg:(NSArray *)allMessage freshMSgInfo:(NSDictionary*)msgInfo{
    
    for (int i= 0;i<allMessage.count;i++) {
        NSDictionary *dict = [allMessage objectAtIndex:i];
        NSString *old = [NSString stringWithFormat:@"%@",dict[@"messageID"]];
        NSString *new = [NSString stringWithFormat:@"%@",msgInfo[@"id"]];
        
        if ([old isEqualToString:new]) {
            return YES;
        }
    }
    return NO;
    
}



-(void)updateGroupDataInDataBase:(NSDictionary *)responseDictionary onDataBase:(CBLDatabase*)cblDB{
    
    
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });
    
    
    NSString *docID = [self getDocumentIDWithGroupID:responseDictionary[@"groupId"] onDatabase:cblDB];
   // NSLog(@"get documentID from GroupID =%@",docID);
    if ([responseDictionary[@"err"] integerValue] == 1) {
        docID = responseDictionary[@"toDocId"];
    }
    
    
    if (docID) {
        
       BOOL isupdated = [cbEvent updateDocumentForGroupData:cblDB documentId:docID data:responseDictionary];
       
       // [[NSNotificationCenter defaultCenter]postNotificationName:@"updateGroupDataDB" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateGroupDataDB" object:nil userInfo:responseDictionary];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatListView" object:nil userInfo:responseDictionary];
        
    }
        
    [self updateGroupchatMessageOnchatscreen:cblDB documentId:docID response:responseDictionary];
    
   
    /*send ack to server*/
    if ([responseDictionary[@"groupType"] integerValue] == 4) {
    
        NSString *userNum = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        //send feedback to only removed Number
        if ([responseDictionary[@"memNum"] isEqualToString:userNum]) {
            
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
            [client callTypeElevenToRemoveUser:responseDictionary[@"memNum"] groupID:responseDictionary[@"groupId"]];
        }];
        }
        
        
    }else if ([responseDictionary[@"groupType"]integerValue] == 5){
        
        NSString *userNum = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        //send feedback to only removed Number
        if ([responseDictionary[@"memNum"] isEqualToString:userNum]) {
            
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
                [client callTypeElevenToRemoveUser:responseDictionary[@"memNum"] groupID:responseDictionary[@"groupId"]];
            }];
        }
        
    }
    
    else
    {
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
        [client sendAckToserverForGroupUpdatedDataRecive:responseDictionary[@"groupId"] groupType:responseDictionary[@"groupType"]];
    }];
    
    
    }
    
    
}

-(void)updateGroupchatMessageOnchatscreen:(CBLDatabase*)db documentId:(NSString*)document response:(NSDictionary*)responseDict{
    
    NSNumber *timeInterval = (NSNumber*)responseDict[@"timeStamp"];
    long long timeInt = [timeInterval longLongValue] / 1000;
    
    NSDate *GMTdate = [NSDate dateWithTimeIntervalSince1970:timeInt];
    NSString *localDate = [self localDateFromGMTDate:GMTdate];
    NSDateFormatter *df = [self DateFormatterProper];
    NSDate *currentDate = [df dateFromString:localDate];
    
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    messageStorage.docInfo = [[self getDocumentInfoForID:document forDatabase:db] mutableCopy];
    NSMutableArray *msgsArray = [messageStorage.docInfo[@"messages"] mutableCopy];
    
    
   // NSString *diplaytext = [self displayTextonChatScreen:responseDict[@"from"] type:responseDict[@"groupType"] message:responseDict[@"mess"]];
    
    Message *msg = [[Message alloc] init];
        msg.type = SOMessageTypeText;
        msg.text = @"" ;
        msg.groupMessageTag = responseDict[@"mess"];
        msg.date = currentDate;
        msg.fromNum = responseDict[@"from"];
        msg.messageID = [NSString stringWithFormat:@"%@",responseDict[@"timeStamp"]];


    NSDictionary *dict;
    //check
    NSString *mess = responseDict[@"mess"];
    if (!responseDict[@"mess"]) {
        mess = @"";
    }
    
    dict = @{@"text":@"",
             @"date":localDate,
             @"messageID":[NSString stringWithFormat:@"%ld",[responseDict[@"timeStamp"] longValue]],
             @"type":@"0",
             @"groupMessageTag":mess,
             @"fromNum":responseDict[@"from"],
             };

    [msgsArray addObject:dict];
    

    NSMutableArray *msgs = [messageStorage.docInfo[@"messages"] mutableCopy];
    [msgs addObject:dict];
    
    messageStorage.docInfo[@"messages"] = msgs;
    
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });
    
    
    [cbEvent updateDocument:db documentId:document withMessages:[msgsArray copy]];
    

    if (self.delegate && [self.delegate respondsToSelector:@selector(receivedNewMessage:forDocID:)]) {
        
        if (document) {
            [self.delegate receivedNewMessage:msg forDocID:document];
        }
    }

    
}


-(NSString*)displayTextonChatScreen:(NSString*)userNumber type:(NSString*)type message:(NSString*)mess{
    
    NSString *original ;
    
    if ([type integerValue] == 6) {
        
        NSString *tempStr = mess;
     //   tempStr = [mess substringToIndex:13];
        if ([mess rangeOfString:userNumber].location != NSNotFound)
        {
        }
       // tempStr = [mess ]
        tempStr = [self checkUserNuminDB:tempStr];
        
        
        original = [NSString stringWithFormat:@"%@ %@",tempStr,[mess substringFromIndex:14]];
    }else if ([type integerValue] == 2){
        
        NSString *tempStr = mess;
        tempStr = [mess substringToIndex:13];
        tempStr = [self checkUserNuminDB:tempStr];
        original = [NSString stringWithFormat:@"%@ %@",tempStr,[mess substringFromIndex:14]];
        
        
    }
    
    
    
    return original;
}





//check user num in db or not
-(NSString *)checkUserNuminDB:(NSString*)userNumber{
    
//    FavDataBase *fav = [FavDataBase sharedInstance];
//    
//    NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",userNumber];
//    NSArray *allFav = [fav getDataFavDataFromDB];
//    NSArray *arr = [allFav filteredArrayUsingPredicate:predi];
//    
//    NSString *userName;
//
//  
//    if (arr.count>0) {
//        NSDictionary *fav = [arr firstObject];
//        userName = fav[@"fullName"];
//    }else{
//        userName = userNumber;
//    }

    return @"name";
    
}

@end
