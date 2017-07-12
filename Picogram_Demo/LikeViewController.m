//
//  LikeViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 4/19/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "LikeViewController.h"
#import "pop/POP.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "UserProfileViewController.h"
#import "TinderGenericUtility.h"
#import "ProgressIndicator.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "FontDetailsClass.h"
#import "Helper.h"


@interface LikeViewController ()<WebServiceHandlerDelegate>
{
    NSMutableArray *followersresponseData;
    NSMutableArray *followingresponseData;
    NSMutableArray *likesResponseArray;
    
    NSMutableArray *arrayOfusername;
    NSMutableArray *arrayOffullname;
    NSMutableArray *arrayOfProfilePicUrl;
    NSMutableArray *arrayOfFollowingStaus;
    NSMutableArray *arrayOfMemberPrivateStatus;
    
    UIRefreshControl *refreshControl;
}
@end

@implementation LikeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //customizing nav bar.
    [self navigationBarCustomization];
    [self addRefreshControl];
    
    
    
    
    
    self.progressIndicatorView.hidden = NO;
    self.tableView.hidden = YES;
    
    
    
    
    //if user wants to see followerslist then followerslistapi will call and passing token as parameter.
    
    if([self.navigationTitle isEqualToString:@"FOLLOWERS"]) {
        [self requestForFollowersDetails];
    }
    
    //if user wants to see followinglist then followinglistapi will call and passing token as parameter.
    if ([self.navigationTitle isEqualToString:@"FOLLOWING"]) {
        [self requestForFollowingDetails];
    }
    
    if ([self.navigationTitle isEqualToString:@"Likers"]) {
        [self requestAllLikesOnPost];
    }
    
    [self updateFollowStatus];
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
}

-(void)updateFollowStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollwoStatus:) name:@"updatedFollowStatus" object:nil];
}


