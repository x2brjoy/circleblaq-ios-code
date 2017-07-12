//
//  ConversationListViewController1.m
//  Sup
//
//  Created by Rahul Sharma on 10/22/15.
//  Copyright © 2015 3embed. All rights reserved.
//


#import "ConversationListViewController1.h"
#import "UsersVC.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import "CouchbaseEvents.h"
#import "MSReceive.h"
#import "ChatViewController.h"
#import "Database.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "ConversationTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import "FavDataBase.h"
#import "ContacDataBase.h"
#import "MacroFile.h"
#import "suggestionViewController.h"
#import "SuggestionNavigationController.h"
#import "PGTabBar.h"
#import "PageContentViewController.h"

#import "PicogramSocketIOWrapper.h"

static NSString *const ATLConversationCellReuseIdentifier = @"ATLConversationCellReuseIdentifier";
static NSString *const ATLImageMIMETypePlaceholderText = @"Attachment: Image";
static NSString *const ATLLocationMIMETypePlaceholderText = @"Attachment: Location";
static NSString *const ATLGIFMIMETypePlaceholderText = @"Attachment: GIF";


@interface ConversationListViewController1 () <UITableViewDataSource,UITableViewDelegate,CouchBaseEventsDelegate,CBLDocumentModel,UISearchBarDelegate>


@property (strong, nonatomic) NSSet *allParticipants;
@property(assign, nonatomic) NSInteger docCount;
@property (strong, nonatomic) CBLQueryEnumerator *result;
@property (strong, nonatomic) NSMutableArray *totalRows;
@property (strong ,nonatomic)NSMutableArray *totalDocumentID;
@property(strong ,nonatomic) NSMutableArray *searchtotalRows;
@property (assign,nonatomic) BOOL iscomeFromSearch;

@property (strong,nonatomic) FavDataBase *favDataBase;

@end

@implementation ConversationListViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    
    
    self.title = @"Chat";
    self.tableVIewOutlet.delegate = self;
    self.tableVIewOutlet.dataSource =self;
    _serachBar.delegate =self;
    
    self.tableVIewOutlet.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableVIewOutlet.separatorColor = [UIColor clearColor];
    
    _favDataBase = [FavDataBase sharedInstance];
    
//    [self createNavRightButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView:) name:@"updateChatListView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatlistView:) name:@"updateChatlistView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadListView:) name:@"NewChatCreated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView:) name:@"ReloadList" object:nil];
    
    
    
}

-(void)reloadView:(NSNotification*)userNotification{
    
    [self.tableVIewOutlet setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view setUserInteractionEnabled:YES];
    
}


- (void)createNavRightButton {
    self.navigationController.navigationItem.hidesBackButton =  YES;
    UIButton  *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"SendChatIconmain"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"SendChatIconmain"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(messageTypeButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
    
    
}

-(void)updateTableView:(NSNotification *)userNotificaton{
    
  
    
    [self countNumberofUnreadMsgUsers ];
    [self reOrderTableViewNewMsgCame];
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [_tableVIewOutlet reloadData];
    }];
    
    
}


-(void)reloadListView:(NSNotification*)userNotification{
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self getAllChatDocuments];
        
        
        [[PicogramSocketIOWrapper sharedInstance]getofflineGroupMsg:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
        
        [_tableVIewOutlet reloadData];
    }];
    
}

