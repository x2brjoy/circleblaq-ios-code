
//
//  CallhistoryTableViewController.m
//  Sup
//
//  Created by Rahul Sharma on 4/28/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "CallhistoryTableViewController.h"
#import "WebServiceHandler.h"
#import "WebServiceConstants.h"
#import "ProgressIndicator.h"
#import "CallHistoryTableViewCell.h"
//#import "Favorites.h"
#import "Database.h"
//#import "ContactDetailsTableViewController.h"
#import "UIHelper.h"
#import "FavDataBase.h"
#import "ContacDataBase.h"
#import "Helper.h"

@interface CallhistoryTableViewController ()<WebServiceHandlerDelegate>
{
    
    
    NSMutableArray *callDetailArr;
    NSMutableArray *storeData;
    NSMutableArray *storeMissedCallArr;
    BOOL isAllcall;
    NSDictionary *passData;
    NSMutableDictionary *dictWithData;
    
}

@property (strong,nonatomic) FavDataBase *favDataBase;
@property (strong,nonatomic) ContacDataBase *contacDataBase;

@end

@implementation CallhistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _favDataBase = [FavDataBase sharedInstance];
    _contacDataBase = [ContacDataBase sharedInstance];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
    self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)viewDidAppear:(BOOL)animated{
    
    isAllcall = YES;
    _segment.selectedSegmentIndex = 0;
    NSArray *tempArr = [[NSUserDefaults standardUserDefaults]objectForKey:@"storeCallDetailsArr"];
    callDetailArr = [[NSMutableArray alloc]initWithArray:tempArr];
    
    if (callDetailArr.count ==0) {
        [[ProgressIndicator sharedInstance] showPIOnView:self.view withMessage:@"Loding..."];
    }
    [self getCallHistory];
    [_tableViewCall reloadData];
    
}

-(void)getCallHistory{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isNetworkAvailable"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Network is not available" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
   

 
    
    NSDictionary *params = @{@"from":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]],
                             @"token":[Helper userToken]
                             };
    [WebServiceHandler getCallHistory:params andDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma webService delegtes
- (void)didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error{
    
    
     NSDictionary *responseDictionary = (NSDictionary*)response;
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
    
   if (error) {

        if ([responseDictionary[@"message"] length])
        {
            [UIHelper showMessage:responseDictionary[@"message"] withTitle:@"Error"];
        }
        else {
            [UIHelper showMessage:error.localizedDescription withTitle:@"Error"];
        }
        return;
    }
    

    if (requestType == RequestTypegetgetCallHistory) {
        
         if ([responseDictionary[@"err"] intValue] == 0) {
             
             callDetailArr = [[NSMutableArray alloc]initWithArray:responseDictionary[@"callDetail"]];
             storeData = [NSMutableArray new];
             storeMissedCallArr = [NSMutableArray new];
             
             [[NSUserDefaults standardUserDefaults]setObject:callDetailArr forKey:@"storeCallDetailsArr"];
             
             for (NSDictionary *dict in callDetailArr) {
                 NSString *callIcon = [NSString stringWithFormat:@"%@",dict[@"isMissed"]];
                 if ([callIcon isEqualToString:@"0"]) {
                     [storeMissedCallArr addObject:dict];
                 }
             }
             [_tableViewCall reloadData];
         }
        else
        {
           // [UIHelper showMessage:responseDictionary[@"message"] withTitle:@"Erorr"];
        }
        
    }
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count = 0;
    if (isAllcall == YES) {
        count = callDetailArr.count;
    }else
        count = storeMissedCallArr.count;
        
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CallHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"callHistoryCell" forIndexPath:indexPath];
    
    cell.detailsIcon.tag = 300+indexPath.row;
    NSDictionary *dict;
    
    if (isAllcall == YES) {
       dict  = callDetailArr[indexPath.row];
    }else{
        dict = storeMissedCallArr[indexPath.row];
    }
    
    if ([dict[@"callType"] isEqualToString:@"0"]) {
        cell.typeCallLbl.text = @"Audio call";
    }else
    cell.typeCallLbl.text = @"Video call";
    
    cell.mainNamelbl.text = dict[@"to"];
    
    NSString *callIcon = [NSString stringWithFormat:@"%@",dict[@"isMissed"]];
    if ([callIcon isEqualToString:@"0"]) {
        cell.image.image = [UIImage imageNamed:@"outgoing_icon"];
    }
    else if ([callIcon isEqualToString:@"1"])
    cell.image.image = [UIImage imageNamed:@"receive_icon"];
    else if ([callIcon isEqualToString:@"2"])
    cell.image.image = [UIImage imageNamed:@"incoming_icon"];
    NSString *calId = [NSString stringWithFormat:@"%@",dict[@"from"]];
    NSString *comp = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];
    if([calId isEqualToString:comp])
    {
    cell.mainNamelbl.text =[self getUserNamefromDB:[NSString stringWithFormat:@"%@",dict[@"toName"]]];
    }else
    {
       cell.mainNamelbl.text =[self getUserNamefromDB:[NSString stringWithFormat:@"%@",dict[@"fromName"]]];
    }
    cell.timelbl.text = [self getLastSeenFormate:[NSString stringWithFormat:@"%@",dict[@"timestamp"]]];
