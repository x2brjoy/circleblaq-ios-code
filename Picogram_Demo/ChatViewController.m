//
//  ChatViewController.m
//  Sup
//
//  Created by Rahul Sharma on 1/11/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "ChatViewController.h"
#import "Message.h"
#import "PicogramSocketIOWrapper.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatHelper.h"
#import <AVKit/AVKit.h>
#import "MSSend.h"
#import "MSReceive.h"
#import "PGTabBar.h"
#import "PageContentViewController.h"
#import "UIImageView+AFNetworking.h"
//#import "ContactDetailsTableViewController.h"
#import "ARDVideoCallViewController.h"
#import "Database.h"
//#import "LocationSubmitTableViewController.h"
//#import "ShowLocationViewController.h"
//#import "Controller/AllContactsTableViewController.h"
//#import "ShowContactTableViewController.h"
#import "videoCallViewController.h"
#import "AudioCallViewController.h"
//#import "SendVoiceRecorderViewController.h"
//#import "ShowVoiceRecorderViewController.h"
#import "GroupInfoTableViewController.h"
//#import "Favorites.h"
//#import "FavDataBase.h"
#import "UserProfileViewController.h"
#import "InstaVIdeoTableViewController.h"
#import "Helper.h"
#import "TinderGenericUtility.h"
#import "ConversationListViewController1.h"
#import "ChatNavigationContollerClass.h"
#import "HomeScreenTabBarController.h"



#define ActionSheetTagForCall 63559156945
#define AcrtionSheetTagForMedia 7357396879357

@interface ChatViewController ()<SocketWrapperDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,MessageStorageDelegate,CouchBaseEventsDelegate,UITextViewDelegate>{
    
    UIButton *buttonUserTitle;
    UIWindow *window ;
    UIView *imagBackView;
    NSString*participantId, *randomString;
    NSString *storeLocation;
    NSString *storeContact;
    NSURL *storeVoice;
    NSString *storeLastSeen;
    NSString *tempStoreLastSeenTime;
    int messageType;
    UIImage *sendImage;
    NSString *filepathStore;
    UIImage *thumImg;
    
    
}
@property UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSMutableArray *dataSource, *jsonMessages;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) PicogramSocketIOWrapper *client;
@property (strong, nonatomic) UIImage *receiverImage;
@property (strong, nonatomic) NSString *documentID;
@property (assign, nonatomic) NSInteger previousMessageButtonPressCount;
@property (assign, nonatomic) BOOL isConnected;
@property (strong,nonatomic) NSString *message;
@property (strong, nonatomic) NSMutableArray *mediaList;
@property (strong ,nonatomic) UIImage *StoreImage;
@property (strong,nonatomic) NSString *SaveStatus;
//@property (strong ,nonatomic) FavDataBase *favDataBase;



@end

@implementation ChatViewController
@synthesize client;

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *full = [_fulldetail objectAtIndex:0];
    //    _receiverName = [NSString stringWithFormat:@"%@",full[@"memberId"]];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
    self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotResponsefromTypingChannel:) name:@"typingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotResponsefromChangeonliechannel:) name:@"getOnlineorLastseenTime" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkOnlineOfflineContiue:) name:@"getOnlineStatusContiues" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotResponseFromCallChannel:) name:@"getResponseFromCallChannel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMsgCount:) name:@"updateChatView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeNetworkStatus:) name:@"observeNetworkStatus" object:nil];
    
    
    //    _favDataBase = [FavDataBase sharedInstance];
    
    
        if ([_groupMems count]>2) {
            _detailButtonPosition.constant = 1;
            _callBtn.hidden = YES;
            _navLastseen.hidden = YES;
        }else
    _detailButtonPosition.constant = 46;
    
    /*get lastseen from server*/
    [[PicogramSocketIOWrapper sharedInstance] getLastseenFromServer:_receiverName] ;
    
    //    if (_isComingfromFav) {
    
    //        UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithTitle:@"Chats" style:UIBarButtonItemStyleBordered target:self action:@selector(NavLeftBtnCliked:)];
//    UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:  @"settings_back_icon_off@2x.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(NavLeftBtnCliked:)];
//    
//    self.navigationItem.leftBarButtonItem = barItem;
    //    }
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.hidesBackButton=YES;
    //    DefaultContactImage
    
    self.groupImageNav.image = [UIImage imageNamed:@"DefaultContactImage"];
    
    
    
    _mediaList = [[NSMutableArray alloc] init];
    
    _previousMessageButtonPressCount = 0;
    self.messageInputView.textInitialHeight = 45;
    self.messageInputView.textView.font = [UIFont systemFontOfSize:17];
    _receiverImage = [UIImage imageNamed:@"jobs.jpg"];
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    MSReceive *msReceive = [MSReceive sharedInstance];
    msReceive.delegate = self;
    _docDict = [messageStorage getDetailsForDocument:_currentDocument];
    
    [_navUserNameBtn setTitle:_userName forState:UIControlStateNormal];
    _navActivity.hidden = YES;
    
    /*commented */
    //_userName = _docDict[@"sendingUser"];
    
    
    _jsonMessages = [NSMutableArray new];
    // Apply changes
    [self.messageInputView adjustInputView];
    
    NSNumber *boolval = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNetworkAvailable"];
    if(boolval.boolValue)
    {
        self.messageInputView.mediaButton.enabled = YES;
        self.messageInputView.sendButton.enabled = YES;
        
    }else{
        self.messageInputView.mediaButton.enabled = NO;
        self.messageInputView.sendButton.enabled = NO;
        
    }
    
    
    self.dataSource = [[NSMutableArray alloc] init]; //[_docDict[@"messages"] mutableCopy];
    
    [self createArrayOfMessages];
    [self getUserImage];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // self.title = @"Offline";
    
}


-(void)viewDidAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:YES];
    
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (delegate.isConnected) {
        //  self.title = @"Online";
        //[self.navUserNameBtn setTitle:_userName forState:UIControlStateNormal];
        //[_navLastseen setText:tempStoreLastSeenTime];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_navActivity stopAnimating];
            _navActivity.hidden = YES;
        }];
        self.messageInputView.mediaButton.enabled = YES;
        self.messageInputView.sendButton.enabled = YES;
    }
    else{
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self.navUserNameBtn setTitle:@"Connecting..." forState:UIControlStateNormal];
            tempStoreLastSeenTime = _navLastseen.text;
            _navLastseen.text = @"";
            [_navActivity startAnimating];
            _navActivity.hidden = NO;
        }];
        self.messageInputView.mediaButton.enabled = NO;
        self.messageInputView.sendButton.enabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnect) name:@"didConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnect) name:@"didDisconnect" object:nil];
    
    NSNumber *boolValue = [[NSUserDefaults standardUserDefaults]objectForKey:@"sendlocation"];
    if (boolValue.boolValue) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sendlocation"];
        [self sendLocation];
    }
    NSNumber *boolVal = [[NSUserDefaults standardUserDefaults]objectForKey:@"contacSelected"];
    if (boolVal.boolValue) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"contacSelected"];
        [self openSendContacScreen];
    }
    
    NSNumber *booL = [[NSUserDefaults standardUserDefaults]objectForKey:@"sendContact"];
    if (booL.boolValue) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sendContact"];
        [self sendContact];
        
    }
    
    
    NSNumber *checkVoice  = [[NSUserDefaults standardUserDefaults]objectForKey:@"sendVoice"];
    if (checkVoice.boolValue) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sendVoice"];
        [self sendVoiceRecorder];
    }
    
    //////////////////////////////////////////////////////////////////////////////
    
    //
    //    if (_groupId.length>0) {
    //        NSNumber *num = [[NSUserDefaults standardUserDefaults]objectForKey:_groupId];
    //        if (num.boolValue == YES) {
    //            [[NSOperationQueue mainQueue]addOperationWithBlock:^{[self addViewOnTextView];}];
    //        }
    //    }
    
    // [self createArrayOfMessages];
    
    if (_groupId.length>0) {
        if ([_isRemoveFromgp isEqualToString:@"YES"]) {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{[self addViewOnTextView];}];
        }else{
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{[self removeViewOnTextView];}];
        }
    }
    
    
    //    if([_groupMems count]<3)
    //    {
    //        _callBtn.enabled = YES;
    //        UIImage *image = [UIImage imageNamed:@"contacts_info_call_icon_off"];
    //        [_callBtn setImage:image];
    //    }
    //    else
    //    {
    //         _callBtn.enabled = NO;
    //        [_callBtn setImage:NULL];
    //    }
    
    
}




