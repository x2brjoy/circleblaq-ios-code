//
//  SIOConfiguration.m
//  SIOClient
//
//  Created by Vinay Raja on 14/09/15.
//  Copyright (c) 2015 3Embed. All rights reserved.
//

#import "SIOConfiguration.h"

//#define kHostURL        @"http://35.161.105.21"
//#define kPortNumber     @"3000"

// Chat Start
#define kHostURL        @"http://159.203.143.251"
#define kPortNumber     @"9001"
// Chat End

@interface SIOConfiguration ()

@property (nonatomic, strong) NSString *hostURL;
@property (nonatomic, strong) NSString *portNumber;

@end

@implementation SIOConfiguration

+ (instancetype) defaultConfiguration {
    SIOConfiguration *config = [[SIOConfiguration alloc] init];
    config.hostURL = kHostURL;
    config.portNumber = kPortNumber;
    return config;
}

- (instancetype) initWithHostURL:(NSString*)hostURL portNumber:(NSString*)portNumber {
    self = [super init];
    if (self) {
        self.hostURL = hostURL;
        self.portNumber = portNumber;
    }
    
    return self;
}

@end

@implementation SIOConfiguration (AccessHelper)

- (NSString*) getHostString {
    return [NSString stringWithFormat:@"%@:%@", _hostURL, _portNumber];
}

@end