-(void)getAllChatDocuments {
    
    _totalRows = [NSMutableArray new];
    _totalDocumentID = [NSMutableArray new];
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
                CBLQueryRow *row = [_result rowAtIndex:count]; //[_totalRows objectAtIndex:count];
                CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
                [_totalDocumentID addObject:row.documentID];
                [self addObserverForDoc:getDocument];
                
                
            }
            
        }
        
        
        
        [self firstTimeReorderTableView:_totalDocumentID];
        
        _docCount = _result.count;
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableVIewOutlet reloadData];
        }];
        
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSNumber *value = [[NSUserDefaults standardUserDefaults]objectForKey:@"isComingfromPush"];
            if (value.boolValue == YES) {
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isComingfromPush"];
                
                NSString *fromNum =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"StoredocIdFromPush"]];
                
                NSString *fromDocID  = [self getDocumentIDWithSenderID:fromNum];
                int rowIndex = 0 ;
                for (int i= 0; i<_totalDocumentID.count; i++) {
                    NSString *docIDS = [_totalDocumentID objectAtIndex:i];
                    if ([docIDS isEqualToString:fromDocID]) {
                        rowIndex = i;
                    }
                }
                //  NSLog(@"doc indexpath =%d",rowIndex);
                NSIndexPath *path =[NSIndexPath indexPathForRow:rowIndex inSection:0];
                [_tableVIewOutlet selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self tableView:self.tableVIewOutlet didSelectRowAtIndexPath:path];
            };
            
        }];
        
    });
    
    
    
}
-(void)firstTimeReorderTableView:(NSMutableArray *)totalDocumentId{
    
    
    NSMutableArray *getPrevArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:StorDocIDArray]];
    
    for (int i=0; i<getPrevArr.count; i++) {
        NSLog(@"first reload , storeID =%@",getPrevArr[i]);
    }
    
    
    if (getPrevArr.count ==0) {
        [[NSUserDefaults standardUserDefaults] setObject:_totalDocumentID forKey:StorDocIDArray];
    }
    
    if (getPrevArr.count == _totalDocumentID.count) {
        
        [_totalDocumentID removeAllObjects];
        [_totalDocumentID addObjectsFromArray:[getPrevArr copy]];
        /*Store DocumentID Array*/
        [[NSUserDefaults standardUserDefaults] setObject:_totalDocumentID forKey:StorDocIDArray];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        for (int i=0;i<_totalDocumentID.count; i++) {
            
            for (int j=0; j<_totalRows.count; j++) {
                
                CBLQueryRow *row = [_totalRows objectAtIndex:j];
                
                if ([row.documentID isEqualToString:_totalDocumentID[i]]) {
                    
                    [temp addObject:_totalRows[j]];
                }
            }
            
        }
        
        [_totalRows removeAllObjects];
        [_totalRows addObjectsFromArray:[temp copy]];
    }
    
    
    
    
}

-(void)reOrderTableViewNewMsgCame{
    
    NSMutableArray *getPrevArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:StorDocIDArray]];
    [_totalDocumentID removeAllObjects];
    [_totalDocumentID addObjectsFromArray:[getPrevArr copy]];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i=0;i<_totalDocumentID.count; i++) {
        
        for (int j=0; j<_totalRows.count; j++) {
            
            CBLQueryRow *row = [_totalRows objectAtIndex:j];
            
            if ([row.documentID isEqualToString:_totalDocumentID[i]]) {
                
                [temp addObject:_totalRows[j]];
            }
        }
        
    }
    
    [_totalRows removeAllObjects];
    [_totalRows addObjectsFromArray:[temp copy]];
    
    
}

-(NSString*)getDocumentIDWithSenderID:(NSString *)senderID{
    NSString *reciverName_DoId;
    
    for (int i=0;i<_totalRows.count ;i++) {
        CBLQueryRow *row = [_totalRows objectAtIndex:i];
        CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        NSString *reciverName = [getDocument.properties objectForKey:@"receivingUser"];
        if ([senderID isEqualToString:reciverName]) {
            
            reciverName_DoId = row.documentID;
        }
    }
    
    return reciverName_DoId;
    
}


- (void) document: (CBLDocument*)doc
        didChange: (CBLDatabaseChange*)change{
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.view setUserInteractionEnabled:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.tableVIewOutlet setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [super viewWillAppear:animated];
    [self.view setUserInteractionEnabled:YES];
}
-(void)viewDidAppear:(BOOL)animated {
    
     self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [super viewDidAppear:animated];
    _iscomeFromSearch = NO;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self countNumberofUnreadMsgUsers ];
        [_tableVIewOutlet reloadData];
        
    }];
    
    MSReceive *msReceive = [MSReceive sharedInstance];
    [self getAllChatDocuments];
    self.tabBarController.tabBar.hidden = NO;
    // [msReceive getDocumentWithSenderID:@""];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
    
   
    
}

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

//Getter to know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

//An illustration of a call to toggle current state
- (IBAction)pressedButton:(id)sender {
    [self setTabBarVisible:![self tabBarIsVisible] animated:YES completion:^(BOOL finished) {
        NSLog(@"finished");
    }];
}

#pragma mark - time stamp