-(void)viewWillDisappear:(BOOL)animated {
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //    [self updateDocument];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"saveFromNumForLocalPush"];
}

-(void)showProfileDetails
{
    //contactInfo
    //ContactDetailsTableViewController
    [self performSegueWithIdentifier:@"contactInfo" sender:self];
    
    
}

-(void)observeNetworkStatus:(NSNotification*)userInfo{
    
    
    NSDictionary *dict = userInfo.userInfo;
    
    //network gone disable send Button
    
    /*
     if ([[dict objectForKey:@"message"] isEqualToString:@"YES"]) {
     
     self.messageInputView.mediaButton.enabled = YES;
     self.messageInputView.sendButton.enabled = YES;
     }
     else{
     
     self.messageInputView.mediaButton.enabled = NO;
     self.messageInputView.sendButton.enabled = NO;
     }
     */
    
    
    
    
    /* MessageStorage *messageStorage = [MessageStorage sharedInstance];
     NSDictionary *allMsgDict = [messageStorage getDetailsForDocument:_currentDocument];
     NSArray *allMessages =  allMsgDict[@"messages"];
     
     
     int totalCount = (int)[allMessages count] -1;
     
     for (int i= totalCount; i>0; i--) {
     NSDictionary *dict =[allMessages objectAtIndex:i];
     if ([dict objectForKey:@"messageSent"]) {
     NSString *msgSentStatus = [NSString stringWithFormat:@"%@",dict[@"messageSent"]];
     if ([msgSentStatus isEqualToString:@"NO"]) {
     SocketMessageType msgType ;
     if ([dict [@"type"] isEqualToString:@"0"]) {
     
     msgType = SocketMessageTypeText;
     }
     else if ([dict [@"type"] isEqualToString:@"1"]){
     
     
     msgType = SocketMessageTypePhoto;
     }
     else if ([dict[@"type"] isEqualToString:@"2"]){
     
     msgType = SocketMessageTypeVideo;
     
     }
     
     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
     [[ChatSocketIOClient sharedInstance] sendMessageAgain:[NSString stringWithFormat:@"%@",dict[@"text"]] fromUser:_currentDocument.properties[@"sendingUser"] toUser:_currentDocument.properties[@"receivingUser"] withDocId:_currentDocument.documentID currentDateId:[NSString stringWithFormat:@"%@",dict[@"messageID"]] withType:msgType];
     }];
     }
     else{
     break;
     }
     }
     }
     */
}

-(void)createArrayOfMessages {
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    _docDict = [messageStorage getDetailsForDocument:_currentDocument];
    NSArray *messages;
    NSArray *allMessages =  _docDict[@"messages"];
    //    for (int i=0; i<allMessages.count; i++) {
    //         NSLog(@"log =%@",allMessages[i]);
    //    }
    
    
    
    ///////
    
    //    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //    CBLManager* bgMgr = [app.manager copy];
    //    NSError *error;
    //
    //    CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
    //    CBLDocument *getDocument = [bgDB documentWithID:_currentDocument.documentID];
    //
    //    NSLog(@"all doc =%@",getDocument.properties[@"messages"]);
    /////
    
    /*check message sent to server or not if not then send recurvise*/
    
    if (_groupId.length == 0) {
        
        
        int totalCount = (int)[allMessages count] -1;
        
        for (int i= totalCount; i>0; i--) {
            
            NSDictionary *dict =[allMessages objectAtIndex:i];
            
            if ([dict objectForKey:@"messageSent"]) {
                NSString *msgSentStatus = [NSString stringWithFormat:@"%@",dict[@"messageSent"]];
                
                if ([msgSentStatus isEqualToString:@"NO"]) {
                    
                    SocketMessageType msgType ;
                    if ([dict [@"type"] isEqualToString:@"0"]) {
                        
                        msgType = SocketMessageTypeText;
                    }
                    else if ([dict [@"type"] isEqualToString:@"1"]){
                        
                        msgType = SocketMessageTypePhoto;
                    }
                    else if ([dict[@"type"] isEqualToString:@"2"]){
                        
                        msgType = SocketMessageTypeVideo;
                    }
                    
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [[PicogramSocketIOWrapper sharedInstance] sendMessageAgain:[NSString stringWithFormat:@"%@",dict[@"text"]] fromUser:_currentDocument.properties[@"sendingUser"] toUser:_currentDocument.properties[@"receivingUser"] withDocId:_currentDocument.documentID currentDateId:[NSString stringWithFormat:@"%@",dict[@"messageID"]] withType:msgType];
                        
                    }];
                    
                }
                else{
                    break;
                }
                
                
            }
            
        }
        
    }
    /****************************/
    
    
    //if unread message is there then send read message status
    
    if (_unreadMesgCount.length>0 || (allMessages.count ==1)) {
        NSDictionary *dict = [allMessages lastObject];
        if ([dict objectForKey:@"messageID"]) {
            NSString *lastMsgID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"messageID"]];
            
            NSString *docID = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@docID",_receiverName]];
            
            
            if (_groupId.length ==0) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [[PicogramSocketIOWrapper sharedInstance] sendReceivedAcknowledgement:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]] withMessageID:lastMsgID ToReciver:_receiverName docID:docID messegStatus:@"3"];
                }];
            }
            
            
        }
        
    }
    
    _jsonMessages = [NSMutableArray arrayWithArray:allMessages];
    
    [self.dataSource removeAllObjects];
    _previousMessageButtonPressCount++;
    if (allMessages.count > 20*_previousMessageButtonPressCount) {
        
        messages = [allMessages subarrayWithRange:NSMakeRange(allMessages.count - 20*_previousMessageButtonPressCount, 20*_previousMessageButtonPressCount)];
    }else {
        messages = allMessages;
        
    }
    if (messages.count == allMessages.count) {
        [self hideHeaderView];
    }
    
    self.dataSource = [messageStorage createIntoSOMessagesfromMessages:messages];
    _mediaList = [messageStorage createMediaListfromMessages:messages];
}

-(void)connectToSocket {
    
    // NSLog(@"connectToSocket");
    _isConnected = NO;
    // self.title = @"Offline";
    client = [PicogramSocketIOWrapper sharedInstance];
    [client connectSocket];
    client.socketdelegate = self;
    
}


- (void)didReceiveMemoryWarning {
    NSLog(@"chat screen memoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)NavLeftBtnCliked:(UIButton *)sender{
    
    //   NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:newChatBtnCliked];
    //
    //    if ([value boolValue]) {
    //        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:newChatBtnCliked];
    //        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"CheckContacFirstTime"];
    //        [self dismissViewControllerAnimated:YES completion:nil];
    //    }
    //
    //
    //     [self.tabBarController.tabBar setHidden:NO];
    
    //      [self.tabBarController.tabBar setHidden:NO];
    //    [self.navigationController popViewControllerAnimated:YES];
    
    //    [self.tabBarController.tabBar setHidden:NO];
    //    [self.tabBarController setSelectedIndex:0];
//        [self.navigationController popViewControllerAnimated:NO];
    
    
    HomeScreenTabBarController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeScreenTabBarController"];
    
    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
 
    
}

- (NSMutableArray *)messages
{
    return self.dataSource;
    
}


- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    Message *message = self.dataSource[index];
    
    
    cell.textView.delegate =self;
    if (!message.fromMe) {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
        cell.textView.textColor = [UIColor blackColor];
    } else {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
        cell.textView.textColor = [UIColor blackColor];
    }
    
    
    //-----------------------------------------------//
    //     Adding datetime label under balloon
    //-----------------------------------------------//
    [self generateLabelForCell:cell];
    //-----------------------------------------------//
}

