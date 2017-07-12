//
//  ConnectToFaceBookViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 5/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ConnectToFaceBookViewController.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "FBLoginHandler.h"
#import "UIScrollView+EmptyDataSet.h"
#import "UIImageView+WebCache.h"
#import "TinderGenericUtility.h"
#import "UserProfileViewController.h"
#import "ListOfPostsViewController.h"
#import "FontDetailsClass.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PicogramSocketIOWrapper.h"
#import "ProgressIndicator.h"
#import "Helper.h"


@interface ConnectToFaceBookViewController ()<UITableViewDataSource,UITableViewDelegate,WebServiceHandlerDelegate,FBLoginHandlerDelegate,SocketWrapperDelegate,UIActionSheetDelegate> {
   
    FacebookNumberOfContactsTableViewCell *numberOfcontactcell;
    NSArray *names;
    NSInteger rowCountForTitleSection;
    NSMutableArray *arrayOfReceivedContactDetails;
    
    
    UIActivityIndicatorView *avForBackGround;
    UIButton *navSetiingButton;
    ProgressIndicator *indicator;
}
@property (strong ,nonatomic) UIWindow *mainWindow;
@property (strong, nonatomic) PicogramSocketIOWrapper *client;
@property bool classIsAppearing;
@end

@implementation ConnectToFaceBookViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]removeObserver:@"getResponseFromCallChannel"];
    
    self.client = [PicogramSocketIOWrapper sharedInstance];
    self.client.socketdelegate = self;
    
   
    [self navTitileSelection];
    [self createNavLeftButton];
    [self createNavSettingButton];
    
    rowCountForTitleSection = 0;
    
    [self addActiVityIndicator];
    
    
    
    arrayOfReceivedContactDetails = [[NSMutableArray alloc] init];
    
}

-(void)updateFollowStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollwoStatus:) name:@"updatedFollowStatus" object:nil];
}