//    if ([cell.mainNamelbl.text isEqualToString:@"You"]) {
//        cell.detailsIcon.enabled = NO;
//    }
    
    return cell;
}
- (IBAction)detailsCliked:(id)sender {
    
    NSInteger index = [sender tag] -300;
    
    NSDictionary *dict ;
    if (isAllcall == YES){
       dict = callDetailArr[index];
    }
    else {
        dict  = storeMissedCallArr[index];
    }
    
    
    NSString *usserNO = [NSString stringWithFormat:@"%@",dict[@"to"]];
    
    //check if user is in Db ot not
    NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",usserNO];
    NSArray *favAll = [_favDataBase getDataFavDataFromDB];
    NSArray *arr = [favAll filteredArrayUsingPredicate:predi];
    //NSArray *arr  =[Database favoriteObjectWithMatchingPhoneNumber:predi];
    NSDictionary *fav;
    if (arr.count>0) {
        fav = [arr firstObject];
        passData = fav;
          
    }else
        [self getallDatafromhacks:usserNO];
    
    [self performSegueWithIdentifier:@"callHistToInfo" sender:self];
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
//    if ([[segue identifier ] isEqualToString:@"callHistToInfo"]) {
//       
//        ContactDetailsTableViewController *contac = [segue destinationViewController];
//        if (passData){
//           contac.favoriteObj = passData;
//            passData = nil;
//        }
//        else  contac.dataDictionary = dictWithData;
//       
//        contac.iscomingFrom = ComingFormFavlistView;
//    }
}

-(void)getallDatafromhacks:(NSString*)receiverName{
    
    NSString *Status = [self gotStatusFormDB:receiverName];
    if ([Status isEqualToString:@""]) {
        Status =@"SGV5IHRoZXJlICEgSSBhbSB1c2luZyBTdXA=";
    }
    
    NSString *userName = [self getUserNamefromDB:receiverName];
    dictWithData =[NSMutableDictionary new];
    [dictWithData setValue:userName forKey:@"fullName"];
    [dictWithData setValue:@"" forKey:@"profilePic"];
    [dictWithData setValue:Status forKey:@"status"];
    [dictWithData setValue:receiverName forKey:@"supNumber"];
    
}

-(NSString *)gotStatusFormDB:(NSString *)receiverSupNo{
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"supNumber == %@",receiverSupNo];
    NSArray *favAll = [_favDataBase getDataFavDataFromDB];
    NSArray *array  =[favAll filteredArrayUsingPredicate:pre];
    
    NSDictionary *fav;
    if (array.count>0) {
        fav = [array objectAtIndex:0];
        return [NSString stringWithFormat:@"%@",fav[@"status"]];
    }
    return @"";
}

-(NSString *)getUserNamefromDB:(NSString *)fromNumber{
    
    NSString *nameofUser;
//    if ([fromNumber isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]]) {
//        return nameofUser= @"You";
//    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"supNumber == %@",fromNumber];
    NSArray *favAll = [_favDataBase getDataFavDataFromDB];
    NSArray *array = [favAll filteredArrayUsingPredicate:predicate];


    NSDictionary *fav;
    if (array.count>0) {
        fav = [array firstObject];
    }
    
    nameofUser = fav[@"fullName"];

    if(nameofUser.length==0)
    {
        nameofUser = fav[@"supNumber"];
    }

    if (nameofUser.length==0)
        nameofUser = fromNumber;
    
    return nameofUser;
}


- (IBAction)segmentCliked:(UISegmentedControl *)sender {
    
    NSInteger selectSeg = sender.selectedSegmentIndex;
    
    if (selectSeg ==0) {
        isAllcall = YES;
        [self getCallHistory];
        [_tableViewCall reloadData];
    }else{
        isAllcall = NO;
        [self getCallHistory];
        if (storeMissedCallArr.count ==0) {
            UIAlertView *alert  = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"You don't have any missed calls" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            //[alert show];
        }
    }
    [_tableViewCall reloadData];
}

-(NSString *)getLastSeenFormate:(NSString *)lastSeenTime{
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
        
        NSTimeZone *gmt = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:gmt];
        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    
        NSArray *arr = [lastSeenTime componentsSeparatedByString:@"-"];
        NSString *time = [arr lastObject];
        NSString * newString = [time substringWithRange:NSMakeRange(3,[time length]-3)];
        NSString *timeStr = [newString substringToIndex:5];
        
        NSString *netDateStr = [NSString stringWithFormat:@"%@/%@/%@ %@",[[arr lastObject] substringToIndex:2],[arr objectAtIndex:1],[arr firstObject],timeStr];
    
        NSString *netDateSt = [NSString stringWithFormat:@"%@-%@-%@",[arr firstObject],[arr objectAtIndex:1],[[arr lastObject] substringToIndex:2]];
    
        NSString *gmtDateString = netDateStr;
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"dd/MM/yyyy HH:mm"];
    
        //Create the date assuming the given string is in GMT
        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        NSDate *date = [df dateFromString:gmtDateString];
        
        //Create a date string in the local timezone
        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
        NSString *localDateString = [df stringFromDate:date];
    
    
    NSDate *todayDate = [NSDate date];
    NSString *todayStr = [NSString stringWithFormat:@"%@",todayDate];
    todayStr = [todayStr substringToIndex:11];
    todayStr = [todayStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    netDateSt = [netDateSt stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([todayStr isEqualToString:netDateSt]){
    
    NSString *cutMsg = localDateString;
    cutMsg=  [cutMsg substringWithRange:NSMakeRange(11,localDateString.length-11)];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    dateformater.dateFormat=@"HH:mm";
    NSDate *date12 = [dateformater dateFromString:cutMsg];
    dateformater.dateFormat = @"hh:mm a";
    cutMsg = [dateformater stringFromDate:date12];
    localDateString = cutMsg;
    return [NSString stringWithFormat:@"%@",localDateString];
    }
    else{
        NSString *temp = localDateString ;
        temp = [temp substringToIndex:11];
        return [NSString stringWithFormat:@"%@",temp];
    }
    
}

@end