- (void)generateLabelForCell:(SOMessageCell *)cell
{
    static NSInteger labelTag = 90;
    //    CGFloat height = [super heightForMessageForIndex:<#(NSInteger)#>]
    Message *message = (Message *)cell.message;
    
    //    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    
    //    NSInteger index = indexpath.row;
    CGFloat height;
    if (message.type != SOMessageTypeText) {
        height = 106;
    }else {
        height = [super heightForMessageForMessage:message] - 14;
    }
    //    NSDateFormatter *formatter = [self DateFormatter];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:labelTag];
    if (!label) {
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:4];
        label.textColor = [UIColor grayColor];
        label.tag = labelTag;
        [cell.contentView addSubview:label];
    }
    //    label.text = [formatter stringFromDate:message.date];
    label.text = @"";
    label.enabled = YES;
    
    
    if (_groupId.length>0) {
        
        if (message.fromMe == NO) {
            NSString *name = @"";
            if(_groupMems.count >2)
            {
                
                for (int i=0; i<[_friendesList count]; i++) {
                    
                    NSManagedObject *friend = [self.friendesList objectAtIndex:i];
                    
                    if([[friend valueForKey:@"memberid"] isEqualToString:message.fromNum])
                    {
                        
                        name = [NSString stringWithFormat:@"%@",[friend valueForKey:@"memberName"]];
                    }
                }
                
                
            }
            
            
            label.text = name;//[self getNameFromDB:message.fromNum];
            label.font = [UIFont systemFontOfSize:9];
            
        }else{
            label.text = @"";
        }
    }
    
    
    if (message.fromMe && message.messageSent) {
        //        label.text = [NSString stringWithFormat:@"%@ ✔️",[formatter stringFromDate:message.date]];
        
        label.font = [UIFont systemFontOfSize:4];
        [label setTextColor:[UIColor grayColor]];
//        label.text = @"✔";//@"✔️";
        
    }
    if (message.fromMe && message.messageDelivered) {
        
        [label setTextColor:[UIColor grayColor]];
        label.font = [UIFont systemFontOfSize:4];
        label.text = @"✔✔";//@"✔️✔️";
        
    }
    if (message.fromMe && message.messageRead) {
        [label setTextColor:[UIColor blueColor]];
        label.font = [UIFont systemFontOfSize:4];
        label.text =@"✔✔✔";
        
    }
    
    
    [label sizeToFit];
    CGRect frame = label.frame;
    CGFloat topMargin = 0.0f;
    CGFloat leftMargin = 15.0f;
    CGFloat rightMargin = 20.0f;
    CGFloat topMarginforGp = 0.0f;
    
    
    if (message.type == SOMessageTypeText) {
        topMargin = 10.0f;
        topMarginforGp = 3.0f;
    }else if (message.type == SOMessageTypePhoto){
        topMargin = 0.0f;
        topMarginforGp = -2.0f;
    }else if (message.type == SOMessageTypeLocation){
        topMargin = 0.0f;
        topMarginforGp = -1.0f;
    }else if (message.type == SOMessageTypeContact){
        topMargin = 0.0f;
        topMarginforGp = -1.0f;
    }else if (message.type == SOMessageTypeVideo){
        topMargin = 0.0f;
        topMarginforGp = -1.0f;
    }else if (message.type == SOMessageTypePost){
        topMargin = 0.0f;
        topMarginforGp = -1.0f;
    }
    
    
    if (message.fromMe) {
        
        frame.origin.x = cell.contentView.frame.size.width  - rightMargin;
        frame.origin.y = cell.containerView.frame.origin.y + height + topMargin;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        label.frame = frame;
        
    } else {
        
        frame.origin.x = cell.containerView.frame.origin.x  + leftMargin;
        frame.origin.y = cell.containerView.frame.origin.y + height + topMargin;
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        label.frame = frame;
    }
    
    
    
    if (message.fromMe == NO && _groupId.length>0) {
        
        frame.origin.x = cell.containerView.frame.origin.x  + leftMargin;
        frame.origin.y = cell.containerView.frame.origin.y + height+topMarginforGp;
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        label.frame = frame;
        
        
    }
    
    
    if (_groupId.length>0) {
        
        NSString *tag = [NSString stringWithFormat:@"%@",message.groupMessageTag];
        if (message.groupMessageTag) {
            
            if ([tag rangeOfString:@"@"].location != NSNotFound) {
                
                NSRange first = [tag rangeOfString:@"@"];
                NSRange last = [tag rangeOfString:@"*"];
                
                NSRange result = NSMakeRange(first.location +first.length,last.location - first.location -first.length);
                NSString *resStr = [tag substringWithRange:result];
                NSString *final;
                if (resStr.length>0) {
                    
                    final = [self getNameFromDB:resStr];
                    if (![final isEqualToString:resStr]) {
                        tag = [tag stringByReplacingOccurrencesOfString:resStr withString:final];
                    }
                }
               
                if ([tag rangeOfString:@"@" options:NSBackwardsSearch].location != NSNotFound) {
                    first = [tag rangeOfString:@"@" options:NSBackwardsSearch];
                    last = [tag rangeOfString:@"*" options:NSBackwardsSearch];
                    result = NSMakeRange(first.location+first.length,last.location - first.location-first.length);
                    NSString *resStr1 = [tag substringWithRange:result];
                    NSString *final1;
                    
                    NSScanner *scanner = [NSScanner scannerWithString:resStr1];
                    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
                    if(isNumeric)
                    {
                        if (resStr1.length>0) {
                            final1 = [self getNameFromDB:resStr1];
                            if (![resStr1 isEqualToString:final1]) {
                                tag = [tag stringByReplacingOccurrencesOfString:resStr1 withString:final1];
                            }
                        }
                    }
                }
                
                
                tag = [tag stringByReplacingOccurrencesOfString:@"@" withString:@""];
                tag = [tag stringByReplacingOccurrencesOfString:@"*" withString:@""];
                
                
            }else{
                
                tag = message.groupMessageTag;
            }
            
            
            
            label.text = tag;
            label.numberOfLines = 2;
            frame.origin.x = 0;
            frame.origin.y = 2;
            frame.size.width = cell.containerView.frame.size.width;
            frame.size.height = 30;
            label.textAlignment =UITextAlignmentCenter;
            // label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.frame = frame;
            label.font = [UIFont systemFontOfSize:10];
            cell.textView.hidden = YES;
            cell.balloonImageView.hidden = YES;
            label.textColor = [UIColor blackColor];
        }
        
    }
    
}


-(NSString *)getNameFromDB:(NSString *)userNum{
    
    
    //    NSString *userName;
    //    if (userNum.length>0) {
    //
    //        NSString *regNo = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
    //        if ([regNo isEqualToString:userNum]) {
    //            return @"you";
    //        }
    //
    //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"supNumber == %@",userNum];
    //        NSArray *allFav = [_favDataBase getDataFavDataFromDB];
    //        NSArray *arr = [allFav filteredArrayUsingPredicate:predicate];
    //        if (arr.count>0) {
    //            NSDictionary *fav = [arr firstObject];
    //            userName = fav[@"fullName"];
    //            if (userName.length==0) {
    //                userName = fav[@"supNumber"];
    //            }
    //
    //        }else{
    //            userName = userNum;
    //        }
    //    }
    //
    NSString *senderName;
    
    if(userNum.length>0) {
        
        NSManagedObject *friend = [self getNameFromDb:[NSString stringWithFormat:@"%@",userNum]];
        
        
        
        senderName = [NSString stringWithFormat:@"%@",[friend valueForKey:@"memberName"]];
        
        
    }
    
    if([senderName isEqualToString:@"(null)"])
    {
        return @"You";
    }
    else
        return senderName;
    
}




