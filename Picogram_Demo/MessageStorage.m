//
//  MessageStorage.m
//  ChatClient
//
//  Created by Bhavuk Jain on 02/01/16.
//  Copyright © 2016 Bhavuk Jain. All rights reserved.
//

#import "MessageStorage.h"
#import "UIImage+AFNetworking.h"
#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

static MessageStorage *messageStorage = NULL;

@implementation MessageStorage


+(instancetype)sharedInstance {
    
    if (!messageStorage) {

        messageStorage = [[MessageStorage alloc] init];
    }
    
    return messageStorage;
}


-(CBLDocument *)getDocumentForID:(NSString *)docID {
    
    CBLDatabase *database = CBObjects.sharedInstance.database;
    
    CBLDocument *document = [database documentWithID:docID];
    
    return document;
}


-(NSDictionary *)getDocumentInfoForID:(NSString *)docID forDatabase:(CBLDatabase *)db {
    
    CBLDatabase *database = db;
    CBLDocument *document = [database documentWithID:docID];
    // [database clearDocumentCache];
    return [self getDetailsForDocument:document];
}

-(NSDictionary *)getDetailsForDocument:(CBLDocument *) document {
    
    //NSError *Error;
    
   // NSLog(@"hello =%@",[document getRevisionHistory:&Error]);
   
   // return document.currentRevision.properties;
    return document.properties;
}