-(NSString*) AgoStringFromTime:(NSDate*) dateTimeFormat
{
    NSDictionary *timeScale = @{@"sec"  :@1,
                                @"min"  :@60,
                                @"hr"   :@3600,
                                @"day"  :@86400,
                                @"week" :@605800,
                                @"month":@2629743,
                                @"year" :@31556926};
    NSString *scale;
    int timeAgo = 0-(int)[dateTimeFormat timeIntervalSinceNow];
    if (timeAgo < 60) {
        scale = @"sec";
    } else if (timeAgo < 3600) {
        scale = @"min";
    } else if (timeAgo < 86400) {
        scale = @"hr";
    } else if (timeAgo < 605800) {
        scale = @"day";
    } else if (timeAgo < 2629743) {
        scale = @"week";
    } else if (timeAgo < 31556926) {
        scale = @"month";
    } else {
        scale = @"year";
    }
    
    timeAgo = timeAgo/[[timeScale objectForKey:scale] integerValue];
    NSString *s = @"";
    if (timeAgo > 1) {
        s = @"s";
    }
    return [NSString stringWithFormat:@"%d %@%@", timeAgo, scale, s];
}


#pragma mark - table view data source and delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 64;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger totalRow;
    
    if (_iscomeFromSearch) {
        totalRow =_searchtotalRows.count;
    }
    else{
        totalRow =_totalRows.count;
    }
    
    return  totalRow;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ConversationTableViewCell";
    
    __weak ConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    CBLQueryRow *row;
    if (_iscomeFromSearch) {
        row = [_searchtotalRows objectAtIndex:indexPath.row];
    }
    else{
        row= [_totalRows objectAtIndex:indexPath.row];
    }
    CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
    NSArray *nameImagArr =  [self getnameAndpicFromDB:[getDocument.properties objectForKey:@"receivingUser"]];
    
    NSString *imageURL1 ;
    NSString *imageURL2 ;
    
    NSArray *arrayMem = [NSArray arrayWithArray:[getDocument.properties objectForKey:@"groupMembers"]];
    
    if([arrayMem count] >2)
    {
        
        if ([getDocument.properties objectForKey:@"groupID"]) {
            NSArray *stringArray = [[NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupPic"]] componentsSeparatedByString: @","];
            imageURL1 = [stringArray firstObject];
            if([stringArray count]>= 2)
            {
                imageURL2 = [stringArray objectAtIndex:1];
            }else
            {   imageURL2 = [stringArray firstObject];}
        }
        cell.groupImageView.hidden = NO;
        if(imageURL1==nil || imageURL1==(id)[NSNull null] || [imageURL1 isEqualToString:@"(null)"])
        {
            cell.groupImageOne.image = [UIImage imageNamed:@"DefaultContactImage"];
        }
        else{
            NSURL *imageUrl =[NSURL URLWithString:imageURL1];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
            UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
            cell.groupImageOne.image = placeholderImage;
            cell.self.groupImageOne.layer.cornerRadius = cell.self.groupImageOne.frame.size.width / 2;
            cell.self.groupImageOne.clipsToBounds = YES;
            [cell setNeedsLayout];
            
            [cell.groupImageOne setImageWithURLRequest:request
                                      placeholderImage:placeholderImage
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   
                                                   cell.groupImageOne.image = image;
                                                   cell.self.groupImageOne.layer.cornerRadius = cell.self.groupImageOne.frame.size.width / 2;
                                                   cell.self.groupImageOne.clipsToBounds = YES;
                                                   [cell setNeedsLayout];
                                               } failure:nil];
            
        }
        
        if(imageURL2==nil || imageURL2==(id)[NSNull null] || [imageURL2 isEqualToString:@"(null)"])
        {
            cell.groupImageTwo.image = [UIImage imageNamed:@"DefaultContactImage"];
        }
        else{
            NSURL *imageUrl =[NSURL URLWithString:imageURL2];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
            UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
            cell.groupImageTwo.image = placeholderImage;
            cell.self.groupImageTwo.layer.cornerRadius = cell.self.groupImageTwo.frame.size.width / 2;
            cell.self.groupImageTwo.clipsToBounds = YES;
            [cell setNeedsLayout];
            
            [cell.groupImageTwo setImageWithURLRequest:request
                                      placeholderImage:placeholderImage
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   
                                                   cell.groupImageTwo.image = image;
                                                   cell.self.groupImageTwo.layer.cornerRadius = cell.self.groupImageTwo.frame.size.width / 2;
                                                   cell.self.groupImageTwo.clipsToBounds = YES;
                                                   [cell setNeedsLayout];
                                               } failure:nil];
            
        }
        
        cell.groupImageOne.layer.borderColor =  [[UIColor whiteColor] CGColor];;
        cell.groupImageOne.layer.borderWidth = 2 ;
        cell.groupImageTwo.layer.borderColor =  [[UIColor whiteColor] CGColor];;
        cell.groupImageTwo.layer.borderWidth = 2 ;
        
    }
    else
    {
        if ([getDocument.properties objectForKey:@"groupID"]) {
            imageURL1 = [NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupPic"]];
        }
        cell.groupImageView.hidden = YES;
        
        if(imageURL1==nil || imageURL1==(id)[NSNull null] || [imageURL1 isEqualToString:@"(null)"])
        {
            cell.groupOrUserImageOutlet.image = [UIImage imageNamed:@"DefaultContactImage"];
        }
        else{
            NSURL *imageUrl =[NSURL URLWithString:imageURL1];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
            UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
            cell.groupOrUserImageOutlet.image = placeholderImage;
            cell.self.groupOrUserImageOutlet.layer.cornerRadius = cell.self.groupImageOne.frame.size.width / 2;
            cell.self.groupOrUserImageOutlet.clipsToBounds = YES;
            [cell setNeedsLayout];
            
            [cell.groupOrUserImageOutlet setImageWithURLRequest:request
                                               placeholderImage:placeholderImage
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                            
                                                            cell.groupOrUserImageOutlet.image = image;
                                                            cell.self.groupOrUserImageOutlet.layer.cornerRadius = cell.self.groupOrUserImageOutlet.frame.size.width / 2;
                                                            cell.self.groupOrUserImageOutlet.clipsToBounds = YES;
                                                            [cell setNeedsLayout];
                                                        } failure:nil];
            
        }
        
        
    }
    
    //    [cell.groupImageTwo.layer setShadowOffset:CGSizeMake(-15.0, 15.0)];
    //    [cell.groupImageTwo.layer setShadowRadius:15.0];
    //    [cell.groupImageTwo.layer setShadowOpacity:1.0];
    //
    //    [cell.groupImageOne.layer setShadowOffset:CGSizeMake(-15.0, 15.0)];
    //    [cell.groupImageOne.layer setShadowRadius:15.0];
    //    [cell.groupImageOne.layer setShadowOpacity:1.0];
    
    
    
    cell.lastMessageTimingOutlet.text = [self getlastMsgtime:getDocument];
    cell.batchCountLabelOutlet.text = [[NSUserDefaults standardUserDefaults] objectForKey:row.documentID];
    cell.fullNameGroupOrUserOutlet.text =[self getReciverName:[nameImagArr firstObject]];
    cell.lastMessageOutlet.text = [self filterLastmsg:getDocument];
    
    
    if ([getDocument.properties objectForKey:@"groupID"]) {
        
        cell.fullNameGroupOrUserOutlet.text =[self getReciverName :[NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupName"]]];
    }
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view setUserInteractionEnabled:NO];
    [self performSegueWithIdentifier:@"toChatController" sender:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    //    self.tabBarController.tabBar.hidden = YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CBLQueryRow *row = [_totalRows objectAtIndex:indexPath.row];
    CBLDocument *doc = [CBObjects.sharedInstance.database documentWithID:row.documentID];
    
    
    if ([doc.properties objectForKey:@"groupID"]) {
        
        NSString *isRemove = [doc.properties objectForKey:@"isRemoveFromgp"];
        if ([isRemove isEqualToString:@"NO"] ) {
            UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"you can't delete group" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [view show];
            return;
        }
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@",[doc.properties objectForKey:@"groupID"]]];
    }
    
    [_totalRows removeObjectAtIndex:indexPath.row];
    
    
    NSMutableArray *tempDocIds = [NSMutableArray new];
    tempDocIds = [_totalDocumentID mutableCopy];
    [tempDocIds removeObject:row.documentID];
    [_totalDocumentID removeAllObjects];
    _totalDocumentID = [tempDocIds mutableCopy];
    
    [[NSUserDefaults standardUserDefaults] setObject:_totalDocumentID forKey:StorDocIDArray];
    
    NSError *error;
    [doc deleteDocument:&error];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
}

#pragma mark - Helpers

- (IBAction)createChatButton:(id)sender {
    
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SuggestionNavigationController *chat = [board instantiateViewControllerWithIdentifier:@"SuggestionNavigationController"];
    [self presentViewController:chat animated:YES completion:nil];
}


- (IBAction)broadcastCliked:(id)sender {
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Opps" message:@"In develop" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    // [alert show];
}



- (IBAction)newGroupCliked:(id)sender {
}


#pragma mark - couchBasedelegates
-(void)newDocumentCreatedID:(NSString *)docID {
    [self getAllChatDocuments ];
    
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_tableVIewOutlet reloadData];
    }];
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender {
    
    if ([segue.identifier isEqualToString:@"toChatController"]) {
        ChatViewController *vc = [segue destinationViewController];
        CBLQueryRow *row;
        if (_iscomeFromSearch) {
            row = [_searchtotalRows objectAtIndex:sender.row];
        }
        else{
            row= [_totalRows objectAtIndex:sender.row];
        }
        
        
        CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        vc.currentDocument = getDocument;
        vc.docDict = getDocument.properties;
        
        
        
        NSArray *nameImagArr =  [self getnameAndpicFromDB:[getDocument.properties objectForKey:@"receivingUser"]];
        vc.userImageStr = [nameImagArr lastObject];
        vc.userName = [nameImagArr firstObject];
        if ([getDocument.properties objectForKey:@"groupID"]) {
            vc.userName = [NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupName"]];
            vc.userImageStr = [NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupPic"]];
            vc.groupId = [NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupID"]];
            vc.gpCreatedBy = [NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"createdBy"]];
            vc.groupMems = [getDocument.properties objectForKey:@"groupMembers"];
            vc.groupAdmin = [getDocument.properties objectForKey:@"groupAdmin"];
            vc.isRemoveFromgp = [getDocument.properties objectForKey:@"isRemoveFromgp"];
        }
        vc.isFirsttime =NO;
        vc.receiverName = [getDocument.properties objectForKey:@"receivingUser"];
        vc.unreadMesgCount = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:row.documentID]];
        [[NSUserDefaults standardUserDefaults]setObject:vc.receiverName forKey:@"saveFromNumForLocalPush"];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:row.documentID];
        [self countNumberofUnreadMsgUsers];
        
    }
}

