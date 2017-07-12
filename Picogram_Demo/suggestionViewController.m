//  FavoritiesTableViewController.m
//  Sup
//
//  Created by Rahul Sharma on 16/03/15.
//  Copyright (c) 2015 3embed. All rights reserved.
//

#import "suggestionViewController.h"
#import "suggesstionListTableViewCell.h"

#import <MessageUI/MessageUI.h>
#import "SearchCollectionViewCell.h"

#import "Database.h"
#import "UIImageView+AFNetworking.h"
#import "UsersVC.h"
#import "Helper.h"
//#import "Contacts.h"
#import "ChatViewController.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import "PicogramSocketIOWrapper.h"
#import "MessageStorage.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FavDataBase.h"
#import "ContacDataBase.h"
#import "PGTabBar.h"
#import "PageContentViewController.h"


#import "WebServiceHandler.h"
#import "ProgressIndicator.h"
#import "AppDelegate.h"
#import "SuggestionCollectionViewCell.h"
#import "ChatNavigationContollerClass.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import "CouchbaseEvents.h"
#import "MSReceive.h"
#import "ContacDataBase.h"
#import "MacroFile.h"


@interface suggestionViewController ()<SocketWrapperDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,WebServiceHandlerDelegate,UISearchBarDelegate,UITextFieldDelegate,UISearchControllerDelegate,suggestListTBDelegate,WebServiceHandlerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSString *groupID;
    BOOL isSearchBeginEditing;
    //    NSMutableArray *userArray;
    NSMutableArray *selectedUsers;
    int selected;
    SearchCollectionViewCell *searchCell;
    NSMutableArray *searchobjectArray;
    BOOL isFiltered ;
    NSString *GroupName;
    
}
@property (strong, nonatomic) NSDictionary *userDictionary;
@property (strong, nonatomic) NSMutableArray *favoriteList;
@property (strong, nonatomic) NSMutableArray *nameListArray;
@property (strong, nonatomic) NSArray * searchResults;
@property (strong,nonatomic) NSDictionary *docDict;
@property (strong,nonatomic) UIRefreshControl *refresher;
@property PicogramSocketIOWrapper *socketIoClient;
//@property AddressBookWrapperClasses *addressBookObj;
@property (nonatomic,assign) BOOL iscancelBtn;
@property (nonatomic,strong) NSArray *arrayOfImages;
@property (nonatomic) NSInteger cellCount ;
@property (strong,nonatomic) FavDataBase *favDataBase;
//@property (strong,nonatomic) ContacDataBase *contacDataBase;
@property (strong, nonatomic) NSMutableArray *contactTypeArr;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) NSMutableArray *totalRows;
@property (strong, nonatomic) CBLQueryEnumerator *result;
@property ( nonatomic) int chatAvaliable;


@end

@implementation suggestionViewController
{
    NSArray *listFollers;
    NSDictionary *userInfo;
    int fav;
}

@synthesize userDictionary;
@synthesize favoriteList;


- (void)viewDidLoad {
    
       self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    _chatAvaliable = 0;
    [super viewDidLoad];
    fav = 0;
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [self getChatDoc];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"CheckContacFirstTime"];
    
    [super viewDidLoad];
    self.title = @"New message";
    isFiltered = NO;
    _selectedArray = [[NSMutableArray alloc]init];
    selectedUsers = [NSMutableArray new];
    
    //    userArray = [@[@"a1", @"a2",@"a3",@"a4",@"a5",@"a6"] mutableCopy];
    selectedUsers = [[NSMutableArray alloc]init];
    
    [self.searchTxtfld becomeFirstResponder];
    
    [self createNavLeftButton];
    
    
    
    
    
    _favDataBase = [FavDataBase sharedInstance];
    //    _contacDataBase = [ContacDataBase sharedInstance];
    
    self.socketIoClient = [PicogramSocketIOWrapper sharedInstance];
    // _socketIoClient.chatDelegate =self;
    
    NSNumber *checkBool = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstResponseCameFromGetContact"];
    if (checkBool.boolValue == NO)
        [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Finding Agents"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseFromChannelsContacts:) name:@"gotoFavorite" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseFromUpdateDetails:) name:@"gotResponseFromUpdatedDetails" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavlistView:) name:@"updateFavlistView" object:nil];
    
    
    self.refresher = [[UIRefreshControl alloc]init];
    [self.refresher addTarget:self action:@selector(doRefresh) forControlEvents:UIControlEventValueChanged];
    [_tableViewOutlet addSubview:self.refresher];
    
    //    [self favoritesSetUp];
    
    [self sendHeartBeat];
    //    [self getdataFromDb];
    
    
    /*update userInfo firstTime*/
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestTOgetUpdateUserDetails];
    });
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(creatnewGroup:) name:@"CreatNewGroup" object:nil];
    
    
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
    self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    
}

-(void)getChatDoc
{
    _totalRows = [NSMutableArray new];
    
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
        CBLQuery *query = [bgDB createAllDocumentsQuery];
        
        query.allDocsMode = kCBLAllDocs;
        query.descending = YES;
        //query.indexUpdateMode = kCBLUpdateIndexBefore;
        // query.descending = NO;
        // [query startKey];
        NSString *contaDocID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:contacDBDocumentID]];
        NSString *favDocID =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:favDBdocumentID]];
        _result = [query run:&error];
        
        
        for (NSInteger count = 0; count < _result.count; count++) {
            if ([[_result rowAtIndex:count].documentID isEqualToString:contaDocID]) {
            }else if ([[_result rowAtIndex:count].documentID isEqualToString:favDocID]){
            }else{
                [_totalRows addObject:[_result rowAtIndex:count]];
                
            }
            
        }
    });
    
}

