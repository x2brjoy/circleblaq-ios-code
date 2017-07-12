//
//  SIOClient.m
//  SIOClient
//
//  Created by Vinay Raja on 14/09/15.
//  Copyright (c) 2015 3Embed. All rights reserved.
//

#import "SIOClient.h"
#import <SIOSocket/SIOSocket.h>
#import "AppDelegate.h"

static SIOClient *sioClient = NULL;

@interface SIOClient ()

@property (nonatomic, strong) SIOSocket *socket;
@property (nonatomic, strong) SIOConfiguration *configuration;

@end

@interface SIOClient (Utility)

- (NSString*) stringForInput:(id)input;

@end

@implementation SIOClient

+ (instancetype) sharedInstance {
    if (!sioClient) {
        sioClient = [SIOClient new];
    
    }
    
    return sioClient;
}

- (void) setConfiguration:(SIOConfiguration*)configuration {
    _configuration = configuration;
}

- (void) connect {
    [SIOSocket socketWithHost: [_configuration getHostString] response: ^(SIOSocket *socket) {
        self.socket = socket;
      socket.onConnect = ^() {
            if (_delegate && [_delegate respondsToSelector:@selector(sioClient:didConnectToHost:)]) {
                [_delegate sioClient:self didConnectToHost:[self.configuration getHostString]];
            }
        };
        socket.onDisconnect = ^() {
            if (_delegate && [_delegate respondsToSelector:@selector(sioClient:didDisconnectFromHost:)]) {
                [_delegate sioClient:self didDisconnectFromHost:[self.configuration getHostString]];
            }
        };
        socket.onError = ^(NSDictionary *errorInfo) {
            if (_delegate && [_delegate respondsToSelector:@selector(sioClient:gotError:)]) {
                [_delegate sioClient:self gotError:errorInfo];
            }
        };
    }];
}

- (void) disconnect {
    [_socket close];
}

- (void) subscribeToChannels:(NSArray*)channelsArray {
    
    for (NSString *channel in channelsArray) {
        [_socket on:channel callback:^(NSArray *args) {
            if (_delegate && [_delegate respondsToSelector:@selector(sioClient:didRecieveMessage:onChannel:)]) {
                [_delegate sioClient:self didRecieveMessage:args onChannel:channel];
            }
        }];
        
        if (_delegate && [_delegate respondsToSelector:@selector(sioClient:didSubscribeToChannel:)]) {
            [_delegate sioClient:self didSubscribeToChannel:channel];
        }
        
    }
    
    
}

- (void) publishToChannel:(NSString*)channel message:(id)message {
    
    
    if (message) {
        [_socket emit:channel args:@[message]];
        if (_delegate && [_delegate respondsToSelector:@selector(sioClient:didSendMessageToChannel:)]) {
            [_delegate sioClient:self didSendMessageToChannel:channel];
        }
    }
    else {
        if (_delegate && [_delegate respondsToSelector:@selector(sioClient:gotError:)]) {
            [_delegate sioClient:self gotError:@{@"error": @"inavlid message format"}];
        }
    }
}

@end

@implementation SIOClient (Utility)

- (NSString*) stringForInput:(id)input {
    NSString *inputString = nil;
    if ([input isKindOfClass:[NSDictionary class]] || [input isKindOfClass:[NSArray class]]) {
    
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:input options:NSJSONWritingPrettyPrinted error:nil];
        inputString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    else if ([input isKindOfClass:[NSString class]]) {
        inputString = input;
    }
    
    return inputString;
}

@end
