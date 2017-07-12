//
//  OptionsViewController.m
//  Picogram
//  Created by Rahul Sharma on 8/4/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "OptionsViewController.h"
#import "ImageTitleTableViewCell.h"
#import "TitleSwitchButtonTableViewCell.h"
#import "FontDetailsClass.h"
#import "EditProfileViewController.h"
#import "ConnectToFaceBookViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "FontDetailsClass.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "businessHelpViewController.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "ProgressIndicator.h"
#import "PGPrivacyPolicyViewController.h"
#import "WebViewForDetailsVc.h"
#import "FeddBackViewController.h"


@interface OptionsViewController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,WebServiceHandlerDelegate> {
    
    
    NSArray *arrayForSectionHeaders;
    NSArray *imageArray;
    NSArray *tittleArrayForfirstSection;
    NSArray *titleArryForSecondSection;
    NSArray *tittleArrayForFourthSection;
    NSArray *tittleArrayForFifthSection;

    
    NSString *titleForContacts;
    NSString *subTitleForContacts;
    NSString *imageForContcts;
    
    TitleSwitchButtonTableViewCell *titleswitchcell;
}

@end
@implementation OptionsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavLeftButton];
    self.navigationItem.title =@"Options";
    arrayForSectionHeaders = [[NSArray alloc] initWithObjects:@"INVITE",@"FOLLOW PEOPLE",@"ACCOUNT",@"SUPPORT",@"ABOUT",@"", nil];
    imageArray =  [[NSArray alloc] initWithObjects:@"settings_facebook_icon",@"settings_contacts_icon", nil];
    [self settingTitleForFirstSection];
    [self creatingNotificationForUpdatingTitleContacts];
    
    
    titleArryForSecondSection = [[NSArray alloc] initWithObjects:@"Edit Profile",@"Switch to Business",@"Private Account",nil];
    tittleArrayForFourthSection =  [[NSArray alloc] initWithObjects:@"Privacy Policy",@"Terms",@"EULA",nil];
    tittleArrayForFifthSection =  [[NSArray alloc] initWithObjects:@"Clear Search History",@"Add Account",@"Log Out",nil];
    
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:30.0f/255.0f green:36.0f/255.0f blue:52.0f/255.0f alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width,0.5)];
    [navBorder setBackgroundColor:[UIColor colorWithRed:62.0f/255.0f green:72.0f/255.0f blue:97.0f/255.0f alpha:1.0f]];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
}*/


-(void)creatingNotificationForUpdatingTitleContacts {
    NSInteger numberOfContactsInPicogram = [[[NSUserDefaults standardUserDefaults]
                                             stringForKey:numberOfContactsFoundInPicogram] integerValue];
    
    NSString *numberofContscs = [NSString stringWithFormat:@"%ld",numberOfContactsInPicogram];
    
    if (numberOfContactsInPicogram > 0) {
        titleForContacts = @"Connected Contacts";
        subTitleForContacts = [numberofContscs stringByAppendingString:@" Contacts"];
        imageForContcts = @"discovery_people_contact_icon";
    }
    else {
        titleForContacts = @"Connect to Contacts";
        subTitleForContacts = @"to follow your friends";
        imageForContcts = @"discover_people_contacts_icon_off";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitleForContcts:) name:@"updateContactSectionTitle" object:nil];
}

-(void)updateTitleForContcts:(NSNotification *)noti {
    
    NSString *numberOfContcts = flStrForObj(noti.object[@"numberOfContactsSynced"][@"numberOfContacts"]);
    
    NSInteger numberOfContactsInPicogram = [numberOfContcts integerValue];
    
    
    if (numberOfContactsInPicogram > 0) {
        titleForContacts = @"Connected Contacts";
        subTitleForContacts = [numberOfContcts stringByAppendingString:@" Contacts"];
        imageForContcts = @"discovery_people_contact_icon";
    }
    else {
        titleForContacts = @"Connect to Contacts";
        subTitleForContacts = @"to follow your friends";
        imageForContcts = @"discover_people_contacts_icon_off";
    }
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:1];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.optionsTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
}


