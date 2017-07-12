//
//  StoreIDs+CoreDataProperties.m
//  
//
//  Created by Rahul Sharma on 17/02/17.
//
//  This file was automatically generated and should not be edited.
//

#import "StoreIDs+CoreDataProperties.h"

@implementation StoreIDs (CoreDataProperties)

+ (NSFetchRequest<StoreIDs *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"StoreIDs"];
}

@dynamic documentid;
@dynamic groupid;

@end
