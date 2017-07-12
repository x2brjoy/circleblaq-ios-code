//
//  Helper.m
//  Picogram
//
//  Created by Rahul Sharma on 9/3/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "Helper.h"
#import "FontDetailsClass.h"
#import  <Social/Social.h>
#import <Accounts/Accounts.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareVideo.h>
#import <FBSDKShareKit/FBSDKShareOpenGraphContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareVideoContent.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKShareKit/FBSDKShareAPI.h>
#import <FBSDKShareKit/FBSDKSharePhotoContent.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface Helper ()

@end

@implementation Helper


/* -----------------------------------------------------------------------*/
#pragma mark
#pragma mark - TimeConverting  From EpochValue
/* ----------------------------------------------------------------------*/

//converting seconds into minutes or hours or  days or weeks based on number of seconds.
+(NSString *)PostedTimeSincePresentTime:(NSTimeInterval)seconds {
    if(seconds < 60)
    {
        NSInteger time = round(seconds);
        //showing timestamp in seconds.
        
        if(seconds < 1)
        {
            seconds = 2;
        }
        NSString *secondsInstringFormat = [NSString stringWithFormat:@"%ld", (long)time];
        NSString *secondsWithSuffixS;
        if (time >1) {
            secondsWithSuffixS = [secondsInstringFormat stringByAppendingString:@" SECONDS AGO"];
        }
        else {
            secondsWithSuffixS = [secondsInstringFormat stringByAppendingString:@" SECOND AGO"];
        }
        
        return secondsWithSuffixS;
    }
    
    else if (seconds >= 60 && seconds <= 60 *60) {
        //showing timestamp in minutes.
        NSInteger numberOfMinutes = seconds / 60;
        NSString *minutesInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfMinutes];
        NSString *minutesWithSuffixM;
        
        if (numberOfMinutes >1) {
            minutesWithSuffixM = [minutesInstringFormat stringByAppendingString:@" MINUTES AGO"];
        }
        else {
            minutesWithSuffixM = [minutesInstringFormat stringByAppendingString:@" MINUTE AGO"];
        }
        
        return minutesWithSuffixM;
    }
    else if (seconds >= 60 *60 && seconds <= 60*60*24) {
        //showing timestamp in hours.
        NSInteger numberOfHours = seconds /(60*60);
        
        NSString *hoursInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfHours];
        NSString *hoursWithSuffixH;
        if (numberOfHours >1) {
            hoursWithSuffixH = [hoursInstringFormat stringByAppendingString:@" HOURS AGO"];
        }
        else {
            hoursWithSuffixH = [hoursInstringFormat stringByAppendingString:@" HOUR AGO"];
        }
        
        return hoursWithSuffixH;
    }
    else if (seconds >= 24 *60 *60 && seconds <= 60*60*24*7) {
        //showing timestamp in days.
        NSInteger numberOfDays = seconds/(60*60*24);
        NSString *daysInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfDays];
        NSString *daysWithSuffix;
        if (numberOfDays >1) {
            daysWithSuffix = [daysInstringFormat stringByAppendingString:@" DAYS AGO"];
        }
        else {
            daysWithSuffix = [daysInstringFormat stringByAppendingString:@" DAY AGO"];
        }
        return daysWithSuffix;
    }
    else if (seconds >= 60*60*24*7) {
        //showing timestamp in weeks.
        NSInteger numberOfWeeks = seconds /(60*60*24*7);
        NSString *weeksInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfWeeks];
        NSString *weeksWithSuffixS;
        if (numberOfWeeks >1) {
            weeksWithSuffixS = [weeksInstringFormat stringByAppendingString:@" WEEKS AGO"];
        }
        else {
            weeksWithSuffixS = [weeksInstringFormat stringByAppendingString:@" WEEK AGO"];
        }
        return weeksWithSuffixS;
    }
    return @"";
}

+(NSString *)convertEpochToNormalTime :(NSString *)epochTime{
    //getting date(including time) from epochTime.
    
    // Convert NSString to NSTimeInterval
    NSTimeInterval seconds = [epochTime doubleValue];
    // (Step 1) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:(seconds/1000)];
    // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    //getting present time.
    
    NSDate *todayDate = [NSDate date]; // get today date
    NSDateFormatter *dateFormatte = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatte setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"]; //Here we can set the format which we need
    //getting duration between posted time to the present time.
    NSTimeInterval secondsBetween = [todayDate timeIntervalSinceDate:epochNSDate];
    NSString *timeStamp = [Helper PostedTimeSincePresentTime:secondsBetween];
    return timeStamp;
}