-(void)didGroupExist
{
    
    for(int i=0;i<[_totalRows count];i++)
    {
        NSMutableArray *groupMembers = [NSMutableArray new];
        int check = 0;
        CBLQueryRow *row;
        row= [_totalRows objectAtIndex:i];
        CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        NSArray *objs = [getDocument.properties objectForKey:@"groupMembers"];
        NSLog(@"%@",objs);
        groupMembers = [objs mutableCopy];
        if ([groupMembers count] < 2) {
            continue;
        }
        NSInteger index = [groupMembers indexOfObject:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
        NSString *name = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
        NSLog(@"%@",name);
        if(index < [groupMembers count] && index >= 0)
        [groupMembers removeObjectAtIndex:index];
        NSInteger countG = [groupMembers count];
        if(countG == [selectedUsers count])
        {
            
            for(int j=0;j<[groupMembers count]; j++)
            {
                for(int k=0;k<[groupMembers count]; k++)
                {
                    NSString *name = [NSString stringWithFormat:@"%@",groupMembers[k]];
                    userInfo = selectedUsers[j];
                    if(![name isEqualToString:[NSString stringWithFormat:@"%@",userInfo[@"memberId"]]])
                    {
                        //                    check=0;
                        //                    break;
                    }else
                    {
                        check=check + 1;
                    }
                }
            }
            if(check == [groupMembers count])
            {
                _chatAvaliable = 1;
                break;
            }
        }
    }
    
    
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(void)CheckDataBase:(NSDictionary *)data value:(int)i
{
    int add = 0;
    
    NSManagedObject *friend;
    
    NSLog(@"%@",data[@"memberId"]);
    for(int j=0 ;j<i;j++)
    {
        
        friend = [self.friendesList objectAtIndex:j];
        NSLog(@"%@",[friend valueForKey:@"memberid"]);
        
        
        if([ [NSString stringWithFormat:@"%@",data[@"memberId"]] isEqualToString:[friend valueForKey:@"memberid"]])
        {
            NSLog(@"%@",[friend valueForKey:@"memberFullName"]);
            if(![ [NSString stringWithFormat:@"%@",data[@"memberFullName"]] isEqualToString:[friend valueForKey:@"memberFullName"]])
            {
                if(data[@"memberFullName"] && ![data[@"memberFullName"] isEqual:[NSNull null]])
                {
                    [friend setValue:[NSString stringWithFormat:@"%@",data[@"memberFullName"]] forKey:@"memberFullName"];
                }
            }
            NSLog(@"%@",[friend valueForKey:@"memberImage"]);
            if(![ [NSString stringWithFormat:@"%@",data[@"memberProfilePicUrl"]] isEqualToString:[friend valueForKey:@"memberImage"]])
            {
                if(data[@"memberProfilePicUrl"] && ![data[@"memberProfilePicUrl"] isEqual:[NSNull null]])
                {
                    [friend setValue:[NSString stringWithFormat:@"%@",data[@"memberProfilePicUrl"]] forKey:@"memberImage"];
                }
            }
            NSLog(@"%@",[friend valueForKey:@"memberName"]);
            if(![ [NSString stringWithFormat:@"%@",data[@"membername"]] isEqualToString:[friend valueForKey:@"memberName"]])
            {
                [friend setValue:[NSString stringWithFormat:@"%@",data[@"membername"]] forKey:@"memberName"];
            }
            NSLog(@"%@",[friend valueForKey:@"memberFullName"]);
            if(![ [NSString stringWithFormat:@"%@",data[@"memberFullName"]] isEqualToString:[friend valueForKey:@"memberFullName"]])
            {
                [friend setValue:[NSString stringWithFormat:@"%@",data[@"memberFullName"]] forKey:@"memberFullName"];
            }
            add = 0 ;
            NSLog(@"Found %@  ==  %@",[friend valueForKey:@"memberid"],data[@"memberId"]);
            break;
        }
        else{
            add = 1;
            
        }
        
        
    }
    
    
    
    if(add == 1)
    {
        NSLog(@"%@",data);
        [self newdata:data];
    }
    
}



-(void)newdata :(NSDictionary *)saveData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
    if(saveData[@"memberFullName"] && ![saveData[@"memberFullName"] isEqual:[NSNull null]])
    {
        [newEntry setValue:[NSString stringWithFormat:@"%@",saveData[@"memberFullName"]] forKey:@"memberFullName"];
    }
    
    if(saveData[@"memberProfilePicUrl"] && ![saveData[@"memberProfilePicUrl"] isEqual:[NSNull null]])
    {
        [newEntry setValue:[NSString stringWithFormat:@"%@",saveData[@"memberProfilePicUrl"]] forKey:@"memberImage"];
    }
    
    
    [newEntry setValue:[NSString stringWithFormat:@"%@",saveData[@"memberId"]] forKey:@"memberid"];
    [newEntry setValue:[NSString stringWithFormat:@"%@",saveData[@"membername"]] forKey:@"memberName"];
    
    NSLog(@"%@     %@",saveData[@"memberId"],saveData[@"membername"]);
    
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

-(void)saveDataToCoreData:(NSArray *)data
{
    for (int i=0; i<[data count]; i++) {
        
        NSDictionary *saveData = [data objectAtIndex:i];
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSString *valueToSave = [NSString stringWithFormat:@"%@",saveData[@"userId"]];
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *valueToName = [NSString stringWithFormat:@"%@",saveData[@"username"]];
        [[NSUserDefaults standardUserDefaults] setObject:valueToName forKey:@"Name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        NSString *valueToImage = [NSString stringWithFormat:@"%@",saveData[@"userprofilePicUrl"]];
        [[NSUserDefaults standardUserDefaults] setObject:valueToImage forKey:@"userprofilePicUrl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if([_friendesList count] >0)
        {
            [self CheckDataBase:saveData value:[_friendesList count]];
        }
        else
        {
            
            // Create a new managed object
            NSManagedObject *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
            if(saveData[@"memberFullName"] && ![saveData[@"memberFullName"] isEqual:[NSNull null]])
            {
                [newEntry setValue:[NSString stringWithFormat:@"%@",saveData[@"memberFullName"]] forKey:@"memberFullName"];
            }
            
            if(saveData[@"memberProfilePicUrl"] && ![saveData[@"memberProfilePicUrl"] isEqual:[NSNull null]])
            {
                [newEntry setValue:[NSString stringWithFormat:@"%@",saveData[@"memberProfilePicUrl"]] forKey:@"memberImage"];
            }
            
            
            [newEntry setValue:[NSString stringWithFormat:@"%@",saveData[@"memberId"]] forKey:@"memberid"];
            [newEntry setValue:[NSString stringWithFormat:@"%@",saveData[@"membername"]] forKey:@"memberName"];
            
            NSLog(@"%@     %@",saveData[@"memberId"],saveData[@"membername"]);
            
            
            NSError *error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
    //    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CreatNewGroup" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ReloadList" object:nil];
    //    ChatNavigationContollerClass *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
    //
    //    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    //    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    //        if (finished) {
    //
    //        }
    //    }];
    self.tabBarController.tabBar.hidden = NO;
}


-(void) createNavLeftButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"comments_back_icon_off"];
    
    //create the button and assign the image
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    
    //set the frame of the button to the size of the image (see note below)
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    
    [button addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //create a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
}
-(void)leftBarButtonClicked:(id)sender{
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
-(void)getdataFromDb
{
    
    NSArray *FavoritesArray =  [_favDataBase getDataFavDataFromDB];
    favoriteList = [NSMutableArray arrayWithArray:FavoritesArray ];
    if([favoriteList count] != 0)
    {
        [self setDataForTable:FavoritesArray];
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        [_tableViewOutlet reloadData];
    }
}


-(void)doRefresh{
    //    [_tableViewOutlet reloadData];
    
    if (self.refresher) {
        fav = 0;
        [self favoritesSetUp];
        
        //    [self.addressBookObj sendLeftnumberToServer];
        //    self.addressBookObj = [AddressBookWrapperClasses sharedInstance:YES];
        //    self.addressBookObj.updateDelegate = self;
        [self.refresher endRefreshing];
    }
}

-(void)requestTOgetUpdateUserDetails{
    
    //  NSMutableArray *listofUser = [[NSMutableArray alloc] initWithArray:[Database dataFromTable:@"Favorites" condition:nil orderBy:nil ascending:YES]];
    NSArray *listofUser =[[NSArray alloc]initWithArray:[_favDataBase getDataFavDataFromDB]];
    NSMutableArray *listOfNum = [[NSMutableArray alloc] init];
    for (NSDictionary *fav in listofUser) {
        [listOfNum addObject:fav[@"supNumber"]];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,2* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self.socketIoClient sendUserNumforaAnyUpdate:listOfNum];
    });
    
    
}

-(void)sendHeartBeat {
    AppDelegate *delegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate sendHeartBeatStatus:@"1"];
}


- (IBAction)createChatButton:(id)sender {
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Creating..."];
    [self didGroupExist];
    if(_chatAvaliable == 1)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            
            [[ProgressIndicator sharedInstance]hideProgressIndicator];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    else
    {
        UIButton *yy = (UIButton*)sender;
        yy.enabled = NO;
        NSString *imagesUrl;
        NSDictionary *details = [selectedUsers firstObject];
//        if([selectedUsers count] != 1)
//        {
            GroupName =[NSString stringWithFormat:@"%@", details[@"username"]];
            
//        }
        if(![details[@"memberProfilePicUrl"] isEqualToString:@"<null>"] && [selectedUsers count]==1)
        {
            imagesUrl = [NSString stringWithFormat:@"%@", details[@"userprofilePicUrl"]];
        }
        NSLog(@"Create chat Button");
        
        NSMutableArray *sendNum = [NSMutableArray new];
        for (int i =0; i<selectedUsers.count; i++) {
            userInfo = selectedUsers[i];
            [sendNum addObject:[NSString stringWithFormat:@"%@",userInfo[@"memberId"]]];
            if(GroupName.length)
            {
                GroupName = [NSString stringWithFormat:@"%@,%@",GroupName ,userInfo[@"membername"] ];
                
                
                if(![userInfo[@"memberProfilePicUrl"] isEqualToString:@"<null>"])
                {
                    if(imagesUrl.length ==0)
                    {
                        imagesUrl = [NSString stringWithFormat:@"%@", userInfo[@"memberProfilePicUrl"]];
                    }
                    else{
                        imagesUrl = [NSString stringWithFormat:@"%@,%@",imagesUrl, userInfo[@"memberProfilePicUrl"]];
                    }
                }
                
            }
            else{
                GroupName = [NSString stringWithFormat:@"%@" ,userInfo[@"membername"] ];
                imagesUrl = [NSString stringWithFormat:@"%@", userInfo[@"memberProfilePicUrl"]];
                
            }
        }
        
        NSString *userNo = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        [sendNum addObject:userNo];
        groupID  = [self randomStringWithLength:20];
        PicogramSocketIOWrapper *sock = [PicogramSocketIOWrapper sharedInstance];
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            if(imagesUrl.length != 0)
            {
                [sock creatNewGroup:GroupName groupMembers:[sendNum copy] groupId:groupID groupPic:imagesUrl type:@"1"];
            }
            else
            {
                [sock creatNewGroup:GroupName groupMembers:[sendNum copy] groupId:groupID groupPic:@"" type:@"1"];
            }
        }];
        
        
        
        
    }
}

-(void)favoritesSetUp
{
    if(fav == 0)
    {
        NSString *token =[Helper userToken];
        
        [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Finding Friends"];
        
        NSDictionary *request = @{@"token":token};
        
        [WebServiceHandler getChatList:request andDelegate:self];
        fav =1;
    }
    
    
}

-(void)setDataForTable:(NSArray *)myArray
{
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"membername"
                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    listFollers = [myArray sortedArrayUsingDescriptors:sortDescriptors];
    favoriteList = [NSMutableArray arrayWithArray:listFollers];
    [self saveFavIndatabase:favoriteList];
    [_tableViewOutlet reloadData];
}


#pragma mark - WebServiceDelegate

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
    
    if(error) {
        return;
    }
    
    if(requestType == RequestTypegetUserFollowRelation)
    {
        NSDictionary *responseDict = (NSDictionary *)response;
        if ([responseDict[@"errNum"] intValue] == 0) {
            NSLog(@"%@",responseDict);
            NSMutableArray *myArray = [[NSMutableArray alloc]init];
            myArray = [[myArray arrayByAddingObjectsFromArray:responseDict[@"data"] ] mutableCopy];
            [self setDataForTable:myArray];
            [self saveDataToCoreData:myArray];
            [self deletmissingdataCore:myArray];
        }
        else
        {
        }
    }
    
}


-(void)deletmissingdataCore:(NSArray*)data
{
    NSManagedObject *friend;
    for(int k=0 ;k<[_friendesList count];k++)
    {
        int delete = 0;
        friend = [self.friendesList objectAtIndex:k];
        NSLog(@"%@",[friend valueForKey:@"memberid"]);
        
        for(int m=0;m<[data count];m++)
        {
            NSDictionary *userCompare = [data objectAtIndex:m];
            
            if([[NSString stringWithFormat:@"%@",[friend valueForKey:@"memberid"]] isEqualToString:[NSString stringWithFormat:@"%@",userCompare[@"memberId"]]])
            {
                delete = 1;
                break;
            }
            
        }
        
        if(delete == 0)
        {
            NSLog(@"///////////////////////Remove Object %@  ",[friend valueForKey:@"memberid"]);
            [[self managedObjectContext] deleteObject:friend];
        }
        
        
    }
}

-(void)saveFavIndatabase:(NSArray*)arr{
    
    
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in arr) {
        
        
        NSString *userName = [NSString stringWithFormat:@"%@",dict[@"Name"]];
        NSDictionary *dbDict= [self databaseDictionary:dict andUsername:userName];
        [temp addObject:dbDict];
        
        
    }
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [_favDataBase saveDataInDocument:@"" withMessages:temp];
        NSArray *FavoritesArray =  [_favDataBase getDataFavDataFromDB];
        //[self favoritesSetUp];
        favoriteList = [NSMutableArray arrayWithArray:FavoritesArray ];
        NSLog(@"%@",FavoritesArray);
        
    }];
    
    
    favoriteList = temp;
    
    
}






