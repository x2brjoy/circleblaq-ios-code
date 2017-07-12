//
//  SIOClient.h
//  SIOClient
//
//  Created by Vinay Raja on 14/09/15.
//  Copyright (c) 2015 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIOConfiguration.h"

@protocol SIOClientDelegate;

/**
 *  Socket IO client class
 */
@interface SIOClient : NSObject

/**
 *  Socket IO configuration object
 */
@property (nonatomic, readonly) SIOConfiguration *configuration;

/**
 *  Socket IO client delegate to recieve callbacks
 */
@property (nonatomic, weak) id <SIOClientDelegate> delegate;

/**
 *  Connect to server
 */
- (void) connect;

/**
 *  Get shared instance of the SIOClient
 *
 *  @return instance of SIOClient
 */
+ (instancetype) sharedInstance;

/**
 *  Set socket io client configuration
 *
 *  @param configuration SIOConfiguration object
 */
- (void) setConfiguration:(SIOConfiguration*)configuration;



/**
 *  Disconnect from server
 */
- (void) disconnect;

/**
 *  Start listening on the specified channels
 *
 *  @param channelsArray NSArray of channels
 */
- (void) subscribeToChannels:(NSArray*)channelsArray;

/**
 *  Publish to specified channel
 *
 *  @param channel Name of channel
 *  @param message Message to be published. Message can be any serializable class object (NSDictionary, NSArray or NSString)
 */
- (void) publishToChannel:(NSString*)channel message:(id)message;

@end


/**
 *  Socket IO Client Delegate protocol
 */
@protocol SIOClientDelegate <NSObject>

/**
 *  Inform delegate that connection has been established
 *
 *  @param client Socket IO client object
 *  @param host   Connected host
 */
- (void) sioClient:(SIOClient *)client didConnectToHost:(NSString*)host;

/**
 *  Inform delegate that subscribption to channle is successful
 *
 *  @param client  Socket IO client object
 *  @param channel Subscribed channel
 */
- (void) sioClient:(SIOClient *)client didSubscribeToChannel:(NSString*)channel;

/**
 *  Inform delegate that message has been sent on specified channel
 *
 *  @param client  Socket IO client object
 *  @param channel Channel name
 */
- (void) sioClient:(SIOClient *)client didSendMessageToChannel:(NSString *)channel;

/**
 *  Inform delegate that message is recieved on specified channel
 *
 *  @param client  Socket IO client object
 *  @param message Recieved message
 *  @param channel Channel name
 */
- (void) sioClient:(SIOClient *)client didRecieveMessage:(NSArray*)message onChannel:(NSString *)channel;

/**
 *  Inform delegate that it is disconnected from host
 *
 *  @param client Socket IO client object
 *  @param host   Disconnected host
 */
- (void) sioClient:(SIOClient *)client didDisconnectFromHost:(NSString*)host;

/**
 *  Inform delegate that there is an error
 *
 *  @param client    Socket IO client object
 *  @param errorInfo Error info
 */
- (void) sioClient:(SIOClient *)client gotError:(NSDictionary *)errorInfo;

@end