/* -----------------------------------------------------------------------*/
#pragma mark
#pragma mark - TimeConverting  From EpochValue
/* ----------------------------------------------------------------------*/

//converting seconds into minutes or hours or  days or weeks based on number of seconds.
+(NSString *)PostedTimeSincePresentTimeInShort:(NSTimeInterval)seconds {
    if(seconds < 60)
    {
        NSInteger time = round(seconds);
        //showing timestamp in seconds.
        
        if(seconds < 1)
        {
            seconds = 2;
        }
        NSString *secondsInstringFormat = [NSString stringWithFormat:@"%ld", (long)time];
        NSString *secondsWithSuffixS;
        
        secondsWithSuffixS = [secondsInstringFormat stringByAppendingString:@"s"];
        
        return secondsWithSuffixS;
    }
    
    else if (seconds >= 60 && seconds <= 60 *60) {
        //showing timestamp in minutes.
        NSInteger numberOfMinutes = seconds / 60;
        NSString *minutesInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfMinutes];
        NSString *minutesWithSuffixM;
        
        minutesWithSuffixM = [minutesInstringFormat stringByAppendingString:@"m"];
        
        return minutesWithSuffixM;
    }
    else if (seconds >= 60 *60 && seconds <= 60*60*24) {
        //showing timestamp in hours.
        NSInteger numberOfHours = seconds /(60*60);
        
        NSString *hoursInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfHours];
        NSString *hoursWithSuffixH;
        hoursWithSuffixH = [hoursInstringFormat stringByAppendingString:@"h"];
        
        return hoursWithSuffixH;
    }
    else if (seconds >= 24 *60 *60 && seconds <= 60*60*24*7) {
        //showing timestamp in days.
        NSInteger numberOfDays = seconds/(60*60*24);
        NSString *daysInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfDays];
        NSString *daysWithSuffix;
       daysWithSuffix = [daysInstringFormat stringByAppendingString:@"d"];
        return daysWithSuffix;
    }
    else if (seconds >= 60*60*24*7) {
        //showing timestamp in weeks.
        NSInteger numberOfWeeks = seconds /(60*60*24*7);
        NSString *weeksInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfWeeks];
        NSString *weeksWithSuffixS;
        weeksWithSuffixS = [weeksInstringFormat stringByAppendingString:@"w"];
        return weeksWithSuffixS;
    }
    return @"";
}

+(NSString *)convertEpochToNormalTimeInshort :(NSString *)epochTime{
    //getting date(including time) from epochTime.
    
    // Convert NSString to NSTimeInterval
    NSTimeInterval seconds = [epochTime doubleValue];
    // (Step 1) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:(seconds/1000)];
    // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    //getting present time.
    
    NSDate *todayDate = [NSDate date]; // get today date
    NSDateFormatter *dateFormatte = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatte setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"]; //Here we can set the format which we need
    //getting duration between posted time to the present time.
    NSTimeInterval secondsBetween = [todayDate timeIntervalSinceDate:epochNSDate];
    NSString *timeStamp = [Helper PostedTimeSincePresentTimeInShort:secondsBetween];
    return timeStamp;
}

+ (CGFloat)measureWidthLabel:(UILabel *)label
{
    CGSize constrainedSize = CGSizeMake(label.frame.size.width  , 9999);
    CGRect requiredHeight=CGRectMake(0, 0, 0, 0);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:label.font.fontName size:label.font.pointSize], NSFontAttributeName,
                                          nil];
    if (label.text) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:label.text attributes:attributesDictionary];
        
        requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        if (requiredHeight.size.width > label.frame.size.width) {
            requiredHeight = CGRectMake(0,0, label.frame.size.width, requiredHeight.size.height);
        }
    }
    
    CGRect newFrame = label.frame;
    newFrame.size.height = requiredHeight.size.height;
    return  newFrame.size.height;
}