#pragma  mark  - supSocketIOClientDelegate

-(void)responseFromChannelsContacts:(NSNotification*)userNotification
{
    
    
    
    
    
}

-(NSDictionary*)databaseDictionary :(NSDictionary *)responseDictionary andUsername: (NSString *)userName
{
    NSMutableDictionary *dbDict = [[NSMutableDictionary alloc] init];
    //
    //    NSString *tt= [userName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //
    //    NSData *nsdataFromBase64String = [[NSData alloc]
    //                                      initWithBase64EncodedString:tt options:0];
    //    NSString *decodedString1  = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    
    
    
    
    //    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:userName options:0];
    //    NSString *decodedString1 = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    //    NSData *decodedData1 = [[NSData alloc] initWithBase64EncodedString:[NSString stringWithFormat:@"%@",userName] options:0];
    //    NSString *decodedString1 = [[NSString alloc] initWithData:decodedData1 encoding:NSUTF8StringEncoding];
    if(responseDictionary[@"memberFullName"] && ![responseDictionary[@"memberFullName"] isEqual:[NSNull null]])
    {
        [dbDict setValue:responseDictionary[@"memberFullName"] forKey:@"memberFullName"];
    }
    else{
        [dbDict setValue:responseDictionary[@"membername"] forKey:@"memberFullName"];
    }
    if(responseDictionary[@"memberProfilePicUrl"] ==(id) [NSNull null] || responseDictionary[@"memberProfilePicUrl"]==nil)
    {
        [dbDict setValue:@"" forKey:@"image"];
    }
    else{
        [dbDict setValue:responseDictionary[@"memberProfilePicUrl"] forKey:@"image"];
    }
    if([responseDictionary[@"image"] isEqualToString:@""])
    {
        [dbDict setValue:@"***no status***" forKey:@"status"];
    }
    else{
        [dbDict setValue:responseDictionary[@"Status"] forKey:@"status"];
    }
    [dbDict setValue:responseDictionary[@"memberId"] forKey:@"supNumber"];
    
    [dbDict setValue:responseDictionary[@"OnlineStatus"] forKey:@"OnlineStatus"];
    
    [dbDict setValue:responseDictionary[@"membername"] forKey:@"fullName"];
    
    return dbDict;
    
    
}