-(void)updateFollowSttusForPhoneContacts {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollwoStatusForPhoneContacts:) name:@"updatedFollowStatus" object:nil];
}
-(void)updateFollwoStatusForPhoneContacts:(NSNotification *)noti {
    if (!_classIsAppearing) {
        //check the postId and Its Index In array.
        NSString *userNamer = flStrForObj(noti.object[@"newUpdatedFollowData"][@"userName"]);
        NSString *foolowStatusRespectToUser = noti.object[@"newUpdatedFollowData"][@"newFollowStatus"];
        for (int i=0; i <arrayOfReceivedContactDetails.count;i++) {
            if ([flStrForObj(arrayOfReceivedContactDetails[i][@"membername"]) isEqualToString:userNamer]) {
//                arrayOfReceivedContactDetails[i][@"followRequestStatus"] = foolowStatusRespectToUser;
                
                NSMutableDictionary *tempDict = [arrayOfReceivedContactDetails[i] mutableCopy];
                [tempDict setValue:foolowStatusRespectToUser forKey:@"followRequestStatus"];
                [arrayOfReceivedContactDetails setObject:tempDict atIndexedSubscript:i];
                
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:1];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                [self.contatctsTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    _classIsAppearing = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    _classIsAppearing = YES;
}

-(void)updateFollwoStatus:(NSNotification *)noti {
    
    if (!_classIsAppearing) {
        //check the postId and Its Index In array.
        NSString *userNamer = flStrForObj(noti.object[@"newUpdatedFollowData"][@"userName"]);
        NSString *foolowStatusRespectToUser = noti.object[@"newUpdatedFollowData"][@"newFollowStatus"];
        
        for (int i=0; i <arrayOfReceivedContactDetails.count;i++) {
            if ([flStrForObj(arrayOfReceivedContactDetails[i][@"membername"]) isEqualToString:userNamer]) {
                arrayOfReceivedContactDetails[i][@"followRequestStatus"] = foolowStatusRespectToUser;
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:1];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                [self.contatctsTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
        
        
    }
}

-(void)sendNewFollowStatusThroughNotification:(NSString *)userNamer andNewStatus:(NSString *)newFollowStatus {
    
    
    
    NSDictionary *newFollowDict = @{@"newFollowStatus"     :flStrForObj(newFollowStatus),
                                    @"userName"            :flStrForObj(userNamer),
                                    };
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedFollowStatus" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"newUpdatedFollowData"]];
}

-(void)addActiVityIndicator {
    
    if ([self.syncingContactsOf isEqualToString:@"phoneBook"]) {
        [self updateFollowSttusForPhoneContacts];
        
        avForBackGround = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [avForBackGround setFrame:CGRectMake(0,0,50,30)];
        [self.view addSubview:avForBackGround];
        avForBackGround.tag  = 1;
        [avForBackGround startAnimating];
        self.contatctsTableView.backgroundView = avForBackGround;
    }
    else {
        
        [self updateFollowStatus];
        
        avForBackGround = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [avForBackGround setFrame:CGRectMake(0,0,50,30)];
        [self.view addSubview:avForBackGround];
        avForBackGround.tag  = 1;
        [avForBackGround startAnimating];
        self.contatctsTableView.backgroundView = avForBackGround;
    }
}

- (void)createNavSettingButton {
    if ([self.syncingContactsOf isEqualToString:@"phoneBook"]) {
        
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"accessDenied"] isEqualToString:@"No"]) {
            
            [self showAlert];
        }
        else
        {
            [self requestForFbOrPhoneContactsSync];
        }
        
        navSetiingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [navSetiingButton setImage:[UIImage imageNamed:@"edit_profile_setting_icon_off"]
                          forState:UIControlStateNormal];
        [navSetiingButton setImage:[UIImage imageNamed:@"edit_profile_setting_icon_on"]
                          forState:UIControlStateSelected];
        [navSetiingButton setTitleColor:[UIColor grayColor]
                               forState:UIControlStateHighlighted];
        [navSetiingButton setFrame:CGRectMake(-10,17,45,45)];
        [navSetiingButton addTarget:self action:@selector(SettingButtonAction:)
                   forControlEvents:UIControlEventTouchUpInside];
        // Create a container bar button
        UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navSetiingButton];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -14;// it was -6 in iOS 6
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
    }
    else {
        [self requestForFbOrPhoneContactsSync];
    }
}

-(void)SettingButtonAction:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"Syncing your contacts helps you follow friends.We'll remove contact info from our system when you disconnect." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disconnect" otherButtonTitles:nil];
    [action showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0)
    {
        
        [self updateTitlesForContactSync:[NSString stringWithFormat:@"%d",0]];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:numberOfContactsFoundInPicogram];
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"phoneContacts"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        NSLog(@"contact List:%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"phoneContacts"]);
        arrayOfReceivedContactDetails = nil;
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        status = kABAuthorizationStatusDenied;
        [[NSUserDefaults standardUserDefaults]setObject:@"No" forKey:@"accessDenied"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)navTitileSelection {
    if ([self.syncingContactsOf isEqualToString:@"faceBook"]) {
        self.navigationItem.title = @"FACEBOOK";
    }
    if ([self.syncingContactsOf isEqualToString:@"phoneBook"]) {
        self.navigationItem.title = @"CONTACTS";
    }
}

-(void)requestForFbOrPhoneContactsSync {
    if ([self.navigationItem.title isEqualToString:@"FACEBOOK"]) {
        
        //if user already login then no need to request for fb login othewise need to show fb login page.
        
        NSString *listOfFaceBookIds = [[NSUserDefaults standardUserDefaults]
                                       stringForKey:@"preferenceName"];
        
        
        
        
        if (listOfFaceBookIds) {
            // request for facebook contact syncing.
            //getting list of faceBook friends id.
            NSString *listOfFaceBookIds = [[NSUserDefaults standardUserDefaults]
                                           stringForKey:@"preferenceName"];
            //passing parameters(faceBookids list and token)
            
            listOfFaceBookIds = nil;
            
            FBLoginHandler *handler = [FBLoginHandler sharedInstance];
            listOfFaceBookIds =  [handler getDetailsFromFacebookUpdate];
            [handler setDelegate:self];
            
            
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                NSDictionary *requestDict = @{mfaceBookId     :flStrForObj(listOfFaceBookIds),
            //                                              mauthToken      :userToken,
            //                                              };
            //                //requesting the service and passing parametrs.
            //                [WebServiceHandler faceBookContactSync:requestDict andDelegate:self];
            //            });
            
        }
        else {
            FBLoginHandler *handler = [FBLoginHandler sharedInstance];
            [handler loginWithFacebook:self];
            [handler setDelegate:self];
            
        }
    }
    else if ([self.navigationItem.title isEqualToString:@"CONTACTS"]) {
        //ask permission for phone contacts acess.
        //connect channel.
        NSString *phoneContacts = [[NSUserDefaults standardUserDefaults]objectForKey:@"phoneContacts"];
        if (phoneContacts.length) {
            [self.client syncContacts:phoneContacts];
        }
        else
        {
            [self loadPhoneContacts];
        }
        
//        NSDictionary *requestDict = @{
//                                      mauthToken      :[Helper userToken],
//                                      };
//        //requesting the service and passing parametrs.
//        [WebServiceHandler phoneContactSync:requestDict andDelegate:self];
        
    }
}

- (void)createNavLeftButton {
    self.navigationController.navigationItem.hidesBackButton =  YES;
    UIButton  *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section==0) {
        return rowCountForTitleSection;
    }
    else  {
        return arrayOfReceivedContactDetails.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        numberOfcontactcell = [tableView dequeueReusableCellWithIdentifier:@"numberOfContactTableViewCell" forIndexPath:indexPath];
        //the numberOfContacsSynced is used to print no of friends on picogram.
        NSString *numberOfContacsSynced =[NSString stringWithFormat:@"%lu", (unsigned long)arrayOfReceivedContactDetails.count];
        //tp print on view controller changing the label text.
        if (arrayOfReceivedContactDetails.count >1) {
            numberOfcontactcell.numberOfFriendsLabelOutlet.text  = [numberOfContacsSynced stringByAppendingString:@" Friends On Picogram"];
        }
        else {
            numberOfcontactcell.numberOfFriendsLabelOutlet.text  = [numberOfContacsSynced stringByAppendingString:@" Friend on picogram"];
        }
        
        numberOfcontactcell.followAllButtonOutlet.hidden = YES;
        
        [numberOfcontactcell.followAllButtonOutlet addTarget:self
                                                      action:@selector(cellFollowAllButtonAction:)
                                            forControlEvents:UIControlEventTouchUpInside];
        
        numberOfcontactcell.followAllButtonOutlet.layer.cornerRadius = 5;
        numberOfcontactcell.followAllButtonOutlet.layer.borderWidth = 1;
        numberOfcontactcell.followAllButtonOutlet.layer.borderColor = [UIColor colorWithRed:0.2392 green:0.3216 blue:0.5922 alpha:1.0].CGColor;
        
        return numberOfcontactcell;
    }
    else {
        
        ConnectToFaceBookContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactDetailsCell"
                                                                                       forIndexPath:indexPath];
        cell.userNameLabelOutlet.text = flStrForObj(arrayOfReceivedContactDetails[indexPath.row][@"membername"]);
        [cell.contactUserImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfReceivedContactDetails[indexPath.row][@"profilePicUrl"]]) placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
         
         [cell.followButtonOutlet addTarget:self
                                     action:@selector(cellFollowButtonAction:)
                           forControlEvents:UIControlEventTouchUpInside];
         
         [cell.followButtonOutlet setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         
         //updating FollowButtonTitle
         [cell updateFollowButtonTitle:flStrForObj(arrayOfReceivedContactDetails[indexPath.row][@"followRequestStatus"]) andIndexPath:indexPath.row];
         
         [cell layoutIfNeeded];
         cell.contactUserImageViewOutlet.layer.cornerRadius = cell.contactUserImageViewOutlet.frame.size.height/2;
         cell.contactUserImageViewOutlet.clipsToBounds = YES;
         cell.followButtonOutlet.tag = 1000 + indexPath.row;
         
         if ([self.syncingContactsOf isEqualToString:@"phoneBook"]) {
             //plot contacts data.
             cell.fullNameLabelOutlet.text = flStrForObj(arrayOfReceivedContactDetails[indexPath.row][@"fullName"]);
             [cell showImagesForContacts:arrayOfReceivedContactDetails forIndex:indexPath.row];
         }
         else {
             //plot fb data.
             cell.fullNameLabelOutlet.text = flStrForObj(arrayOfReceivedContactDetails[indexPath.row][@"fullname"]);
             [cell showImagesForFb:arrayOfReceivedContactDetails forIndex:indexPath.row];
         }
         return cell;
    }
}
         
-(void)cellFollowAllButtonAction:(id)sender {
    
//    [cell.followButtonOutlet sendActionsForControlEvents:UIControlEventTouchUpInside];
}
         
-(void)cellFollowButtonAction:(id)sender {
             
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [self.contatctsTableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    NSString *memberPrivateAccountState = flStrForObj(arrayOfReceivedContactDetails[selectedCellForLike.row][@"memberPrivate"]);
    
    //PGTableViewCell *selectedCell = [self.followContactsTableView cellForRowAtIndexPath:selectedCellForLike];
    
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([selectedButton.titleLabel.text isEqualToString:@"FOLLOW"]) {
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag%1000][@"membername"]) andNewStatus:@"0"];
            
            [selectedButton setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            NSMutableDictionary *tempDict = [arrayOfReceivedContactDetails[selectedCellForLike.row] mutableCopy];
            [tempDict setValue:@"0" forKey:@"followRequestStatus"];
            [arrayOfReceivedContactDetails setObject:tempDict atIndexedSubscript:selectedCellForLike.row];
            
            
            [selectedButton  setTitle:@"REQUESTED" forState:UIControlStateNormal];
            
            [selectedButton setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            
           
            selectedButton.backgroundColor = requstedButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor clearColor].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(arrayOfReceivedContactDetails[selectedCellForLike.row][@"membername"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
        else if ([selectedButton.titleLabel.text isEqualToString:@"FOLLOWING"])  {
            
            [self showUnFollowAlert:flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag%1000][@"profilePicUrl"]) and:flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag%1000][@"membername"])  and:sender];
            
           
            
        }
        else {
            // cancel request for follow.
            
            [selectedButton  setTitle:@"FOLLOW" forState:UIControlStateNormal];
            [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
            [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            selectedButton.backgroundColor = followButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            
            
            
            
            NSMutableDictionary *tempDict = [arrayOfReceivedContactDetails[selectedCellForLike.row] mutableCopy];
            [tempDict setValue:@"2" forKey:@"followRequestStatus"];
            [arrayOfReceivedContactDetails setObject:tempDict atIndexedSubscript:selectedCellForLike.row];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag%1000][@"membername"]) andNewStatus:@"2"];
            
            NSDictionary *requestDict = @{muserNameToUnFollow     : flStrForObj(arrayOfReceivedContactDetails[selectedCellForLike.row][@"membername"]),
                                          mauthToken            :[Helper userToken],
                                          };
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
    }
    //actions for when the account is public.
    else {
        if ([selectedButton.titleLabel.text isEqualToString:@"FOLLOWING"]) {
            
            [self showUnFollowAlert:flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag%1000][@"profilePicUrl"]) and:flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag%1000][@"membername"])  and:sender];
            
        }
        else {
            
            NSMutableDictionary *tempDict = [arrayOfReceivedContactDetails[selectedCellForLike.row] mutableCopy];
            [tempDict setValue:@"1" forKey:@"followRequestStatus"];
            [arrayOfReceivedContactDetails setObject:tempDict atIndexedSubscript:selectedCellForLike.row];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag%1000][@"membername"]) andNewStatus:@"1"];
            [selectedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [selectedButton  setTitle:@"FOLLOWING" forState:UIControlStateNormal];
            
            [selectedButton setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
            
            selectedButton.backgroundColor = followingButtonBackGroundColor;
            selectedButton.layer.borderColor = [UIColor clearColor].CGColor;
            
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(arrayOfReceivedContactDetails[selectedCellForLike.row][@"membername"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
    }
}
         
         
         
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
             
    if(indexPath.section==0) {
        return 50;
    }
    else  {
        NSMutableArray *numberOfuserPosts;
        
        if ([self.syncingContactsOf isEqualToString:@"phoneBook"]) {
            numberOfuserPosts = arrayOfReceivedContactDetails[indexPath.row][@"postData"];
            
            if ([flStrForObj(numberOfuserPosts[0][@"thumbnailImageUrl"]) isEqualToString:@""]) {
                numberOfuserPosts = nil;
            }
            //numberOfuserPosts =arrayOfReceivedContactDetails[indexPath.row][@"postData"];
        }
        else {
            numberOfuserPosts =arrayOfReceivedContactDetails[indexPath.row][@"userPosts"];
            if ([flStrForObj(numberOfuserPosts[0][@"thumbnailImageUrl"]) isEqualToString:@""]) {
                numberOfuserPosts = nil;
            }
            
        }
        
        NSString *memberPrivateStatus = flStrForObj(arrayOfReceivedContactDetails[indexPath.row][@"memberPrivate"]);
        NSString *followStatus = flStrForObj(arrayOfReceivedContactDetails[indexPath.row][@"followRequestStatus"]);
        
        if ([followStatus isEqualToString:@"1"]) {
            if(numberOfuserPosts.count ==0) {
                return 100;
            }
            else {
                return 60 + self.view.frame.size.width/4
                ;
            }
        }
        else {
            
            
            
            
            
            if([memberPrivateStatus isEqualToString:@"1"]){
                return 100;
            }
            else {
                if(numberOfuserPosts.count ==0) {
                    return 100;
                }
                else {
                    return 60 + self.view.frame.size.width/4;
                }
                
            }
        }
    }
}
         
         
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae =flStrForObj(arrayOfReceivedContactDetails[indexPath.row][@"membername"]);
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
}
         
