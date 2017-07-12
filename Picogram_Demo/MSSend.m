//
//  MSSend.m
//  ChatClient
//
//  Created by Bhavuk Jain on 02/01/16.
//  Copyright © 2016 Bhavuk Jain. All rights reserved.
//

#import "MSSend.h"
#import "ChatHelper.h"
#import "PicogramSocketIOWrapper.h"
#import "zlib.h"
#import "MSReceive.h"
static MSSend *msSend = NULL;

@implementation MSSend


+(instancetype)sharedInstance {
    
    if (!msSend) {
           
        msSend = [[MSSend alloc] init];
    }
    
    return msSend;
}


-(Message *)sendMessage:(NSString *)message onDocument:(CBLDocument *)document groupId:(NSString *)groupId{
    
    NSData* dataMsg = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDate *date = [NSDate date];
    Message *msg = [[Message alloc] init];
    msg.text = message;
    msg.fromMe = YES;
    msg.date = date;
    msg.messageID = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    msg.messageSent = NO;
    msg.messageDelivered = NO;
    msg.messageRead =NO;
    msg.type = 0;
    
    NSDictionary *dict = @{@"text":message,
                           @"fromMe":@"YES",
                           @"date":[ChatHelper getCurrentDateTime:date dateFormat:@"yyyy-MM-dd HH:mm:ss"],
                           @"messageID":[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000],
                           @"messageSent":@"NO",
                           @"messageDelivered":@"NO",
                           @"messageRead":@"NO",
                           @"type":@"0"};
    
//    NSDictionary *docInfo;// = document.properties;
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
        if (![messageStorage.previousDocID isEqualToString:document.documentID]) {
            [messageStorage setPreviousDocID:document.documentID];
            [messageStorage setDocInfo:[document.properties mutableCopy]];
        }
        NSMutableArray *messagesArray =[[NSMutableArray alloc]initWithArray:[messageStorage.docInfo[@"messages"] copy]];
        [messagesArray addObject:dict];
        messageStorage.docInfo[@"messages"] = messagesArray;
        @synchronized(self) {
         [self updateDocument:document withMessages:[messagesArray mutableCopy] onDatabase:bgDB];
        }
        
    });
    
    
    if (groupId.length == 0) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"%@",document.properties[@"sendingUser"]);
            NSLog(@"%@",document.properties[@"receivingUser"] );
            NSLog(@"%@",document.documentID);
            [[PicogramSocketIOWrapper sharedInstance] sendMessage:dataMsg fromUser:document.properties[@"sendingUser"] toUser:document.properties[@"receivingUser"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeText];
        }];
    }
    else{
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance]sendMessagetoGroup:dataMsg fromUser:document.properties[@"createdBy"] toUser:document.properties[@"groupID"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeText groupName:document.properties[@"groupName"]];
        }];
    }
    
    return msg;

}