#pragma  mark - updateConact Delegate

-(void)updateContact:(NSMutableArray *)contactString
{
    NSLog(@"send contac to server =%@",contactString);
    [self.socketIoClient syncContacts:contactString];
}

-(void)reloadFavtableView{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self favoritesSetUp ];
    }];
    
    //[_tableViewOutlet reloadData];
}
-(void)viewDidAppear:(BOOL)animated{
    
    //        self.addressBookObj = [AddressBookWrapperClasses sharedInstance:YES];
    //        self.addressBookObj.updateDelegate = self;
    
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
    fav = 0;
    [self favoritesSetUp] ;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    //    NSNumber *value = [[NSUserDefaults standardUserDefaults]objectForKey:@"isComingFromChat"];
    //    _isComingFromChatList = [value boolValue];
    //    if (_isComingFromChatList ) {
    //
    //        _navLeftBtn.title =@"Cancel";
    //        _iscancelBtn = YES;
    //        [self.navigationItem setTitle:@"New Chat"];
    //        _navRightAddBtn.tintColor = [UIColor colorWithRed:(48.0/255.0) green:(201.0/255.0) blue:(232.0/255.0) alpha:0];
    //        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isComingFromChat"];
    //        [_navLeftBtn setEnabled:YES];
    //        [_navRightAddBtn setEnabled:NO];
    //
    //    }
    //
    //    else{
    //        _iscancelBtn = NO;
    //        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isComingFromChat"];
    //        _navLeftBtn.tintColor = [UIColor colorWithRed:(48.0/255.0) green:(201.0/255.0) blue:(232.0/255.0) alpha:0];
    //        [_navLeftBtn setEnabled:NO];
    //        [_navRightAddBtn setEnabled:YES];
    //    }
    //
    //
    //
    //    [self.tabBarController.tabBar setHidden:NO];
    self.socketIoClient = [PicogramSocketIOWrapper sharedInstance];
    
    
    //    [self favoritesSetUp];
    
    
    // [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (IBAction)newMessageButton:(id)sender {
//
//    [self performSegueWithIdentifier:@"SuggestionToChatView" sender:self];
//
//}




#pragma mark - Table view data source








- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(isFiltered == YES)
    {
        return [searchobjectArray count];
    }
    else
    {
        //        if (self.indexFirstLetterFav.count == 0) {
        //            return 0;
        //        }
        //        else
        return [listFollers count];
        //return [self.favoriteList count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    suggesstionListTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"suggestionListCell"
                                           forIndexPath:indexPath];
    
    if(selectedUsers.count == 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    
    if (isFiltered == YES)
    {
        userInfo = [searchobjectArray objectAtIndex:indexPath.row];
        
        cell.friendsImage.layer.cornerRadius = 8;
        
        NSString *imageURL = userInfo[@"memberProfilePicUrl"];
        if(imageURL==nil || imageURL==(id)[NSNull null] || [imageURL isEqualToString:@"(null)"])
        {
            cell.friendsImage.image = [UIImage imageNamed:@"DefaultContactImage"];
        }
        else{
            
            //            NSURL * imageURL = [NSURL URLWithString:userInfo[@"profilePicUrl"]];
            //            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            //            UIImage * image = [UIImage imageWithData:imageData];
            //            cell.friendsImage.image = image;
            NSURL *imageUrl =[NSURL URLWithString:userInfo[@"memberProfilePicUrl"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
            UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
            [cell.friendsImage setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  cell.friendsImage.image = image;
                                                  cell.friendsImage.layer.cornerRadius = cell.friendsImage.frame.size.width / 2;;
                                                  cell.friendsImage.clipsToBounds = YES;
                                                  [cell setNeedsLayout];
                                              } failure:nil];
            
        }
        
        
        cell.userNameLbl.text = userInfo[@"membername"];
        
        if(userInfo[@"memberFullName"] && ![userInfo[@"memberFullName"] isEqual:[NSNull null]])
        {
            cell.fullNameLbl.text = userInfo[@"memberFullName"];
        }
        else{
            cell.fullNameLbl.text = @"";
        }
        
        
        int s=0;
        for(int i=0; i<[selectedUsers count];i++)
        {
            NSDictionary *obj = [selectedUsers objectAtIndex:i];
            if([obj isEqual:userInfo])
            {
                
                s=1;
                
            }
            
        }
        if (s ==0)  {
            cell.selectBtn.image = [UIImage imageNamed:@"Chat_Unselected"];
            cell.userNameLbl.textColor = [UIColor blackColor];
            cell.fullNameLbl.textColor = [UIColor grayColor];
            
        }else{
            
            cell.selectBtn.image = [UIImage imageNamed:@"Chat_Selected"];
            cell.userNameLbl.textColor = [UIColor greenColor];
            cell.fullNameLbl.textColor = [UIColor greenColor];
        }
        
        
    }
    else{
        
        userInfo = [listFollers objectAtIndex:indexPath.row];
        
        cell.friendsImage.layer.cornerRadius = 8;
        
        NSString *imageURL = userInfo[@"memberProfilePicUrl"];
        if(imageURL==nil || imageURL==(id)[NSNull null] || [imageURL isEqualToString:@"(null)"])
        {
            cell.friendsImage.image = [UIImage imageNamed:@"DefaultContactImage"];
        }
        else{
            //
            //                NSURL * imageURL = [NSURL URLWithString:userInfo[@"profilePicUrl"]];
            //                NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            //                UIImage * image = [UIImage imageWithData:imageData];
            //                cell.friendsImage.image = image;
            
            NSURL *imageUrl =[NSURL URLWithString:userInfo[@"memberProfilePicUrl"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
            UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
            [cell.friendsImage setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  cell.friendsImage.image = image;
                                                  cell.friendsImage.layer.cornerRadius = cell.friendsImage.frame.size.width / 2;
                                                  cell.friendsImage.clipsToBounds = YES;
                                                  [cell setNeedsLayout];
                                              } failure:nil];
            
        }
        
//        NSString *valueToSave = [NSString stringWithFormat:@"%@",userInfo[@"userId"]];
//        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"userId"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        cell.userNameLbl.text = userInfo[@"membername"];
        
        if(userInfo[@"memberFullName"] && ![userInfo[@"memberFullName"] isEqual:[NSNull null]])
        {
            cell.fullNameLbl.text = userInfo[@"memberFullName"];
        }
        else{
            cell.fullNameLbl.text = @"";
        }
        
        
        int s=0;
        
        for(int i=0; i<[selectedUsers count];i++)
        {
            NSDictionary *obj = [selectedUsers objectAtIndex:i];
            if([obj isEqual:userInfo])
            {
                
                s=1;
                
            }
            
        }
        
        if (s ==0)  {
            cell.selectBtn.image = [UIImage imageNamed:@"Chat_Unselected"];
            cell.userNameLbl.textColor = [UIColor blackColor];
            cell.fullNameLbl.textColor = [UIColor grayColor];
            
        }else{
            
            cell.selectBtn.image = [UIImage imageNamed:@"Chat_Selected"];
            cell.userNameLbl.textColor = [UIColor colorWithRed:64.0f/255.0f green:154.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
            cell.fullNameLbl.textColor = [UIColor colorWithRed:64.0f/255.0f green:154.0f/255.0f blue:250.0f/255.0f alpha:0.5f];
        }
    }
    return cell;
}



// Override to support conditional editing of the table view.


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    if (selected ==0)  {
    //        selected = 1;
    //    }else{
    //        selected =0;
    //    }
    
    searchCell.searchTextField.placeholder =@"Search Text...";
    
  
    
    int s=0;
    if (isFiltered == YES)
    {
        for(int i=0; i<[selectedUsers count];i++)
        {
            NSDictionary *obj = [selectedUsers objectAtIndex:i];
            userInfo = listFollers[indexPath.row];
            if([obj isEqual:userInfo])
            {
                s=1;
                [_selectedArray removeObjectAtIndex: i];
                userInfo = searchobjectArray[indexPath.row];
                
                [selectedUsers removeObjectAtIndex:i];
            }
        }
        if(s==0)
        {
            [_selectedArray addObject:indexPath];
            userInfo = searchobjectArray[indexPath.row];
            [selectedUsers addObject:userInfo];
        }
        
        [_tableViewOutlet reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    else
    {
        for(int i=0; i<[selectedUsers count];i++)
        {
            NSDictionary *obj = [selectedUsers objectAtIndex:i];
            userInfo = listFollers[indexPath.row];
            if([obj isEqual:userInfo])
            {
                s=1;
                [_selectedArray removeObjectAtIndex: i];
                userInfo = listFollers[indexPath.row];
                
                [selectedUsers removeObjectAtIndex:i];
            }
        }
        if(s==0)
        {
            [_selectedArray addObject:indexPath];
            userInfo = listFollers[indexPath.row];
            [selectedUsers addObject:userInfo];
        }
        
        [_tableViewOutlet reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.collectionViewOutlet reloadData] ;
}


- (NSArray *)shortArrayFav:(int)index{
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"username"
                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSArray *sortedArray = [listFollers sortedArrayUsingDescriptors:sortDescriptors];
    
    
    return sortedArray;
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //    [textField becomeFirstResponder];
    
    return  YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    [textField addTarget:self action:@selector(textChangedLabel:) forControlEvents:UIControlEventEditingChanged];
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return newLength <= 25;
}

-(void)textChangedLabel:(UITextField *)textField
{
    NSString *nameString = textField.text;
    searchobjectArray = [NSMutableArray array];
    for(NSDictionary *wine in listFollers)
    {
        
        NSString *memberName = [wine objectForKey:@"membername"];
        NSString *memberFullName = @"";
        
        NSString *fullName = [wine objectForKey:@"memberFullName"];
        if(fullName==nil || fullName==(id)[NSNull null] || [fullName isEqualToString:@"<null>"])
        {
            memberFullName = [wine objectForKey:@"memberFullName"];
        }
        
        if ([memberName rangeOfString:nameString options:NSCaseInsensitiveSearch].location != NSNotFound  || [memberFullName rangeOfString:nameString options:NSCaseInsensitiveSearch].location != NSNotFound   ) {
            
            [searchobjectArray addObject:wine];
            
        }
        
    }
    
    
    
    if([nameString length] == 0)
    {
        isFiltered = NO;
    }
    else{
        isFiltered = YES;
    }
    
    [_tableViewOutlet reloadData];
    
    
}


#pragma mark - Collection View delegate methods



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == [selectedUsers count])
    {
        CGSize calCulateSizze =[@"Search Text...." sizeWithAttributes:NULL];
        NSLog(@"%f     %f",calCulateSizze.height, calCulateSizze.width);
        calCulateSizze.width = calCulateSizze.width+20;
        calCulateSizze.height = calCulateSizze.height + 10;
        return calCulateSizze;
        
    }
    NSDictionary *dict = [selectedUsers objectAtIndex:indexPath.row];
    CGSize calCulateSizze =[(NSString*)[dict objectForKey:@"membername"] sizeWithAttributes:NULL];
    NSLog(@"%f     %f",calCulateSizze.height, calCulateSizze.width);
    calCulateSizze.width = calCulateSizze.width+20;
    calCulateSizze.height = calCulateSizze.height + 10;
    return calCulateSizze;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [selectedUsers count]+1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"customCell";
    
    SuggestionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if(indexPath.row == [selectedUsers count])
    {
        static NSString *identifier = @"searchCell";
        
        searchCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        return searchCell;
    }
    NSArray *sampleArra1 =selectedUsers;
    userInfo = sampleArra1[indexPath.row];
    cell.nameLabel.text = userInfo[@"membername"];
    
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    [_selectedArray removeObjectAtIndex: indexPath.row];
    
    
    [selectedUsers removeObjectAtIndex:indexPath.row];
    
    [_collectionViewOutlet reloadData];
    [_tableViewOutlet reloadData];
    
    
}








#pragma  mark - other class methods

//for adding data to existing view



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"SuggestionToChatView"])
    {
        NSString *GroupName;
        NSMutableArray *sendNum = [NSMutableArray new];
        for (int i =0; i<selectedUsers.count; i++) {
            userInfo = selectedUsers[i];
            [sendNum addObject:userInfo[@"memberId"]];
            
        }
        ChatViewController *chatView = segue.destinationViewController;
        
        chatView.groupId = groupID;
        
        chatView.receiverName =[NSString stringWithFormat:@"%@",groupID];
        chatView.isFirsttime = YES;
        
    }
}


//it will send data to other controller through segue
-(void)checkInChatHistry:(NSInteger )selectedRow ViewController:(ChatViewController*)chatView{
    
    [self.tabBarController.tabBar setHidden:YES];
    BOOL isFirsttime = YES;
    NSMutableArray *documentIDArr = [NSMutableArray new];
    documentIDArr = [[[NSUserDefaults standardUserDefaults] objectForKey:StorDocIDArray]mutableCopy];
    
    
    
    if (isFiltered == YES) {
        userDictionary = [favoriteList objectAtIndex:(unsigned)selectedRow];
    }else{
        userDictionary = [favoriteList objectAtIndex:(unsigned)selectedRow];
    }
    
    
    // userDictionary = [favoriteList objectAtIndex:(unsigned)selectedRow];
    
    
    // NSString *receiverName = [NSString stringWithFormat:@"%@@gmail.com",userDictionary.supNumber];
    NSString *receiverName = [NSString stringWithFormat:@"%@",userDictionary[@"supNumber"]];
    
    
    chatView.isComingfromFav = YES;
    chatView.receiverName = receiverName;
    
    for (int i=0;i<documentIDArr.count; i++) {
        
        CBLDocument *document = [CBObjects.sharedInstance.database documentWithID:documentIDArr[i]];
        NSLog(@"%@",[document.properties objectForKey:@"memberId"]);
        if ([receiverName isEqualToString:[document.properties objectForKey:@"memberId"]]) {
            
            chatView.currentDocument = document;
            chatView.docDict = document.properties;
            chatView.isFirsttime = NO;
            isFirsttime = NO;
        }
    }
    
    
    if (isFirsttime) {
        chatView.isFirsttime = YES;
        
    }
    
    
}

- (IBAction)navLeftBtnCliked:(id)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"CheckContacFirstTime"];
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

//first time call
-(void)responseFromUpdateDetails:(NSNotification*)userINfo{
    
    NSDictionary *dict = userINfo.userInfo;
    
    NSLog(@"dict =%@",dict);
    // NSLog(@"gotUser =%@",dict[@"message"][0][0][@"msidn"]);
    NSArray  *gotUserListArrtemp = [[NSArray alloc] initWithArray:dict[@"message"]];
    NSArray *tempBuffer = [[NSArray alloc] initWithArray:gotUserListArrtemp[0]];
    
    
    
    for ( NSDictionary *dict in tempBuffer) {
        NSString *msisdn = dict[@"msidn"];
        
        NSArray *contacAlldata = [[NSArray alloc]initWithArray:[_favDataBase getDataFavDataFromDB]];
        NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"supNumber == %@",msisdn];
        NSArray *array = [contacAlldata filteredArrayUsingPredicate:bPredicate];
        
        NSMutableDictionary *favDict  =[[NSMutableDictionary alloc]init];
        if(array.count>0){
            
            NSDictionary *fav = [array firstObject];
            [favDict setValue:dict[@"Status"] forKey:@"status"];
            [favDict setValue:dict[@"ProfilePic"] forKey:@"image"];
            [favDict setValue:fav[@"supNumber"] forKey:@"supNumber"];
            [favDict setValue:fav[@"fullName"] forKey:@"fullName"];
            
            [_favDataBase updateContacDatabase:favDict contacID:[NSString stringWithFormat:@"%@",favDict[@"supNumber"]]];
            
        }
        
    }
    
    
    
    self.favoriteList = [[NSMutableArray alloc] initWithArray:[_favDataBase getDataFavDataFromDB]];
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [_tableViewOutlet reloadData];
    }];
    
    
    
}