-(NSString *)filterLastmsg:(CBLDocument*)getDocument{
    
    NSString *lastMsg;
    NSArray *messageArr = [getDocument.properties objectForKey:@"messages"];
    if (messageArr.count>0) {
        NSDictionary *dict = [messageArr lastObject];
        lastMsg = [dict objectForKey:@"text"];
        
        if (lastMsg.length>25) {
            NSString *cutMsg = lastMsg;
            cutMsg=  [cutMsg substringToIndex:25];
            cutMsg = [cutMsg stringByAppendingString:@"..."];
            lastMsg = cutMsg;
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"1"]) {
            
            lastMsg = @"Image";
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"2"]) {
            lastMsg = @"Video";
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"3"]) {
            lastMsg = @"Location";
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"4"]) {
            lastMsg = @"Contact";
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"5"]) {
            lastMsg = @"Voice";
        }
        if ([[dict objectForKey:@"type"] isEqualToString:@"8"]) {
            lastMsg = @"Post";
        }
        return lastMsg;
        
    }
    else{
        
        if ([getDocument.properties objectForKey:@"groupID"]){
            
            lastMsg = @"";
        }else{
            lastMsg = defaultLastSeenMsg;
        }
        
    }
    
    
    return lastMsg;
}

-(NSString *)getReciverName:(NSString *)reciverName{
    
    if (reciverName.length>12) {
        NSString *cutMsg = reciverName;
        cutMsg=  [cutMsg substringToIndex:12];
        cutMsg = [cutMsg stringByAppendingString:@"..."];
        reciverName = cutMsg;
    }
    return reciverName;
    
}

