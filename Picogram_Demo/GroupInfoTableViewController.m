//
//  GroupInfoTableViewController.m
//  Sup
//
//  Created by Rahul Sharma on 5/18/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "GroupInfoTableViewController.h"
#import "PicogramSocketIOWrapper.h"
#import "GroupInfoTableViewCell.h"
#import "GroupInfoMemebersTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "ProgressIndicator.h"
//#import "UploadFile.h"
#import "AppDelegate.h"
//#import "Favorites.h"
#import "Database.h"
#import "suggestionViewController.h"
#import "AddSingleMemberTableViewController.h"
#import "MessageStorage.h"
#import "AllMediaViewController.h"
#import "EditGroupnameTableViewController.h"
//#import "ProgressIndicator/ProgressIndicator.h"
#import "FavDataBase.h"
#import "Helper.h"
#import "WebServiceHandler.h"

#define photoPickActionSheet 357957957
#define groupOptionActionSheet 9859257
#define groupOptionActionSheetAlredyadmin 8929359509
#define groupOptionActionSheetNotadmin 892935950932
#define leveGroupalert 83769346873687
#define clearChatalert 9467395784697
#define emailChatActionSheet 748677246899

#define FreshPhoto @"Take a fresh photo"
#define FromLib @"Pick from library"
#define CancelText @"Cancel"

@interface GroupInfoTableViewController ()<MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,MessageStorageDelegate,UIAlertViewDelegate>{
    
    NSString *storegpCreatedByname;
    NSString *storeSelecteduserNum;
    BOOL isUserAdmin;
    BOOL isUserMember;
//    UISwitch *switchView;
}



@property (strong,nonatomic)NSMutableArray *gpFavoriteArr;
@property (strong, nonatomic) NSMutableArray *mediaList;
@property (strong, nonatomic) FavDataBase *favDataBase;


@end

@implementation GroupInfoTableViewController
@synthesize OncompleteChangeInGpData;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    _favDataBase = [FavDataBase sharedInstance];
    isUserAdmin = NO;
    [self.navigationItem setTitle:@"Details"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateGroupDataInDB:) name:@"updateGroupDataDB" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateGroupName:) name:@"updateGroupName" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(leaveGroupresponse:) name:@"LeaveGroup" object:nil];
    
    [self getDataFromDB];
    
    [_tableViewInfo reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    NSLog(@"memebrs arr =%@",_gpFavoriteArr);
    [self getGroupCreatByNameFromDB];
    
    [self checkUserIsadminorNot];
    [self checkUserIsMemeberorNot];
    
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

-(void)checkUserIsadminorNot{
    
    isUserAdmin = NO;
    
    for (int i= 0; i<_groupAdmins.count; i++) {
        if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] isEqualToString:_groupAdmins[i]]) {
            isUserAdmin = YES;
        }
    }
    
}

-(void)checkUserIsMemeberorNot{
    
    isUserMember = NO;
    for (int i=0; i<_groupMembers.count; i++) {
        if(self.stringForuserDetails.length == 0)
        {
            self.stringForuserDetails = [NSString stringWithFormat:@"%@",self.groupMembers[i]];
        }
        else{
            self.stringForuserDetails = [NSString stringWithFormat:@"%@,%@",self.stringForuserDetails ,self.groupMembers[i] ];
        }
        
        if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] isEqualToString:_groupMembers[i]]) {
            isUserMember = YES;
        }
        
        
    }
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Getting Group Members Details..."];
    
    NSDictionary *requestDict = @{@"memberId"     : self.stringForuserDetails,
                                  @"token"        :[Helper userToken],
                                  };
    [WebServiceHandler getUserDetailsbyID:requestDict andDelegate:self];
}

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    if (error) {
        
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        
        return;
    }
    
    
    NSDictionary *responseDict = (NSDictionary*)response;
    
    if (requestType == RequestTypegetUserById ) {
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        self.dataToShow = response[@"data"];
        [_tableViewInfo reloadData];
    }
    
}