+ (CGFloat)measureHieightLabel: (UILabel *)label
{
    CGSize constrainedSize = CGSizeMake(label.frame.size.width  , 9999);
    CGRect requiredHeight=CGRectMake(0, 0, 0, 0);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:label.font.fontName size:label.font.pointSize], NSFontAttributeName,
                                          nil];
    if (label.text) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:label.text attributes:attributesDictionary];
        
        requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        if (requiredHeight.size.width > label.frame.size.width) {
            requiredHeight = CGRectMake(0,0, label.frame.size.width, requiredHeight.size.height);
        }
    }
    
    CGRect newFrame = label.frame;
    newFrame.size.height = requiredHeight.size.height;
    return  newFrame.size.height;
}





-(void)attr {
    
    
}


#pragma marks - customizing cell activity statements

+(NSMutableAttributedString*)customisedActivityStmt:(NSString*)username :(NSString*)statment {
    
    
    
    NSString *testString= statment;
    
    NSRange range = [testString rangeOfString:username];
    
    
    
    
    NSMutableAttributedString * attributtedComment = [[NSMutableAttributedString alloc] initWithString:statment];
    
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                               range:range];
    
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:RobotoMedium size:14]
                               range:range];
    
    
    
    return attributtedComment;
}

+(NSMutableAttributedString*)customisedActivityStmt:(NSString*)username seconUserName:(NSString *)secondUserName  timeForPost:(NSString *)time : (NSString*)statment {
    
    NSRange range = [statment rangeOfString:username];
    
    NSRange seconUserNameRage = [statment rangeOfString:secondUserName];
    
    NSRange rangeForTime = [statment rangeOfString:time];
    
    
    NSMutableAttributedString * attributtedComment = [[NSMutableAttributedString alloc] initWithString:statment];
    
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                               range:range];
    
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:RobotoMedium size:14]
                               range:range];
    
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                               range:seconUserNameRage];
    
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:RobotoMedium size:14]
                               range:seconUserNameRage];
    
    
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor lightGrayColor]
                               range:rangeForTime];
    
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:RobotoRegular size:14]
                               range:rangeForTime];
    
    return attributtedComment;
}




#pragma marks - customizing lable and button
+(void)setToLabel:(UILabel*)lbl Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size Color:(UIColor*)color
{
    
    lbl.textColor = color;
    
    if (txt != nil) {
        lbl.text = txt;
    }
    
    
    if (font != nil) {
        lbl.font = [UIFont fontWithName:font size:_size];
    }
    
}

+(void)setButton:(UIButton*)btn Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size TitleColor:(UIColor*)t_color ShadowColor:(UIColor*)s_color
{
    [btn setTitle:txt forState:UIControlStateNormal];
    
    [btn setTitleColor:t_color forState:UIControlStateNormal];
    
    if (s_color != nil) {
        [btn setTitleShadowColor:s_color forState:UIControlStateNormal];
    }
    
    
    if (font != nil) {
        btn.titleLabel.font = [UIFont fontWithName:font size:_size];
    }
    else
    {
        btn.titleLabel.font = [UIFont systemFontOfSize:_size];
    }
}


+(NSString *)userName {
    
    NSDictionary *userDatawhileRegistration =[[NSUserDefaults standardUserDefaults]objectForKey:userDetailkeyWhileRegistration];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:userDetailKey];
    NSDictionary *userData = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    
    //if user first time login(registration) then userData dictonary will be empty and user login then userData will contain data.
    
    NSString *userToken;
    
    if (userData[@"token"]) {
        userToken = userData[@"username"];
    }
    else {
        userToken = userDatawhileRegistration[@"response"][@"username"];
    }
    
    return userToken;
}

+(NSString *)userToken {
    NSDictionary *userDatawhileRegistration =[[NSUserDefaults standardUserDefaults]objectForKey:userDetailkeyWhileRegistration];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:userDetailKey];
    NSDictionary *userData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //if user first time login(registration) then userData dictonary will be empty and user login then userData will contain data.
    
    NSString *userToken;
    
    if (userData[@"token"]) {
        userToken = userData[@"token"];
    }
    else {
        userToken = userDatawhileRegistration[@"response"][@"authToken"];
    }
    
    return userToken;
}

+(NSString *)deviceToken{
    NSString *deviceToken =[[NSUserDefaults standardUserDefaults]objectForKey:mdeviceToken];;
    return deviceToken;
}

+(BOOL)isPrivateAccount
{
    
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"PrivateAccountType"];
}

+(BOOL)isBusinessAccount
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"BussinessSuccessCheck"];
}