-(void)updateFollwoStatus:(NSNotification *)noti {
    //check the postId and Its Index In array.
        NSString *userName = flStrForObj(noti.object[@"newUpdatedFollowData"][@"userName"]);
        NSString *foolowStatusRespectToUser = noti.object[@"newUpdatedFollowData"][@"newFollowStatus"];
    
    
        for (int i=0; i <arrayOfusername.count;i++) {
            if ([flStrForObj(arrayOfusername[i]) isEqualToString:userName]) {
                arrayOfFollowingStaus[i] = foolowStatusRespectToUser;
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:0];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
}

-(void)addRefreshControl {
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
}


-(void)refreshTable:(id)sender {
    
    if ([self.navigationTitle isEqualToString:@"Likers"]) {
        [self requestAllLikesOnPost];
    }
    if ([self.navigationTitle isEqualToString:@"FOLLOWING"])  {
        [self requestForFollowingDetails];
    }
    if([self.navigationTitle isEqualToString:@"FOLLOWERS"]) {
        [self requestForFollowersDetails];
    }
   
}

-(void)requestAllLikesOnPost {
    NSDictionary *requestDict = @{
                                  mauthToken:flStrForObj([Helper userToken]),
                                  mpostid:flStrForObj(self.postId),
                                  mposttype:self.postType,// 0 for photo and 1 for video.
                                  moffset:flStrForObj([NSNumber numberWithInteger:0]),
                                  mlimit:flStrForObj([NSNumber numberWithInteger:20])
                                  };
    [WebServiceHandler getAllLikesOnPost:requestDict andDelegate:self];
}

-(void)requestForFollowersDetails {
    //user can check his/her own  following list or he can check others.
    if (self.getdetailsDetailsOfUserName && ![self.getdetailsDetailsOfUserName isEqualToString:[Helper userName]]) {
        NSDictionary *requestDict = @{mauthToken : flStrForObj([Helper userToken]),
                                      mmemberName :self.getdetailsDetailsOfUserName
                                      };
        [WebServiceHandler getMemberFollowersList:requestDict andDelegate:self];
    }
    else {
        NSDictionary *requestDict = @{mauthToken : flStrForObj([Helper userToken]),
                                      };
        [WebServiceHandler getFollowersList:requestDict andDelegate:self];
    }
}

-(void)requestForFollowingDetails {
    //user can check his/her own  followers list or he can check others.
    if (self.getdetailsDetailsOfUserName && ![self.getdetailsDetailsOfUserName isEqualToString:[Helper userName]]) {
        NSDictionary *requestDict = @{mauthToken : flStrForObj([Helper userToken]),
                                      mmemberName :self.getdetailsDetailsOfUserName
                                      };
        [WebServiceHandler getMemberFollowingList:requestDict andDelegate:self];
    }
    else {
        NSDictionary *requestDict = @{mauthToken : flStrForObj([Helper userToken]),
                                      };
        [WebServiceHandler getFollowingList:requestDict andDelegate:self];
    }
}

/*-------------------------------------------*/
#pragma mark -
#pragma mark - viewDidLoad methods defination
/*-------------------------------------------*/

-(void)navigationBarCustomization {
    //navigationtitle is setby string name navigationTitle (bcoz this view controller common for like,followers and following view controllers.)
    self.navigationItem.title = self.navigationTitle;
    
    //customizing navigationBar.
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    // creating navigationBar left buttton.
    [self createNavLeftButton];
}

/*-------------------------------------------*/
#pragma mark
#pragma mark - navigation bar buttons
/*-------------------------------------------*/

- (void)createNavLeftButton {
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    // UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)sendNewFollowStatusThroughNotification:(NSString *)userName andNewStatus:(NSString *)newFollowStatus {
    
   
    
    NSDictionary *newFollowDict = @{@"newFollowStatus"     :flStrForObj(newFollowStatus),
                                    @"userName"            :flStrForObj(userName),
                                  };
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedFollowStatus" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"newUpdatedFollowData"]];
}

/*---------------------------------------------------------*/
#pragma mark
#pragma mark -tableview delegates and datasource methods.
/*---------------------------------------------------------*/

/**
 *  tableView Delegates
 *  @return numberOfRowsInSection
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.navigationTitle isEqualToString:@"FOLLOWERS"]) {
        return  followersresponseData.count;
    }
    else if ([self.navigationTitle isEqualToString:@"FOLLOWING"]) {
        return followingresponseData.count;
    }
    else if ([self.navigationTitle isEqualToString:@"Likers"]) {
        return likesResponseArray.count;
    }
    else
        return 0;
}

/*
 *  @return customized cell
 */
-(void)updateFollowButtonTitle :(NSInteger )row and:(id)sender {
    
    
    UIButton *reeceivedButton = (UIButton *)sender;
    
    reeceivedButton .layer.cornerRadius = 5;
    reeceivedButton .layer.borderWidth = 1;
    
    //[reeceivedButton  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    //  if follow status is 0 ---> title as "Requested"
    //  if follow status is 1 ---> title as "Following"
    //  if follow status is nil ---> title as "Follow"
    
   
      
    if ([arrayOfFollowingStaus[row]  isEqualToString:@"0"]) {
        [reeceivedButton  setTitle:@" REQUESTED" forState:UIControlStateNormal];
        [reeceivedButton setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
        [reeceivedButton setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
        reeceivedButton.backgroundColor = requstedButtonBackGroundColor;
        reeceivedButton .layer.borderColor = [UIColor clearColor].CGColor;
    }
    else if(([arrayOfFollowingStaus[row]  isEqualToString:@"1"])) {
        [reeceivedButton  setTitle:@" Following" forState:UIControlStateNormal];
       [reeceivedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
        [reeceivedButton setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
        reeceivedButton.backgroundColor = followingButtonBackGroundColor;
        reeceivedButton.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else {
        
        [reeceivedButton  setTitle:@" Follow" forState:UIControlStateNormal];
      [reeceivedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
        reeceivedButton.backgroundColor = followButtonBackGroundColor;
        [reeceivedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
        reeceivedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    }
    
    
    
    
    if ([arrayOfusername[row]  isEqualToString:flStrForObj([Helper userName])]) {
        reeceivedButton.hidden = YES;
    }
    else {
        reeceivedButton.hidden = NO;
    }
    
    reeceivedButton.tag = 1000 + row;
    [reeceivedButton addTarget:self
                                action:@selector(cellFollowButtonAction:)
                      forControlEvents:UIControlEventTouchUpInside];
}

-(void)addProfilePic:(NSInteger )row profileImage:(UIImageView *)profileImageView{
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:[arrayOfProfilePicUrl objectAtIndex:row]] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
     [self.view layoutIfNeeded];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2;
    profileImageView.clipsToBounds = YES;
}

-(void)addUserDeatils:(NSInteger )row  usernameLabel:(UILabel *)usernameLabel fullnameLabel:(UILabel *)fullnameLabel{
    fullnameLabel.text = arrayOffullname[row];
    usernameLabel.text = arrayOfusername[row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
      LikeTableViewCell *cell ;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"commentsCell"
                                                                          forIndexPath:indexPath];
    [self addUserDeatils:indexPath.row usernameLabel:cell.userNameLabelOutlet fullnameLabel:cell.NameLabelOutlet];
    
    [self updateFollowButtonTitle:indexPath.row and:cell.followButtonOutlet];
    [cell layoutIfNeeded];
    [self addProfilePic:indexPath.row profileImage:cell.profileImageViewOutlet];
    return cell;
}

-(void)cellFollowButtonAction:(id)sender {
    
    
    UIButton *selectedButton = (UIButton *)sender;
    
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    NSString *memberPrivateAccountState = arrayOfMemberPrivateStatus[selectedButton.tag%1000] ;
    
    
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([selectedButton.titleLabel.text isEqualToString:@" Follow"]) {
            [selectedButton  setTitle:@" REQUESTED" forState:UIControlStateNormal];
            [selectedButton setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfusername[selectedButton.tag%1000]) andNewStatus:@"0"];
            
            arrayOfFollowingStaus[selectedButton.tag%1000] = @"0";
            
          
            [selectedButton setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            
            selectedButton.backgroundColor = requstedButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor clearColor].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :arrayOfusername[selectedButton.tag %1000],
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
        else if ([selectedButton.titleLabel.text isEqualToString:@" Following"])  {
            [self showUnFollowAlert:flStrForObj(arrayOfProfilePicUrl[selectedButton.tag%1000]) and:arrayOfusername[selectedButton.tag%1000]  and:sender];
        }
        else {
            // cancel request for follow.
            [selectedButton  setTitle:@" Follow" forState:UIControlStateNormal];
            [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            arrayOfFollowingStaus[selectedButton.tag%1000] = @"2";
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfusername[selectedButton.tag%1000]) andNewStatus:@"2"];
            
           
            selectedButton.backgroundColor = followButtonBackGroundColor;
            
            
            [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            
            
            NSDictionary *requestDict = @{muserNameToUnFollow     : flStrForObj(arrayOfusername[selectedButton.tag%1000]) ,
                                          mauthToken            :[Helper userToken],
                                          };
            
            [WebServiceHandler unFollow:requestDict andDelegate:self];
            
            
        }
    }
    
    //actions for when the account is public.
    else {
        if ([selectedButton.titleLabel.text isEqualToString:@" Following"]) {
             [self showUnFollowAlert:flStrForObj(arrayOfProfilePicUrl[selectedButton.tag%1000]) and:arrayOfusername[selectedButton.tag%1000]  and:sender];
        }
        else {
            
            [selectedButton  setTitle:@" Following" forState:UIControlStateNormal];
            [selectedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            arrayOfFollowingStaus[selectedButton.tag%1000] = @"1";
             [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfusername[selectedButton.tag%1000]) andNewStatus:@"1"];
           
            [selectedButton setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
            
            
            selectedButton.backgroundColor = followingButtonBackGroundColor;
            
            selectedButton.layer.borderColor = [UIColor clearColor].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :arrayOfusername[selectedButton.tag %1000],
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.navigationTitle isEqualToString:@"FOLLOWERS"]) {
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        newView.checkProfileOfUserNmae = arrayOfusername[indexPath.row];
        newView.checkingFriendsProfile = YES;
        [self.navigationController pushViewController:newView animated:YES];
    }
    else if([self.navigationTitle isEqualToString:@"FOLLOWING"]){
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        newView.checkProfileOfUserNmae = arrayOfusername[indexPath.row];
        newView.checkingFriendsProfile = YES;
        [self.navigationController pushViewController:newView animated:YES];
    }
    else if([self.navigationTitle isEqualToString:@"Likers"]){
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        newView.checkProfileOfUserNmae = flStrForObj(likesResponseArray[indexPath.row][@"username"]);
        newView.checkingFriendsProfile = YES;
        [self.navigationController pushViewController:newView animated:YES];
    }
    else {
    }
 }

/*---------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*---------------------------------*/

//handling response
- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
     [refreshControl endRefreshing];
    
    self.progressIndicatorView.hidden = YES;
    self.tableView.hidden = NO;
    
    if (error) {
        [refreshControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];//Send via SMS
        [alert show];
        return;
    }
    NSDictionary *responseDict = (NSDictionary*)response;
    
    //response for requesttype :: RequestTypeGetFollowingList.
    if (requestType == RequestTypeGetFollowingList ) {
        switch ([responseDict[@"code"] integerValue]) {
                //response code 200 for success.
            case 200: {
                [self handlingSuccessResponseOfFollowingList:responseDict];
            }
                break;
            default:
                break;
        }
    }
    
    //response for requesttype :: RequestTypeGetFollowersList.
    if (requestType == RequestTypeGetFollowersList ) {
        
        switch ([responseDict[@"code"] integerValue]) {
                //response code 200 for success.
            case 200 :{
                [self handlingSuccessResponseOfFollowersList:responseDict];
            }
                break;
            default:
                break;
        }
    }
    //response for requesttype :: RequestTypeGetFollowersList.
    if (requestType == RequestTypeGetMemberFollowersList ) {
        
        switch ([responseDict[@"code"] integerValue]) {
                //response code 200 for success.
            case 200 :{
                [self handlingSuccessResponseOfMemberFollowersList:responseDict];
            }
                break;
            default:
                break;
        }
    }
    //response for requesttype :: RequestTypeGetFollowingList.
    if ( requestType == RequestTypeGetMemberFollowingList) {
        switch ([responseDict[@"code"] integerValue]) {
                //response code 200 for success.
            case 200: {
                [self handlingSuccessResponseOfMemberFollowingList:responseDict];
            }
                break;
            default:
                break;
        }
    }

    if (requestType == RequestTypeGetAllLikesOnPost) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200:
            {
                [self handlingSuccessResponseOfLikesList:responseDict];
                
                
                likesResponseArray = [[NSMutableArray alloc] init];
                likesResponseArray = [responseDict[@"data"] mutableCopy];
                
                [self.tableView reloadData];
            }
                break;
            default:
                break;
        }
    }
}

- (void)errrAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}

-(void)handlingSuccessResponseOfLikesList:(NSDictionary *)likesListData {
    
    if (likesListData) {
        //arrayOfFollowingusername(contains only Followersusername),arrayOfFollowingname(contains only name),followingresponseData(contains array of Followingusername and name),FollowingListData(dictonary contains data of success response).
        
        arrayOfusername =[[NSMutableArray alloc] init];
        arrayOffullname = [[NSMutableArray alloc] init];
        arrayOfProfilePicUrl =  [[NSMutableArray alloc] init];
        arrayOfFollowingStaus = [[NSMutableArray alloc] init];
        arrayOfMemberPrivateStatus = [[NSMutableArray alloc] init];
        
        likesResponseArray = likesListData[@"data"];
        
        /*
         *  separating userName,fullname and thumbnailimageUrl from followingresponseData array and intialinzing in separate arrays.
         */
        for(int i = 0; i< likesResponseArray.count;i++) {
            NSString *userName = flStrForObj(likesResponseArray[i][@"username"]);
            NSString *fullName = flStrForObj( likesResponseArray[i][@"fullname"]);
            NSString *profilePicUrl = flStrForObj(likesResponseArray[i][@"profilePicUrl"]);
            NSString *followingstatus =  [NSString stringWithFormat:@"%@", likesResponseArray[i][@"userFollowRequestStatus"]];
            
            NSString *memberPrivateStatus = [NSString stringWithFormat:@"%@", likesResponseArray[i][@"memberPrivateFlag"]];
          
            //adding user names  to the array.
            [arrayOfusername addObject:userName];
            [arrayOffullname addObject:fullName];
            [arrayOfProfilePicUrl addObject:profilePicUrl];
            [arrayOfFollowingStaus addObject:followingstatus];
            [arrayOfMemberPrivateStatus addObject:memberPrivateStatus];
        }
    }
    [self.tableView reloadData];
}

//getting response of followersList api and converting into arrays(arrayOfFollowersusername,arrayOfFollowersname to populate the data in tableview).

-(void)handlingSuccessResponseOfFollowersList:(NSDictionary *)FollowersListData {
    if (FollowersListData) {
        //arrayOfFollowersusername(contains only Followersusername),arrayOfFollowersname(contains only name),followersresponseData(contains array of Followersusername and name),FollowersListData(dictonary contains data of success response).
        
        arrayOfusername =[[NSMutableArray alloc] init];
        arrayOffullname = [[NSMutableArray alloc] init];
        arrayOfProfilePicUrl =  [[NSMutableArray alloc] init];
        arrayOfFollowingStaus = [[NSMutableArray alloc] init];
        followersresponseData =[[NSMutableArray alloc] init];
        arrayOfMemberPrivateStatus = [[NSMutableArray alloc] init];
        
        
        followersresponseData = FollowersListData[@"followers"];
        
        
        /*
         *  separating userName,fullname and thumbnailimageUrl from followersresponseData array and intialinzing in separate arrays.
         */
        for(int i = 0; i< followersresponseData.count;i++) {
            
            NSString *userName = followersresponseData[i][@"username"];
            NSString *fullName = flStrForObj( followersresponseData[i][@"fullname"]);
            NSString *profilePicUrl = flStrForObj(followersresponseData[i][@"profilePicUrl"]);
//            NSString *followingstatus =  [NSString stringWithFormat:@"%@", followersresponseData[i][@"FollowedBack"]];
            
            NSString *followingstatus =  [NSString stringWithFormat:@"%@", followersresponseData[i][@"userFollowRequestStatus"]];
            
             NSString *memberPrivateStatus = [NSString stringWithFormat:@"%@", followersresponseData[i][@"memberPrivateFlag"]];
            
            //adding user names  to the array.
            [arrayOfusername addObject:userName];
            [arrayOffullname addObject:fullName];
            [arrayOfProfilePicUrl addObject:profilePicUrl];
            [arrayOfFollowingStaus addObject:followingstatus];
            [arrayOfMemberPrivateStatus addObject:memberPrivateStatus];

        }
    }
    [self.tableView reloadData];
}

//getting response of followingList api and converting into arrays(arrayOfFollowingusername,arrayOfFollowingname to populate the data in tableview).
-(void)handlingSuccessResponseOfFollowingList:(NSDictionary *)FollowingListData {
    if (FollowingListData) {
        //arrayOfFollowingusername(contains only Followersusername),arrayOfFollowingname(contains only name),followingresponseData(contains array of Followingusername and name),FollowingListData(dictonary contains data of success response).
        
        arrayOfusername =[[NSMutableArray alloc] init];
        arrayOffullname = [[NSMutableArray alloc] init];
        arrayOfProfilePicUrl =  [[NSMutableArray alloc] init];
        followingresponseData =[[NSMutableArray alloc] init];
         arrayOfFollowingStaus = [[NSMutableArray alloc] init];
        arrayOfMemberPrivateStatus = [[NSMutableArray alloc] init];
        followingresponseData = FollowingListData[@"result"];
    
        /*
         *  separating userName,fullname and thumbnailimageUrl from followingresponseData array and intialinzing in separate arrays.
         */
        for(int i = 0; i< followingresponseData.count;i++) {
            NSString *userName =flStrForObj( followingresponseData[i][@"username"]);
            NSString *fullName = flStrForObj( followingresponseData[i][@"fullName"]);
            NSString *profilePicUrl = flStrForObj(followingresponseData[i][@"profilePicUrl"]);
            NSString *followingstatus =  [NSString stringWithFormat:@"%@", followingresponseData[i][@"userFollowRequestStatus"]];
            
            NSString *memberPrivateStatus = [NSString stringWithFormat:@"%@", followingresponseData[i][@"memberPrivateFlag"]];
         
           // NSString *followingstatus =  [NSString stringWithFormat:@"%@",@"1"];
            [arrayOfFollowingStaus addObject:followingstatus];
            
         //adding user names  to the array.
            [arrayOfusername addObject:userName];
            [arrayOffullname addObject:fullName];
            [arrayOfProfilePicUrl addObject:profilePicUrl];
            [arrayOfMemberPrivateStatus addObject:memberPrivateStatus];
        }
    }
    [self.tableView reloadData];
}
//getting response of followingList api and converting into arrays(arrayOfFollowingusername,arrayOfFollowingname to populate the data in tableview).
-(void)handlingSuccessResponseOfMemberFollowingList:(NSDictionary *)FollowingListData {
  
    if (FollowingListData) {
        //arrayOfFollowingusername(contains only Followersusername),arrayOfFollowingname(contains only name),followingresponseData(contains array of Followingusername and name),FollowingListData(dictonary contains data of success response).
        arrayOfusername =[[NSMutableArray alloc] init];
        arrayOffullname = [[NSMutableArray alloc] init];
        arrayOfProfilePicUrl =  [[NSMutableArray alloc] init];
        arrayOfFollowingStaus = [[NSMutableArray alloc] init];
        arrayOfMemberPrivateStatus = [[NSMutableArray alloc] init];
        followingresponseData =[[NSMutableArray alloc] init];
        followingresponseData = FollowingListData[@"following"];
        /*
         *  separating userName,fullname and thumbnailimageUrl from followingresponseData array and intialinzing in separate arrays.
         */
        for(int i = 0; i< followingresponseData.count;i++) {
            NSString *userName =flStrForObj( followingresponseData[i][@"username"]);
            NSString *fullName = flStrForObj( followingresponseData[i][@"fullname"]);
            NSString *profilePicUrl = flStrForObj(followingresponseData[i][@"profilePicUrl"]);
       
            NSString *followingstatus =  [NSString stringWithFormat:@"%@", followingresponseData[i][@"userFollowRequestStatus"]];
            
            NSString *memberPrivateStatus = [NSString stringWithFormat:@"%@", followingresponseData[i][@"memberPrivateFlag"]];
            
            [arrayOfFollowingStaus addObject:followingstatus];
       
            //adding user names  to the array.
            [arrayOfusername addObject:userName];
            [arrayOffullname addObject:fullName];
            [arrayOfProfilePicUrl addObject:profilePicUrl];
            [arrayOfMemberPrivateStatus addObject:memberPrivateStatus];
        }
    }
    [self.tableView reloadData];
}

//getting response of followingList api and converting into arrays(arrayOfFollowingusername,arrayOfFollowingname to populate the data in tableview).

-(void)handlingSuccessResponseOfMemberFollowersList:(NSDictionary *)FollowersListData {

    if (FollowersListData) {
        //arrayOfFollowingusername(contains only Followersusername),arrayOfFollowingname(contains only name),followingresponseData(contains array of Followingusername and name),FollowingListData(dictonary contains data of success response).
        
        arrayOfusername =[[NSMutableArray alloc] init];
        arrayOffullname = [[NSMutableArray alloc] init];
        arrayOfProfilePicUrl =  [[NSMutableArray alloc] init];
        followersresponseData =[[NSMutableArray alloc] init];
         arrayOfFollowingStaus = [[NSMutableArray alloc] init];
        arrayOfMemberPrivateStatus =[[NSMutableArray alloc] init];
        followersresponseData = FollowersListData[@"memberFollowers"];
        
        /*
         *  separating userName,fullname and thumbnailimageUrl from followingresponseData array and intialinzing in separate arrays.
         */
        for(int i = 0; i< followersresponseData.count;i++) {
            NSString *userName = flStrForObj(followersresponseData[i][@"username"]);
            NSString *fullName = flStrForObj( followersresponseData[i][@"fullname"]);
            NSString *profilePicUrl = flStrForObj(followersresponseData[i][@"profilePicUrl"]);
            
            NSString *followingstatus =  [NSString stringWithFormat:@"%@", followersresponseData[i][@"userFollowRequestStatus"]];
            NSString *memberPrivateStatus = [NSString stringWithFormat:@"%@", followersresponseData[i][@"memberPrivateFlag"]];
            
            [arrayOfFollowingStaus addObject:followingstatus];

            //adding user names  to the array.
            [arrayOfusername addObject:userName];
            [arrayOffullname addObject:fullName];
            [arrayOfProfilePicUrl addObject:profilePicUrl];
            [arrayOfMemberPrivateStatus addObject:memberPrivateStatus];
        }
    }
    [self.tableView reloadData];
}



/*-----------------------------------------------------*/
#pragma mark -
#pragma mark - CustomActionSheet
/*----------------------------------------------------*/
- (void)showUnFollowAlert:(NSString *)profileUrl and:(NSString *)profileName  and:(id)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    CGFloat margin = 8.0F;
    UIView *customView;
    customView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0F, 80)];
    
    UIImageView *UserImageView =[[UIImageView alloc] init];
   // UserImageView.image = profieImage;
    
    [UserImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(profileUrl)] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
    
    UserImageView.frame = CGRectMake(customView.frame.size.width/2-20,10,40,40);
     [self.view layoutIfNeeded];
    UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
    UserImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    UserImageView.layer.borderWidth = 2.0;
    UserImageView.layer.masksToBounds = YES;
    customView.backgroundColor = [UIColor colorWithRed:0.9753 green:0.9753 blue:0.9753 alpha:1.0];
    
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
    
    UIAlertAction *actionForUnfollow = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self unfollowAction:sender];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    [alertController addAction:actionForUnfollow];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)unfollowAction:(id)sender {
    NSLog(@"unfollow clicked");
    UIButton *selectedButton = (UIButton *)sender;
    
    [selectedButton  setTitle:@" Follow" forState:UIControlStateNormal];
    [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
    arrayOfFollowingStaus[selectedButton.tag%1000] = @"2";
    
    [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfusername[selectedButton.tag%1000]) andNewStatus:@"2"];

    selectedButton.backgroundColor = followButtonBackGroundColor;
    
    
    [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
    selectedButton .layer.borderColor = [UIColor colorWithRed:0.2196 green:0.5882 blue:0.9412 alpha:1.0].CGColor;
    
    
    //passing parameters.
    NSDictionary *requestDict = @{muserNameToUnFollow: arrayOfusername[selectedButton.tag %1000],
                                  mauthToken            :flStrForObj([Helper userToken]),
                                  };
    //requesting the service and passing parametrs.
    [WebServiceHandler unFollow:requestDict andDelegate:self];
}


/*--------------------------------------*/
#pragma mark - UIsearchbardelegate.
/*--------------------------------------*/

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  
    [searchBar resignFirstResponder];
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

@end