-(void)getGroupCreatByNameFromDB{
    
    NSString *usernum = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    if ([usernum isEqualToString:_groupCreatedBy]) {
        storegpCreatedByname = @"You";
    }else
        
        if (_groupCreatedBy.length>0) {
            
            NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",_groupCreatedBy];
            NSArray *allFav = [_favDataBase getDataFavDataFromDB];
            NSArray *arr = [allFav filteredArrayUsingPredicate:predi];
            
            if (arr.count>0) {
                NSDictionary *fav = [arr firstObject];
                storegpCreatedByname = fav[@"fullName"];
            }else{
                storegpCreatedByname = _groupCreatedBy;
            }
            
            
        }
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSNumber *num =  [[NSUserDefaults standardUserDefaults]objectForKey:@"sendRequestFrogpName"];
    if (num.boolValue == YES) {
        [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading.."];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"sendRequestFrogpName"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        _groupName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"storeGroupName"]];
        PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
        [client sendRequestToUpdateGroupName:_groupName groupId:_groupId documentId:_documentID];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //    NSNumber *num =  [[NSUserDefaults standardUserDefaults]objectForKey:@"sendRequestFrogpName"];
    //    if (num.boolValue == YES) {
    //        [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading.."];
    //        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"sendRequestFrogpName"];
    //        [[NSUserDefaults standardUserDefaults]synchronize];
    //        _groupName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"storeGroupName"]];
    //        PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
    //        [client sendRequestToUpdateGroupName:_groupName groupId:_groupId documentId:_documentID];
    //    }
    
}

-(void)getDataFromDB{
    
    _gpFavoriteArr  = [NSMutableArray new];
    
    for (int i=0; i<_groupMembers.count; i++) {
        
        NSPredicate *predi = [NSPredicate predicateWithFormat:@"supNumber == %@",_groupMembers[i]];
        NSArray *allFav = [_favDataBase getDataFavDataFromDB];
        
        NSArray *arr = [allFav filteredArrayUsingPredicate:predi];
        
        if (arr.count>0) {
            NSDictionary *fav = [arr firstObject];
            NSDictionary *dict = @{@"fullName":fav[@"fullName"],
                                   @"image":fav[@"image"],
                                   @"status":fav[@"status"],
                                   @"supNumber":fav[@"supNumber"]
                                   };
            [_gpFavoriteArr addObject:dict];
        }else{
            
            NSDictionary *dict = @{@"fullName":_groupMembers[i],
                                   @"image":@"",
                                   @"status":@"",
                                   @"supNumber":_groupMembers[i]
                                   };
            
            if (![_groupMembers[i] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]]) {
                [_gpFavoriteArr addObject:dict];
            }
            
            
        }
    }
    
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger noRow =0;
    if (section == 0) {
        noRow = 2;
    }else if (section == 1){
        
        noRow = 1+_gpFavoriteArr.count;
        if (isUserAdmin == YES  && [_groupMembers count]>2) {
            noRow = 2+_gpFavoriteArr.count;
        }
        
    }else if (section == 2){
        
        noRow = 1;
    }else if (section == 3){
        noRow = 2;
    }
    return noRow;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section ==1) {
        
        GroupInfoMemebersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupInfoMembersCell" forIndexPath:indexPath];
        
        if (isUserAdmin == YES && [_groupMembers count]>2) {
            
            if (indexPath.row ==0 ) {
                cell.mainLbl.hidden = YES;cell.imagePic.hidden = YES;cell.addmemLbl.hidden = NO;
                if (isUserMember == YES) {
                    cell.addmemLbl.text =@"Add People...";
                }else{
                    cell.addmemLbl.text = @"you are no longer a participant in this group";
                     cell.subLbl.hidden = YES;
                }
                cell.subLbl.hidden = YES;
                cell.groupAdminlbl.hidden = YES;
                
            }else{
                
                cell.mainLbl.hidden = NO;
                cell.subLbl.hidden = NO;
                cell.imagePic.hidden = NO;
                cell.addmemLbl.hidden = YES;
                [self fillDataInSection1:cell  indexPath:indexPath check:1];
            }
        }else{
            
            [self fillDataInSection1:cell indexPath:indexPath check:0];
        }
        
        return cell;
        
    }
    else{
        
        GroupInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupInfoCell" forIndexPath:indexPath];
        if (indexPath.section ==0 && indexPath.row ==0) {
            [self hideUnhideViewForSection0:cell];
            
        }
        else
        {[self hideUnhideViewForSection0Row1:cell indexPath:indexPath];
        }
        
        return cell;
    }
    
    return nil;
    
}