-(void)settingTitleForFirstSection{
    NSInteger numberOfFaceBookFriendsInPicogram = [[[NSUserDefaults standardUserDefaults]
                                                    stringForKey:numberOfFbFriendFoundInPicogram] integerValue];
    
    if (numberOfFaceBookFriendsInPicogram >0) {
        NSString *titleForFbCell = [[NSString stringWithFormat:@"%lu",(unsigned long)numberOfFaceBookFriendsInPicogram]  stringByAppendingString:@" Facebook Friends"];
          tittleArrayForfirstSection = [[NSArray alloc] initWithObjects:titleForFbCell,@"Find Contacts",nil];
       
    }
    else {
          tittleArrayForfirstSection = [[NSArray alloc] initWithObjects:@"Find Facebook Friends",@"Find Contacts",nil];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch(section){
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 3;
            break;
        case 3:
            return 1;
            break ;
        case 4:
            return 3;
            break ;
        case 5:
            return 1;
            break;
        default:  return 0;
            break;
      }
    
 }

//Custom Header
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // creating custom header view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor =[UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    UIView *TopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,1)];
    view.backgroundColor =[UIColor colorWithRed:0.9753 green:0.9753 blue:0.9753 alpha:1.0];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(49, 0, tableView.frame.size.width,1)];
    view.backgroundColor =[UIColor colorWithRed:0.9753 green:0.9753 blue:0.9753 alpha:1.0];
    
    /* Create custom view to display section header... */
    UILabel *titileForHeader = [[UILabel alloc] init];
    titileForHeader.text =[arrayForSectionHeaders objectAtIndex:section];
    [titileForHeader setFont:[UIFont fontWithName:RobotoMedium size:14]];
    titileForHeader.textColor =[UIColor colorWithRed:0.5296 green:0.5296 blue:0.5296 alpha:1.0];
    titileForHeader.frame=CGRectMake(20, 20, self.view.frame.size.width - 10, 15);
    
    [view addSubview:titileForHeader];
    [view addSubview:TopLine];
    [view addSubview:bottomLine];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0)
    {
        return 0.0;
    }
    if (section == 5) {
        return 40.0;
    }
    else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0f;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 0.0f;
    }
    if(indexPath.section == 2 && indexPath.row == 2)
    {
        NSString *bussinessStatus = [Helper bussinessAccountStatus];
        if ([bussinessStatus isEqualToString:@"1"] ||[bussinessStatus isEqualToString:@"0"]) {
            
        //if ([Helper isBusinessAccount]) {
            return 0;
        }
    }
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 2 ) {
        titleswitchcell   = [tableView dequeueReusableCellWithIdentifier:@"titleSwitchCell"
                                                            forIndexPath:indexPath];
        titleswitchcell.titleLabel.text =  @" Private Account";
        [ titleswitchcell.switchButtonOutlet addTarget:self
                                                action:@selector(privateAccountButtionAction:)
                                      forControlEvents:UIControlEventValueChanged];
        
        if ([self.privateAccountState isEqualToString:@"1"]) {
            [titleswitchcell.switchButtonOutlet setOn:YES];
        }
        else {
            [titleswitchcell.switchButtonOutlet setOn:NO];
        }
       
        NSString *bussinessStatus = [Helper bussinessAccountStatus];
         if ([bussinessStatus isEqualToString:@"1"] ||[bussinessStatus isEqualToString:@"0"]) {
             
       // if([Helper isBusinessAccount])
        
            [titleswitchcell.switchButtonOutlet setEnabled:NO];
        }
        
        
        return titleswitchcell;
    }
    else {
        ImageTitleTableViewCell   *imagetitleCell;
        imagetitleCell   = [tableView dequeueReusableCellWithIdentifier:@"imageTitleCell"
                                                           forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            imagetitleCell.textLabel.text = @"Invite Facebook Friends";
             imagetitleCell.textLabel.textColor = [UIColor colorWithRed:0.0107 green:0.1495 blue:0.3366 alpha:1.0];
            imagetitleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                  imagetitleCell.textLabel.text = [tittleArrayForfirstSection objectAtIndex:indexPath.row];
            }
            else {
                  imagetitleCell.textLabel.text = titleForContacts;
            }
            
            imagetitleCell.textLabel.textColor = [UIColor colorWithRed:0.1569 green:0.1569 blue:0.1569 alpha:1.0];
            imagetitleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else if (indexPath.section == 2) {
            imagetitleCell.textLabel.text =  [titleArryForSecondSection objectAtIndex:indexPath.row];
            imagetitleCell.textLabel.textColor = [UIColor colorWithRed:0.1569 green:0.1569 blue:0.1569 alpha:1.0];
            if (indexPath.row ==2) {
                imagetitleCell.accessoryType = UITableViewCellAccessoryNone;
            }
            if (indexPath.row ==1) {
                imagetitleCell.textLabel.text  = [titleArryForSecondSection objectAtIndex:indexPath.row];
                
            }
            else {
                imagetitleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        else if (indexPath.section ==3)
        {
            imagetitleCell.textLabel.text =  @"Report a Problem";
            imagetitleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            imagetitleCell.textLabel.textColor = [UIColor colorWithRed:0.1569 green:0.1569 blue:0.1569 alpha:1.0];
        }
        else if (indexPath.section == 4 ) {
            
                imagetitleCell.textLabel.text =  [tittleArrayForFourthSection objectAtIndex:indexPath.row];
                imagetitleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                imagetitleCell.textLabel.textColor = [UIColor colorWithRed:0.1569 green:0.1569 blue:0.1569 alpha:1.0];
            
        }
        else if (indexPath.section ==5) {
            imagetitleCell.textLabel.text = @"Log Out";
            imagetitleCell.accessoryType = UITableViewCellAccessoryNone;
            imagetitleCell.textLabel.textColor = [UIColor colorWithRed:0.0107 green:0.1495 blue:0.3366 alpha:1.0];
        }
        
        if (indexPath.section == 0 && indexPath.section == 1) {
            imagetitleCell.imageView.image = [UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
        }
        else {
            imagetitleCell.imageView.image  = nil;
        }
        return imagetitleCell;
    }
}

-(void)privateAccountButtionAction:(id)sender {
    UISwitch *switchButton =(UISwitch *)sender;
    if (switchButton.on) {
        [switchButton setOn:YES];
        //making profile as private
        self.privateAccountState = @"1";
        [self requestForPrivateProfile:@"1"];
        
    }
    else {
        self.privateAccountState = @"0";
        [switchButton setOn:NO];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"PrivateAccountType"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Privacy" message:@"Anyone will be able to see your photos and videos on Picogram.You will no longer need to approve followers." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alert.tag = 23456;
        [alert show];
    }
}

-(void)requestForPrivateProfile:(NSString *)isprivateState {
    // Requesting For set private Api.(passing "token" as parameter)
    // isPrivate [0 : public, 1 : private]
    
    NSDictionary *requestDict = @{
                                  mauthToken :flStrForObj(_token),
                                  misPrivate :isprivateState
                                  };
    [WebServiceHandler setPrivateProfile:requestDict andDelegate:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 23456) {
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked
            //making profile as private.
            [titleswitchcell.switchButtonOutlet setOn:YES];
            } else {
            //ok clicked
            //making profile as public.
            self.privateAccountState = @"0";
            [self requestForPrivateProfile:@"0"];
            }
    }
    else if (alertView.tag == 10) {
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked
        } else {
            //yes clicked
            [self actionForLogout];

        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected section  %ld",(long)indexPath.section);
    NSLog(@"selected section  %ld",(long)indexPath.row);
    
    //section o,row 1 ---> invite facebook friends.
    if (indexPath.section ==0 && indexPath.row ==1) {
    }
    
    //section 1,row o ---> find facebook friends.
    if (indexPath.section == 1 && indexPath.row ==0) {
        [self actionForFindFacebookFriends];
    }
      //section 1,row 1 ---> find  contacts.
     if (indexPath.section == 1 && indexPath.row ==1) {
         [self actionForFindContacts];
    }
    //section 2,row 0 --->Edit Profile
    if (indexPath.section == 2 && indexPath.row ==0) {
        [self actionForeditProfile];
    }
    //section 2,row 1 ---> Switch to Business Profile
    if (indexPath.section == 2 && indexPath.row ==1) {
        if ([self.privateAccountState isEqualToString:@"1"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Business account can't be private" message:@"To switch to a business account must be public" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
        }
        else
        {
            if ([titleArryForSecondSection[indexPath.row] isEqualToString:@"Switch back to personal account"]) {
                [self downgradeFRomBusiness];
            }
            else
            {
                
                NSString *type = flStrForObj([Helper bussinessAccountStatus]);
                
                //BussinessAccountStatus
                //admin should accept it
                //0 means requested
                //1 : accepted
                //2 : rejected
                //rolled back (under dev)
                
                if ([type isEqualToString:@"3"] ) {
                    [self requestForUpgradeToBussiness];
                }
                else {
                    businessHelpViewController *businessVC = [[businessHelpViewController alloc] init];
                    self.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:businessVC animated:YES];
                    [businessVC.navigationController setNavigationBarHidden:YES];
                    self.hidesBottomBarWhenPushed=NO;
                }
            }
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    //section 2,row 1 ---> Private Account
    if (indexPath.section == 2 && indexPath.row ==1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    //section 3,row 0 ---> Report a Problem
    if (indexPath.section ==3 && indexPath.row ==0) {
        [self reportaProblem];
        
    }
    //section 4,row 1---> EULA
    if (indexPath.section ==4 && indexPath.row ==2) {
        WebViewForDetailsVc *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailWebViewStoryBoardId"];
        newView.showTermsAndPolicy = YES;
        newView.showElu = YES;
        [self.navigationController pushViewController:newView animated:YES];
        
    }
    //section 4,row 0 ---> privacy Policy
    if (indexPath.section == 4 && indexPath.row ==0) {
        
        WebViewForDetailsVc *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailWebViewStoryBoardId"];
        newView.showTermsAndPolicy = NO;
        [self.navigationController pushViewController:newView animated:YES];
        
//        [self performSegueWithIdentifier:@"optionsToWebViewSegue" sender:nil];
    }
    //section 4,row 1---> Terms
    if (indexPath.section ==4 && indexPath.row ==1) {
        WebViewForDetailsVc *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailWebViewStoryBoardId"];
        newView.showTermsAndPolicy = YES;
        [self.navigationController pushViewController:newView animated:YES];
    }
    //section 5,row 0--->  Logout
    if (indexPath.section ==5 && indexPath.row ==0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure want to logout" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alert.tag = 10;
        [alert show];
    }
}

-(void)requestForUpgradeToBussiness {
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showMessage:@"Updating to business Profile.." On:self.view];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:userDetailForBussiness];
    NSDictionary *userData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSDictionary *requestDict = @{
                                  mauthToken            :flStrForObj([Helper userToken]),
                                  mbusinessName         :flStrForObj(userData[@"businessName"]),
                                  maboutBusiness        :flStrForObj(userData[@"aboutBusiness"]),
                                  mlocation             :flStrForObj(userData[@"place"]),
                                  mlatitude             :flStrForObj(userData[@"latitude"]),
                                  mlongitude            :flStrForObj(userData[@"longitude"]),
                                  mwebsite              :flStrForObj(userData[@"website"]),
                                  mphoneNumber          :flStrForObj(userData[@"phoneNumber"]),
                                  };
    
    [WebServiceHandler updradeToBusniessProfile:requestDict andDelegate:self];
}

-(void)reportaProblem {
    FeddBackViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"feedBackVcStoryBoardId"];
    [self.navigationController pushViewController:postsVc animated:YES];
}

-(void)actionForFindFacebookFriends {
    // connectToFaceBookFriendsStoryBoardId
    
     ConnectToFaceBookViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"connectToFaceBookFriendsStoryBoardId"];
     postsVc.syncingContactsOf = @"faceBook";
    [self.navigationController pushViewController:postsVc animated:YES];
}


-(void)actionForFindContacts {
    ConnectToFaceBookViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"connectToFaceBookFriendsStoryBoardId"];
    postsVc.syncingContactsOf = @"phoneBook";
    [self.navigationController pushViewController:postsVc animated:YES];
}