-(NSString *)getlastMsgtime:(CBLDocument*)getDocument{
    
    NSString *lastMsgtime;
    NSArray *messageArr = [getDocument.properties objectForKey:@"messages"];
    
    if (messageArr.count>0) {
        NSDictionary *dict = [messageArr lastObject];
        lastMsgtime = [dict objectForKey:@"date"];
        if (lastMsgtime.length ==0) {
            return nil;
        }
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        formater.dateFormat =@"YYYY-MM-dd HH:mm:ss";
        NSDate *date12 = [formater dateFromString:lastMsgtime];
        NSDate *todayDate = [NSDate date];
        
        NSString *lastMsgDateStr = [NSString stringWithFormat:@"%@",date12];
        
        lastMsgDateStr = [lastMsgDateStr substringToIndex:11];
        NSString *todayStr = [NSString stringWithFormat:@"%@",todayDate];
        todayStr = [todayStr substringToIndex:11];
        
        if ([lastMsgDateStr isEqualToString:todayStr]){
            
            NSString *cutMsg = lastMsgtime;
            cutMsg=  [cutMsg substringWithRange:NSMakeRange(11,lastMsgtime.length-14)];
            
            NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
            dateformater.dateFormat=@"HH:mm";
            NSDate *date = [dateformater dateFromString:cutMsg];
            dateformater.dateFormat = @"hh:mm a";
            cutMsg = [dateformater stringFromDate:date];
            lastMsgtime = cutMsg;
            return lastMsgtime;
        }
        else{
            
            lastMsgtime = lastMsgDateStr ;
            return lastMsgtime;
        }
        
    }
    
    return nil;
    
    
    
}