#pragma mark - SOMessaging delegate
- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell
{
    [self.view endEditing:YES];
    // Show selected media in fullscreen
    [super didSelectMedia:media inMessageCell:cell];
    
    if (cell.message.type == SOMessageTypeLocation){
        
        // NSLog(@"locationType cliked =%@",cell.message.text);
        storeLocation = cell.message.text;
        [self performSegueWithIdentifier:@"chatVCtoLocationVC" sender:self];
        
    }
    if (cell.message.type == SOMessageTypeContact) {
        storeContact = cell.message.text;
        [self performSegueWithIdentifier:@"chatVCToshowcontacVC" sender:self];
    }
    if (cell.message.type == SOMessageTypeVoice) {
        
        NSArray *pathComponent = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)lastObject],@"MyAudioMemo.m4a",nil];
        NSURL  *outputFileURL = [NSURL fileURLWithPathComponents:pathComponent];
        [cell.message.media writeToFile:[outputFileURL path] atomically:YES];
        
        storeVoice = outputFileURL;
        [self performSegueWithIdentifier:@"gotoShowVoice" sender:self];
    }
    if (cell.message.type == SOMessageTypePost) {
        
        NSArray *singlePostDetails  = [[NSArray alloc]initWithObjects:cell.message.postData,nil];
        NSLog(@"%@",cell.message.media);
        if([singlePostDetails count ] == 0)
        {
            singlePostDetails  = [[NSArray alloc]initWithObjects:cell.message.media,nil];
        }
        
        // NSDictionary *postpic = cell.message.postData;
        
        //        InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
        //        newView.showListOfDataFor = @"ListViewForPostFromProfile";
        //        newView.dataFromExplore = singlePostDetails[0];
        //        newView.movetoRowNumber   = 0;
        //        newView.navigationBarTitle =@"Photo";
        //        NSString *ProfilePicUrl = postpic[@"profilePicUrl"] ;
        //
        //        newView.profilePicForPostFromProfile =flStrForObj(ProfilePicUrl);
        //
        //        NSLog(@"%@",newView.profilePicForPostFromProfile);
        //
        //        NSString *ProfileName = postpic[@"postedByUserName"];
        //
        //        newView.UserNameForPostFromProfile = ProfileName;// self.navigationItem.title;
        //        [self.navigationController pushViewController:newView animated:YES];
        
        
        InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
        newView.showListOfDataFor = @"ActivityProfile";
        //newView.dataForListView = dataForListView;
        newView.movetoRowNumber = 0;
        newView.postId = flStrForObj(singlePostDetails[0][@"postId"]);
        newView.activityUser = flStrForObj(singlePostDetails[0][@"postedByUserName"]);
        
        newView.postType = flStrForObj(singlePostDetails[0][@"postsType"]);
        
        NSString *typePost = [NSString stringWithFormat:@"%@",newView.postType];
        if([typePost isEqualToString:@"0"])
        {
            newView.navigationBarTitle =@"Photo";
        }else if ([typePost isEqualToString:@"1"])
        {
            newView.navigationBarTitle =@"Video";
        }
        newView.controllerType = @"ActivityProfile";
        //        newView.navigationBarTitle =   flStrForObj([Helper userName]);//self.navigationItem.title;
        [self.navigationController pushViewController:newView animated:YES];
        
        
        
        NSLog(@"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////SharePost : 10000");
    }
}

- (void)didSelectPost:(NSDictionary *)media inMessageCell:(SOMessageCell *)cell
{
    [self.view endEditing:YES];
    // Show selected media in fullscreen
    [super didSelectMedia:media inMessageCell:cell];
    
    
    if (cell.message.type == SOMessageTypePost) {
        
        NSArray *singlePostDetails  = [[NSArray alloc]initWithObjects:cell.message.postData,nil];
        NSLog(@"%@",cell.message.media);
        if([singlePostDetails count ] == 0)
        {
            singlePostDetails  = [[NSArray alloc]initWithObjects:cell.message.media,nil];
        }
        
        InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
        newView.showListOfDataFor = @"ActivityProfile";
        //newView.dataForListView = dataForListView;
        newView.movetoRowNumber = 0;
        newView.postId = flStrForObj(singlePostDetails[0][@"postId"]);
        newView.activityUser = flStrForObj(singlePostDetails[0][@"postedByUserName"]);
        
        newView.postType = flStrForObj(singlePostDetails[0][@"postsType"]);
        
        NSString *typePost = [NSString stringWithFormat:@"%@",newView.postType];
        if([typePost isEqualToString:@"0"])
        {
            newView.navigationBarTitle =@"Photo";
        }else if ([typePost isEqualToString:@"1"])
        {
            newView.navigationBarTitle =@"Video";
        }
        newView.controllerType = @"ActivityProfile";
        //        newView.navigationBarTitle =   flStrForObj([Helper userName]);//self.navigationItem.title;
        [self.navigationController pushViewController:newView animated:YES];
        
        
        
        NSLog(@"/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////SharePost : 10000");
    }
}



#pragma mark - SupSocketIOClient delegates

-(void)receivedNewMessage:(Message *)msg forDocID:(NSString *)docID {
    
    // NSLog(@"receive New message update tableView123");
    if ([_currentDocument.documentID isEqualToString:docID]) {
        
        if (_groupId.length>0) {
            _groupMems = [_currentDocument.properties objectForKey:@"groupMembers"];
            _groupAdmin = [_currentDocument.properties objectForKey:@"groupAdmin"];
            _userName = [NSString stringWithFormat:@"%@",[_currentDocument.properties objectForKey:@"groupName"]];
            _userImageStr = [NSString stringWithFormat:@"%@",[_currentDocument.properties objectForKey:@"groupPic"]];
            _isRemoveFromgp = [NSString stringWithFormat:@"%@",[_currentDocument.properties objectForKey:@"isRemoveFromgp"]];
            if ([_isRemoveFromgp isEqualToString:@"YES"]) {
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{[self addViewOnTextView];}];
            }else{
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{[self removeViewOnTextView];}];
            }
        }
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // NSLog(@"receive New message update tableView");
            [self receiveMessage:msg];
            
        }];
    }
    
}

-(void)addViewOnTextView{
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0,self.tableView.frame.size.height -50,self.view.frame.size.width,50)];
    view1.tag =  98967598;
    view1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view1];
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width,50)];
    lbl.textColor = [UIColor blackColor];
    lbl.backgroundColor = [UIColor lightGrayColor];
    lbl.numberOfLines = 2;
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.font = [UIFont fontWithName:@"Roboto-Regular" size:12];
    [lbl setText:@"you can’t send messages to this group because you’re no longer a participant."];
    [view1 addSubview:lbl];
    //store value to creat bottom view
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:_groupId];
    
    
}

-(void)removeViewOnTextView{
    
    UIView *view = [self.view viewWithTag:98967598];
    [view removeFromSuperview];
    view = nil;
    
}

#pragma mark - MessageStorage Delegate

-(void)reloadTableForMessageID:(NSString *)messageID andDocID:(NSString *)docID status:(NSString *)status {
    
    if ([docID isEqualToString:_currentDocument.documentID]) {
        
        MessageStorage *messageStorage = [MessageStorage sharedInstance];
        NSInteger index = [messageStorage indexOfMessageWithID:messageID inMessages:self.dataSource];
        
        //stop crash here
        if (self.dataSource.count >index) {
            
            Message *msg = [self.dataSource objectAtIndex:index];
            msg.messageSent = YES;
            if ([status  isEqual: MessagesuccesfullyDeliver]) {
                msg.messageDelivered =YES;
            }
            if ([status  isEqual: MessagesuccesfullyRead]) {
                msg.messageRead =YES;
            }
            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }];
            
        }
        
    }
    
}


//-(void)messageSentSuccessfullyToServer:(NSNotification *)notification {
//
//    NSDictionary *info = notification.userInfo;
//
//    NSString *messageID = info[@"messageID"];
//
//    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"messageID contains[cd] %@",messageID];
//    NSArray *messageObject = [self.dataSource filteredArrayUsingPredicate:bPredicate];
//    NSArray *jsonObject = [_jsonMessages filteredArrayUsingPredicate:bPredicate];
//    NSDictionary *dict = [jsonObject lastObject];
//    NSMutableDictionary *dictMutable = [dict mutableCopy];
//    dictMutable[@"messageSent"] = @"YES";
//    NSInteger indexOfdict = [_jsonMessages indexOfObject:dict];
//    [_jsonMessages replaceObjectAtIndex:indexOfdict withObject:[dictMutable copy]];
////    [dictMutable removeAllObjects];
//    NSLog(@"HERE %@",messageObject);
//    Message *msg = [messageObject lastObject];
//    msg.messageSent = YES;
//    NSInteger index = [self.dataSource indexOfObject:msg];
//
//
//
////    SOMessageCell *cell = (SOMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//
////        CouchbaseEvents *cbEvent = [[CouchbaseEvents alloc] init];
//////        [self.tableView reloadData];
////        [cbEvent updateDocument:CBObjects.sharedInstance.database documentId:_documentID withMessages:_jsonMessages];
//        [self.tableView beginUpdates];
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView endUpdates];
//    }];
//
//}


-(void)didDisconnect {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.navUserNameBtn setTitle:@"Connecting..." forState:UIControlStateNormal];
        tempStoreLastSeenTime = _navLastseen.text;
        _navLastseen.text = @"";
        _navActivity.hidden = NO;
        [_navActivity startAnimating];
    }];
    
    self.messageInputView.mediaButton.enabled = NO;
    self.messageInputView.sendButton.enabled = NO;
}


