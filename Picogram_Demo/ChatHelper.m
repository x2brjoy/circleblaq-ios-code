//
//  ChatHelper.m
//  Picogram
//
//  Created by Rahul Sharma on 16/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ChatHelper.h"
#import "AppDelegate.h"

@implementation ChatHelper


static ChatHelper *helper;
@synthesize r_id;
@synthesize r_Name;
@synthesize ROViewLoadFrom;
@synthesize dish_Price;
@synthesize mealId;
@synthesize r_Tax;



+ (id)sharedInstance {
    if (!helper) {
        helper  = [[self alloc] init];
    }
    
    return helper;
}


+(void)setToLabel:(UILabel*)lbl Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size Color:(UIColor*)color
{
    lbl.backgroundColor = [UIColor clearColor];
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

+(void)showAlertWithTitle:(NSString*)title Message:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


+ (NSString *)removeWhiteSpaceFromURL:(NSString *)url {
    NSMutableString *string = [[NSMutableString alloc] initWithString:url];
    [string replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])];
    //	[string replaceOccurrencesOfString:@"www.museumhunters.com" withString:@"207.150.204.61" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])];
    //	//NSLog(@"returnted : %@",string);
    return string;
}
+ (NSString *)stripExtraSpacesFromString:(NSString *)string {
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [string componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    
    return [filteredArray componentsJoinedByString:@" "];
}
+(NSString*)getCurrent_Date
{
    // Get current date time
    
    NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // Get the date time in NSString
    
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    
    return dateInStringFormated;
    
}

+(NSString*)getCurrentDate
{
    // Get current date time
    
    NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    // Get the date time in NSString
    
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    
    return dateInStringFormated;
    
}

+(NSString*)getCurrentDateWithTime
{
    // Get current date time
    
    NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // Get the date time in NSString
    
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    
    return dateInStringFormated;
    ////NSLog(@"%@", dateInStringFormated);
    
    // Release the dateFormatter
    
    //[dateFormatter release];
}


+(NSString*)getCurrentDateWithYearMonthFormat
{
    // Get current date time
    
    NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // Get the date time in NSString
    
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    
    return dateInStringFormated;
    ////NSLog(@"%@", dateInStringFormated);
    
    // Release the dateFormatter
    
    //[dateFormatter release];
}


+(NSString*)getCurrentTime
{
    NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    
    [dateFormatter setDateFormat:@"HH:mm"];
    
    // Get the date time in NSString
    
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    
    return dateInStringFormated;
    
}
+(NSString*)getImageName:(NSString*) _name For:(int)_devicetype
{
    NSString *imageName;
    if (_devicetype == 4) {
        imageName = [NSString stringWithFormat:@"%@.png",_name];
        
    }
    else if(_devicetype == 5)
    {
        imageName = [NSString stringWithFormat:@"%@_568.png",_name];
    }
    return imageName;
}
+ (UIColor *)getColorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (BOOL)isiPhone5 {
    if ([[UIScreen mainScreen] bounds].size.height > 480) {
        return YES;
    }
    else {
        return NO;
    }
}
+ (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
        
        
        
    });
    return formatter;
}
+(void)deleteDatabase:(NSString *)tableName
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:tableName inManagedObjectContext:context];
    
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    
    NSError *fetchError;
    NSError *error;
    NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
    for (NSManagedObject *product in fetchedProducts) {
        [context deleteObject:product];
    }
    [context save:&error];
}


+ (BOOL)deleteClub:(NSString*)clubID userID: (NSString*)userID
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"ClubDetails" inManagedObjectContext:context];
    
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:entity];
    //    NSPredicate *pred = [NSPredicate predicateWithFormat:@"club_id = '%@' && userID = '%@'", clubID,userID];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"club_id == %@", clubID];
    [fetch setPredicate:pred];
    //... add sorts if you want them
    NSError *fetchError;
    NSError *error;
    NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
    for (NSManagedObject *product in fetchedProducts) {
        [context deleteObject:product];
    }
    
    if ([context save:&error]) {
        return YES;
    }
    else {
        return NO;
    }
    return NO;
}

+ (NSString*)encodeStringTo64:(NSString*)fromString
{
    NSData *plainData = [fromString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
    } else {
        base64String = [plainData base64Encoding];                              // pre iOS7
    }
    
    return base64String;
}

+(NSString *)getCurrentDateTime:(NSDate *)dateString dateFormat:(NSString *)dFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:dFormat];
    
    NSString *dateInStringFormated = [dateFormatter stringFromDate:dateString];
    
    // NSLog(@"date in string %@ ",dateInStringFormated);
    
    
    return dateInStringFormated;
    
}
+(NSString *)decodedStringFrom64:(NSString*)fromString{
    
    NSString *decodedStr;
    if (fromString) {
        NSData *nsdataFromBase64String = [[NSData alloc]
                                          initWithBase64EncodedString:fromString options:0];
        decodedStr  = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    }
    return decodedStr;
}

+(BOOL)checkImageNullorNot:(UIImage *)image{
    
    BOOL isthere = NO;
    
    
    CGImageRef cgRef = [image CGImage];
    CIImage *cImg = [image CIImage];
    
    if (cImg == nil && cgRef == NULL) {
        isthere = YES;
    }
    
    return isthere;
}

+ (NSString *) nonNullStringForString:(NSString *) string
{
    return (string == nil) ? @""  : string;
}

+(NSString*)getDocumentIDWithSenderID:(NSString *)senderID onDatabase:(CBLDatabase *)db {
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name MATCHES %@",senderID];
    CBLView *productView = [db viewNamed:@"products"];
    //    dispat    ch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    //Background Thread
    
    [productView setMapBlock:^(NSDictionary *doc, CBLMapEmitBlock emit) {
        emit(@"name", doc[@"receivingUser"]);
    }  version:@"3"];
    
    //    });
    
    CBLQuery *query = [[db viewNamed:@"products"] createQuery];
    // we don't need the reduce here
    [query setMapOnly:YES];
    
    //    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    //    });
    CBLQueryEnumerator *result = [query run:nil];
    CBLQueryRow *filteredRow;
    
    for (CBLQueryRow *row in result) {
        if ([[row value] isEqualToString:senderID]) {
            filteredRow = row;
            break;
        }
        NSString *productName = [row value];
        // NSLog(@"Product name %@", productName);
    }
    
    return filteredRow.documentID;
}


+(NSString*)getDocumentIDWithGroupID:(NSString*)groupID onDatabase:(CBLDatabase*)db{
    
    
    NSString *docID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupid == %@",[NSString stringWithFormat:@"%@",groupID]];
    NSArray *arr = [Database storeIdobjectWithMatchingStoreID:predicate];
    if (arr.count>0) {
        StoreIDs *store = [arr firstObject];
        docID = store.documentid;
    }
    
    
    return docID;
    
}



+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}






@end