//Share post
-(Message *)sendPost:(NSArray *)data onDocument:(CBLDocument *)document groupId:(NSString *)groupId{
//    NSDate *date = [NSDate date];
//   
//    NSData* dataMsg = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSDate *date = [NSDate date];
    
    
//    NSData *postEnData = [NSKeyedArchiver archivedDataWithRootObject:data];
    
    NSLog(@"%@",document);
    
    Message *msg = [[Message alloc] init];
    msg.postData = data;
    msg.fromMe = YES;
    msg.date = date;
    msg.messageID = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    msg.type = SOMessageTypePost;
    msg.messageSent = NO;
    msg.messageDelivered = NO;
    msg.messageRead = NO;
    
    NSDictionary *dict = @{@"Postdata":data, //message,
                           @"fromMe":@"YES",
                           @"date":[ChatHelper getCurrentDateTime:date dateFormat:@"yyyy-MM-dd HH:mm:ss"],
                           @"messageID":[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000],
                           @"messageSent":@"NO",
                           @"messageRead":@"NO",
                           @"messageDelivered":@"NO",
                           @"type":@"8",
                           @"isUrlDownloaded":@"NO"
                           };
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
        if (![messageStorage.previousDocID isEqualToString:document.documentID]) {
            [messageStorage setPreviousDocID:document.documentID];
            [messageStorage setDocInfo:[document.properties mutableCopy]];
        }
        NSMutableArray *messagesArray =[[NSMutableArray alloc]initWithArray:[messageStorage.docInfo[@"messages"] copy]];
        [messagesArray addObject:dict];
        messageStorage.docInfo[@"messages"] = messagesArray;
        @synchronized(self) {
            [self updateDocument:document withMessages:[messagesArray mutableCopy] onDatabase:bgDB];
        }
        
    });
    
    
    if (groupId.length == 0) {
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            NSLog(@"%@",document.properties[@"sendingUser"]);
//            NSLog(@"%@",document.properties[@"receivingUser"] );
//            NSLog(@"%@",document.documentID);
//            [[PicogramSocketIOWrapper sharedInstance] sendMessage:data fromUser:document.properties[@"sendingUser"] toUser:document.properties[@"receivingUser"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypePost];
//        }];
    }
    else{
        NSLog(@"%@",document.properties[@"sendingUser"]);
        NSLog(@"%@",document.properties[@"receivingUser"] );
        NSLog(@"%@",document.documentID);
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance]sendPostToGroup:data fromUser:document.properties[@"createdBy"] toUser:document.properties[@"groupID"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypePost groupName:document.properties[@"groupName"]];
        }];
    }
    
    return msg;
    

    
}

-(Message *)sendImage:(UIImage *)image onDocument:(CBLDocument *)document groupId:(NSString *)groupId{
    
    NSDate *date = [NSDate date];
    NSData *data = UIImageJPEGRepresentation(image,0.2);
    NSString *message = [data base64EncodedStringWithOptions:kNilOptions];
    
    
   UIImage *thumbnail = [ChatHelper imageWithImage:image scaledToSize:CGSizeMake(20,20)];
    NSData  *data1  = UIImageJPEGRepresentation (thumbnail,0.2);
    NSString *thumbStr = [data1 base64EncodedStringWithOptions:kNilOptions];
    
    NSData  *pathData = [self storeImageinMemeory:data messageID:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
    NSString *encodedMess = [pathData base64EncodedStringWithOptions:kNilOptions];
    
    Message *msg = [[Message alloc] init];
    msg.media = pathData;
    msg.fromMe = YES;
    msg.date = date;
    msg.messageID = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    msg.type = SOMessageTypePhoto;
    msg.messageSent = NO;
    msg.messageDelivered = NO;
    msg.messageRead = NO;
    
    NSDictionary *dict = @{@"media":encodedMess, //message,
                           @"fromMe":@"YES",
                           @"date":[ChatHelper getCurrentDateTime:date dateFormat:@"yyyy-MM-dd HH:mm:ss"],
                           @"messageID":[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000],
                           @"messageSent":@"NO",
                           @"messageRead":@"NO",
                           @"messageDelivered":@"NO",
                           @"type":@"1",
                           @"isUrlDownloaded":@"YES"
                           };
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
        
        if (![messageStorage.previousDocID isEqualToString:document.documentID]) {
            messageStorage.previousDocID = document.documentID;
            messageStorage.docInfo = [document.properties mutableCopy];
        }
        
        NSMutableArray *messagesArray = [messageStorage.docInfo[@"messages"] mutableCopy];
        [messagesArray addObject:dict];
        messageStorage.docInfo[@"messages"] = messagesArray;
        @synchronized(self) {
        [self updateDocument:document withMessages:[messagesArray mutableCopy] onDatabase:bgDB];
        }

    });
    
    

    
    if (groupId.length == 0) {
    
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance] uploadFiletoSocketgetUrl:data fromUser:document.properties[@"sendingUser"] toUser:document.properties[@"receivingUser"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypePhoto thumData:thumbStr];
        }];
    
        
    }else{
    
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            NSLog(@"%@  %@    %@  %@   ",document.properties[@"createdBy"],document.properties[@"groupID"],document.documentID,document.properties[@"groupName"] );
            [[PicogramSocketIOWrapper sharedInstance] uploadFiletoSockectForGroupChat:data fromUser:document.properties[@"createdBy"] toUser:document.properties[@"groupID"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypePhoto groupName:document.properties[@"groupName"] thumData:thumbStr];
        }];
    
        
    }
    
    
    return msg;
}