/* when user update his photo or status notify here */

-(void)updateFavlistView:(NSNotification*)userInfo{
}

-(NSMutableArray*)gotMediaFromDB:(NSInteger)selectedRow{
    
    NSMutableArray *_mediaList = [NSMutableArray new];
    NSMutableArray *documentIDArr = [NSMutableArray new];
    documentIDArr = [[[NSUserDefaults standardUserDefaults] objectForKey:StorDocIDArray]mutableCopy];
    
    userDictionary = [favoriteList objectAtIndex:(unsigned)selectedRow];
    NSString *receiverName = [NSString stringWithFormat:@"%@",userDictionary[@"supNumber"]];
    
    for (int i=0;i<documentIDArr.count; i++) {
        
        CBLDocument *document = [CBObjects.sharedInstance.database documentWithID:documentIDArr[i]];
        if ([receiverName isEqualToString:[document.properties objectForKey:@"receivingUser"]]) {
            
            MessageStorage *messageStorage = [MessageStorage sharedInstance];
            _docDict = [messageStorage getDetailsForDocument:document];
            
            NSArray *allMessages =  _docDict[@"messages"];
            _mediaList = [messageStorage createMediaListfromMessages:allMessages];
            return _mediaList;
        }
    }
    return nil;
}





//===============================================================================================================================================================