-(void)actionForInviteFaceBookFriends {
    
}

-(void)actionForLogout {
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    status =  kABAuthorizationStatusDenied;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userDetail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userDetailWhileRegistration"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"preferenceName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userFbDetails"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"phoneContacts"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ProfileWebUrl"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ProfileContact"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ProfileEmail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Profilebio"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PrivateAccountType"]; 
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BussinessSuccessCheck"];
       [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BussinessAccountStatus"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDetailForBussiness];

    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:numberOfFbFriendFoundInPicogram];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:numberOfContactsFoundInPicogram];
    
    
    [[NSUserDefaults standardUserDefaults]synchronize];

//    [self performSegueWithIdentifier:@"logOutSegue" sender:nil];
    
    
        // it will jump to root view controoler.(making viewcontroller as login screen).
    
        AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
    
    
        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"loginVcStoryBoardId"];
    
        UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
        appDelegateTemp.window.rootViewController = navigation;

}


-(void)actionForPricayPolicy {
    PGPrivacyPolicyViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"LinkWebViewController"];
    [self.navigationController pushViewController:postsVc animated:YES];
}

-(void)actionForeditProfile {
     EditProfileViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfiileScereenStoryBoardId"];
     postsVc.necessarytocallEditProfile = YES;
     [self.navigationController pushViewController:postsVc animated:YES];
}