/*store image to memory*/
-(NSData*)storeImageinMemeory:(NSData*)data messageID:(NSString*)messageID{
    
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    NSString *movieName = [NSString stringWithFormat:@"%@.jpg",messageID];
    NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
    NSLog(@"%@",moviePath);
    NSData *data1;
    if([data writeToFile:moviePath atomically:YES]) {
        // NSURL *url = [[NSURL alloc] initFileURLWithPath:moviePath];
        data1 = [moviePath dataUsingEncoding:NSUTF8StringEncoding];
        
    }
    
    
    return data1;
}

-(NSData*)storeImagethumbinMemeory:(NSData*)data messageID:(NSString*)messageID{
    
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




-(Message *)sendVideo:(NSString *)filePath withThumbnailImage:(UIImage *)thumbnailImage onDocument:(CBLDocument *)document groupId:(NSString *)groupId {
    
    NSDate *date = [NSDate date];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
   // NSData *data1 = [self encodeWithZlib:data];
    NSString *message = [data base64EncodedStringWithOptions:kNilOptions];
    
    UIImage *thumbnail = [ChatHelper imageWithImage:thumbnailImage scaledToSize:CGSizeMake(20,20)];
    NSData *imageDatathumb = UIImagePNGRepresentation(thumbnailImage);
    
    
    NSArray  *documentPaths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDir1  = [documentPaths1 objectAtIndex:0];
    NSString *movieName1 = [NSString stringWithFormat:@"%@.mp4",[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
    NSString *moviePath1  = [documentsDir1 stringByAppendingPathComponent:movieName1];
    
    if([data writeToFile:moviePath1 atomically:YES]) {
        
    }
    

    NSData *pathData = [self storeImagethumbinMemeory:imageDatathumb messageID:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
    
    NSString *encodedMess = [pathData base64EncodedStringWithOptions:kNilOptions];
    

    //   [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//        [self storeVideoinMemeory:data messageID:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
//   }];
   
    
    
    Message *msg = [[Message alloc] init];
    msg.media = pathData;
    msg.thumbnail = thumbnailImage;
    msg.fromMe = YES;
    msg.date = date;
    msg.messageID = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    msg.type = SOMessageTypeVideo;
    msg.messageSent = NO;
    msg.messageDelivered = NO;
    msg.messageRead =NO;
    
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
    NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
    NSString *thumbnailImageString = [ChatHelper encodeStringTo64:moviePath];
    
    
    NSDictionary *dict = @{@"media":encodedMess,
                           @"fromMe":@"YES",
                           @"date":[ChatHelper getCurrentDateTime:date dateFormat:@"yyyy-MM-dd HH:mm:ss"],
                           @"messageID":[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000],
                           @"messageSent":@"NO",
                           @"messageDelivered":@"NO",
                           @"messageRead":@"NO",
                           @"type":@"2",
                           @"thumbnail":thumbnailImageString,
                           @"isUrlDownloaded":@"YES",
                           };
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
        if (![messageStorage.previousDocID isEqualToString:document.documentID]) {
            messageStorage.previousDocID = document.documentID;
            messageStorage.docInfo = [document.properties mutableCopy];
        }
        NSMutableArray *messagesArray = [messageStorage.docInfo[@"messages"] mutableCopy];
        [messagesArray addObject:dict];
        messageStorage.docInfo[@"messages"] = messagesArray;
        [self updateDocument:document withMessages:[messagesArray mutableCopy] onDatabase:bgDB];

    });
    
    
    
     UIImage *thumbnail1 = [ChatHelper imageWithImage:thumbnailImage scaledToSize:CGSizeMake(20,20)];
     NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnail1);
      NSString *thumbnailImageString1 = [thumbnailImageData base64EncodedStringWithOptions:kNilOptions];

    
    if (groupId.length == 0) {
      
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance] uploadFiletoSocketgetUrl:data fromUser:document.properties[@"sendingUser"] toUser:document.properties[@"receivingUser"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeVideo thumData:thumbnailImageString1];
        }];
    
    }else{
    
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance] uploadFiletoSockectForGroupChat:data fromUser:document.properties[@"createdBy"] toUser:document.properties[@"groupID"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeVideo groupName:document.properties[@"groupName"] thumData:thumbnailImageString1];
        }];
    
    }
    
    return msg;
}


