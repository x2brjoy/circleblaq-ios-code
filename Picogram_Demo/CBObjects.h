//
//  CBObjects.h
//  CouchbaseDb
//
//  Created by Bhavuk Jain on 02/11/15.
//  Copyright (c) 2015 Bhavuk Jain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface CBObjects : NSObject

+(CBObjects *)sharedInstance;

@property (strong, nonatomic) CBLDatabase *database;
@property (strong, nonatomic) CBLManager *manager;

-(void) startReplications;

@end