-(void)downgradeFRomBusiness
{
    
    NSDictionary *requestDict = @{
                                  mauthToken :flStrForObj(_token),
                                  };
    [WebServiceHandler downgradeFromBusinessProfile:requestDict andDelegate:self];
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showMessage:@"Processing.." On:self.view];
}

/*-------------------------------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*-------------------------------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    
    //storing the response from server to dictonary.
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypeDowngradeFromBusinessProfile) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                
                NSString *type =@"3";
                [[NSUserDefaults standardUserDefaults] setValue:type forKey:@"BussinessAccountStatus" ];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                titleArryForSecondSection = [[NSArray alloc] initWithObjects:@"Edit Profile",@"Switch to Business",@"Private Account",nil];
                [self.optionsTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation: UITableViewRowAnimationFade];
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"BusinessProfileDetails"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bussinessProfileUpdated" object:nil];
                // [self.optionTblV reloadData];
            }
                break;
                //failure response.
            case 23462: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1972: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1973: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1974: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
    
    //checking the request type and handling respective response code.
    if (requestType == RequestTypesetPrivateProfile) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                NSString *privateKey = flStrForObj(responseDict[@"data"][0][@"isPrivate"]);
                if ([flStrForObj(privateKey) isEqualToString:@"1"]) {
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"PrivateAccountType"];
                }
                else [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"PrivateAccountType"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            }
                break;
                //failure response.
            case 23462: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1972: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1973: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1974: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }

    if (requestType == RequestTypeGetupdradeToBusniessProfile ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                ProgressIndicator *pi = [ProgressIndicator sharedInstance];
                [pi hideProgressIndicator];
                
                
                NSString *type =@"1";
                [[NSUserDefaults standardUserDefaults] setValue:type forKey:@"BussinessAccountStatus" ];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"bussinessProfileUpdated" object:nil];
                
                titleArryForSecondSection = [[NSArray alloc] initWithObjects:@"Edit Profile",@"Switch back to personal account",@"Private Account",nil];
                [self.optionsTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation: UITableViewRowAnimationFade];
                
                [Helper showAlertWithTitle:@"Welcome" Message:@"Your Business profile is now active on your Picogram profile,hope you grow your business on Picogram "];
            }
                break;
                //failure responses.
            case 2021: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 2022: {
                [self errAlert:responseDict[@"message"]];
                
            }
                break;
            default:
                break;
        }
    }
}

- (void)errAlert:(NSString *)message {
    //creating alert for error message.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}

-(void)viewWillDisappear:(BOOL)animated {
     [_delegate sendPrivateStatusToUserProfileVc:_privateAccountState];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    
   self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
    
    self.tabBarController.tabBar.hidden = NO;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    //BOOL new = [[NSUserDefaults standardUserDefaults]boolForKey:@"BussinessSuccessCheck"];
    
    NSString *bussinessStatus = [Helper bussinessAccountStatus];
    
    if ([bussinessStatus isEqualToString:@"1"] ||[bussinessStatus isEqualToString:@"0"]) {
        
//    if ([Helper isBusinessAccount]) {
        
        NSString *type = flStrForObj([Helper bussinessAccountStatus]);
        
        //BussinessAccountStatus
        //admin should accept it
        //0 means requested
        //1 : accepted
        //2 : rejected
        //3:rolled back (under dev)
        
        if ([type isEqualToString:@"0"]) {
          titleArryForSecondSection = [[NSArray alloc] initWithObjects:@"Edit Profile",@"Requested For Bussiness",@"Private Account",nil];
        }
        else if ([type isEqualToString:@"1"]) {
            titleArryForSecondSection = [[NSArray alloc] initWithObjects:@"Edit Profile",@"Switch back to personal account",@"Private Account",nil];
        }
        else if ([type isEqualToString:@"2"]) {
            titleArryForSecondSection = [[NSArray alloc] initWithObjects:@"Edit Profile",@"Switch to Bussiness",@"Private Account",nil];
        }
        else if ([type isEqualToString:@"3"]) {
            
            titleArryForSecondSection = [[NSArray alloc] initWithObjects:@"Edit Profile",@"Switch to Bussiness",@"Private Account",nil];
        }
        else {
          titleArryForSecondSection = [[NSArray alloc] initWithObjects:@"Edit Profile",@"Switch to Bussiness",@"Private Account",nil];
        }
    }
}

@end