-(Message *)sendLocation:(NSString *)name address:(NSString *)address latlog:(NSString*)latlog onDocument:(CBLDocument*)document groupId:(NSString *)groupId{
    
      NSDate *date = [NSDate date];
    NSArray *latlogArr =[latlog componentsSeparatedByString:@","];
    double latitude = 0.0;
    double logitude = 0.0;
    if (![address isEqualToString:@"current location"]) {
        
        latitude = [[latlogArr firstObject] doubleValue];
        logitude = [[latlogArr lastObject] doubleValue];
        
    }else{
        
        latitude = [[latlogArr firstObject]doubleValue];
        logitude = [[latlogArr firstObject]doubleValue];
    }
    
//    for (int i=0; i<latlogArr.count; i++) {
//        if (i == 0) {
//            NSString *getLat = [latlogArr objectAtIndex:i];
//            NSArray *subArr = [getLat componentsSeparatedByString:@" "];
//            getLat = [subArr lastObject];
//            getLat = [getLat substringFromIndex:1];
//            getLat = [getLat substringToIndex:10];
//            latitude = [getLat doubleValue];
//        }else if(i == 1){
//            
//            NSString *getLog = [latlogArr objectAtIndex:i];
//            NSArray *subArr = [getLog componentsSeparatedByString:@" "];
//            getLog = [subArr lastObject];
//            getLog = [getLog substringFromIndex:1];
//            getLog = [getLog substringToIndex:10];
//            logitude = [getLog doubleValue];
//        }
//    }
  //  }
    
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?markers=color:red|%f,%f&%@&sensor=true",latitude,logitude,@"zoom=10&size=270x200"];
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    UIImage *thumbnailImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
    
    [self storeImagethumbinMemeory:[NSData dataWithContentsOfURL:mapUrl] messageID:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
    
    
    if (thumbnailImage == nil) {
        thumbnailImage = [UIImage imageNamed:@"default_568h"];
        [self storeImageinMemeory:UIImagePNGRepresentation(thumbnailImage) messageID:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
        
    }

    
   // NSString *message = [NSString stringWithFormat:@"%@,%@,%@",latlogArr,name,address];
    NSMutableArray *locarr = [NSMutableArray new];
    NSString *latlogStr12 = [NSString stringWithFormat:@"(%@,%@)",[latlogArr objectAtIndex:0],[latlogArr objectAtIndex:1]];
//    [locarr addObject:latlogStr12];
//    [locarr addObject:name];   //name should not be nill
//    [locarr addObject:address]; /// address also
    
    NSString *message = [NSString stringWithFormat:@"%@@@%@@@%@",latlogStr12,name,address];
    //NSString *message = [NSString stringWithFormat:@"%@",locarr];
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
  
    Message *msg = [[Message alloc] init];
    msg.text = message;
    msg.thumbnail = thumbnailImage;
    msg.fromMe = YES;
    msg.date = date;
    msg.messageID = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    msg.messageSent = NO;
    msg.messageDelivered = NO;
    msg.messageRead =NO;
    msg.type = SOMessageTypeLocation;
    
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
    NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
    NSString *thumbnailImageString = [ChatHelper encodeStringTo64:moviePath];
    
    NSDictionary *dict = @{@"text":message,
                           @"fromMe":@"YES",
                           @"date":[ChatHelper getCurrentDateTime:date dateFormat:@"yyyy-MM-dd HH:mm:ss"],
                           @"messageID":[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000],
                           @"messageSent":@"NO",
                           @"messageDelivered":@"NO",
                           @"messageRead":@"NO",
                           @"thumbnail":thumbnailImageString,
                           @"type":@"3"};
    
    //NSDictionary *docInfo;// = document.properties;
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
        if (![messageStorage.previousDocID isEqualToString:document.documentID]) {
            [messageStorage setPreviousDocID:document.documentID];
            [messageStorage setDocInfo:[document.properties mutableCopy]];
        }
        NSMutableArray *messagesArray = [messageStorage.docInfo[@"messages"] mutableCopy];
        [messagesArray addObject:dict];
        messageStorage.docInfo[@"messages"] = messagesArray;
        @synchronized(self) {
            [self updateDocument:document withMessages:[messagesArray mutableCopy] onDatabase:bgDB];
        }
        
    });
    
  
    if (groupId.length ==0) {
       
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance] sendMessage:data fromUser:document.properties[@"sendingUser"] toUser:document.properties[@"receivingUser"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeLocation];
        }];
        
    }else{
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance]sendMessagetoGroup:data fromUser:document.properties[@"createdBy"] toUser:document.properties[@"groupID"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeLocation groupName:document.properties[@"groupName"]];
        }];

    }
    
    return msg;
};

