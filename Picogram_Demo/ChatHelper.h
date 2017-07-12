//
//  ChatHelper.h
//  Picogram
//
//  Created by Rahul Sharma on 16/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

#define StorDocIDArray @"Store database array"
#define defaultLastSeenMsg @"Hey there ! I am using Sup"
#define defaultGroupMsg @""
#define newchatCreated @"newChatcreated"


#define MessagesuccesfullyDeliver @"2"
#define MessagesuccesfullyRead @"3"

/*for go to userdetails*/
#define ComingFromChatView @"ComingFromChatView"
#define ComingFromContacView @"ComingFromContacView"
#define ComingFormFavlistView @"ComingFromFavlistView"


#define newChatBtnCliked @"newChatBtnCliked"

#import "Database.h"
#import "StoreIDs+CoreDataClass.h"
#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface ChatHelper : NSObject




@property(nonatomic,strong)NSString *r_id;
@property(nonatomic,strong)NSString *r_Name;
@property(nonatomic,assign)int ROViewLoadFrom;
@property(nonatomic,strong)NSString *dish_Price;
@property(nonatomic,strong)NSString *r_Tax;
@property(nonatomic,strong)NSString *mealId;




+ (id)sharedInstance;

+(void)setToLabel:(UILabel*)lbl Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size Color:(UIColor*)color;
+(void)setButton:(UIButton*)btn Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size TitleColor:(UIColor*)t_color ShadowColor:(UIColor*)s_color;
+(void)showAlertWithTitle:(NSString*)title Message:(NSString*)message;
//+(void)showErrorFor:(int)errorCode;
+ (NSString *)removeWhiteSpaceFromURL:(NSString *)url;
+ (NSString *)stripExtraSpacesFromString:(NSString *)string;
+ (NSString*)getCurrentDate;
+(NSString*)getCurrent_Date;
+(NSString*)getCurrentTime;
+(NSString*)getImageName:(NSString*) _name For:(int)_devicetype;
+ (UIColor *)getColorFromHexString:(NSString *)hexString;
+(NSString*)getCurrentDateWithYearMonthFormat;
+(NSString*)getCurrentDateWithTime;
+ (BOOL)isiPhone5;
+ (NSDateFormatter *)formatter;
+(void)deleteDatabase:(NSString *)tableName;
+ (BOOL)deleteClub:(NSString*)clubID userID: (NSString*)userID;

+(NSString *)getCurrentDateTime:(NSDate *)dateString dateFormat:(NSString *)dFormat;
+(NSString *)decodedStringFrom64:(NSString*)fromString;
+ (NSString*)encodeStringTo64:(NSString*)fromString;
+(BOOL)checkImageNullorNot:(UIImage*)image;
+ (NSString *) nonNullStringForString:(NSString *) string;
+(NSString*)getDocumentIDWithSenderID:(NSString *)senderID onDatabase:(CBLDatabase *)db;
+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;


+(NSString*)getDocumentIDWithGroupID:(NSString*)groupID onDatabase:(CBLDatabase*)db;





@end