-(NSMutableArray *)createIntoSOMessagesfromMessages:(NSArray *)messages {
 //convert Message fromat in to chatView message fromat
    NSMutableArray *messagesArray = [NSMutableArray new];
    for (NSDictionary *dict in messages) {
        
        NSDateFormatter *formatter = [self DateFormatterProper];
        Message *msg = [[Message alloc] init];
        msg.date = [formatter dateFromString:dict[@"date"]];
        msg.fromMe = [dict[@"fromMe"] boolValue];
        msg.messageID = dict[@"messageID"];
        msg.fromNum = dict[@"fromNum"];
        
        
        if (dict[@"isUrlDownloaded"] && [dict[@"type"]integerValue] == 8) {
            msg.isUrlDownloaded = [dict[@"isUrlDownloaded"] boolValue];
        }else if (dict[@"isUrlDownloaded"]) {
             msg.isUrlDownloaded = [dict[@"isUrlDownloaded"] boolValue];
        }
        
        
        if (dict[@"groupMessageTag"]) {
            msg.groupMessageTag = dict[@"groupMessageTag"];
        }
        
        if (dict[@"groupID"]) {
            msg.groupID = dict[@"groupID"];
        }
        
        if (dict[@"messageSent"]) {
            msg.messageSent = [dict[@"messageSent"] boolValue];
        }
        if (dict[@"messageDelivered"]) {
            msg.messageDelivered = [dict[@"messageDelivered"]boolValue];
        }
        if (dict[@"messageRead"]) {
            msg.messageRead = [dict[@"messageRead"]boolValue];
        }
        
        if (dict[@"text"]) {
            msg.text = dict[@"text"];
        }
        if (dict[@"media"]) {
           
            if (msg.isUrlDownloaded == NO) {
                if (msg.fromMe == YES) {

                    NSData *originalData = [[NSData alloc]
                                            initWithBase64EncodedString:dict[@"media"] options:0];
                    msg.media = originalData;
                    
                }else{
                    msg.media = dict[@"media"];
                }
                
                
            }else{
            NSData *originalData = [[NSData alloc]
                                    initWithBase64EncodedString:dict[@"media"] options:0];
            msg.media = originalData;
            }
        }
        if ([dict[@"type"]integerValue] == 8) {
            
            if (msg.isUrlDownloaded == NO) {
              
                    msg.postData = dict[@"Postdata"];
            
                
                
            }else{
              
                msg.postData = dict[@"Postdata"];
            }
        }
        if (dict[@"thumbnail"]) {
 
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",dict[@"messageID"]];
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
            UIImage *image = [UIImage imageWithContentsOfFile:moviePath];
            msg.thumbnail = image;
            
            
        }
        if (dict[@"dataSize"]) {
            msg.dataSize = dict[@"dataSize"];
        }
        
        if ([dict[@"type"] integerValue] == 0) {
            msg.type = SOMessageTypeText;
        }else if ([dict[@"type"] integerValue] == 1) {
            msg.type = SOMessageTypePhoto;
        }else if ([dict[@"type"] integerValue] == 2) {
            msg.type = SOMessageTypeVideo;
        }else if ([dict[@"type"] integerValue] == 3){
            msg.type = SOMessageTypeLocation;
        }else if ([dict[@"type"] integerValue] == 4){
            msg.type = SOMessageTypeContact;
        }
        else if ([dict[@"type"] integerValue] ==5){
            msg.type = SOMessageTypeVoice;
        }
        else if ([dict[@"type"] integerValue] ==8){
            msg.type = SOMessageTypePost;
        }

        [messagesArray addObject:msg];
    }
    
    return messagesArray;
    
}
/***************/
-(NSMutableArray *)createMediaListfromMessages:(NSArray *)messages{
    
    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    _mediaInfo = [NSMutableDictionary new];
    _medialist = [NSMutableArray new];
    NSString *dateStr;
    NSDate *now = [NSDate date];
    for (int i = 0; i<messages.count; i++) {
        
        if (messages[i][@"media"] && ([messages[i][@"isUrlDownloaded"] isEqualToString:@"YES"])) {
            _medialist = [NSMutableArray new];
            
            NSDateFormatter *formatter = [self DateFormatterProper];
            NSDate *dt  = [formatter dateFromString:messages[i][@"date"]];
            
            /***/
            NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                               components:NSCalendarUnitDay
                                               fromDate:dt
                                               toDate:now
                                               options:0];
            
            int days = (int)[ageComponents day];
           // NSLog(@"day:%d",days);
            if (days == 0) {
                
                dateStr = @"Today";
            }
            else if (days == 1)
            {
                dateStr = @"Yesterday";
            }
            else
            {
                NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                [formatter1 setDateFormat:@"MMMM"];
                dateStr = [formatter1 stringFromDate:dt];
                
            }
            
            
          //  NSLog(@"New Date:%@",dateStr);
            [_mediaInfo setObject:dateStr forKey:@"Date"];
            
            NSString *messageID = [NSString stringWithFormat:@"%@",messages[i][@"messageID"]];
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName;
            if ([messages[i][@"type"] isEqualToString:@"1"]) {
              movieName  = [NSString stringWithFormat:@"%@.jpg",messageID];
            }else{
                
                movieName = [NSString stringWithFormat:@"%@.mp4",messageID];
            }
            
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
            
            NSData *originalData = [NSData dataWithContentsOfFile:moviePath];
//            if (originalData ==nil) {
//                return ;
//            }
          //  NSData *originalData = [[NSData alloc]
                                //initWithBase64EncodedString:messages[i][@"media"] options:0];
            
            if (originalData == nil) {
                 UIImage *thumbnailImage = [UIImage imageNamed:@"avatar_image_contac"];
                 originalData = UIImagePNGRepresentation(thumbnailImage);
                [_mediaInfo setObject:originalData forKey:@"Image"];
            }else{
                [_mediaInfo setObject:originalData forKey:@"Image"];}
            [_mediaInfo setObject:messages[i][@"type"] forKey:@"Types"];
            if (messages[i][@"thumbnail"]) {
              
                NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDir  = [documentPaths objectAtIndex:0];
                NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageID];
                NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
                NSData *thumbnailData = [NSData dataWithContentsOfFile:moviePath];
               // NSData *thumbnailData = [[NSData alloc]
                                       //  initWithBase64EncodedString:messages[i][@"thumbnail"] options:0];
                [_mediaInfo setObject:thumbnailData forKey:@"Thumbnail"];
            }
            [messagesArray addObject:[_mediaInfo copy]];
            
        }else if([messages[i][@"type"] isEqualToString:@"8"] && ([messages[i][@"isUrlDownloaded"] isEqualToString:@"NO"]))
        {
            
            _medialist = [NSMutableArray new];
            
            NSDateFormatter *formatter = [self DateFormatterProper];
            NSDate *dt  = [formatter dateFromString:messages[i][@"date"]];
            
            NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                               components:NSCalendarUnitDay
                                               fromDate:dt
                                               toDate:now
                                               options:0];
            
            int days = (int)[ageComponents day];
            
            if (days == 0) {
                
                dateStr = @"Today";
            }
            else if (days == 1)
            {
                dateStr = @"Yesterday";
            }
            else
            {
                NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                [formatter1 setDateFormat:@"MMMM"];
                dateStr = [formatter1 stringFromDate:dt];
                
            }
            
            [_mediaInfo setObject:dateStr forKey:@"Date"];
            
            NSString *messageID = [NSString stringWithFormat:@"%@",messages[i][@"messageID"]];
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName;
            //                if ([messages[i][@"type"] isEqualToString:@"1"]) {
            movieName  = [NSString stringWithFormat:@"%@.jpg",messageID];
            //                }else{
            //
            //                    movieName = [NSString stringWithFormat:@"%@.mp4",messageID];
            //                }
            
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
            
            NSData *originalData = [NSData dataWithContentsOfFile:moviePath];
            
            