-(void)fillDataInSection1:(GroupInfoMemebersTableViewCell*)cell indexPath:(NSIndexPath*)indexPath check:(int)check{
    
    NSDictionary *friend;
    
    if (indexPath.row == check) {
        
        if (isUserMember == NO) {
            
            cell.mainLbl.hidden = YES;cell.imagePic.hidden = YES;cell.addmemLbl.hidden = NO;
            cell.addmemLbl.text = @"you are no longer a participant in this group";
            cell.addmemLbl.font = [UIFont fontWithName:@"Roboto" size:14];
            cell.addmemLbl.textColor = [UIColor redColor];
            cell.groupAdminlbl.hidden = YES;
            
            
            
        }else{
            cell.subLbl.hidden = YES;
            cell.mainLbl.text = @"You";
            //        cell.subLbl.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Status"]];
            //        if ([cell.subLbl.text isEqualToString:@"(null)"]) {
            //            cell.subLbl.text = @"***no status***";
            //        }
            cell.groupAdminlbl.hidden = YES;
            
            if (isUserAdmin == YES && [_groupMembers count]>2) {
                cell.groupAdminlbl.hidden = NO;
            }
            
            NSString *pic = [[NSUserDefaults standardUserDefaults]
                                    stringForKey:@"userprofilePicUrl"];
            
            
            if(pic== nil || pic==(id)[NSNull null] || [pic isEqualToString:@"(null)"] || [pic isEqualToString:@"defaultUrl"])
            {
                cell.imagePic.image = [UIImage imageNamed:@"DefaultContactImage"];
            }
            else{
                NSURL *imageUrl =[NSURL URLWithString:pic];
                NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
                UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
                cell.imagePic.image = placeholderImage;
                cell.self.imagePic.layer.cornerRadius = cell.self.imagePic.frame.size.width / 2;
                cell.self.imagePic.clipsToBounds = YES;
                [cell setNeedsLayout];
                
                [cell.imagePic setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  cell.imagePic.image = image;
                                                  cell.self.imagePic.layer.cornerRadius = cell.self.imagePic.frame.size.width / 2;
                                                  cell.self.imagePic.clipsToBounds = YES;
                                                  [cell setNeedsLayout];
                                              } failure:nil];
                
            }
            
        }
        
    }
    else{
        
        if (check == 0) {
            check = 1;
        }else check = 0;
        
        
        
        NSDictionary *fav = [_gpFavoriteArr objectAtIndex:indexPath.row - 2+check];
        //        cell.mainLbl.text = fav[@"fullName"];
        //        if (cell.mainLbl.text.length==0) {
        
        
        friend = [self getNameFromDb:[NSString stringWithFormat:@"%@",fav[@"supNumber"]]];
        
        NSLog(@"%@",friend);
        NSString *fullName = [NSString stringWithFormat:@"%@",friend[@"memberFullName"]];
         cell.mainLbl.text =   [NSString stringWithFormat:@"%@",friend[@"membername"]];
        if(friend[@"memberFullName"] && ![fullName isEqualToString:@"<null>"] && !(fullName.length == 0) )
        {
            cell.subLbl.hidden = NO;
            cell.subLbl.text = [NSString stringWithFormat:@"%@",friend[@"memberFullName"]];
        }
        else
        {
            cell.subLbl.hidden = YES;
           cell.subLbl.text= @"";
        }
        cell.groupAdminlbl.hidden = YES;
        for (int i= 0; i<_groupAdmins.count; i++) {
            
            if ([fav[@"supNumber"] isEqualToString:_groupAdmins[i]]) {
                if([_groupMembers count]>2)
                cell.groupAdminlbl.hidden = NO;
            }
            
        }
        
        
//        NSString *decodeStatus = [fav[@"status"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//        decodeStatus = [ChatHelper decodedStringFrom64:decodeStatus];
//        cell.subLbl.text = decodeStatus;
        
        NSString *pic = friend[@"memberProfilePicUrl"];
        
        if(pic== nil || pic==(id)[NSNull null] || [pic isEqualToString:@"(null)"])
        {
            cell.imagePic.image = [UIImage imageNamed:@"DefaultContactImage"];
        }
        else{
            NSURL *imageUrl =[NSURL URLWithString:pic];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
            UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
            cell.imagePic.image = placeholderImage;
            cell.self.imagePic.layer.cornerRadius = cell.self.imagePic.frame.size.width / 2;
            cell.self.imagePic.clipsToBounds = YES;
            [cell setNeedsLayout];
            
            [cell.imagePic setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              cell.imagePic.image = image;
                                              cell.self.imagePic.layer.cornerRadius = cell.self.imagePic.frame.size.width / 2;
                                              cell.self.imagePic.clipsToBounds = YES;
                                              [cell setNeedsLayout];
                                          } failure:nil];
            
        }
        
        
        
        
    }
    
    
    
}