+(NSString *)bussinessAccountStatus {
    
    NSString *bussinessAccStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"BussinessAccountStatus"];
    return bussinessAccStatus;
}

+ (BOOL) validateUrl: (NSString *) weburl {
//    NSString *urlRegEx = @"((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*)+)+(/)?(\\?.*)?";
    
//    NSString *urlRegEx =
//    @"((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*‌​|([0-9]*)|([-|_])*))‌​+";
    
//    @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?"
    
    NSString *urlRegEx =    @"((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?";


    
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    
    if ([urlTest evaluateWithObject:weburl]) {
        if ([weburl containsString:@".."]) {
            return false;
        }
        else {
            return true;
        }
    }
    else {
        return false;
    }
}

+ (BOOL)validatePhone:(NSString *)enteredphoneNumber {
    NSString *phoneNumber = enteredphoneNumber;
    NSString *phoneRegex = @"[2356789][0-9]{6}([0-9]{3})?";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL matches = [test evaluateWithObject:phoneNumber];
    return matches;
}


/**
 
 *  This method is to convert media link into tinylink
 
 */


+ (NSString*)getWebLinkForFeed:(NSDictionary*)postDic

{
    
    NSString *shortUrl;
    
    NSString *apiEndpoint;
    
    NSString *originallink = postDic[@"mainUrl"];
    
    if (adminGalleryURL.length)
        
    {
        
        NSLog(@"Sharing with adminLink");
        
        NSString *link = [NSString stringWithFormat:@"%@/%@/%@",adminGalleryURL,@"userId",@"postId"];
        //NSString *link = [NSString stringWithFormat:@"%@=%@&uid=%@",adminGalleryURL,@"userId",@"postId"]
        
        apiEndpoint = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",link];
        
        shortUrl = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint]
                    
                                            encoding:NSASCIIStringEncoding
                    
                                               error:nil];
        
    }
    
    else
        
    {
        
        apiEndpoint = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",originallink];
        
        shortUrl = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint]
                    
                                            encoding:NSASCIIStringEncoding
                    
                                               error:nil];
        
    }
    
    return shortUrl;
    
}


/*-------------------------------------------------------*/
#pragma mark
#pragma mark - labelHeightDynamically.
/*------------------------------------------------------*/

+(CGFloat )heightOfText:(UILabel *)label {
    
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    CGFloat dynamicHeightOfLabel = newFrame.size.height;
    return dynamicHeightOfLabel;
}



#pragma mark - twitterSharing

+(void)twitterSharing:(NSDictionary *)postDetails
{
//    NSString *mediaLink =[Helper getWebLinkForFeed:postDetails];//[@"mainUrl"];
//    
//    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
//    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    
//    // Request access from the user to use their Twitter accounts.
//    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
//        if(granted) {
//            // Get the list of Twitter accounts.
//            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
//            
//            if ([accountsArray count] > 0) {
//                
//                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
//                SLRequest *postRequest = nil;
//                NSLog(@"Twitter Login User:%@",twitterAccount.username);
//                NSLog(@"Twitter AccountType:%@",twitterAccount.accountType);
//                
//                // Post Text
//                
//                NSString *posttext = [NSString stringWithFormat:@"Shared via @Piocgram %@",mediaLink];
//                
//                NSDictionary *message = @{@"status": posttext, @"wrap_links": @"true"};
//                
//                // URL
//                NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
//                
//                // Request
//                postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:message];
//                
//                // Set Account
//                postRequest.account = twitterAccount;
//                
//                // Post
//                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//                    NSLog(@"Twitter HTTP response: %li", (long)[urlResponse statusCode]);
//                    
//                }];
//                
//            }
//            else {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"There is no Twitter account configured" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
//                [alert show];
//                
//                
//            }
//        }
//        
//    }];
    
}

+ (void)makeFBPostWithParams:(NSDictionary*)params
{
    NSData *imageData;
    NSString *caption;
    if (params[@"link"]) {
        imageData = [[NSData alloc] initWithContentsOfURL:params[@"link"]];
        caption = params[@"title"];
    }
    else
    {
        imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:params[mmailUrl]]];
        caption = params[mpostCaption];
    }
    
    
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
           dispatch_async(dispatch_get_main_queue(), ^{
            FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
            sharePhoto.caption = caption;//params[@"title"]; //@"Test Caption";
            sharePhoto.image = image;//[UIImage imageNamed:@"BGI.jpg"];
            FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
            content.photos = @[sharePhoto];
            
            [FBSDKShareAPI shareWithContent:content delegate:nil];
        });
        
}