-(void)addObserverForDoc:(CBLDocument*)getDoc{
    
    [[NSNotificationCenter defaultCenter] addObserverForName: kCBLDocumentChangeNotification
                                                      object: getDoc
                                                       queue: nil
                                                  usingBlock: ^(NSNotification *n) {
                                                      CBLDatabaseChange* change = n.userInfo[@"change"];
                                                      //[self setNeedsDisplay: YES];  // redraw the view
                                                      
                                                      [self reOrderListView:change.documentID];
                                                      
                                                  }
     ];
    
    
}


-(void)reOrderListView:(NSString *)documentID{
    
    NSMutableArray *temp = [[NSMutableArray alloc]initWithArray:[_totalDocumentID copy]];
    
    for (int i=0;i<_totalRows.count;i++)
    {
        // NSString *docID = _totalDocumentID[i];
        NSString *docID = temp[i];
        
        if ([docID isEqualToString:documentID])
        {
            CBLQueryEnumerator *resetEnumerator = _totalRows[i];
            NSMutableArray *tempArr = [NSMutableArray new];
            tempArr = [_totalRows mutableCopy];
            [tempArr removeObjectAtIndex:i];
            
            NSMutableArray *temp2 = [NSMutableArray new];
            [temp2 addObject:resetEnumerator];
            [temp2 addObjectsFromArray:tempArr];
            
            _totalRows  =[NSMutableArray new];
            _totalRows = [temp2 mutableCopy];
            
            [_totalDocumentID removeAllObjects];
            _totalDocumentID = [NSMutableArray new];
            
            for (int i=0;i<_totalRows.count;i++) {
                CBLQueryRow *row = [_totalRows objectAtIndex:i];
                [_totalDocumentID addObject:row.documentID];
            }
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_totalDocumentID forKey:StorDocIDArray];
    
}



#pragma mark - SearchBar delegates

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [_serachBar setShowsCancelButton:YES animated:YES];
    //  CGRect tableHeight = self.tableVIewOutlet.frame;
    // tableHeight.size.height =self.tableVIewOutlet.frame.size.height- 500;
    //self.tableVIewOutlet.frame = tableHeight;
    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    [self.view endEditing:YES];
    [_serachBar resignFirstResponder];
    _serachBar.text=@"";
    [_serachBar setShowsCancelButton:NO animated:YES];
    _iscomeFromSearch = NO;
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [_tableVIewOutlet reloadData];
    }];
    
    
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
    //hide keyboard
    
    // [_serachBar resignFirstResponder];
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length ==0) {
        _iscomeFromSearch = NO;
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [_tableVIewOutlet reloadData];
        }];
        
        
    }
    else{
        
        _iscomeFromSearch = YES;
        [_serachBar setShowsCancelButton:YES animated:YES];
        //        NSMutableArray *getNameArr = [NSMutableArray new];
        //        NSMutableArray *allIndex = [NSMutableArray new];
        //        NSMutableArray *getFavName = [NSMutableArray new];
        //        NSMutableArray *getFavNum = [NSMutableArray new];
        
        _searchtotalRows = [NSMutableArray new];
        
        
        
        
        
        for(int i=0; i<[_totalRows count]; i++)
        {
            CBLQueryRow *row =[_totalRows objectAtIndex:i];
            CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
            
            
            NSString *memberName = [getDocument.properties objectForKey:@"groupName"];
            
            
            
            if ([memberName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound    ) {
                
                [_searchtotalRows addObject:[self.totalRows objectAtIndex:i]];
                
            }
            
            
        }
        
        
        //        for (int i= 0; i<_totalRows.count; i++) {
        //            CBLQueryRow *row =[_totalRows objectAtIndex:i];
        //            CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        //            //temp check
        //            if ([getDocument.properties objectForKey:@"groupID"]) {
        //
        //                [getNameArr addObject:[getDocument.properties objectForKey:@"groupName"]];
        //                [getFavName addObject:[getDocument.properties objectForKey:@"groupName"]];
        //                [getFavNum addObject:[getDocument.properties objectForKey:@"groupName"]];
        //
        //            }else{
        //
        //                [getNameArr addObject:[getDocument.properties objectForKey:@"receivingUser"]];
        //                NSString *gotName =[self getNameFromDB:[getDocument.properties objectForKey:@"receivingUser"]];
        //                NSArray *arr = [gotName componentsSeparatedByString:@"*:"];
        //
        //                [getFavName addObject:arr[0]];
        //                [getFavNum addObject:arr[1]];
        //            }
        //
        //        }
        //
        //
        //        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText];
        //        NSArray  *searchResults  = [getFavName filteredArrayUsingPredicate:pred];
        //
        //
        //        for (int i=0;i<getFavName.count;i++) {
        //            NSString *str = getFavName[i];
        //            for (int j=0;j<searchResults.count;j++)
        //            {
        //                if ([[searchResults objectAtIndex:j] isEqualToString:str]){
        ////                    int s=0;
        ////                    for(i=0;i<[allIndex count];i++)
        ////                    {
        ////                        NSString *comp = [NSString stringWithFormat:@"%d",i];
        ////                        NSString *comp2 = [NSString stringWithFormat:@"%@",[allIndex objectAtIndex:i]];
        ////                        if([comp2 isEqualToString:comp])
        ////                        {
        ////                            s=1;
        ////                        }
        ////
        ////                    }
        ////                    if(s == 0)
        //                    [allIndex addObject:[NSString stringWithFormat:@"%d",i]];
        //                }
        //            }
        //        }
        //
        //        NSMutableArray *saveIndexMatch = [NSMutableArray new];
        //
        //        for (int i=0;i<getNameArr.count;i++) {
        //            NSString *temp = getNameArr[i];
        //            for (int j=0;j<allIndex.count;j++) {
        //                NSString *tempfavNum =[getFavNum objectAtIndex:[[allIndex objectAtIndex:j]integerValue]];
        //                if ([temp isEqualToString:tempfavNum]) {
        //                    [saveIndexMatch addObject:[NSString stringWithFormat:@"%d",i]];
        //                }
        //            }
        //        }
        //        for (int i=0;i<saveIndexMatch.count;i++) {
        //            for (int j=0;j<_totalRows.count;j++) {
        //                NSString *str = [NSString stringWithFormat:@"%d",j];
        //                if ([saveIndexMatch[i] isEqualToString:str]) {
        //                    [_searchtotalRows addObject:_totalRows[j]];
        //                }
        //            }
        //        }
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [_tableVIewOutlet reloadData];
        }];
    }
}