#pragma mark
#pragma mark - facebook
         
         - (void)didFacebookUserLoginWithDetails:(NSDictionary*)userInfo {
             NSLog(@"FB Data =  %@", userInfo);
             // request for facebook contact syncing.
             //getting list of faceBook friends id.
             NSString *listOfFaceBookIds = [[NSUserDefaults standardUserDefaults]
                                            stringForKey:@"preferenceName"];
             //passing parameters(faceBookids list and token)
             NSDictionary *requestDict = @{mfaceBookId     :listOfFaceBookIds,
                                           mauthToken      :[Helper userToken],
                                           };
             //requesting the service and passing parametrs.
             [WebServiceHandler faceBookContactSync:requestDict andDelegate:self];
         }
         
         - (void)didFailWithError:(NSError *)error {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
         }
         
         - (void)didUserCancelLogin {
             NSLog(@"USER CANCELED THE LOGIN");
             [self backButtonClicked];
         }
         
        /*---------------------------------------------------*/
#pragma mark - Webservice Handler
#pragma mark - WebServiceDelegate
        /*---------------------------------------------------*/
         
         
         - (void) didFinishLoadingRequest:(RequestType )requestType withResponse:(id)response error:(NSError*)error {
             // handling response.
             
             self.contatctsTableView.backgroundView = nil;
             
             
             if (error) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:[error localizedDescription]
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil,nil];
                 [alert show];
                 
                 [self backGrounViewWithImageAndTitle:[error localizedDescription]];
                 [avForBackGround stopAnimating];
                 [[ProgressIndicator sharedInstance] hideProgressIndicator];
                 return;
             }
             
             //storing response data  in dictonary.
             NSDictionary *responseDict = (NSDictionary*)response;
             
             //checking the request type and handling response.
             if (requestType == RequestTypeLoginfaceBookContactSync ) {
                 //checking the response  code and handling error message or success message by depending on code.
                 switch ([responseDict[@"code"] integerValue]) {
                     case 200: {
                         //successs response.
                         arrayOfReceivedContactDetails =responseDict[@"facebookUsers"];
                         
                         [self updateTitlesForFbSync:[NSString stringWithFormat:@"%lu",(unsigned long)arrayOfReceivedContactDetails.count]];
                         
                         //it will reload the data.
                         if(arrayOfReceivedContactDetails.count) {
                             rowCountForTitleSection = 1;
                             NSString *numberOfContacsSynced =[NSString stringWithFormat:@"%lu", (unsigned long)arrayOfReceivedContactDetails.count];
                             
                             [[NSUserDefaults standardUserDefaults] setObject:numberOfContacsSynced forKey:numberOfFbFriendFoundInPicogram];
                             [[NSUserDefaults standardUserDefaults] synchronize];
                             
                             [self.contatctsTableView reloadData];
                         }
                         else
                         {
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"None Of Your Friends Are Using Picogram" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                             [alert show];
                         }
                     }
                         break;
                         //failure responses.
                     case 2021: {
                         [self backGrounViewWithImageAndTitle:responseDict[@"message"]];
                         [avForBackGround stopAnimating];
                         [[ProgressIndicator sharedInstance] hideProgressIndicator];
                     }
                         break;
                     case 2022: {
                         [avForBackGround stopAnimating];
                         [[ProgressIndicator sharedInstance] hideProgressIndicator];
                         [self backGrounViewWithImageAndTitle:@"No suggestions Available"];
                         
                     }
                         break;
                     case 2023: {
                         [avForBackGround stopAnimating];
                         [[ProgressIndicator sharedInstance] hideProgressIndicator];
                         [self backGrounViewWithImageAndTitle:@"No suggestions Available"];
                     }
                         break;
                     case 2024: {
                         [self errorAlert:responseDict[@"message"]];
                     }
                         break;
                     case 2025: {
                         [self errorAlert:responseDict[@"message"]];
                     }
                         break;
                     case 2026: {
                         [self errorAlert:responseDict[@"message"]];
                     }
                         break;
                     case 2027: {
                         [self errorAlert:responseDict[@"message"]];
                     }
                         break;
                     case 2028: {
                         [self errorAlert:responseDict[@"message"]];
                     }
                         break;
                     default:
                         break;
                 }
             }
             else if (requestType == RequestTypePhoneContactSync) {
                 //connect channel.
                 NSString *phoneContacts = [[NSUserDefaults standardUserDefaults]objectForKey:@"phoneContacts"];
                 if (phoneContacts.length) {
                     [self.client syncContacts:phoneContacts];
                 }
                 else
                 {
                     [self loadPhoneContacts];
                 }
             }
         }
         
         - (void)errorAlert:(NSString *)message {
             //showing error alert for failure response.
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil,nil];
             [alert show];
         }
         
         
        /*-----------------------------------------------------*/