-(void)didConnect {
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self sendHeartBeat];
        [self.navUserNameBtn setTitle:_userName forState:UIControlStateNormal];
        [_navLastseen setText:tempStoreLastSeenTime];
        [_navActivity stopAnimating];
        _navActivity.hidden = YES;
    }];
    
    self.messageInputView.mediaButton.enabled = YES;
    self.messageInputView.sendButton.enabled = YES;
    
    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    // [appdel  didSubscribeToGetMessageAcks];
    // [appdel didSubscribeToHistory];
    [[PicogramSocketIOWrapper sharedInstance]callMethodTogetadduserwhileOffline];
}

-(void)sendHeartBeat {
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate sendHeartBeatStatus:@"1"];
}

#pragma mark - Methods for sending a text message

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message
{
    
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
    
    
    //    if (_isFirsttime) {
    //
    //        _message = message;
    //        _isFirsttime = NO;
    //        messageType = 0;
    //        [self newChatCreat];
    //    }
    //    else{
    
    MSSend *messageStorage = [MSSend sharedInstance];
    messageStorage.delegate = self;
    Message *msg = [messageStorage sendMessage:message onDocument:_currentDocument groupId:_groupId];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self sendMessage:msg];
    }];
    
    
}

-(void)newChatCreat{
    
    CouchbaseEvents *cbEvent = [[CouchbaseEvents alloc] init];
    cbEvent.delegate =self;
    NSString *userName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
    
    
    AppDelegate *appdelegate  = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([appdelegate isConnected]) {
        [appdelegate sendHeartBeatStatus:@"1"];
    }
    
    
    [cbEvent createDocument:CBObjects.sharedInstance.database forReceivingUser:_receiverName andSendingUser:userName withMessages:@[] newMessageCount:@""];
}

-(void)messageTextViewdidChaneg:(NSString *)text
{
    NSInteger len = _groupId.length  ;
    
    if (len==0) {
        PicogramSocketIOWrapper *chatsocket=[PicogramSocketIOWrapper sharedInstance];
        [chatsocket sendTypeingStatustoServer:_receiverName];
    }
    
}

-(void)gotResponsefromTypingChannel:(NSNotification*)notification{
    
    NSDictionary *dict = notification.userInfo;
    NSArray *message = [dict objectForKey:@"message"];
    
    for (NSDictionary *dict1 in message) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([dict1[@"from"] isEqualToString:_receiverName]) {
                if (dict1[@"typing"] ) {
                    _navLastseen.text= @"typing...";
                    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ChangeOnlineStatus) userInfo:nil repeats:NO];}
            }
        });
        
    }
    
}
-(void)ChangeOnlineStatus{
    
    if ([_navLastseen.text isEqualToString:@"typing..."]) {
        _navLastseen.text = @"Online";
    }
    
}

-(void)gotResponsefromChangeonliechannel:(NSNotification *)notification{
    
    NSDictionary *dict = notification.userInfo;
    NSArray *message =[dict objectForKey:@"message"];
    for (NSDictionary *dict1 in message) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *getLastseen =[self getLastSeenFormate:dict1[@"DateTime"]];
            
            _navLastseen.text =getLastseen;
            _SaveStatus = [NSString stringWithFormat:@"%@",dict1[@"OnlineStatus"]];
            if ([_SaveStatus isEqualToString:@"1"]) {
                _navLastseen.text =@"Online";
            }
            
        });
        
    }
}
-(void)checkOnlineOfflineContiue:(NSNotification*)notification{
    NSDictionary *dict = notification.userInfo;
    NSArray *message = [dict objectForKey:@"message"];
    
    if ([[[message firstObject]valueForKey:@"msisdn"] isEqualToString:_receiverName]) {
        
        for (NSDictionary *dict1 in message) {
            
            dispatch_async(dispatch_get_main_queue(),^{
                // NSLog(@"dict changeSt channel =%@",dict1);
                
                NSString *status = [NSString stringWithFormat:@"%@",dict1[@"Status"]];
                if ([status isEqualToString:@"1"]) {
                    _navLastseen.text = @"Online";
                }
                else{
                    _navLastseen.text = @"Offline";
                    storeLastSeen = [self getLastSeenFormate:dict1[@"DateTime"]];
                    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateLastSeen) userInfo:nil repeats:NO];
                }
                
            });
        }
        
        
    }
    
}

-(void)updateLastSeen{
    
    if ([_navLastseen.text isEqualToString:@"Offline"]) {
        // storeLastSeen = tempStoreLastSeenTime ;
        _navLastseen.text = storeLastSeen;
    }
    
}


-(void)gotResponseFromCallChannel:(NSNotification*)userNotification{
    
    NSDictionary *responseDictionary =userNotification.userInfo;
    
    [self.indicator stopAnimating];
    NSArray* status = [responseDictionary valueForKey:@"status"];
    if([[status objectAtIndex:0] isEqualToString:@"Accept"]) {
        /* Open the video call here */
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            ARDVideoCallViewController *videoCallViewController =
            [[ARDVideoCallViewController alloc] initForRoom:randomString
                                                 isLoopback:NO
                                                isAudioOnly:NO];
            videoCallViewController.modalTransitionStyle =
            UIModalTransitionStyleCrossDissolve;
            [self presentViewController:videoCallViewController
                               animated:YES
                             completion:nil];
        }];
    } else if([[status objectAtIndex:0] isEqualToString:@"Reject"]) {
        /* Show a error message and cancel the call */
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Call"
                                                            message:@"Call Declined by the User"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
}

-(void)updateUnreadMsgCount:(NSNotification*)userInfo{
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:_currentDocument.documentID];
    
}

#pragma couchBasedelegates
-(void)newDocumentCreatedID:(NSString *)docID {
    // NSLog(@"new Docment is created");
    // NSMutableArray *documentIDArr = [NSMutableArray new];
    // documentIDArr = [[[NSUserDefaults standardUserDefaults] objectForKey:StorDocIDArray] mutableCopy];
    // [documentIDArr addObject:docID];
    // [[NSUserDefaults standardUserDefaults]setObject:documentIDArr forKey:StorDocIDArray];
    
    
    CBLDocument *document = [CBObjects.sharedInstance.database documentWithID:docID];
    _currentDocument =document;
    MSSend *messageStorage = [MSSend sharedInstance];
    messageStorage.delegate = self;
    
    switch (messageType) {
        case 0:{
            Message *msg = [messageStorage sendMessage:_message onDocument:document groupId:_groupId];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self sendMessage:msg];
            }];
            
        }
            break;
            
        case 1:{
            
            MSSend *messageStorage = [MSSend sharedInstance];
            Message *msg = [messageStorage sendImage:sendImage onDocument:_currentDocument groupId:_groupId];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self sendMessage:msg];
            }];
            
        }break;
            
        case 2:{
            
            
            MSSend *messageStorage = [MSSend sharedInstance];
            Message *msg = [messageStorage sendVideo:filepathStore withThumbnailImage:thumImg onDocument:_currentDocument groupId:_groupId];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self sendMessage:msg];
            }];
            
            
        }break;
            
        case 3:{
            
            NSDictionary *dict =[[NSUserDefaults standardUserDefaults] objectForKey:@"savelatlog"];
            MSSend *messageStorage = [MSSend sharedInstance];
            Message *msg = [messageStorage sendLocation:dict[@"name"] address:dict[@"address"] latlog:dict[@"latlog"] onDocument:_currentDocument groupId:_groupId];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self sendMessage:msg];
            }];
            
            
        }break;
            
        case 4:{
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveContacDict"];
            MSSend *messageStorage = [MSSend sharedInstance];
            Message *msg = [messageStorage sendContact:dict onDocument:_currentDocument groupId:_groupId];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self sendMessage:msg];
            }];
            
        }break;
            
        case 5:{
            
            NSString *recVoice = [[NSUserDefaults standardUserDefaults]objectForKey:@"storeVoicedata"];
            MSSend *messageStorage = [MSSend sharedInstance];
            Message *msg = [messageStorage sendVoiceRecorder:recVoice onDocument:_currentDocument groupId:_groupId];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self sendMessage:msg];
            }];
            
            
            
        };
            break;
            
            
        default:
            break;
    }
    
}



-(void)sendImage:(UIImage *)image {
    
    if (_isFirsttime) {
        
        sendImage = image;
        _isFirsttime = NO;
        messageType = 1;
        [self newChatCreat];
        
    }else{
        
        
        
        
        
        MSSend *messageStorage = [MSSend sharedInstance];
        Message *msg = [messageStorage sendImage:image onDocument:_currentDocument groupId:_groupId];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self sendMessage:msg];
        }];
        
    }
    
}

