//
//  Message.m
//  
//
//  Created by Rahul Sharma on 3/20/15.
//
//

#import "Message.h"

@implementation Message
@synthesize attributes,text,date,fromMe,media,thumbnail,type,messageID,messageDelivered,messageSent,messageRead,fromNum,groupMessageTag,isUrlDownloaded,dataSize,groupID,postData;

- (id)init
{
    if (self = [super init]) {
        self.date = [NSDate date];
    }
    
    return self;
}


@end
