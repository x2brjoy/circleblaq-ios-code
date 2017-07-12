//
//  ApprovePrivateRequestViewController.m
//  Picogram
//
//  Created by Rahul_Sharma on 06/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ApprovePrivateRequestViewController.h"
#import "ApproveOrRejectPrivateRequestTableViewCell.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "Helper.h"
#import "TinderGenericUtility.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "UserProfileViewController.h"
#import "FontDetailsClass.h"

@interface ApprovePrivateRequestViewController ()<UITableViewDelegate,UITableViewDataSource,WebServiceHandlerDelegate>
{
    NSMutableArray *responseForPrivateRequest;
    UIActivityIndicatorView *av;
    NSMutableArray *userRespondedOnStatus;
    
}
@end

@implementation ApprovePrivateRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self requestForPrivteReuests];
    [self createActivityViewInNavbar];
    
    self.title = @"Follow Requests";
    
    //   [self customizingSearchBar];
    //    self.searchBarOutlet.barTintColor = [UIColor whiteColor];
    //    self.searchBarOutlet.tintColor = [UIColor blackColor];
    
    userRespondedOnStatus = [[NSMutableArray alloc] init];
    [self notificationForNumberOfPrivateRequests];
    [self updateFollowStatus];
    
    [self createNavLeftButton];
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

-(void)updateFollowStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollwoStatus:) name:@"updatedFollowStatus" object:nil];
}

