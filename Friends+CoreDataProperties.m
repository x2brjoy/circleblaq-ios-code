//
//  Friends+CoreDataProperties.m
//  
//
//  Created by Rahul Sharma on 17/02/17.
//
//  This file was automatically generated and should not be edited.
//

#import "Friends+CoreDataProperties.h"

@implementation Friends (CoreDataProperties)

+ (NSFetchRequest<Friends *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
}

@dynamic memberFullName;
@dynamic memberid;
@dynamic memberImage;
@dynamic memberName;

@end