//-(NSManagedObject *)getNameFromDb :(NSString *)memberId
//{
//    for (int i=0; i<[_friendesList count]; i++) {
//
//    NSManagedObject *friend = [self.friendesList objectAtIndex:i];
//
//        if([[friend valueForKey:@"memberid"] isEqualToString:memberId])
//        {
//            NSLog(@"%@          =          %@",memberId,[friend valueForKey:@"memberid"]);
//            return friend;
//        }
//    }
//    return Nil;
//}


-(NSDictionary*)getNameFromDb:(NSString*)memberId
{
    for (int i=0; i<[_dataToShow count]; i++) {
        NSDictionary *detail = [_dataToShow objectAtIndex:i];
        if([memberId isEqualToString:[NSString stringWithFormat:@"%@",detail[@"memberId"]]])
        {
            return detail;
        }
    }
    return nil;
}

-(BOOL)checkSelectedNumberisAdminOrnot:(NSString*)number{
    
    for (int i= 0; i<_groupAdmins.count; i++) {
        if ([number isEqualToString:_groupAdmins[i]]) {
            return YES;
        }
    }
    
    
    return NO;
}

-(void)hideUnhideViewForSection0:(GroupInfoTableViewCell*)cell{
    
    cell.gpImage.hidden = NO;
    cell.gpName.hidden = NO;
    cell.groupNameOutlet.hidden = NO;
    cell.upperLine.hidden  = NO;
    cell.lowerLine.hidden = NO;
    cell.maintitleLbl.hidden = YES;
    cell.gpImage.layer.cornerRadius = cell.gpImage.frame.size.height /2;
    cell.gpImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageCliked)];
    [cell.gpImage addGestureRecognizer:tap];
    cell.gpImage.layer.masksToBounds = YES;
    [cell.gpName setTitle:_groupName forState:UIControlStateNormal];
    [cell.gpName addTarget:self action:@selector(editGropNameCliked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if(_groupPic== nil || _groupPic==(id)[NSNull null] || [_groupPic isEqualToString:@"(null)"])
    {
        cell.gpImage.image = [UIImage imageNamed:@"DefaultContactImage"];
    }
    else{
        NSURL *imageUrl =[NSURL URLWithString:_groupPic];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
        cell.gpImage.image = placeholderImage;
        cell.self.gpImage.layer.cornerRadius = cell.self.gpImage.frame.size.width / 2;
        cell.self.gpImage.clipsToBounds = YES;
        [cell setNeedsLayout];
        
        [cell.gpImage setImageWithURLRequest:request
                            placeholderImage:placeholderImage
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         cell.gpImage.image = image;
                                         cell.self.gpImage.layer.cornerRadius = cell.self.gpImage.frame.size.width / 2;
                                         cell.self.gpImage.clipsToBounds = YES;
                                         [cell setNeedsLayout];
                                     } failure:nil];
        
    }
    
    
    
    
}
-(void)hideUnhideViewForSection0Row1:(GroupInfoTableViewCell*)cell  indexPath:(NSIndexPath*)indexPath{
//    switchView.hidden = YES;
    cell.maintitleLbl.hidden = NO;
    cell.gpImage.hidden = YES;
    cell.groupNameOutlet.hidden = YES;
    cell.gpName.hidden = YES;
    cell.upperLine.hidden = YES;
    cell.lowerLine.hidden = YES;
//    if (indexPath.section == 0 && indexPath.row ==1) {
//        cell.maintitleLbl.text = @"Group Notification";
//        cell.maintitleLbl.textAlignment = UITextAlignmentLeft;
////        switchView.hidden = NO;
////        switchView = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width - 60, 5, 0, 0)];
////        cell.accessoryView = switchView;
////        [switchView setOn:NO animated:NO];
////        [switchView addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }else
        if (indexPath.section == 0 && indexPath.row ==1) {
        cell.maintitleLbl.text = @"View All Media";
        cell.maintitleLbl.textAlignment = UITextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.maintitleLbl.textColor = [UIColor blackColor];
    }else if (indexPath.section == 2 && indexPath.row ==0){
//        switchView.hidden = YES;
        cell.maintitleLbl.text = @"Export Chat";
        cell.maintitleLbl.textAlignment = UITextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.maintitleLbl.textColor = [UIColor blackColor];
    }else if (indexPath.section == 3 && indexPath.row == 0){
//        switchView.hidden = YES;
        cell.maintitleLbl.text = @"Clear Chat";
        cell.maintitleLbl.textAlignment = UITextAlignmentCenter;
        cell.maintitleLbl.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if (indexPath.section == 3 && indexPath.row == 1){
//        switchView.hidden = YES;
        cell.maintitleLbl.text = @"Exit Group";
        cell.maintitleLbl.textAlignment = UITextAlignmentCenter;
        if (isUserMember == YES) {
            cell.maintitleLbl.textColor =[UIColor redColor];
        }else{
            cell.maintitleLbl.textColor =[UIColor lightGrayColor];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section ==0 && indexPath.row == 1) {
        
        [self createMessagesArray];
        ProgressIndicator *progressIndicator = [ProgressIndicator sharedInstance];
        [progressIndicator showPIOnView:self.view withMessage:@"Loading..."];
        [self performSegueWithIdentifier:@"groupMediaseuge" sender:self];
        
    }
    
    if (indexPath.section == 3 && indexPath.row ==1) {
        
        if (isUserMember ==YES) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to leave this group?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            alert.tag = (int)leveGroupalert;
            [alert show];
        }
        
        
    }
    if (indexPath.section == 3 && indexPath.row == 0)  {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure want to Clear Chat" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alertView.tag = (int)clearChatalert ;
        [alertView show];
        
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        
        UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"Attaching media will generate a larger chat archive." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Without Media", nil];
        action.tag = (int)emailChatActionSheet;
        [action showInView:self.view];
        
    }
    
    
    
    if (isUserAdmin == YES && [_groupMembers count]>2) {
        if (indexPath.section == 1 && indexPath.row == 0)
            [self performSegueWithIdentifier:@"gotoAddsingleMem" sender:self];
        if (indexPath.section == 1 && indexPath.row !=0 && indexPath.row !=1){
            
            NSDictionary *fav = [_gpFavoriteArr objectAtIndex:indexPath.row - 2];
            storeSelecteduserNum = fav[@"supNumber"];
            BOOL isSelctedNumAdmin = [self checkSelectedNumberisAdminOrnot:fav[@"supNumber"]];
            
            if (isSelctedNumAdmin == YES) {
                
                UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove From Group", nil];
                sheet.tag = (int)groupOptionActionSheetAlredyadmin;
                [sheet showInView:self.view];
                
                
            }else{
                
                UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Make Group Admin",@"Remove From Group", nil];
                sheet.tag = (int)groupOptionActionSheetNotadmin;
                [sheet showInView:self.view];
                
            }
            
            
            
        }
        
    }else{
        
        
        if (indexPath.section == 1 && indexPath.row !=0 ){
            
            //            Favorites *fav = [_gpFavoriteArr objectAtIndex:indexPath.row - 1];
            //            storeSelecteduserNum = fav.supNumber;
            //
            //            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Make Group Admin", nil];
            //            sheet.tag =groupOptionActionSheet;
            //            [sheet showInView:self.view];
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    if (section == 0)
    //        return 1.0f;
    return 30.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    if (indexPath.section == 0 && indexPath.row ==0) {
    //        return 100.0;
    //    }
    return 47.0;
    
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    NSString *Str = @"";
    if (section == 3) {
        Str = [NSString stringWithFormat:@"Group Created By %@",storegpCreatedByname];
    }
    
    return Str;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString *Str = @"";
    if (section == 1) {
        if (isUserMember == YES) {
            Str =[NSString stringWithFormat:@"MEMBERS: %u",_gpFavoriteArr.count+1];
        }else{
            Str =[NSString stringWithFormat:@"MEMBERS: %lu",(unsigned long)_gpFavoriteArr.count];
        }
        
    }
    return Str;
    
}
-(void)imageCliked{
    
    if (isUserMember ==NO) {
        
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CancelText destructiveButtonTitle:nil otherButtonTitles:FreshPhoto,FromLib, nil];
        actionSheet.tag = photoPickActionSheet;
        [actionSheet showInView:self.view];
    }
    
}

- (void)changeSwitch:(id)sender{
    if([sender isOn]){
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
    } else{
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"gotoAddsingleMem"]) {
        
        AddSingleMemberTableViewController *single = [segue destinationViewController];
        single.groupName = _groupName;
        single.groupMembers = _groupMembers;
        single.groupId = _groupId;
        single.groupPic = _groupPic;
        single.groupCreatBy = _groupCreatedBy;
        single.documentId = _documentID;
    }
    else if ([segue.identifier isEqualToString:@"groupMediaseuge"]){
        
        AllMediaViewController *vc = [segue destinationViewController];
        vc.mediaList = _mediaList;
    }
    
    
}

#pragma mark -  UIActionsheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == photoPickActionSheet) {
        
        if (buttonIndex ==0) {
            
            [self takeFreshPhoto];
        }
        else if (buttonIndex == 1){
            
            [self takeFromLib];
        }
    }
    else if (actionSheet.tag  == (int)groupOptionActionSheetNotadmin){
        
        if (buttonIndex == 0) {
            
            ProgressIndicator *progressIndicator = [ProgressIndicator sharedInstance];
            [progressIndicator showPIOnView:self.view withMessage:@"Loading..."];
            PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
            [client sendRequestToMakeGroupAdmin:_groupId memNumber:storeSelecteduserNum documentID:_documentID];
            
        }else if(buttonIndex == 1){
            
            ProgressIndicator *progressIndicator = [ProgressIndicator sharedInstance];
            [progressIndicator showPIOnView:self.view withMessage:@"Loading..."];
            PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
            [client sendRequestTORemoveFromGroup:_groupId memNumber:storeSelecteduserNum documentID:_documentID];
            
        }
        
        
    }
    else if (actionSheet.tag == (int)groupOptionActionSheetAlredyadmin){
        
        if (buttonIndex == 0) {
            
            ProgressIndicator *progressIndicator = [ProgressIndicator sharedInstance];
            [progressIndicator showPIOnView:self.view withMessage:@"Loading..."];
            PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
            [client sendRequestTORemoveFromGroup:_groupId memNumber:storeSelecteduserNum documentID:_documentID];
            
        }
        
    }
    else if (actionSheet.tag == (int)emailChatActionSheet){
        
        if (buttonIndex ==0) {
            [self sendChatArchiveToMail];
        }
        
    }
    
    
}