//            ...........................
            
            if (originalData == nil) {
                
                UIImageView *imagepost;
                UIImage *thumbnailImage;
              
                 
                NSString *imageURL = [NSString stringWithFormat:@"%@",messages[i][@"Postdata"][@"thumbnailImageUrl"]];

                
                    
                

                [_mediaInfo setObject:imageURL forKey:@"Image"];
                [_mediaInfo setObject:imageURL forKey:@"Thumbnail"];
            }else{
                NSString *imageURL = [NSString stringWithFormat:@"%@",messages[i][@"Postdata"][@"thumbnailImageUrl"]];
                [_mediaInfo setObject:imageURL forKey:@"Image"];}
            [_mediaInfo setObject:messages[i][@"type"] forKey:@"Types"];

            [messagesArray addObject:[_mediaInfo copy]];
            
        }

        
        
    }
    messagesArray=[[[messagesArray reverseObjectEnumerator] allObjects] mutableCopy];
    
    return messagesArray;
    
}
-(NSMutableArray *)replaceMsgObjectWithID:(NSString *)messageID inMessages:(NSMutableArray *)messages status:(NSString *)status docID:(NSString *)documentID{
    
   // NSLog(@"replaceMsgObjectWithID =%@ =%@",messageID,messages);
    NSMutableArray *message1 = [NSMutableArray new];
    message1 = [messages mutableCopy];

    if (message1.count>0) {
        
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"messageID contains[cd] %@",messageID];
    
    NSArray *messageObject = [message1 filteredArrayUsingPredicate:bPredicate];
    if (messageObject.count>0) {
    NSDictionary *dict = [messageObject lastObject];
    
    NSMutableDictionary *dictMutable = [dict mutableCopy];
    [dictMutable setObject:@"YES" forKey:@"messageSent"];
   // dictMutable[@"messageSent"] = @"YES";
    if ([status  isEqual: MessagesuccesfullyDeliver]) {
       // dictMutable[@"messageDelivered"] = @"YES";
        [dictMutable setObject:@"YES" forKey:@"messageDelivered"];
    }
    if ([status isEqual:MessagesuccesfullyRead]) {
        [dictMutable setObject:@"YES" forKey:@"messageRead"];
        [dictMutable setObject:@"YES" forKey:@"messageDelivered"];
        [dictMutable setObject:@"YES" forKey:@"messageSent"];
       // dictMutable[@"messageRead"] =@"YES";
    }
    
    NSMutableArray *tempBuffer = [[NSMutableArray alloc] initWithArray:messages];
    NSInteger indexOfdict = [tempBuffer indexOfObject:dict];
    
    NSMutableArray *storMessageArr =[[NSMutableArray alloc] initWithArray:messages];
    
    for (int i=(int)indexOfdict-1;i>0;i--) {
        
        NSDictionary *dict =[storMessageArr objectAtIndex:i];
        NSString *isRead = dict[@"messageRead"];
       
        if ([isRead isEqualToString:@"YES"]) {
            break;
        }
        else if ([dict[@"fromMe"] isEqualToString:@"NO"]){
        }
        else{
            
            if ([dictMutable[@"messageRead"] isEqualToString:@"YES"]) {
                
            NSMutableDictionary *dictMutableCopy = [dict mutableCopy];
            [dictMutableCopy setObject:@"YES" forKey:@"messageDelivered"];
            [dictMutableCopy setObject:@"YES" forKey:@"messageRead"];
            [dictMutableCopy setObject:@"YES" forKey:@"messageSent"];
            //NSLog(@"dictMutableCopy check MessageRead=%@",dictMutableCopy);
            if (dictMutableCopy) {

               // [message1 replaceObjectAtIndex:i withObject:dictMutableCopy];
               [messages replaceObjectAtIndex:i withObject:dictMutableCopy];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadTableForMessageID:andDocID:status:)]) {
                    [self.delegate reloadTableForMessageID:dictMutableCopy[@"messageID"] andDocID:documentID status:MessagesuccesfullyRead];
                }
                
                }
            }
        }
    }
    
    
    if (dictMutable) {
     //carsh slove
       /* NSMutableArray *temp = [NSMutableArray new];
        temp = [message1 mutableCopy];
        [temp replaceObjectAtIndex:indexOfdict withObject:dictMutable];
        [message1 removeAllObjects];
        message1 = [temp mutableCopy];*/
        [messages replaceObjectAtIndex:indexOfdict withObject:dictMutable];
    }
    
    }
    }
    
    return messages;//message1;
}

-(NSInteger)indexOfMessageWithID:(NSString *)messageID inMessages:(NSMutableArray *)messages {
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"messageID contains[cd] %@",messageID];
    NSArray *messageObject = [messages filteredArrayUsingPredicate:bPredicate];
    NSDictionary *dict = [messageObject lastObject];
    NSInteger indexOfdict = [messages indexOfObject:dict];
    
    return indexOfdict;
    
}


-(void)updateDocument:(CBLDocument *)document withMessages:(NSMutableArray *)messages {
    
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [cbEvent updateDocument:CBObjects.sharedInstance.database documentId:document.documentID withMessages:messages];
        
    }];
    
}

//extra call for test

-(void)updateDocumentWithID:(NSString *)documentID withMessages:(NSMutableArray *)messages onDatabase:(CBLDatabase *)db {
    
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        [cbEvent updateDocument:db documentId:documentID withMessages:[messages copy]];
        
//    }];
}

-(void)updateDocForTickmark:(NSString*)documentID withMessages:(NSMutableArray*)messages onDatabase:(CBLDatabase*)db{
   
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });
    
    BOOL isUpdate = [cbEvent updateDoc:db documentId:documentID withmessage:[messages copy]];
   // NSLog(@"tick updated =%d",isUpdate);
    
}

- (NSDateFormatter *)DateFormatterProper {
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        //        formatter.dateFormat = @"dd MMM yyyy";
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return formatter;
}



@end