-(void)sendVideo:(NSString *)filePath andThumbnailImage:(UIImage *)thumbnailImage {
    
    if (_isFirsttime) {
        
        filepathStore = filePath;
        thumImg = thumbnailImage;
        _isFirsttime = NO;
        messageType = 2;
        [self newChatCreat];
    }
    else{
        
        MSSend *messageStorage = [MSSend sharedInstance];
        Message *msg = [messageStorage sendVideo:filePath withThumbnailImage:thumbnailImage onDocument:_currentDocument groupId:_groupId];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self sendMessage:msg];
        }];
        
    }
    
}


-(void)sendLocation{
    
    NSDictionary *dict =[[NSUserDefaults standardUserDefaults] objectForKey:@"savelatlog"];
    
    if (_isFirsttime) {
        _isFirsttime = NO;
        messageType = 3;
        [self newChatCreat];
    }else{
        
        
        MSSend *messageStorage = [MSSend sharedInstance];
        Message *msg = [messageStorage sendLocation:dict[@"name"] address:dict[@"address"] latlog:dict[@"latlog"] onDocument:_currentDocument groupId:_groupId];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self sendMessage:msg];
        }];
        
    }
    
}

-(void)sendContact{
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveContacDict"];
    if (_isFirsttime) {
        _isFirsttime = NO;
        messageType = 4;
        [self newChatCreat];
    }else{
        MSSend *messageStorage = [MSSend sharedInstance];
        Message *msg = [messageStorage sendContact:dict onDocument:_currentDocument groupId:_groupId];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self sendMessage:msg];
            
        }];
    }
    
}


-(void)sendVoiceRecorder{
    NSString *recVoice = [[NSUserDefaults standardUserDefaults]objectForKey:@"storeVoicedata"];
    if (_isFirsttime) {
        _isFirsttime = NO;
        messageType = 5;
        [self newChatCreat];
    }else{
        MSSend *messageStorage = [MSSend sharedInstance];
        Message *msg = [messageStorage sendVoiceRecorder:recVoice onDocument:_currentDocument groupId:_groupId];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self sendMessage:msg];
        }];
    }
}


#pragma mark - Methods for sending an image


-(void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView {
    
    [self.view endEditing:YES];
    UIActionSheet *actionSheet;
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select ", @"Select ") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo ", @"Take Photo "),NSLocalizedString(@"Photo Library", @"Photo Library"),nil];///*,NSLocalizedString(@"Share location",@"Share location"),NSLocalizedString(@"Share Contact", @"Share Contact")*/,nil];
    
    //NSLocalizedString(@"Send Voice",@"Send Voice")
    
    [actionSheet showInView:self.view];
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag == (NSInteger)63559156945) {
        
        switch (buttonIndex) {
            case 0:
            {
                [self startAudioCall];
                break;
            }
            case 1:{
                [self startVideoCall];
            }
            default:
                break;
        }
        
        
    }else{
        
        switch (buttonIndex)
        {
            case 0:
            {
                [self cameraButtonClicked:nil];
                break;
            }
            case 1:
            {
                [self libraryButtonClicked:nil];
                break;
            }
            case 2:
            {
                //            [self sharelocationButtonCliked];
                break;
                
            }
            case 3:{
                
                //            [self shareContactButtonCliked];
            }
            case 4:{
                
                //[self shareVoiceRecorder];
            }
            default:
                break;
                
        }
    }
}

-(void)shareVoiceRecorder{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nav = [story instantiateViewControllerWithIdentifier:@"sendVoiceNavigtion"];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

-(void)shareContactButtonCliked{
    
    UIStoryboard *Story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // AllContactsTableViewController *contcVC =[Story instantiateViewControllerWithIdentifier:@"AllContactsTableViewController"];
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"comingFormChatScreenTocontac"];
    
    UINavigationController *nav = [Story instantiateViewControllerWithIdentifier:@"ContacNavigation"];
    [self.navigationController presentModalViewController:nav animated:YES];
    
}

-(void)cameraButtonClicked:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate =self;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:/*(NSString*)kUTTypeMovie,*/(NSString *)kUTTypeImage,nil];
        imagePicker.allowsEditing = YES;
//        imagePicker.videoMaximumDuration = 20;
//        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message", @"Message") message: NSLocalizedString(@"Camera is not available", @"Camera is not available") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)libraryButtonClicked:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate =self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage]; //@[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
//    picker.videoQuality = UIImagePickerControllerQualityTypeLow;
    picker.allowsEditing = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        
        //[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}


-(void)sharelocationButtonCliked{
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nav = [story instantiateViewControllerWithIdentifier:@"UINavigationController"];
    [self presentViewController:nav animated:YES completion:nil];
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
        NSString *moviePath = [videoUrl path];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *err = NULL;
        CMTime requestedTime = CMTimeMake(1, 60);     // To create thumbnail image
        CGImageRef imgRef = [generator copyCGImageAtTime:requestedTime actualTime:NULL error:&err];
        // NSLog(@"err = %@, imageRef = %@", err, imgRef);
        
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
        CGImageRelease(imgRef);    // MUST release explicitly to avoid memory leak
        [self sendVideo:moviePath andThumbnailImage:thumbnailImage];
        
    }else {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        //    NSData *data = UIImagePNGRepresentation(image);
        // NSLog(@"Image Info : %@",info);
        [self sendImage:image];
        
    }
    
}


- (NSDateFormatter *)DateFormatter {
    
    //EEE - day(eg: Thu)
    //MMM - month (eg: Nov)
    // dd - date (eg 01)
    // z - timeZone
    
    //eg : @"EEE MMM dd HH:mm:ss z yyyy"
    
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        //        formatter.dateFormat = @"dd MMM yyyy";
        [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    });
    return formatter;
}

- (NSDateFormatter *)DateFormatterProper {
    
    //EEE - day(eg: Thu)
    //MMM - month (eg: Nov)
    // dd - date (eg 01)
    // z - timeZone
    
    //eg : @"EEE MMM dd HH:mm:ss z yyyy"
    
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        //        formatter.dateFormat = @"dd MMM yyyy";
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return formatter;
}

- (NSString *)localDateFromGMTDate:(NSDate *)gmtDate{
    
    //EEE - day(eg: Thu)
    //MMM - month (eg: Nov)
    // dd - date (eg 01)
    // z - timeZone
    
    //eg : @"EEE MMM dd HH:mm:ss z yyyy"
    
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    });
    
    return [formatter stringFromDate:gmtDate];
}


-(void)previousMessagesAction:(id)sender {
    
    
    [self createArrayOfMessages];
    
    [self refreshMessagesReloadTable];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count - 20*(_previousMessageButtonPressCount - 1) inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
}


-(void)hideHeaderView {
    
    self.tableView.tableHeaderView = nil;
}



- (IBAction)navCallBtncliked:(id)sender {
    [self.view endEditing:YES];
    
        UIActionSheet *actionSheet;
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select ", @"Select ") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Audio Call", @"Audio Call"),NSLocalizedString(@"Video Call",@"Video Call"),nil];
        actionSheet.tag = ActionSheetTagForCall;
        [actionSheet showInView:self.view];
    
  
    
}

- (IBAction)navUsernameCliked:(id)sender {
    //    if (_groupId.length == 0) {
    //        NSString *nameCompareCall = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
    //
    //        self.receiverName =[NSString stringWithFormat:@"%@",[_groupMems firstObject]];
    //
    //        if([nameCompareCall isEqualToString:self.receiverName])
    //        {
    //            self.receiverName =[NSString stringWithFormat:@"%@",[_groupMems objectAtIndex:1]];
    //        }
    //
    //
    //
    //
    //        NSManagedObject *friend = [self getNameFromDb:[NSString stringWithFormat:@"%@",self.receiverName]];
    //
    //
    //        [self openProfileOfUsername:[friend valueForKey:@"memberName"]];
    //
    //    }else{
    //        [self performSegueWithIdentifier:@"gotoGroupInfo" sender:self];
    //    }
    
}

- (IBAction)groupInfoAction:(id)sender{
    [self.view endEditing:YES];

      [self performSegueWithIdentifier:@"gotoGroupInfo" sender:self];
}