-(Message *)sendContact:(NSDictionary *)contacdict onDocument:(CBLDocument*)document groupId:(NSString *)groupId{
    
    NSDate *date = [NSDate date];
    NSString *name  = [NSString stringWithFormat:@"%@",contacdict[@"fullName"]];
    NSMutableArray *phNumbers  = [[contacdict objectForKey:@"contactNumbers"]mutableCopy];
    for (NSString *str in phNumbers)
    {
        if(str.length == 1)
        {
            [phNumbers removeObjectAtIndex:[phNumbers indexOfObject:str]];
        }
    }
    
    for (int i=0;i<phNumbers.count;i++) {
        name = [name stringByAppendingString:@"@@"];
        name = [name stringByAppendingString:phNumbers[i]];
    }
    
   // NSLog(@"send contact =%@",name);
    UIImage *thumbnailImage = [UIImage imageNamed:@"avatar_image_contac"];
    [self storeImagethumbinMemeory:UIImagePNGRepresentation(thumbnailImage) messageID:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
    NSString *message = [NSString stringWithFormat:@"%@",name];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    
    Message *msg = [[Message alloc] init];
    msg.text = message;
    msg.thumbnail = thumbnailImage;
    msg.fromMe = YES;
    msg.date = date;
    msg.messageID = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    msg.messageSent = NO;
    msg.messageDelivered = NO;
    msg.messageRead =NO;
    msg.type = SOMessageTypeContact;
    
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000]];
    NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
    NSString *thumbnailImageString = [ChatHelper encodeStringTo64:moviePath];


    NSDictionary *dict = @{@"text":message,
                           @"fromMe":@"YES",
                           @"date":[ChatHelper getCurrentDateTime:date dateFormat:@"yyyy-MM-dd HH:mm:ss"],
                           @"messageID":[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000],
                           @"messageSent":@"NO",
                           @"messageDelivered":@"NO",
                           @"messageRead":@"NO",
                           @"thumbnail":thumbnailImageString,
                           @"type":@"4"};
    
    //NSDictionary *docInfo;// = document.properties;
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
        if (![messageStorage.previousDocID isEqualToString:document.documentID]) {
            [messageStorage setPreviousDocID:document.documentID];
            [messageStorage setDocInfo:[document.properties mutableCopy]];
        }
        NSMutableArray *messagesArray = [messageStorage.docInfo[@"messages"] mutableCopy];
        [messagesArray addObject:dict];
        messageStorage.docInfo[@"messages"] = messagesArray;
        @synchronized(self) {
            [self updateDocument:document withMessages:[messagesArray mutableCopy] onDatabase:bgDB];
        }
        
    });
    
    
    if (groupId.length ==0) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance] sendMessage:data fromUser:document.properties[@"sendingUser"] toUser:document.properties[@"receivingUser"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeContact];
        }];
        
    }else{
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance]sendMessagetoGroup:data fromUser:document.properties[@"createdBy"] toUser:document.properties[@"groupID"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeContact groupName:document.properties[@"groupName"]];
        }];
    }
    
    return msg;
}