/*TODO- preperChatData to send via Email*/
-(void)sendChatArchiveToMail{
    
    AppDelegate *appdeleget = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    CBLManager* bgMgr = [[appdeleget manager] copy];
    NSError *error;
    CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
    
    
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    messageStorage.docInfo = [[messageStorage getDocumentInfoForID:_documentID forDatabase:bgDB] mutableCopy] ;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/textfile.txt",
                          documentsDirectory];
    //create content - four lines of text
    
    NSString *filterMsg = [self filterMessage:messageStorage.docInfo[@"messages"]];
    
    NSString *content = filterMsg;
    
    if (content.length>0) {
        //save content to the documents directory
        [content writeToFile:fileName
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
        
        
        NSArray *paths1 = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory1 = [paths1 objectAtIndex:0];
        
        //make a file name to write the data to using the documents directory:
        NSString *fileName1 = [NSString stringWithFormat:@"%@/textfile.txt",
                               documentsDirectory1];
        
        NSData *data = [NSData dataWithContentsOfFile:fileName1];
        
        NSString *content1 = [[NSString alloc] initWithContentsOfFile:fileName
                                                         usedEncoding:nil
                                                                error:nil];
        
        
        // Email Subject
        NSString *emailTitle = [NSString stringWithFormat:@"Yayway? Chat with %@",_groupName];
        // Email Content
        NSString *messageBody = @"Send Chat";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@""];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        [mc addAttachmentData:data mimeType:@"application/scarybugs" fileName:[NSString stringWithFormat:@"Sup App %@",_groupName]];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
        
    }
    
}


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