-(void)updateFollwoStatus:(NSNotification *)noti {
    //check the postId and Its Index In array.
    
    NSString *userName = flStrForObj(noti.object[@"newUpdatedFollowData"][@"userName"]);
    NSString *foolowStatusRespectToUser = noti.object[@"newUpdatedFollowData"][@"newFollowStatus"];
    
    for (int i=0; i <responseForPrivateRequest.count;i++) {
        if ([flStrForObj(responseForPrivateRequest[i][@"membername"]) isEqualToString:userName]) {
            responseForPrivateRequest[i][@"userFollowRequestStatus"] = foolowStatusRespectToUser;
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            [self.privateRequestTableview reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}


-(void)notificationForNumberOfPrivateRequests {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePrivateRequestStatus:) name:@"updatePrivateRequstedPeopleNumber" object:nil];
}

-(void)updatePrivateRequestStatus:(NSNotification *)noti {
    
    NSString *userName = flStrForObj(noti.object[@"statusForRequst"][0][@"membername"]);
    NSString *messageForStatus = flStrForObj(noti.object[@"statusForRequst"][0][@"message"]);
    
    if ([messageForStatus containsString:@"accept"]) {
        for (int i=0; i <responseForPrivateRequest.count;i++) {
            
            if ([flStrForObj(responseForPrivateRequest[i][@"membername"]) isEqualToString:userName])
            {
                //NSUInteger atSection = [selectedCellIndexPathForActionSheet section];
                
                [userRespondedOnStatus setObject:@"no" atIndexedSubscript:i];
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:0];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,nil];
                [self.privateRequestTableview reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    else {
        for (int i=0; i <responseForPrivateRequest.count;i++) {
            
            if ([flStrForObj(responseForPrivateRequest[i][@"membername"]) isEqualToString:userName])
            {
                //NSUInteger atSection = [selectedCellIndexPathForActionSheet section];
                
                [userRespondedOnStatus setObject:@"no" atIndexedSubscript:i];
                
                NSIndexPath *deleteRowAtIndexpath = [NSIndexPath indexPathForRow:i  inSection:0];
                NSUInteger row = [deleteRowAtIndexpath row];
                [userRespondedOnStatus removeObjectAtIndex:deleteRowAtIndexpath.row];
                [responseForPrivateRequest removeObjectAtIndex:row];
                [self.privateRequestTableview beginUpdates];
                [self.privateRequestTableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:deleteRowAtIndexpath]  withRowAnimation:UITableViewRowAnimationTop];
                [self.privateRequestTableview endUpdates];
                
                if (responseForPrivateRequest.count == 0) {
                    [self backGrounViewWithImageAndTitle:@"No Users found"];
                }
                
                break;
            }
        }
    }
}


-(void)customizingSearchBar {
    //searchbar customization.
    
    
    UITextField *textSearchField;
    
    textSearchField = [self.searchBarOutlet valueForKey:@"_searchField"];
    textSearchField.backgroundColor = [UIColor colorWithRed:0.8447 green:0.8488 blue:0.8684 alpha:1.0];
    textSearchField.textColor =[UIColor blackColor];
    [textSearchField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                   forKeyPath:@"_placeholderLabel.textColor"];
    [self.searchBarOutlet setImage:[UIImage imageNamed:@"search_search_icon_off"]
                  forSearchBarIcon:UISearchBarIconSearch
                             state:UIControlStateNormal];
    [self.searchBarOutlet setImage:[UIImage imageNamed:@"search_search_icon_on"]
                  forSearchBarIcon:UISearchBarIconSearch
                             state:UIControlStateSelected];
    self.searchBarOutlet.showsBookmarkButton =NO;
    //    isSearchBeginEditing = NO;
    textSearchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

//method for creating activityview in  navigation bar right.
- (void)createActivityViewInNavbar {
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [av setFrame:CGRectMake(0,0,50,30)];
    [self.view addSubview:av];
    av.tag  = 1;
    [av startAnimating];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:av];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)requestForPrivteReuests {
    NSDictionary *requestDict = @{
                                  mauthToken            :[Helper userToken],
                                  };
    
    //requesting the service and passing parametrs.
    [WebServiceHandler getFollowRequestsForPrivateUsers:requestDict andDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return responseForPrivateRequest.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ApproveOrRejectPrivateRequestTableViewCell *requestCell  = [tableView dequeueReusableCellWithIdentifier:@"approveRejectCellIdentifier" forIndexPath:indexPath];
    requestCell.userNameLabel.text = flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]);
    requestCell.fullNameLabel.text = flStrForObj(responseForPrivateRequest[indexPath.row][@"memberfullName"]);
    [requestCell layoutIfNeeded];
    requestCell.profileImageviewOutlet.layer.cornerRadius= requestCell.profileImageviewOutlet.frame.size.height/2;
    requestCell.profileImageviewOutlet.clipsToBounds = YES;
    
    if ([userRespondedOnStatus[indexPath.row] isEqualToString:@"yes"]) {
        [requestCell needToShowAcceptRejectView:@"yes"];
    }
    else {
        [requestCell needToShowAcceptRejectView:@"no"];
    }
    
     [requestCell.followButtonOutlet  setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    
    [requestCell updateFollowButtonTitle:indexPath.row  andStatus:flStrForObj(responseForPrivateRequest[indexPath.row][@"userFollowRequestStatus"])];
    
    
    [requestCell.profileImageviewOutlet sd_setImageWithURL:[NSURL URLWithString:flStrForObj(responseForPrivateRequest[indexPath.row][@"memberProfilePicUrl"])] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
    requestCell.viewForAcceptRejectButton.backgroundColor = [UIColor clearColor];
    requestCell.acceptButtonOutlet.tag = indexPath.row;
    requestCell.rejectButtonOutlet.tag = indexPath.row;
    return requestCell;
}

- (IBAction)acceptButtonAction:(id)sender {
    NSIndexPath *indexPath = [self.privateRequestTableview indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    
    ApproveOrRejectPrivateRequestTableViewCell *selectedCell = [self.privateRequestTableview cellForRowAtIndexPath:indexPath];
    
    
    [self requestForAcceptFollowOrDeny:@"1" andUserName:responseForPrivateRequest[indexPath.row][@"membername"]];
    
    // acceptButton Should Hide when user clicks on accept button and unhide the activityIndicatorView.
    
    selectedCell.acceptButtonOutlet.hidden = YES;
    selectedCell.rejectButtonOutlet.enabled = NO;
    selectedCell.acceptActivityIndicator.hidden  = NO;
    [selectedCell.acceptActivityIndicator startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //[self deleteRowAtIndex:sender];
        [userRespondedOnStatus setObject:@"no" atIndexedSubscript:indexPath.row];
        selectedCell.viewForAcceptRejectButton.hidden = YES;
        selectedCell.followButtonOutlet.hidden = NO;
    });
}

- (IBAction)rejectButtonAction:(id)sender {
    NSIndexPath *indexPath = [self.privateRequestTableview indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    ApproveOrRejectPrivateRequestTableViewCell *selectedCell = [self.privateRequestTableview cellForRowAtIndexPath:indexPath];
    
    [self requestForAcceptFollowOrDeny:@"0" andUserName:responseForPrivateRequest[indexPath.row][@"membername"]];
    
    selectedCell.rejectButtonOutlet.hidden = YES;
    selectedCell.acceptButtonOutlet.enabled = NO;
    selectedCell.rejectActivityIndicator.hidden = NO;
    [selectedCell.rejectActivityIndicator startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        //       [self deleteRowAtIndex:sender];
        
        //        [userRespondedOnStatus setObject:@"no" atIndexedSubscript:indexPath.row];
        //        selectedCell.viewForAcceptRejectButton.hidden = YES;
        //        selectedCell.followButtonOutlet.hidden = NO;
    });
}

-(void)deleteRowAtIndex:(id)sender{
    
    NSIndexPath *indexPath = [self.privateRequestTableview indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview ]];
    NSUInteger row = [indexPath row];
    [userRespondedOnStatus removeObjectAtIndex:indexPath.row];
    [responseForPrivateRequest removeObjectAtIndex:row];
    [self.privateRequestTableview beginUpdates];
    [self.privateRequestTableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationTop];
    [self.privateRequestTableview endUpdates];
    
    if (responseForPrivateRequest.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)requestForAcceptFollowOrDeny:(NSString *)followAction andUserName:(NSString *)memberName{
    
    //   action  --->   0 : reject,
    //   action  ----> 1 : accept]
    
    NSDictionary *requestDict = @{
                                  mauthToken :[Helper userToken],
                                  mmembername:memberName,
                                  mfollowAction:followAction
                                  };
    [WebServiceHandler accceptFollowRequest:requestDict andDelegate:self];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openProfileOfUsername:responseForPrivateRequest[indexPath.row][@"membername"]];
}

-(void)openProfileOfUsername:(NSString *)selectedUserName {
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkingFriendsProfile = YES;
    newView.checkProfileOfUserNmae = selectedUserName;
    [self.navigationController pushViewController:newView animated:YES];
}


- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    [av stopAnimating];
    self.privateRequestTableview.backgroundView = nil;
    if (error) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
        //                                                        message:[error localizedDescription]
        //                                                       delegate:self
        //                                              cancelButtonTitle:@"Ok"
        //                                              otherButtonTitles:nil,nil];
        //        [alert show];
        
        if (responseForPrivateRequest.count > 0) {
            [self showingMessageForCollectionViewBackground:[error localizedDescription]];
        }
        return;
    }
    
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypeGetFollowRequestForAccept )
    {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                responseForPrivateRequest = (NSMutableArray *)response[@"data"];
                
                for (int i =0;i<responseForPrivateRequest.count;i++) {
                    
                    NSString *status =@"yes";
                    [userRespondedOnStatus addObject:status];
                }
                
                [self.privateRequestTableview reloadData];
            }
                break;
                //failure responses.
            case 8474: {
                
                [self backGrounViewWithImageAndTitle:@"No Users found"];
                
                
            }
                break;
            case 2022: {
                [self errorAlert:responseDict[@"message"]];
                
            }
                break;
            default:
                break;
        }
    }
    if (requestType == RequestTypeaccceptFollowRequest )
    {
        switch ([response[0][@"code"] integerValue]) {
            case 200: {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePrivateRequstedPeopleNumber" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"statusForRequst"]];
            }
                break;
                //failure responses.
            case 2021: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 2022: {
                [self errorAlert:responseDict[@"message"]];
                
            }
                break;
            default:
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 12) {
        if (buttonIndex == 0) {
            //ok button action.
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
}


- (void)errorAlert:(NSString *)message {
    //showing error alert for failure response.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}


-(void)backGrounViewWithImageAndTitle:(NSString *)mesage{
    
    UIView *viewWhenNoPosts = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImageView *image =[[UIImageView alloc] init];
    image.image = [UIImage imageNamed:@"ip5"];
    image.frame =  CGRectMake(self.view.frame.size.width/2 - 45, self.view.frame.size.height/2 - 45, 90, 90);
    [viewWhenNoPosts addSubview:image];
    
    UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
    labelForNoPostsMessage.text = mesage;
    labelForNoPostsMessage.numberOfLines =0;
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    labelForNoPostsMessage.frame = CGRectMake(0, CGRectGetMaxY(image.frame) + 10, self.view.frame.size.width, 60);
    [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoRegular size:18]];
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    [viewWhenNoPosts addSubview:labelForNoPostsMessage];
    self.privateRequestTableview.backgroundColor = [UIColor whiteColor];
    self.privateRequestTableview.backgroundView = viewWhenNoPosts;
}

-(void)sendNewFollowStatusThroughNotification:(NSString *)userName andNewStatus:(NSString *)newFollowStatus {
    NSDictionary *newFollowDict = @{@"newFollowStatus"     :flStrForObj(newFollowStatus),
                                    @"userName"            :flStrForObj(userName),
                                    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedFollowStatus" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"newUpdatedFollowData"]];
}

- (IBAction)followButtonAction:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    
    NSIndexPath *indexPath = [self.privateRequestTableview indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    NSString *memberPrivateAccountState = flStrForObj(responseForPrivateRequest[indexPath.row][@"memberPrivate"]);
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOW"]) {
            [selectedButton  setTitle:@" REQUESTED" forState:UIControlStateNormal];
              [selectedButton setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]) andNewStatus:@"0"];
            
            //            arrayOfFollowingStaus[selectedButton.tag%1000] = @"0";
            
            [selectedButton setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            selectedButton.backgroundColor = requstedButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor clearColor].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
        else if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOWING"])  {
            [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
            [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            selectedButton.backgroundColor = followButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            
            //arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]) andNewStatus:@"2"];
            
            //passing parameters.    muserNameToUnFollow
            NSDictionary *requestDict = @{muserNameToUnFollow     :flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]),
                                          mauthToken            :[Helper userToken],
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
        else {
            // cancel request for follow.
            [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
             [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            // arrayOfFollowingStaus[selectedButton.tag%1000] = @"2";
            [self sendNewFollowStatusThroughNotification:flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]) andNewStatus:@"2"];
            
            selectedButton.backgroundColor = followButtonBackGroundColor;
            
            
            [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            
            NSDictionary *requestDict = @{muserNameToUnFollow     : flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]),
                                          mauthToken            :[Helper userToken],
                                          };
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
    }
    
    //actions for when the account is public.
    else {
        if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOWING"]) {
             [selectedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
         
            selectedButton.backgroundColor = followButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            
            //arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]) andNewStatus:@"2"];
            
            //passing parameters.    muserNameToUnFollow
            NSDictionary *requestDict = @{muserNameToUnFollow     :flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]),
                                          mauthToken            :[Helper userToken],
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler unFollow:requestDict andDelegate:self];
            
        }
        else {
             [selectedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [selectedButton  setTitle:@" FOLLOWING" forState:UIControlStateNormal];
            //arrayOfFollowingStaus[selectedButton.tag%1000] = @"1";
            [self sendNewFollowStatusThroughNotification:flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]) andNewStatus:@"1"];
           
            [selectedButton setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
            selectedButton.backgroundColor =followingButtonBackGroundColor;
            selectedButton.layer.borderColor = [UIColor clearColor].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(responseForPrivateRequest[indexPath.row][@"membername"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
    }
}

-(UIView *)showingMessageForCollectionViewBackground:(NSString *)textmessage {
    UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [noDataAvailableMessageView setCenter:self.view.center];
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200,100)];
    message.numberOfLines =0;
    message.textAlignment = NSTextAlignmentCenter;
    message.text = textmessage;
    [noDataAvailableMessageView addSubview:message];
    self.privateRequestTableview.backgroundColor = [UIColor whiteColor];
    self.privateRequestTableview.backgroundView = noDataAvailableMessageView;
    return noDataAvailableMessageView;
}
@end
