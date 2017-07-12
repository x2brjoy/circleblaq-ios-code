//
//  Helper.h
//  Picogram
//
//  Created by Rahul Sharma on 9/3/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceConstants.h"

@interface Helper : NSObject
+(NSString *)PostedTimeSincePresentTime:(NSTimeInterval)seconds;
+(NSString *)convertEpochToNormalTime :(NSString *)epochTime;
+(NSMutableAttributedString*)customisedActivityStmt:(NSString*)username :(NSString*)statment;
+(NSMutableAttributedString*)customisedActivityStmt:(NSString*)username seconUserName:(NSString *)secondUserName  timeForPost:(NSString *)time : (NSString*)statment;

+ (NSString *)getIPAddressl;
+ (CGFloat)measureHieightLabel: (UILabel *)label;
+(NSString *)userName;
+(NSString *)userToken;
+ (NSString*)getWebLinkForFeed:(NSDictionary*)postDic;
+(CGFloat )heightOfText:(UILabel *)label;
+(NSString *)deviceToken;
+(void)twitterSharing:(NSDictionary *)postDetails;
+ (void)makeFBPostWithParams:(NSDictionary*)params;
+(void)sharingVideo:(NSDictionary *)param;
+(void)videoOnInstagram:(NSDictionary *)param;
+(void)chkTwitterLogin;
+(void)checkFbLogin;
+(BOOL)isPrivateAccount;
//+(BOOL)isBusinessAccount;
+(NSString *)bussinessAccountStatus;
+(void)deviceDetails;
+(NSString *)instagramSharing:(NSDictionary *)param;
+(void)showAlertWithTitle:(NSString*)title Message:(NSString*)message;
+(void)setToLabel:(UILabel*)lbl Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size Color:(UIColor*)color;
+(void)setButton:(UIButton*)btn Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size TitleColor:(UIColor*)t_color ShadowColor:(UIColor*)s_color;
+ (BOOL) validateUrl: (NSString *) weburl;
+ (BOOL)validatePhone:(NSString *)enteredphoneNumber;
+(NSString *)convertEpochToNormalTimeInshort :(NSString *)epochTime;
+ (CGFloat)measureWidthLabel:(UILabel *)label;
+(BOOL)emailValidationCheck:(NSString *)emailToValidate;
+(NSString *)makeWebPostLink:(NSString *)postId andUserName:(NSString *)userName;

#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
#define ACCEPTABLE_CHARACTERSFORPRICE @"0123456789$₹."

#define mInstaTableVcStoryBoardId       @"instaTableViewController"
#define mDiscoverPeopleVcSI             @"discoverPeopleStoryBoardId"
#define numberOfFbFriendFoundInPicogram @"numberOfYourFbFriendFoundInPicogram"
#define numberOfContactsFoundInPicogram @"numberOfContactsFoundInPicogram"


#define defaultProfileImageName  @"defaultpp"


#define followButtonBackGroundColor [UIColor whiteColor]

#define followingButtonBackGroundColor [UIColor colorWithRed:0.4 green:0.7412 blue:0.1804 alpha:1.0]

#define requstedButtonBackGroundColor [UIColor colorWithRed:0.7804 green:0.7804 blue:0.7804 alpha:1.0];

#define backGroundColor [UIColor whiteColor];

#define followButtonTextColor [UIColor colorWithRed:0.2196 green:0.5882 blue:0.9412 alpha:1.0]

#define followingButtonTextColor [UIColor whiteColor]

#define requestedButtonTextColor [UIColor whiteColor]


@end