-(NSString *)filterMessage:(NSArray *)messages{
    
    NSString *displayStr = [NSString new];
    NSMutableArray *storeMessage =[NSMutableArray new];
    if (messages.count ==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Opps" message:@"there is no chat" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    else
    {
        
        for (NSDictionary *dict in messages) {
            
            NSString *date ;
            NSString *text;
            if (dict[@"date"]) {
                
                date = [NSString stringWithFormat:@"%@",dict[@"date"]];
            }
            
            if ([dict[@"type"] isEqualToString:@"0"]) {
                text = [NSString stringWithFormat:@"%@",dict[@"text"]];
            }else{
                
                text = @"<media omitted>";
            }
            
            displayStr = [NSString stringWithFormat:@"%@  : %@: %@",date,_groupName,text];
            [storeMessage addObject:displayStr];
        }
        
        
    }
    
    
    return [NSString stringWithFormat:@"%@",storeMessage];
}



#pragma mark - alertView delegtes

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag ==(int) leveGroupalert) {
        
        if (buttonIndex == 1) {
            [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
            PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
            [client sendRequestToleaveGroup:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] withGroupId:_groupId documentID:_documentID];
        }
        
    }
    else if (alertView.tag == (int)clearChatalert){
        if (buttonIndex == 1) {
            //delete document messages
            NSMutableArray *blankArr = [NSMutableArray new];
            AppDelegate *appdeleget = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            CBLManager* bgMgr = [[appdeleget manager] copy];
            NSError *error;
            CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
            MessageStorage *Storge = [MessageStorage sharedInstance];
            Storge.docInfo[@"messages"] = blankArr;
            [Storge updateDocumentWithID:_documentID withMessages:blankArr onDatabase:bgDB];
            
            [self.tabBarController.tabBar setHidden:NO];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
    
    
}

-(void)takeFreshPhoto{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate =self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.navigationBar.tintColor = [UIColor blueColor];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message: @"Camera is not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

-(void)takeFromLib{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing =YES;
    [[picker navigationBar] setTintColor:[UIColor blueColor]];
    picker.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
    } else {
        
        [self dismissViewControllerAnimated:NO completion:nil];
        [self presentViewController:picker animated:YES completion:nil];
        
    }
    
}

#pragma UIImagePicker delegtes

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//
//    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
//    image = [self imageWithImage:image scaledToSize:CGSizeMake(100,100)];
//
//    UploadFile *uploading = [[UploadFile alloc] init];
//    uploading.delegate = self;
//    NSData *data1 = UIImagePNGRepresentation(image);
//    [uploading uploadData:data1];
//
//    [self dismissViewControllerAnimated:YES completion:nil];
//    ProgressIndicator *progressIndicator = [ProgressIndicator sharedInstance];
//    [progressIndicator showPIOnView:self.view withMessage:@"Loading..."];
//
//}
//
//
//-(void)uploadFile:(UploadFile *)uploadfile didFailedWithError:(NSError *)error
//{
//    ProgressIndicator *progressIndicator = [ProgressIndicator sharedInstance];
//    [progressIndicator hideProgressIndicator];
//    [UIHelper showMessage:@"Uploading Failed" withTitle:@"Error"];
//
//}
//
//-(void)uploadFile:(UploadFile *)uploadfile didUploadSuccessfullyWithUrl:(NSArray *)imageUrls
//{
//    NSLog(@"array : %@",imageUrls);
//    ProgressIndicator *progressIndicator = [ProgressIndicator sharedInstance];
//    [progressIndicator hideProgressIndicator];
//    NSDictionary *dict = imageUrls[0];
//    _groupPic = dict[@"Url"];
//    [_tableViewInfo reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self updateGroupImagetoSocket:_groupPic];
//
//}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


-(void)updateGroupImagetoSocket:(NSString*)imgUrl{
    
    PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
    [client sendRequestToUpdateGroupPic:imgUrl groupId:_groupId documentId:_documentID];
    
}

-(void)updateGroupName:(NSNotification*)notify
{
    [self viewDidAppear:YES];
    NSNumber *num =  [[NSUserDefaults standardUserDefaults]objectForKey:@"sendRequestFrogpName"];
    if (num.boolValue == YES) {
        [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading.."];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"sendRequestFrogpName"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        _groupName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"storeGroupName"]];
        PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
        [client sendRequestToUpdateGroupName:_groupName groupId:_groupId documentId:_documentID];
    }
}


-(void)leaveGroupresponse:(NSNotification*)notify
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        //Your code goes in here
        
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        NSDictionary* userInfo = notify.userInfo;
        NSString* message = userInfo[@"message"];
        
        UIAlertView *messageAlert = [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [messageAlert show];
        
    }];
    
    
}