#pragma mark -
#pragma mark - CustomActionSheet
        /*----------------------------------------------------*/
- (void)showUnFollowAlert:(NSString *)profilePicUrl and:(NSString *)profileName  and:(id)sender{
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
             CGFloat margin = 8.0F;
             UIView *customView;
             customView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0F, 80)];
             
             UIImageView *UserImageView =[[UIImageView alloc] init];
    
    
        [UserImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(profilePicUrl)] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
     
             UserImageView.frame = CGRectMake(customView.frame.size.width/2-20,10,40,40);
             [self.view layoutIfNeeded];
             
             UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
             UserImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
             UserImageView.layer.borderWidth = 2.0;
             UserImageView.layer.masksToBounds = YES;
             customView.backgroundColor = [UIColor clearColor];
             
             //creating user name label
             UILabel *UserNamelabel = [[UILabel alloc] init];
             NSString *BoldText = [profileName stringByAppendingString:@"?"];
             NSString *text = [NSString stringWithFormat:@"Unfollow  %@",
                               BoldText];
             
             // If attributed text is supported (iOS6+)
             if ([UserNamelabel respondsToSelector:@selector(setAttributedText:)]) {
                 
                 // Define general attributes for the entire text
                 NSDictionary *attribs = @{
                                           NSForegroundColorAttributeName:UserNamelabel.textColor,
                                           NSFontAttributeName: UserNamelabel.font
                                           };
                 
                 NSMutableAttributedString *attributedText =
                 [[NSMutableAttributedString alloc] initWithString:text
                                                        attributes:attribs];
                 
                 // black and bold text attributes
                 UIColor *blackColor = [UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0];
                 UIFont *boldFont = [UIFont fontWithName:RobotoThin size:14];
                 NSRange BoldTextRange = [text rangeOfString:BoldText];
                 [attributedText setAttributes:@{NSForegroundColorAttributeName:blackColor,
                                                 NSFontAttributeName:boldFont}
                                         range:BoldTextRange];
                 UserNamelabel.attributedText = attributedText;
             }
             // If attributed text is NOT supported (iOS5-)
             else {
                 UserNamelabel.text = text;
             }
             
             [UserNamelabel setFont:[UIFont systemFontOfSize:14]];
             UserNamelabel.frame=CGRectMake(-20,60, self.view.frame.size.width,15);
             UserNamelabel.textAlignment = NSTextAlignmentCenter;
             
             [customView addSubview:UserNamelabel];
             [customView addSubview:UserImageView];
             [alertController.view addSubview:customView];
             
             UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                 
                 [self unfollowAction:sender];
                 
             }];
             UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
             [alertController addAction:somethingAction];
             [alertController addAction:cancelAction];
             [self presentViewController:alertController animated:YES completion:^{}];
             
}
         
