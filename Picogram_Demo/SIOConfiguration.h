//
//  SIOConfiguration.h
//  SIOClient
//
//  Created by Vinay Raja on 14/09/15.
//  Copyright (c) 2015 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class to setup the configuration for the Socket connection
 */
@interface SIOConfiguration : NSObject

/**
 *  Host URL
 */
@property (nonatomic, readonly) NSString *hostURL;

/**
 *  Host port number
 */
@property (nonatomic, readonly) NSString *portNumber;

/**
 *  Gets the default configuration
 *
 *  @return SIOConfiguration object
 */
+ (instancetype) defaultConfiguration;

/**
 *  Initializer for SIOConfiguration object
 *
 *  @param hostURL    Host URL
 *  @param portNumber Host port number
 *
 *  @return SIOConfiguration object
 */
- (instancetype) initWithHostURL:(NSString*)hostURL portNumber:(NSString*)portNumber;

@end

/**
 *  AccessHelper category for SIOConfiguration
 */
@interface SIOConfiguration (AccessHelper)

/**
 *  Get host string for host url and port number
 *
 *  @return NSString host string
 */
- (NSString*) getHostString;

@end