-(Message *)sendVoiceRecorder:(NSString *)voicedict onDocument:(CBLDocument*)document groupId:(NSString *)groupId{
    
    //Voice Recorder
    UIImage  *thumbnailImage = [UIImage imageNamed:@"avatar_image_contac"];
    NSDate *date = [NSDate date];
    NSData *data = [[NSData alloc] initWithContentsOfFile:voicedict];

    NSString *message = [data base64EncodedStringWithOptions:kNilOptions];
    Message *msg = [[Message alloc] init];
    msg.media = data;
    msg.thumbnail = thumbnailImage;
    msg.fromMe = YES;
    msg.date = date;
    msg.messageID = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    msg.type = SOMessageTypeVoice;
    msg.messageSent = NO;
    msg.messageDelivered = NO;
    msg.messageRead =NO;
    
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    NSString *thumbnailImageString = [thumbnailImageData base64EncodedStringWithOptions:kNilOptions];
    
    NSDictionary *dict = @{@"media":message,
                           @"fromMe":@"YES",
                           @"date":[ChatHelper getCurrentDateTime:date dateFormat:@"yyyy-MM-dd HH:mm:ss"],
                           @"messageID":[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000],
                           @"messageSent":@"NO",
                           @"messageDelivered":@"NO",
                           @"messageRead":@"NO",
                           @"type":@"5",
                           @"thumbnail":thumbnailImageString};
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
        if (![messageStorage.previousDocID isEqualToString:document.documentID]) {
            messageStorage.previousDocID = document.documentID;
            messageStorage.docInfo = [document.properties mutableCopy];
        }
        NSMutableArray *messagesArray = [messageStorage.docInfo[@"messages"] mutableCopy];
        [messagesArray addObject:dict];
        messageStorage.docInfo[@"messages"] = messagesArray;
        [self updateDocument:document withMessages:[messagesArray mutableCopy] onDatabase:bgDB];
        
    });
    
   
    if (groupId.length ==0) {
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
             [[PicogramSocketIOWrapper sharedInstance] sendMessage:data fromUser:document.properties[@"sendingUser"] toUser:document.properties[@"receivingUser"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeVoiceRec];
        }];
       
        
    }else{
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [[PicogramSocketIOWrapper sharedInstance]sendMessagetoGroup:data fromUser:document.properties[@"createdBy"] toUser:document.properties[@"groupID"] withDocId:document.documentID currentDate:date withTpe:SocketMessageTypeVoiceRec groupName:document.properties[@"groupName"]];
        }];
    }
  
    return msg;
}


-(void)updateDocument:(CBLDocument *)document withMessages:(NSMutableArray *)messages onDatabase:(CBLDatabase *)db {
    
    static CouchbaseEvents *cbEvent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cbEvent = [[CouchbaseEvents alloc] init];
    });
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [cbEvent updateDocument:db documentId:document.documentID withMessages:messages];
        
//    }];
    
}


-(void)storeVideoinMemeory:(NSData *)data messageID:(NSString *)messageID{
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    NSString *movieName = [NSString stringWithFormat:@"%@.mp4",messageID];
    NSString *moviePath  = [documentsDir stringByAppendingPathComponent:movieName];

    if([data writeToFile:moviePath atomically:YES]) {
        NSLog(@"video");
    
    }

    
    
}




@end