-(void)unfollowAction:(id)sender {
    NSLog(@"unfollow clicked");
    UIButton *selectedButton = (UIButton *)sender;
    [selectedButton  setTitle:@"FOLLOW" forState:UIControlStateNormal];
    
    [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
    
    
    
    NSMutableDictionary *tempDict = [arrayOfReceivedContactDetails[selectedButton.tag%1000] mutableCopy];
    [tempDict setValue:@"2" forKey:@"followRequestStatus"];
    [arrayOfReceivedContactDetails setObject:tempDict atIndexedSubscript:selectedButton.tag%1000];
    
    
    [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag%1000][@"membername"]) andNewStatus:@"2"];
    
    selectedButton.backgroundColor = followButtonBackGroundColor;
    [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
    selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    //passing parameters.
    NSDictionary *requestDict = @{muserNameToUnFollow: flStrForObj(arrayOfReceivedContactDetails[selectedButton.tag %1000][@"membername"]),
                                  mauthToken            :flStrForObj([Helper userToken]),
                                  };
    //requesting the service and passing parametrs.
    [WebServiceHandler unFollow:requestDict andDelegate:self];
}
         
#pragma mark - DeviceContacts
         
-(void)loadPhoneContacts{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusDenied) {
        
        // if you got here, user had previously denied/revoked permission for your
        
        // app to access the contacts, and all you can do is handle this gracefully,
        
        // perhaps telling the user that they have to go to settings to grant access
        
        // to contacts
        
         [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        errorAlert.tag = 5;
        [errorAlert show];
        
//        [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (error) {
        
        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
        
        if (addressBook) CFRelease(addressBook);
        
        return;
        
    }
    if (status == kABAuthorizationStatusNotDetermined) {
        // present the user the UI that requests permission to contacts ...
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
            }
            if (granted) {
                // if they gave you permission, then just carry on
                [self listPeopleInAddressBook:addressBook];
                
                //showing progress indicator and requesting for posts.
                ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];  [HomePI showPIOnView:self.view withMessage:@"Syncing Contacts .."];
                
            } else {
                
                // however, if they didn't give you permission, handle it gracefully, for example...
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // BTW, this is not on the main thread, so dispatch UI updates back to the main queue
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    errorAlert.tag = 5;
                    [errorAlert show];
                });
            }
            if (addressBook) CFRelease(addressBook);
        });
    } else if (status == kABAuthorizationStatusAuthorized) {
        [self listPeopleInAddressBook:addressBook];
        if (addressBook) CFRelease(addressBook);
        //showing progress indicator and requesting for posts.
        ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];  [HomePI showPIOnView:self.view withMessage:@"Syncing Contacts .."];
    }
}
         
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
             if (alertView.tag == 5) {
                 if (buttonIndex == [alertView cancelButtonIndex]){
                    [self.navigationController popViewControllerAnimated:YES];
                 }
             }
}
         
- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook {
    self.client = [PicogramSocketIOWrapper sharedInstance];
    self.client.socketdelegate = self;
    NSString *phoneNumber;
    NSInteger numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSMutableArray  *onlyPhoneNumbers = [[NSMutableArray alloc] init];;
    for (NSInteger i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSLog(@"Name:%@ %@", firstName, lastName);
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            NSLog(@"  phone:%@", phoneNumber);
        }
        CFRelease(phoneNumbers);
        NSLog(@"=============================================");
        if(phoneNumber){
            [onlyPhoneNumbers addObject:phoneNumber];
        }
    }
    NSLog(@"#########################");
    NSLog(@"number of contacts:%lu",(unsigned long)onlyPhoneNumbers.count);
    self.greeting = [onlyPhoneNumbers componentsJoinedByString:@","];
    NSLog(@"%@",self.greeting);
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,+"] invertedSet];
    NSString *resultString = [[self.greeting componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSLog (@"Result: %@", resultString);
    [self.client syncContacts:resultString];
    [[NSUserDefaults standardUserDefaults] setObject:resultString forKey:@"phoneContacts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
         
         -(void)updateTitlesForContactSync:(NSString *)numberOfContcts {
             NSDictionary *newFollowDict = @{@"numberOfContacts" :flStrForObj(numberOfContcts),
                                             };
             
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"updateContactSectionTitle" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"numberOfContactsSynced"]];
         }
         
         -(void)updateTitlesForFbSync:(NSString *)numberOfContcts {
             NSDictionary *newFollowDict = @{@"numberOfContacts" :flStrForObj(numberOfContcts),
                                             };
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFaceBookSectionTitle" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"numberOfContactsSynced"]];
         }
         
#pragma marks-socket Delegate
         
-(void)responseFromChannels:(NSDictionary *)responseDictionary {
             
    dispatch_async(dispatch_get_main_queue(), ^{
        switch ([responseDictionary[@"code"] integerValue]) {
            case 200: {
                [avForBackGround stopAnimating];
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
                //successs response.
                
                
                
                arrayOfReceivedContactDetails = [responseDictionary[@"data"] mutableCopy];
                
                
                
                
               
                
                [self updateTitlesForContactSync:[NSString stringWithFormat:@"%lu",(unsigned long)arrayOfReceivedContactDetails.count]];
                
                //it will reload the data.
                if(arrayOfReceivedContactDetails.count) {
                    rowCountForTitleSection = 1;
                    NSString *numberOfContacsSynced =[NSString stringWithFormat:@"%lu", (unsigned long)arrayOfReceivedContactDetails.count];
                    [[NSUserDefaults standardUserDefaults] setObject:numberOfContacsSynced forKey:numberOfContactsFoundInPicogram];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.contatctsTableView reloadData];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"None Of Your Friends Are Using Picogram" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
            }
                break;
                //failure responses.
            case 2021: {
                [avForBackGround stopAnimating];
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
                
                [self backGrounViewWithImageAndTitle:@"Error Fetching In Contact list"];
            }
                break;
            case 2022: {
                [avForBackGround stopAnimating];
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
                [self backGrounViewWithImageAndTitle:@"No suggestions Available"];
            }
                break;
            case 2023: {
                [self backGrounViewWithImageAndTitle:responseDictionary[@"message"]];
                [avForBackGround stopAnimating];
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
            }
                break;
            case 2024: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2025: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2026: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2027: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2028: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            default:
                break;
        }
        
    });
}
         
         -(UIView *)backGroundViewForEmptyTable:(NSString *)message {
             UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
             labelForNoPostsMessage.text = message;
             labelForNoPostsMessage.numberOfLines =0;
             labelForNoPostsMessage.frame = CGRectMake(0, self.view.frame.size.height/2 - 20, self.view.frame.size.width, 40);
             [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoMedium size:15]];
             labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
             
             return labelForNoPostsMessage;
         }
         
