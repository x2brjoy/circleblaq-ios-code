//
//  CBObjects.m
//  CouchbaseDb
//
//  Created by Bhavuk Jain on 02/11/15.
//  Copyright (c) 2015 Bhavuk Jain. All rights reserved.
//

#import "CBObjects.h"

@implementation CBObjects


+(instancetype)sharedInstance {
    
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


- (id)init {
    self = [super init];
    if (self) {
        NSError *error;
        self.manager = [CBLManager sharedInstance];
        if (!self.manager) {
            NSLog(@"Cannot create shared instance of CBLManager");
            return nil;
        }
        self.database = [self.manager databaseNamed:@"couchbasenew" error:&error];
        if (!self.database) {
            NSLog(@"Cannot create database. Error message: %@", error.localizedDescription);
            return nil;
        }
    }
    return self;
}

-(void) startReplications {
    // 1
    NSURL *syncURL = [[NSURL alloc] initWithString:@"http://107.170.66.211"];
    // 2
    CBLReplication *pull = [self.database createPullReplication:syncURL];
    CBLReplication *push = [self.database createPushReplication:syncURL];
    // 3
    pull.continuous = YES;
    push.continuous = YES;
    // 4
    [pull start];
    [push start];
}



@end