-(NSManagedObject *)getNameFromDb :(NSString *)memberId
{
    for (int i=0; i<[_friendesList count]; i++) {
        
        NSManagedObject *friend = [self.friendesList objectAtIndex:i];
        
        if([[friend valueForKey:@"memberid"] isEqualToString:memberId])
        {
            
            
            return friend;
        }
    }
    return Nil;
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

-(void)openProfileOfUsername:(NSString *)selectedUserName {
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkingFriendsProfile = YES;
    newView.checkProfileOfUserNmae = selectedUserName;
    [self.navigationController pushViewController:newView animated:YES];
}

- (IBAction)userImageBtnCliked:(id)sender {
    [self.view endEditing:YES];
    
    window = [[UIApplication sharedApplication]keyWindow];
    
    imagBackView = [[UIView alloc] init];
    imagBackView.frame = CGRectMake(0,0,0,0);
    imagBackView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    
    imagBackView.backgroundColor = [UIColor whiteColor];
    [window addSubview:imagBackView];
    
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,64)];
    navView.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(201.0/255.0) blue:(232.0/255.0) alpha:1];
    [imagBackView addSubview:navView];
    
    UILabel *nameLbl;
    UIButton *navCancelBtn;
    //    if (_groupId.length>0) {
    //
    //       navCancelBtn =[[UIButton alloc]initWithFrame:CGRectMake(0,20,70,44)];
    //        nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(navCancelBtn.frame.origin.x+navCancelBtn.frame.size.width,20,navView.frame.size.width-navCancelBtn.frame.size.width-navCancelBtn.frame.size.width,44)];
    //
    //    }else{
    //
    //        navCancelBtn =[[UIButton alloc]initWithFrame:CGRectMake(0,20,70,44)];
    //        nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,20,navView.frame.size.width,44)];
    //    }
    
    navCancelBtn =[[UIButton alloc]initWithFrame:CGRectMake(0,20,70,44)];
    nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(navCancelBtn.frame.origin.x+navCancelBtn.frame.size.width,20,navView.frame.size.width-navCancelBtn.frame.size.width-navCancelBtn.frame.size.width,44)];
    
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.text =_userName;
    nameLbl.font = [UIFont fontWithName:@"Roboto-Bold" size:17.0];
    nameLbl.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:nameLbl];
    
    
    [navCancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [navCancelBtn addTarget:self action:@selector(navCancelBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:navCancelBtn];
    
    
    
    //  UIImageView *userImagView = [[UIImageView alloc] initWithFrame:CGRectMake(0,64+50,self.view.frame.size.width,self.view.frame.size.height-100-50)];
    UIImageView *userImagView = [[UIImageView alloc]init];
    userImagView.tag = 134565634;
    userImagView.frame  = CGRectMake(self.view.frame.size.width-60,20,40,40);
    
    userImagView.image = _StoreImage;
    if (_StoreImage == nil) {
        userImagView.image = [UIImage imageNamed:@"contacts_info_image_frame"];
    }
    [imagBackView addSubview:userImagView];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect fram = CGRectZero;
        fram = CGRectMake(0,64+50,self.view.frame.size.width,self.view.frame.size.height-100-50);
        userImagView.frame = fram;
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}




-(void)startVideoCall{
    
    // Kick off the video call.
    //  NSLog(@"call button is pressed");
    randomString = [self randomStringWithLength:20];
    /* For debug purpose here - Call the socket API here */
    // NSDictionary *data = @{@"to" : _receiverName,
    //  @"call_id":randomString};
    
    NSString *nameCompareCall = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
    
    self.receiverName =[NSString stringWithFormat:@"%@",[_groupMems firstObject]];
    
    if([nameCompareCall isEqualToString:self.receiverName])
    {
        self.receiverName =[NSString stringWithFormat:@"%@",[_groupMems objectAtIndex:1]];
    }
    
    NSDictionary *data = @{@"to" : _receiverName,
                           @"call_id":randomString,@"callType":@"1"};
    
    client = [PicogramSocketIOWrapper sharedInstance];
    [self.client callUser:data];
    
    videoCallViewController *videoCallViewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"videoCallViewController"];
    videoCallViewController.infoDictionary=data;
    videoCallViewController.isDialing=YES;
    videoCallViewController.modalTransitionStyle =
    UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:videoCallViewController
                       animated:YES
                     completion:nil];
}

//Initiate Audio Call
-(void)startAudioCall
{
    randomString = [self randomStringWithLength:20];
    /* For debug purpose here - Call the socket API here */
    
    
    NSString *nameCompareCall = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
    
    self.receiverName =[NSString stringWithFormat:@"%@",[_groupMems firstObject]];
    
    if([nameCompareCall isEqualToString:self.receiverName])
    {
        self.receiverName =[NSString stringWithFormat:@"%@",[_groupMems objectAtIndex:1]];
    }
    
    
    
    
    NSDictionary *data = @{@"to" : _receiverName,
                           @"call_id":randomString,@"callType":@"0"};
    
    
    client = [PicogramSocketIOWrapper sharedInstance];
    [self.client callUser:data];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    AudioCallViewController *audioController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AudioCallViewController"];
    audioController.dataDictionary=[NSMutableDictionary dictionaryWithDictionary:data];
    audioController.isDialing=YES;
    audioController.modalTransitionStyle =
    UIModalTransitionStyleCrossDissolve;
    [self presentViewController:audioController animated:YES completion:nil];
    
}


-(NSString *) randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString1 = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString1 appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString1;
    
    return @"123412csasda";
}




-(void)createMessagesArray {
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    _docDictNew = [messageStorage getDetailsForDocument:_currentDocument];
    //  NSArray *messages;
    NSArray *allMessages =  _docDictNew[@"messages"];
    _jsonMessages = [NSMutableArray arrayWithArray:allMessages];
    
    [self.dataSource removeAllObjects];
    _previousMessageButtonPressCount++;
    _mediaList = [messageStorage createMediaListfromMessages:allMessages];
}

-(void)navCancelBtnCliked:(UIButton*)sender{
    
    UIImageView *imagView = (UIImageView *)[imagBackView viewWithTag:134565634];
    [UIView animateWithDuration:0.2 animations:^{
        
        imagView.frame = CGRectMake(self.view.frame.size.width-60,25,40,40);
        
    } completion:^(BOOL finished) {
        
        [imagBackView removeFromSuperview];
    }];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"contactInfo"]) {
        
        //[self createMessagesArray];
        
        NSString *Status = [self gotStatusFormDB:_receiverName];
        if ([Status isEqualToString:@""]) {
            Status =@"SGV5IHRoZXJlICEgSSBhbSB1c2luZyBTdXA=";
        }
        NSMutableDictionary *dict =[NSMutableDictionary new];
        [dict setValue:_userName forKey:@"fullName"];
        [dict setValue:_userImageStr forKey:@"profilePic"];
        [dict setValue:Status forKey:@"status"];
        [dict setValue:_receiverName forKey:@"supNumber"];
        
        // [self createArrayOfMessages];
        //        ContactDetailsTableViewController *contacDetailView = [segue destinationViewController];
        //        contacDetailView.controller = @"chatVC";
        //       // contacDetailView.mediaList = _mediaList;
        //        contacDetailView.iscomingFrom = ComingFromChatView;
        //        contacDetailView.documentID = _currentDocument.documentID;
        //        contacDetailView.dataDictionary = dict;
        
    }
    else if ([segue.identifier isEqualToString:@"chatVCtoLocationVC"]) {
        
        //        ShowLocationViewController *showLocation = [segue destinationViewController];
        //        showLocation.storeLocationStr = storeLocation;
        
    }
    else if ([segue.identifier isEqualToString:@"chatVCToshowcontacVC"]){
        
        //        ShowContactTableViewController *showContact = [segue destinationViewController];
        //        showContact.contactStr = storeContact;
        
    }
    else if ([segue.identifier isEqualToString:@"gotoShowVoice"]){
        //        ShowVoiceRecorderViewController *showVoice = [segue destinationViewController];
        //        showVoice.voiceData = storeVoice;
    }
    else if ([segue.identifier isEqualToString:@"gotoGroupInfo"]){
        
        GroupInfoTableViewController *gpInfo = [segue destinationViewController];
        gpInfo.groupId = _groupId;
        gpInfo.groupPic = _userImageStr;
        gpInfo.groupName = _userName;
        gpInfo.groupCreatedBy = _gpCreatedBy;
        gpInfo.documentID = _currentDocument.documentID;
        gpInfo.groupMembers = _groupMems;
        gpInfo.groupAdmins = _groupAdmin;
        gpInfo.isRemoveFromgp = _isRemoveFromgp;
        
        gpInfo.OncompleteChangeInGpData=^(NSString *groupName,NSString *grouPpic,NSArray *gpMem,NSArray* gpAdmins,NSString *isRemoveFromgp){
            
            _userImageStr = grouPpic;
            [self getUserImage];
            [_navUserNameBtn setTitle:groupName forState:UIControlStateNormal];
            _groupMems = gpMem;
            _groupAdmin = gpAdmins;
            
            
            if (![_userName isEqualToString:groupName]) {
                [_navUserNameBtn setTitle:groupName forState:UIControlStateNormal];
            }
            if (![_userImageStr isEqualToString:grouPpic]) {
                _userImageStr = grouPpic;
                [self getUserImage];
            }
            if (_groupMems.count != gpMem.count) {
                _groupMems = gpMem;
            }
            if (_groupAdmin.count != gpAdmins.count) {
                _groupAdmin = gpAdmins;
            }
            
            
            _isRemoveFromgp = isRemoveFromgp;
            
        };
    }
    
    
}

