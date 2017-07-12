//
//  Friends+CoreDataProperties.h
//  
//
//  Created by Rahul Sharma on 17/02/17.
//
//  This file was automatically generated and should not be edited.
//

#import "Friends+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Friends (CoreDataProperties)

+ (NSFetchRequest<Friends *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *memberFullName;
@property (nullable, nonatomic, copy) NSString *memberid;
@property (nullable, nonatomic, copy) NSString *memberImage;
@property (nullable, nonatomic, copy) NSString *memberName;

@end

NS_ASSUME_NONNULL_END
