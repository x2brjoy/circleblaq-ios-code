//
//  Database.h
//  privMD
//
//  Created by Rahul Sharma on 20/03/14.
//  Copyright (c) 2014 Rahul Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//#import "Contacts.h"
//#import "Favorites.h"


@interface Database : NSObject

#pragma mark - To fetch data from data base

+ (NSArray *)dataFromTable:(NSString *)table condition:(NSString *)condition orderBy:(NSString *)column ascending:(BOOL)asc ;
+ (NSManagedObjectContext *)context;
+(NSArray *)favoriteObjectWithMatchingPhoneNumber:(NSPredicate *)phoneumber;
+(NSArray *)contactObjectWithMatchingPhoneNumebr:(NSPredicate *)phoneumber;
+(NSArray *)chatMessageObjectWithMatchingMessageID:(NSPredicate *)messageID;
+(NSArray *)contacobjectWithMatchingContacID:(NSPredicate*)contactID;
+(NSArray *)storeIdobjectWithMatchingStoreID:(NSPredicate*)storeID;

#pragma mark - Adding in Data base

-(BOOL)makeDataBaseEntryForContacts:(NSDictionary *)dictionary;
-(BOOL)makeDataBaseEntryForFavorites:(NSDictionary *)dictionary;
-(BOOL)makeDataBaseEntryforChatMessages:(NSDictionary *)dictionary;
-(BOOL)makeDataBaseEntryforStoreID:(NSDictionary *)dictionary;

#pragma mark - Delete Data Base

+ (BOOL)deleteRowFromDataBaseWithTableName:(NSString*)tableName andKeys: (NSString *)keys;
+ (void)deleteAllRowsFromDataBaseTableWithTableName: (NSString *)tableName;

//+(void)updateContacDatabase:(NSDictionary *)dictionary contac:(Contacts*)entity;
//+(void)updateFavDatabase:(NSDictionary *)dictionary fav:(Favorites*)entity;

@end