/*get name and pic from database*/
-(NSArray *)getnameAndpicFromDB:(NSString *)receiverSupNo{
    
    NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",receiverSupNo];
    NSArray *allFav = [_favDataBase getDataFavDataFromDB];
    NSArray *array = [allFav filteredArrayUsingPredicate:predi];
    NSArray *nameImageArr;
    NSDictionary *fav;
    if (array.count>0) {
        
        if (array.count>2) {
            fav = [self shortArray:array recivrNo:receiverSupNo];
        }else{
            fav = [array objectAtIndex:0];
        }
        NSString *favName = [NSString stringWithFormat:@"%@",fav[@"fullName"]];
        if (favName.length == 0 ||[favName isEqualToString:@" "] || [favName isEqualToString:@"(null)"]) {
            favName = fav[@"supNumber"];
        }else{
            favName =fav[@"fullName"];
        }
        nameImageArr =@[[NSString stringWithFormat:@"%@",favName],[NSString stringWithFormat:@"%@",fav[@"status"]],[NSString stringWithFormat:@"%@",fav[@"image"]]];
    }
    else{
        nameImageArr = @[[NSString stringWithFormat:@"%@",receiverSupNo],[NSString stringWithFormat:@"%@",@""]];
    }
    return nameImageArr;
}
-(NSString *)getNameFromDB:(NSString *)receiverSupNo{
    
    NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",receiverSupNo];
    NSArray *allFav = [_favDataBase getDataFavDataFromDB];
    NSArray *array = [allFav filteredArrayUsingPredicate:predi];
    
    NSDictionary *fav ;
    
    if (array.count>0) {
        
        if (array.count>2) {
            fav =[self shortArray:array recivrNo:receiverSupNo];
        }
        else{
            fav = [array objectAtIndex:0];
        }
        
    }
    
    NSString *favName = [NSString stringWithFormat:@"%@",fav[@"fullName"]];
    NSString *favNumber = [NSString stringWithFormat:@"%@",fav[@"supNumber"]];
    
    favName = [favName stringByAppendingString:@"*:"];
    favName = [favName stringByAppendingString:favNumber];
    
    return favName;
}