/**
 @method mailButton
 @discription mail button pressed
 @param sender
 @result IBAction
 */
-(IBAction)mailButton:(id)sender
{
    
    // Email Subject
    NSString *emailTitle = @"About new app Sup";
    // Email Content
    NSString *messageBody = @"Check out Sup for your smartphone.Download it today from https://itunes.apple.com/us/app/sup-instant-messaging-free/id896434121?mt=8";
    
    //
    
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@""];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}
/**
 *  used for handling the compose mail
 *
 *  @param controller open a new controller as a pop up
 *  @param result     return a result as an output
 *  @param error      if it failed then popp up a error output
 */
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled://for cancelling the mail
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved://saving the mail
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent://mail sent
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/**
 @method messageButton
 @discription send message button
 @param sender
 @result IBAction
 */
-(IBAction)messageButton:(id)sender
{
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    // message Content
    NSString *messageBody = @"Check out \"Sup\" Messenger for your smartphone.Download it today from https://itunes.apple.com/us/app/sup-instant-messaging-free/id896434121?mt=8";
    
    // To address
    NSArray *toRecipents = @[@""];
    
    MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
    message.messageComposeDelegate = self;
    //[message setRecipients:toRecipents];
    [message setBody:messageBody];
    // Present message view controller on screen
    [self presentViewController:message animated:YES completion:NULL];
    
}

/**
 @method messageComposeViewController
 @discription used for handling the message bady
 @param controller
 @param result
 @result void
 */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled://Cancelled by user
            break;
            
        case MessageComposeResultFailed://message failed
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            // NSLog(@"Message sent");//mesaege sent
            break;
            
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Action Sheet Delegates method

- (void)actionSheet:(UIActionSheet *)popupSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popupSheet.tag) {
        case 0: {
            switch (buttonIndex) {
                case 0:
                    [self mailButton:nil];
                    break;
                case 1:
                    [self messageButton:nil];
                    break;
                    
                case 2:
                    [self.tableViewOutlet reloadData];
                    break;
                    
                case 3:
                    
                    break;
                    
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


-(NSString *)randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString1 = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString1 appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString1;
}


//Creat New Group
-(void)creatnewGroup:(NSNotification*)notification{
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}




//===============================================================================================================================================================

@end