/*show user image on Navtionbar*/
-(void)getUserImage{
    
    NSString *imageURL = _userImageStr;
    if(imageURL==nil || imageURL==(id)[NSNull null] || [imageURL isEqualToString:@"(null)"])
    {
        
        [_userNavPic setBackgroundImage:[UIImage imageNamed:@"contacts_info_image_frame"] forState:UIControlStateNormal];
        _StoreImage = _userNavPic.currentImage;
    }
    else{
        
        NSURL *imageUrl =[NSURL URLWithString:imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"contacts_info_image_frame"];
        [_userNavPic.imageView setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  [_userNavPic setBackgroundImage:image forState:UIControlStateNormal];
                                                  _userNavPic.layer.cornerRadius = 20;
                                                  _userNavPic.clipsToBounds = YES;
                                                  _StoreImage = image;
                                                  
                                              } failure:nil];
    }
}



-(NSString *)getLastSeenFormate:(NSString *)lastSeenTime{
    
    if (lastSeenTime == (id)[NSNull null]) {
        return @"";
    }
    
    //   // NSLog(@"lastseeen =%@",lastSeenTime);
    //
    //
    //    if ([lastSeenTime isEqual:[NSNull null]] || lastSeenTime.length ==0 || lastSeenTime == nil || [lastSeenTime isEqualToString:@"<null>"]) {
    //
    //    }else{
    //
    //
    //   // NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:[NSDate date]];
    //    /*
    //    NSString *time = @"09:45:31";
    //    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    //
    //    [df setDateFormat:@"HH:mm:ss"];
    //    */
    //
    ////
    ////    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    ////    [formatter setDateFormat:@"HH:mm:ss"];//use the formatted as per your requirement.
    ////
    ////    //Optionally for time zone converstions
    ////    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    ////
    ////    NSString *localTimeDateString = [formatter stringFromDate:localDateTime];
    //
    //
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";
    //
    //    NSTimeZone *gmt = [NSTimeZone systemTimeZone];
    //    [dateFormatter setTimeZone:gmt];
    //     NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    //
    //
    //    NSArray *arr = [lastSeenTime componentsSeparatedByString:@"-"];
    //   // NSLog(@"arr =%@",arr);
    //
    //
    //    NSString *time = [arr lastObject];
    //    NSString * newString = [time substringWithRange:NSMakeRange(3,[time length]-3)];
    //    NSString *timeStr = [newString substringToIndex:5];
    //
    //    NSString *netDateStr = [NSString stringWithFormat:@"%@/%@/%@ %@",[[arr lastObject] substringToIndex:2],[arr objectAtIndex:1],[arr firstObject],timeStr];
    //
    //    NSString *gmtDateString = netDateStr;//@"08/03/2016 09:45";
    //
    //    NSDateFormatter *df = [NSDateFormatter new];
    //    [df setDateFormat:@"dd/MM/yyyy HH:mm"];
    //
    //    //Create the date assuming the given string is in GMT
    //    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    //    NSDate *date = [df dateFromString:gmtDateString];
    //
    //    //Create a date string in the local timezone
    //    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    //    NSString *localDateString = [df stringFromDate:date];
    //   // NSLog(@"date = %@", localDateString);
    //
    //
    //
    //
    //
    //    /*
    //
    //    NSString *dateAsString = lastSeenTime;
    //
    //    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    //
    //    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //    [df setTimeZone:gmt];
    //
    //    NSDate *myDate = [df dateFromString: dateAsString];
    //
    //    NSLog(@"my date =%@",myDate);
    //    */
    //
    //
    //
    //
    //
    // //   NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    //
    //  //  NSTimeInterval localTimeInterval = [localDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    //
    //  //  NSDate *localCurrentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:localTimeInterval];
    //
    //
    ////    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    ////    [formater setDateStyle:NSDateFormatterFullStyle];
    ////    [formater setTimeStyle:NSDateFormatterFullStyle];
    ////
    ////  //  formater.dateFormat =@"YYYY-MM-dd HH:mm:ss";
    ////  NSDate *date12 = [formater dateFromString:lastSeenTime];
    //
    //   // 2016/3/2 12:16 PM
    //
    ////    NSString *lastMsgDateStr =[NSString stringWithFormat:@"%@",lastSeenTime];
    ////    lastMsgDateStr = [lastMsgDateStr substringToIndex:11];
    ////
    ////    NSDate *todayDate = [NSDate date];
    ////    NSString *todayStr = [NSString stringWithFormat:@"%@",todayDate];
    ////    todayStr = [todayStr substringToIndex:11];
    ////
    ////    if ([lastMsgDateStr isEqualToString:todayStr]){
    ////        NSString *cutMsg = lastSeenTime;
    ////        cutMsg=  [cutMsg substringWithRange:NSMakeRange(11,lastSeenTime.length-14)];
    ////
    ////        NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    ////        [dateformater setDateFormat:@"HH:mm"];
    ////        NSDate *date = [dateformater dateFromString:cutMsg];
    ////        dateformater.dateFormat = @"hh:mm a";
    ////        cutMsg = [dateformater stringFromDate:date];
    ////
    ////        return [NSString stringWithFormat:@"Last seen at today %@",cutMsg];
    ////        }
    //
    //
    //        return [NSString stringWithFormat:@"Last seen at %@",localDateString];
    //
    //    }
    //
    //    return @"Offline";
    //
    
    //======= = - - ------======================----====///////////////--===
    
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
    
    
    //    NSDate *todayDate = [NSDate date];
    //    NSString *todayStr = [NSString stringWithFormat:@"%@",todayDate];
    //    todayStr = [todayStr substringToIndex:11];
    //    todayStr = [todayStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    netDateSt = [netDateSt stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // if ([todayStr isEqualToString:netDateSt]) {
    
    NSString *cutMsg = localDateString;
    cutMsg=  [cutMsg substringWithRange:NSMakeRange(11,localDateString.length-11)];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    dateformater.dateFormat=@"HH:mm";
    NSDate *date12 = [dateformater dateFromString:cutMsg];
    dateformater.dateFormat = @"hh:mm a";
    cutMsg = [dateformater stringFromDate:date12];
    
    NSString *temp = localDateString ;
    temp = [temp substringToIndex:11];;
    
    if ([temp isEqualToString:@"(null)"]) {
        return @"";
    }
    
    return  [NSString stringWithFormat:@"Last seen at %@ %@",temp,cutMsg];
}

-(NSString *)gotStatusFormDB:(NSString *)receiverSupNo{
    //  NSString *Str =[NSString stringWithFormat:@"supNumber beginswith[c] '%@'",receiverSupNo];
    // NSArray *array = [Database dataFromTable:@"Favorites" condition:Str orderBy:nil ascending:YES];
    //    
    //    NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",receiverSupNo];
    //    NSArray *favAll = [_favDataBase getDataFavDataFromDB];
    //    NSArray *array = [favAll filteredArrayUsingPredicate:predi];
    //    
    //    NSDictionary *fav;
    //    if (array.count>0) {
    //        fav = [array objectAtIndex:0];
    //        return [NSString stringWithFormat:@"%@",fav[@"status"]];
    //    }
    return @"";
}


-(void)openSendContacScreen{
    
    // NSLog(@"open share contac screen");
    UIStoryboard *Story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nav = [Story instantiateViewControllerWithIdentifier:@"openSendContacScreen"];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (IBAction)backButtonAction:(id)sender {
    HomeScreenTabBarController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeScreenTabBarController"];
    
    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}
@end