#pragma UpdataGroupData in Database
-(void)updateGroupDataInDB:(NSNotification*)notify{
    
    [[ProgressIndicator sharedInstance]hideProgressIndicator];
    
    CBLDocument *database = [CBObjects.sharedInstance.database documentWithID:_documentID];
    NSLog(@"gp meme =%@  ",[database.properties objectForKey:@"groupMembers"]);
    NSLog(@"gp Admin =%@  ",[database.properties objectForKey:@"groupAdmin"]);
    
    _groupMembers = [database.properties objectForKey:@"groupMembers"];
    _groupAdmins = [database.properties objectForKey:@"groupAdmin"];
    _groupName = [NSString stringWithFormat:@"%@",[database.properties objectForKey:@"groupName"]];
    _groupPic = [NSString stringWithFormat:@"%@",[database.properties objectForKey:@"groupPic"]];
    _isRemoveFromgp = [NSString stringWithFormat:@"%@",[database.properties objectForKey:@"isRemoveFromgp"]];
    
    if ([_isRemoveFromgp  isEqualToString:@"NO"]) {
        isUserMember = YES;
    }
    
    [self getDataFromDB];
    [self checkUserIsadminorNot];
    [self checkUserIsMemeberorNot];
    
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [_tableViewInfo reloadData];
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
    
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:_groupId];
    
}