-(NSDictionary *)shortArray:(NSArray *)dbArray recivrNo:(NSString*)reciverNo{
    NSDictionary *fav;
    
    for (NSDictionary *fav1 in dbArray) {
        
        if ([fav1[@"supNumber"] isEqualToString:reciverNo]) {
            fav =fav1;
        }
    }
    return fav;
}

//count number of unread Message

-(void)countNumberofUnreadMsgUsers{
    
    int totalCount =0;
    
    for (int i=0;i<_totalDocumentID.count;i++) {
        
        NSString *doc_id =[NSString stringWithFormat:@"%@",[_totalDocumentID objectAtIndex:i]];
        int count = [[[NSUserDefaults standardUserDefaults] objectForKey:doc_id] intValue];
        if (count>0) {
            totalCount ++;
        }
    }
    
    if (totalCount >0) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.navigationController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",totalCount]];
        }];
    }
    else{
        [self.navigationController.tabBarItem setBadgeValue:nil];}
    
}

//update chatlistView

-(void)updateChatlistView:(NSNotification*)userInfo{
    
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [_tableVIewOutlet reloadData];
    }];
    
    
    
    
}

-(void)messageTypeButtonClicked {
    //    UIActionSheet *acctionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Message", nil];
    //    [acctionSheet showInView:self.view];
    
    //    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    SuggestionNavigationController *chat = [board instantiateViewControllerWithIdentifier:@"SuggestionNavigationController"];
    //    [self presentViewController:chat animated:YES completion:nil];
    
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //    if  (buttonIndex == 0) {
    //
    //        [[NSUserDefaults standardUserDefaults]setValue:@"directChaT" forKey:@"CameraControllerType"];
    //        [[NSUserDefaults standardUserDefaults]synchronize];
    //
    //
    //        [self performSegueWithIdentifier:@"directChatToCam" sender:nil];
    //        /*BaseViewController *baseVC1 = [self.storyboard instantiateViewControllerWithIdentifier:@"baseVC"];
    //         UINavigationController *navBar =[[UINavigationController alloc]initWithRootViewController:baseVC1];
    //         [self presentViewController:navBar animated:YES completion:nil];*/
    //        //baseVC
    //
    //
    //        NSLog(@"Send Media");
    //    }
    if (buttonIndex == 0) {
        
        //        suggestionViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"chatToSuggestion"];
        //
        ////        suggestionViewController *suggestionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatToSuggestion"];
        ////        //UINavigationController *navBar =[[UINavigationController alloc]initWithRootViewController:suggestionVC];
        ////        [self.navigationController pushViewController:suggestionVC animated:YES];
        //        //[self presentViewController:navBar animated:YES completion:nil];
        //         [vc presentViewController:incomingVC animated:YES completion:nil];
        
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SuggestionNavigationController *chat = [board instantiateViewControllerWithIdentifier:@"SuggestionNavigationController"];
        [self presentViewController:chat animated:YES completion:nil];
        
        
        
        NSLog(@"Send Message");
    }
}




- (IBAction)backButtonAction:(id)sender {
    
    PGTabBar *  homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginToHomeViewController"];
    
    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
    
}
@end