+(void)sharingVideo:(NSDictionary *)param
{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock = ^(NSURL *newURL, NSError *error) {
        if (error)
        {
            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
        }
        else
        {
            NSLog(@"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
            
            FBSDKShareVideo* video = [FBSDKShareVideo videoWithVideoURL:newURL];
            
            FBSDKShareVideoContent* content = [[FBSDKShareVideoContent alloc] init];
            content.video = video;
            [FBSDKShareAPI shareWithContent:content delegate:nil];
            
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
        NSString *urlToDownload = param [mmailUrl];
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
            
            
            
            
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"File Saved !");
                
                
                NSURL *videoURL = [NSURL URLWithString:filePath];
                if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL])
                {
                    [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:videoWriteCompletionBlock];
                }
                
                
            });
        }
        
    });
    
    
    
}

/*
 * FaceBook Sharing: Method
 */
+(void)checkFbLogin
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
    }
    else{
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithPublishPermissions:@[@"publish_actions"]
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           NSLog(@"Process error");
                                       } else if (result.isCancelled)
                                       {
                                           NSLog(@"Cancelled");
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookCancel" object:nil];
                                       }
                                       else
                                       {
                                           NSLog(@"Logged in");
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                           });
                                       }
                                   }];
        
    }
    
}

/*
 * Twitter Sharing: Method to check active Twitter account
 */
+(void)chkTwitterLogin
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                //SLRequest *postRequest = nil;
                NSLog(@"Twitter Login User:%@",twitterAccount.username);
                NSLog(@"Twitter AccountType:%@",twitterAccount.accountType);
               
            }
            else {
               
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterLoginFailed" object:nil];
                
            }
        }
    }];
}

/*
 *  Instagram sharing: converting media string to directory path
 */

+(NSString *)instagramSharing:(NSDictionary *)param
{
    NSString *mediaLink =[Helper getWebLinkForFeed:param];
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sharing.igo"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:savePath])
    {
        [fm removeItemAtPath:savePath error:nil];
    }
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaLink]]];
    NSData *imageD = UIImageJPEGRepresentation(image, 1);
    
    [imageD writeToFile:savePath atomically:YES];
    return savePath;
}


+(void)videoOnInstagram:(NSDictionary *)param
{
    NSString *mediaLink =[Helper getWebLinkForFeed:param];
    NSURL *videoFilePath = [NSURL URLWithString:mediaLink]; // Your local path to the video
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:videoFilePath completionBlock:^(NSURL* assetURL, NSError* error) {
        NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?AssetPath=%@",[assetURL absoluteString]]];
        [[UIApplication sharedApplication] openURL:instagramURL];
        
    }];
}

+(void)showAlertWithTitle:(NSString*)title Message:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}


+(BOOL)emailValidationCheck:(NSString *)emailToValidate
{
    NSString *regexForEmailAddress = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailValidation = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexForEmailAddress];
    return [emailValidation evaluateWithObject:emailToValidate];
}

+(NSString *)makeWebPostLink:(NSString *)postId andUserName:(NSString *)userName {
    
    NSString *baseUrl = @"http://159.203.143.251/picogramwebsite/home/homepost/";
    NSString *postUrl = [[baseUrl stringByAppendingString:userName] stringByAppendingString:[@"/" stringByAppendingString:postId ]];
    
    return postUrl;
}

+ (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

+(void)deviceDetails
{
    NSString *platform = [UIDevice currentDevice].model;
    
    NSLog(@"[UIDevice currentDevice].model: %@",platform);
    NSLog(@"[UIDevice currentDevice].description: %@",[UIDevice currentDevice].description);
    NSLog(@"[UIDevice currentDevice].localizedModel: %@",[UIDevice currentDevice].localizedModel);
    NSLog(@"[UIDevice currentDevice].name: %@",[UIDevice currentDevice].name);
    NSLog(@"[UIDevice currentDevice].systemVersion: %@",[UIDevice currentDevice].systemVersion);
    NSLog(@"[UIDevice currentDevice].systemName: %@",[UIDevice currentDevice].systemName);
    //NSLog(@"current Host:%@",[[NSHost currentHost] address]);
}
@end