-(void)backGrounViewWithImageAndTitle:(NSString *)mesage{
    
    UIView *viewWhenNoPosts = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImageView *image =[[UIImageView alloc] init];
    image.image = [UIImage imageNamed:@"ip5"];
    image.frame =  CGRectMake(self.view.frame.size.width/2 - 45, self.view.frame.size.height/2 - 45, 90, 90);
    [viewWhenNoPosts addSubview:image];
    
    UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
    labelForNoPostsMessage.text = mesage;
    labelForNoPostsMessage.textColor = [UIColor blackColor];
    labelForNoPostsMessage.numberOfLines =0;
    labelForNoPostsMessage.frame = CGRectMake(8, CGRectGetMaxY(image.frame) + 10, self.view.frame.size.width-16, 40);
    [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoRegular size:15]];
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    [viewWhenNoPosts addSubview:labelForNoPostsMessage];
    
    self.contatctsTableView.backgroundView = viewWhenNoPosts;
}
         
         
#pragma mark - Custome Alert
-(void)showAlert {
    _mainWindow = [[[UIApplication sharedApplication] delegate] window];
    UIView *iView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width , self.view.frame.size.height)];
    [self.view addSubview:iView];
    
    iView.alpha = 0;
    [UIView animateWithDuration:0.6
                     animations:^{
                         iView.center = self.view.center;
                         iView.alpha = 15;
                     }
                     completion:^(BOOL finished){
                     }];
    
    iView.tag =10;
    [_mainWindow addSubview:iView];
    
    
    //[iView addGestureRecognizer:oneTap];
    iView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
    
    UIView *infoDetailsView = [[UIView alloc] initWithFrame:CGRectMake(25 ,self.view.frame.size.height/2 - 200/2 , 250+15, 203)];
    
    infoDetailsView.center = iView.center;
    
    infoDetailsView.backgroundColor = [UIColor whiteColor];
    [iView addSubview:infoDetailsView];
    
    infoDetailsView.layer.cornerRadius = 10.0f;
    infoDetailsView.layer.masksToBounds = YES;
    
    
    UILabel *infoTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,8,250 , 25)];
    infoTitle.textAlignment = NSTextAlignmentCenter;
    [Helper setToLabel:infoTitle Text:@"Find people to follow " WithFont:RobotoMedium FSize:16 Color:[UIColor blackColor]];//[UIColor colorWithRed:47/255.0 green:183/255.0 blue:107/255.0 alpha:1.0]];
    [infoDetailsView addSubview:infoTitle];
    
    UILabel *infoDetail =[[UILabel alloc]initWithFrame:CGRectMake(15,0,247-10,158-15)];//10,32-10,247-5,158-20
    infoDetail.backgroundColor = [UIColor clearColor];
    [Helper setToLabel:infoDetail Text:@"To help people connect to picogran,your contacts are periodically synced and securely stored on our servers.You choose which contacts to follow.Disconnect at any time to remove them." WithFont:RobotoRegular FSize:12 Color:[UIColor blackColor]];
    infoDetail.numberOfLines = 0;
    infoDetail.textAlignment = NSTextAlignmentCenter;
    [infoDetailsView addSubview:infoDetail];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 104+20, 265, 80)];
    bottomView.backgroundColor = [UIColor colorWithRed:247.0f/255.0 green:247.0f/255.0 blue:247.0f/255.0 alpha:1.0];
    [infoDetailsView addSubview:bottomView];
    
    
    
    
    UIButton *allowAccessBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,45, 265, 30)];//120, 0, 40, 40
    allowAccessBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [Helper setButton:allowAccessBtn  Text:@"Allow Access" WithFont:RobotoMedium FSize:16 TitleColor:[UIColor colorWithRed:59/255.0f green:132/255.0f blue:239/255.0f alpha:1.0f] ShadowColor:nil];
    [allowAccessBtn addTarget:self action:@selector(allowAccess:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:allowAccessBtn];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 265, 0.5)];
    bottomLineView.backgroundColor = [UIColor colorWithRed:216.0f/255.0 green:216.0f/255.0 blue:216.0f/255.0 alpha:1.0];
    [bottomView addSubview:bottomLineView];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 265, 0.5)];
    topLineView.backgroundColor = [UIColor colorWithRed:216.0f/255.0 green:216.0f/255.0 blue:216.0f/255.0 alpha:1.0];
    [bottomView addSubview:topLineView];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5,265, 30)];
    
    [cancelBtn addTarget:self action:@selector(dissmissBtn:) forControlEvents:UIControlEventTouchUpInside];
    [Helper setButton:cancelBtn Text:@"Cancel" WithFont:RobotoMedium FSize:16 TitleColor:[UIColor colorWithRed:59/255.0f green:132/255.0f blue:239/255.0f alpha:1.0f] ShadowColor:nil];
    //[iView addSubview:cancelBtn];
    [bottomView addSubview:cancelBtn];
}
         
-(IBAction)allowAccess:(id)sender{
    [UIView animateWithDuration:0 animations:^ {
        [self dissmissBtn:self];
    }completion:^(BOOL finished) {
        [self requestForFbOrPhoneContactsSync];
    }];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"accessDenied"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
         
- (IBAction)dissmissBtn:(id)sender {
    
    UIView *view = [_mainWindow   viewWithTag:10];
    [UIView animateWithDuration:0.6
                     animations:^{
                         
                         view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         
                         [view removeFromSuperview];
                         if([[NSUserDefaults standardUserDefaults]objectForKey:@"accessDenied"]){
                             [self.navigationController popViewControllerAnimated:YES];
                         }
                     }];
}
         
         @end