-(void)createMessagesArray{
    
    CBLDocument *document = [CBObjects.sharedInstance.database documentWithID:_documentID];
    MessageStorage *messageStorage = [MessageStorage sharedInstance];
    NSDictionary *docDictNew = [messageStorage getDetailsForDocument:document];
    NSArray *allMessages =  docDictNew[@"messages"];
    _mediaList = [messageStorage createMediaListfromMessages:allMessages];
}


-(void)editGropNameCliked:(UIButton*)sender{
    
    if (isUserMember ==NO) {
        
    }else{
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EditGroupnameTableViewController *edit = [story instantiateViewControllerWithIdentifier:@"EditGroupNameController"];
        [self presentViewController:edit animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setObject:_groupName forKey:@"storeGroupName"];
    }
    
}

- (void)willMoveToParentViewController:(UIViewController *)parent{
    if (parent == NULL) {
        
        if (OncompleteChangeInGpData) {
            
            OncompleteChangeInGpData(_groupName,_groupPic,_groupMembers,_groupAdmins,_isRemoveFromgp);
        }
        
    }
}

//-(void)reloadGroupChatInfo:(NSString*)docID{
//
//
//    CBLDocument *database = [CBObjects.sharedInstance.database documentWithID:_documentID];
//    _groupMembers = [database.properties objectForKey:@"groupMembers"];
//
//
//    [self getDataFromDB];
//
//
//    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//           [_tableViewInfo reloadData];
//   }];
//
//
//}
@end
