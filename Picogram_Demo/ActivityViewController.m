//
//  ActivityViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 4/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ActivityViewController.h"
#import "YouTableViewCell.h"
#import "FollowTableViewCell.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "UIImageView+WebCache.h"
#import "FontDetailsClass.h"
#import "UserProfileViewController.h"
#import "HomeViewController.h"
#import "InstaVIdeoTableViewController.h"
#import "Helper.h"
#import "PGDiscoverPeopleViewController.h"

@interface ActivityViewController ()<WebServiceHandlerDelegate,FollowTableViewCellDelegate,YouTableViewCellDelegate,UIGestureRecognizerDelegate> {
    
    NSMutableArray *temp;
    NSMutableArray *arrayOfFollowingActivity;
    NSMutableArray *tempOwn;
    NSMutableArray *arrayOfSelfActivity;
    int index;
    int followingIndex;
    UIRefreshControl *refreshControl;
    UIRefreshControl *refreshControlForFollowing;
    
    NSInteger numberOfPrivateRequests;
    NSString *profilePictureForRequestedToFollow;
    
    UIActivityIndicatorView *avForSelfActivity;
    UIActivityIndicatorView *avForFollowingActivity;
}
@property bool classIsAppearing;
@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    index = 0;
    followingIndex = 0;
    [self addingRefreshControl];
    arrayOfFollowingActivity =[[NSMutableArray alloc] init];
    arrayOfSelfActivity =[[NSMutableArray alloc] init];
    
    self.followingViewButtonOutlet.selected = YES;
    
    // [self getAllActivities];
    
    
    self.selfActivityTable.estimatedRowHeight = 60.0;
    self.selfActivityTable.rowHeight = UITableViewAutomaticDimension;
    
    //    self.followingActivityTable.estimatedRowHeight = 60.0;
    //    self.followingActivityTable.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
    
    
    [self getAllActivities];
    
    [self makingBackGroundOfTablev];
    
    
    [self notificationForNumberOfPrivateRequests];
    [self updateFollowStatus];
}
-(void)updateFollowStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollwoStatus:) name:@"updatedFollowStatus" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated {
    _classIsAppearing = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Activity";
    self.navigationController.navigationBar.topItem.title = @"Activity";
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    _classIsAppearing = YES;
}
-(void)notificationForNumberOfPrivateRequests {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSelfTableView:) name:@"updatePrivateRequstedPeopleNumber" object:nil];
}

-(void)reloadSelfTableView:(NSNotification *)noti {
    [refreshControl beginRefreshing];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.selfActivityTable;
    index =0;
    [self getOwnersActivity];
}


-(void)makingBackGroundOfTablev {
    avForSelfActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    avForSelfActivity.frame =CGRectMake(self.view.frame.size.width/2 -12.5, self.view.frame.size.height/2 -12.5, 25,25);
    avForSelfActivity.tag  = 1;
    [self.selfActivityTable addSubview:avForSelfActivity];
    [avForSelfActivity startAnimating];
    
    
    
    avForFollowingActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    avForFollowingActivity.frame =CGRectMake(self.view.frame.size.width/2 -12.5, self.view.frame.size.height/2 -12.5, 25,25);
    avForFollowingActivity.tag  = 1;
    [self.followingActivityTable addSubview:avForFollowingActivity];
    [avForFollowingActivity startAnimating];
    
}


-(void)removeRequestedToFollowSuggestion {
    
}

-(void)addingRefreshControl {
    
    refreshControlForFollowing = [[UIRefreshControl alloc]init];
    refreshControlForFollowing.tintColor = [UIColor blackColor];
    [self.followingActivityTable addSubview:refreshControlForFollowing];
    [refreshControlForFollowing addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.tintColor = [UIColor blackColor];
    [self.selfActivityTable addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshSelfTable:) forControlEvents:UIControlEventValueChanged];
}


-(void)refreshTable:(id)sender {
    //reload table
    
    [refreshControlForFollowing beginRefreshing];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    followingIndex = 0;
    tableViewController.tableView = self.followingActivityTable;
    [self getFollowingActivity];
    
}

-(void)refreshSelfTable:(id)sender {
    //reload table
    [refreshControl beginRefreshing];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.selfActivityTable;
    index =0;
    [self getOwnersActivity];
    
}

- (IBAction)followingButtonAction:(id)sender
{
    CGRect frame = self.mainScrollView.bounds;
    frame.origin.x = 0;
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    
    self.followingViewButtonOutlet.selected = YES;
    self.YouViewOutlet.selected = NO;
}

- (IBAction)youButtonAction:(id)sender {
    
    CGRect frame = self.mainScrollView.bounds;
    frame.origin.x = CGRectGetWidth(self.view.frame);
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    
    self.followingViewButtonOutlet.selected = NO;
    self.YouViewOutlet.selected = YES;
}

/*--------------------------------------------------*/
#pragma mark - Scrollview Delegate
/*--------------------------------------------------*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.mainScrollView]) {
        CGPoint offset = scrollView.contentOffset;
        self.movableDividerLeadingConstraintOutlet.constant = scrollView.contentOffset.x/2;
        
        if(offset.x <= CGRectGetWidth(self.view.frame) /2 ) {
            // Followig selected
            self.followingViewButtonOutlet.selected = YES;
            self.YouViewOutlet.selected = NO;
        }
        else {
            //you button selected
            self.followingViewButtonOutlet.selected = NO;
            self.YouViewOutlet.selected = YES;
        }
        
        // Set offset to adjusted value
        scrollView.contentOffset = offset;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.mainScrollView]) {
        CGPoint offset = scrollView.contentOffset;
        if(offset.x <= CGRectGetWidth(self.view.frame) /2 ) {
            // Followig selected
            self.movableDividerLeadingConstraintOutlet.constant = 0;
        }
        else {
            //you button selected
            self.movableDividerLeadingConstraintOutlet.constant = CGRectGetWidth(self.view.frame) /2;
        }
    }
}



/*---------------------------------------------------------------------------*/
#pragma
#pragma mark - tableview delegates and data source.
/*--------------------------------------------------------------------------*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 100) {
        return [arrayOfFollowingActivity count];
    }
    else
    {
        //YOU(SELF) TABLEVIEW.
        if (numberOfPrivateRequests >0 && section == 0) {
            return 1;
        }
        else {
            return  [arrayOfSelfActivity count];
        }
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    if (tableView.tag == 100){
        //tag 100 for follow table.
        return 1;
        
    }
    else {
        if (numberOfPrivateRequests >0) {
            return 2;
        }
        else {
            return 1;
        }
    }
}






//Custom Header (it contains profile image of the posted person and his/her username and time label and location if available.)


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 200 ) {
        if(numberOfPrivateRequests >
           0 && indexPath.section == 0)
        {
            PrivateAccountRequestTableViewCell   *PrivateAccountRequestCell = [tableView dequeueReusableCellWithIdentifier:@"privateAccountTableviewCellIdentifier" forIndexPath:indexPath];
            [PrivateAccountRequestCell layoutIfNeeded];
            
            
            
            PrivateAccountRequestCell.profileImageViewOutlet.layer.cornerRadius =PrivateAccountRequestCell.profileImageViewOutlet.frame.size.height/2;
            PrivateAccountRequestCell.profileImageViewOutlet.clipsToBounds = YES;
            
            
            [PrivateAccountRequestCell.profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:profilePictureForRequestedToFollow] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
            
            PrivateAccountRequestCell.badgeOnImageView.text = [NSString stringWithFormat:@"%ld",(long)numberOfPrivateRequests];
            
            PrivateAccountRequestCell.badgeOnImageView.layer.cornerRadius = PrivateAccountRequestCell.badgeOnImageView.frame.size.height/2;
            PrivateAccountRequestCell.badgeOnImageView.clipsToBounds = YES;
            
            
            UILabel *bageLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,2, 15, 15)];
            bageLabel.text =[NSString stringWithFormat:@"%ld",(long)numberOfPrivateRequests];
            [PrivateAccountRequestCell addSubview:bageLabel];
            [bageLabel setTextColor:[UIColor blackColor]];
            [bageLabel setFont:[UIFont fontWithName:RobotoBold size:10]];
            bageLabel.textAlignment = NSTextAlignmentCenter;
            bageLabel.layer.cornerRadius = PrivateAccountRequestCell.badgeOnImageView.frame.size.height/2;
            bageLabel.clipsToBounds = YES;
            bageLabel.backgroundColor =[UIColor redColor];
            
            PrivateAccountRequestCell.badgeOnImageView.hidden = YES;
            
            return PrivateAccountRequestCell;
        }
        else {
            
            YouTableViewCell *youtablecell;
            
            youtablecell = [tableView dequeueReusableCellWithIdentifier:@"youTableViewCell"
                                                           forIndexPath:indexPath];
            //roundImage
            
            [youtablecell.particularPostImageView setHidden:YES];
            [youtablecell.postButtonOutlet setHidden:YES];
            [youtablecell.followButtonOutlet setHidden:YES];
            
            [youtablecell layoutIfNeeded];
            youtablecell.FriendProfileImageView.layer.cornerRadius =youtablecell.FriendProfileImageView.frame.size.height/2;
            youtablecell.FriendProfileImageView.clipsToBounds = YES;
            youtablecell.delegate = self;
            youtablecell.usernameBtn.userInteractionEnabled = YES;
            youtablecell.userdetails = arrayOfSelfActivity[indexPath.row];
            youtablecell.actitvtyUserName = flStrForObj(arrayOfSelfActivity[indexPath.row][@"username"]);
            youtablecell.postID = flStrForObj(arrayOfSelfActivity[indexPath.row][@"postId"]);
            
            
            youtablecell.accessoryType = UITableViewCellAccessoryNone;
            
            
            NSString *activityStmt;
            NSString *activitytime = [Helper convertEpochToNormalTimeInshort:flStrForObj(arrayOfSelfActivity[indexPath.row][@"createdOn"])];
            
            if ([flStrForObj(arrayOfSelfActivity[indexPath.row][@"notificationType"]) integerValue] == 5)
            {
                [youtablecell.particularPostImageView setHidden:NO];
                [youtablecell.postButtonOutlet setHidden:NO];
                
                activityStmt = [NSString stringWithFormat:@"%@ commented your post.  %@",flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"]),activitytime];
                
                [youtablecell.particularPostImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfSelfActivity[indexPath.row][@"thumbnailImageUrl"])] placeholderImage:[UIImage imageNamed:@""]];
                [youtablecell.followButtonOutlet setHidden:YES];
                
            }
            else if([flStrForObj(arrayOfSelfActivity[indexPath.row][@"notificationType"])integerValue] == 3)
            {
                
                [youtablecell.followButtonOutlet setHidden:NO];
                activityStmt = [NSString stringWithFormat:@"%@ started following you.  %@",flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"]),activitytime];
            }
            if([flStrForObj(arrayOfSelfActivity[indexPath.row][@"notificationType"])integerValue] == 4)
            {
                
                [youtablecell.followButtonOutlet setHidden:NO];
                activityStmt = [NSString stringWithFormat:@"%@ requested to follow you.  %@",flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"]),activitytime];
            }
            
            else if ([flStrForObj(arrayOfSelfActivity[indexPath.row][@"notificationType"]) integerValue] == 2)
            {
                [youtablecell.particularPostImageView setHidden:NO];
                [youtablecell.postButtonOutlet setHidden:NO];
                
                activityStmt = [NSString stringWithFormat:@"%@ liked your post.  %@",flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"]),activitytime];
                
                [youtablecell.particularPostImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfSelfActivity[indexPath.row][@"thumbnailImageUrl"])] placeholderImage:[UIImage imageNamed:@""]];
                [youtablecell.followButtonOutlet setHidden:YES];
                
            }
            else if ([flStrForObj(arrayOfSelfActivity[indexPath.row][@"notificationType"]) integerValue] == 0)
            {
                [youtablecell.particularPostImageView setHidden:NO];
                [youtablecell.postButtonOutlet setHidden:NO];
                
                activityStmt = [NSString stringWithFormat:@"%@ tagged you in their post.  %@",flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"]),activitytime];
                youtablecell.actitvtyUserName = flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"]);
                [youtablecell.particularPostImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfSelfActivity[indexPath.row][@"thumbnailImageUrl"])] placeholderImage:[UIImage imageNamed:@""]];
                [youtablecell.followButtonOutlet setHidden:YES];
                
            }
            
            else if ([flStrForObj(arrayOfSelfActivity[indexPath.row][@"notificationType"])integerValue]==1)
            {
                [youtablecell.particularPostImageView setHidden:NO];
                [youtablecell.postButtonOutlet setHidden:NO];
                
                activityStmt = [NSString stringWithFormat:@"%@ commented:%@",flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"]),flStrForObj(arrayOfSelfActivity[indexPath.row][@"b"][@"properties"][@"postCaption"])];
                [youtablecell.particularPostImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfSelfActivity[indexPath.row][@"thumbnailImageUrl"]]) placeholderImage:[UIImage imageNamed:@""]];
                 
                 [youtablecell.followButtonOutlet setHidden:YES];
                 
                 }
                 if(activityStmt)
                 {
                     //                     [ youtablecell.descrptionLabel setAttributedText:[Helper customisedActivityStmt:flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"]) :activityStmt]];
                     
                     
                     [youtablecell.descrptionLabel setAttributedText:[Helper customisedActivityStmt:flStrForObj(arrayOfSelfActivity[indexPath.row][@"membername"])  seconUserName:flStrForObj(arrayOfSelfActivity[indexPath.row][@"user2_username"]) timeForPost:activitytime :activityStmt]];
                 }
                 
                 [youtablecell.FriendProfileImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfSelfActivity[indexPath.row][@"memberProfilePicUrl"]]) placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
                  
                  [self updateFollowButtonTitle:indexPath.row and:youtablecell.followButtonOutlet andFollowStatus:flStrForObj(arrayOfSelfActivity[indexPath.row][@"followRequestStatus"])];
                  
                  youtablecell.followButtonOutlet.tag = 1000 + indexPath.row;
                  
                  return youtablecell;
          }
       }
                  
                  else {
                      FollowTableViewCell *followCell;
                      
                      followCell = [tableView dequeueReusableCellWithIdentifier:@"followTableviewcell"
                                                                   forIndexPath:indexPath];
                      [followCell layoutIfNeeded];
                      
                      followCell.friendProfileImage.layer.cornerRadius = followCell.friendProfileImage.frame.size.height/2;
                      followCell.friendProfileImage.clipsToBounds = YES;
                      followCell.delegate = self;
                      followCell.postID = flStrForObj(arrayOfFollowingActivity[indexPath.row][@"postId"]);
                      followCell.postType = @"0";
                      followCell.actitvtyUserName = flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user2_username"]);
                      followCell.nameButton = [[UIButton alloc]init];
                      followCell.nameButton.tag = indexPath.row;
                      followCell.nameButton.userInteractionEnabled = YES;
                      [followCell.nameButton addTarget:self action:@selector(nameAction:) forControlEvents:UIControlEventTouchUpInside];
                      followCell.nameButton.backgroundColor = [UIColor clearColor];
                      
                      [followCell.descriptionLabel addSubview:followCell.nameButton];
                      followCell.userdetails = arrayOfFollowingActivity[indexPath.row];
                      followCell.postdetails = arrayOfFollowingActivity[indexPath.row][@"postDetails"];
                      NSString *activityStmt;
                      NSString *activitytime = [Helper convertEpochToNormalTimeInshort:flStrForObj(arrayOfFollowingActivity[indexPath.row][@"createdOn"])];
                      
                      if([flStrForObj(arrayOfFollowingActivity[indexPath.row][@"notificationType"])integerValue] == 0){
                          [followCell.postImage setHidden:NO];
                          NSLog(@"Tagged activity");
                          activityStmt = [NSString stringWithFormat:@"%@ tagged %@ in post.  %@",flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user1_username"]),flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user2_username"]),activitytime];
                          [followCell.postImage sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfFollowingActivity[indexPath.row][@"thumbnailImageUrl"])] placeholderImage:[UIImage imageNamed:@""]];
                          
                      }
                      if([flStrForObj(arrayOfFollowingActivity[indexPath.row][@"notificationType"])integerValue] == 1){
                          [followCell.postImage setHidden:NO];
                          NSLog(@"Mentioned in comment ");
                          activityStmt = [NSString stringWithFormat:@"%@ Mentioned in comment   %@",flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user1_username"]),activitytime];/*[@"node3"][@"properties"][@"username"]),flStrForObj(temp[indexPath.row][@"node3"][@"properties"][@"likes"]),activitytime]*/
                          [followCell.postImage sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfSelfActivity[indexPath.row][@"thumbnailImageUrl"])] placeholderImage:[UIImage imageNamed:@""]];
                          
                      }
                      else if ([flStrForObj(arrayOfFollowingActivity[indexPath.row][@"notificationType"])integerValue] == 2)
                      {
                          [followCell.postImage setHidden:NO];
                          NSLog(@"Liked activity");
                          activityStmt = [NSString stringWithFormat:@"%@ liked %@ post.  %@",flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user1_username"]),flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user2_username"]),activitytime];
                          
                          [followCell.postImage sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfFollowingActivity[indexPath.row][@"thumbnailImageUrl"])] placeholderImage:[UIImage imageNamed:@""]];
                          
                          
                      }
                      else if([flStrForObj(arrayOfFollowingActivity[indexPath.row][@"notificationType"])integerValue] == 3)
                      {
                          NSLog(@"started follow activity");
                          
                          activityStmt = [NSString stringWithFormat:@"%@ started following %@.  %@",flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user1_username"]),flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user2_username"]),activitytime];
                          
                          [followCell.postImage setHidden:YES];
                          
                      }
                      else if([flStrForObj(arrayOfFollowingActivity[indexPath.row][@"notificationType"])integerValue] == 4){
                          [followCell.postImage setHidden:NO];
                          NSLog(@"requestedToFollow");
                          activityStmt = [NSString stringWithFormat:@"%@ requested to follow %@.  %@",flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user1_username"]),flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user2_username"]), activitytime];
                      }
                      else if([flStrForObj(arrayOfFollowingActivity[indexPath.row][@"notificationType"])integerValue] == 5) {
                          [followCell.postImage setHidden:NO];
                          NSLog(@"requestedToFollow");
                          
                          [followCell.postImage sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfFollowingActivity[indexPath.row][@"thumbnailImageUrl"])] placeholderImage:[UIImage imageNamed:@""]];
                          
                          
                          
                          activityStmt = [NSString stringWithFormat:@"%@ commented on %@ post.  %@",flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user1_username"]),flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user2_username"]),activitytime];
                      }
                      
                      if(activityStmt)
                      {
                          [followCell.descriptionLabel setAttributedText:[Helper customisedActivityStmt:flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user1_username"])  seconUserName:flStrForObj(arrayOfFollowingActivity[indexPath.row][@"user2_username"]) timeForPost:activitytime :activityStmt]];
                      }
                      
                      
                      
                      
                      followCell.nameButton.frame = CGRectMake(0, 10, 80, 15);
                      
                      [followCell.friendProfileImage sd_setImageWithURL:[NSURL URLWithString:flStrForObj(arrayOfFollowingActivity[indexPath.row] [@"user1_profilePicUrl"] ]) placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
                       
                       return followCell;
                       
                       }
}
                       

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
                           
    if (tableView.tag == 200 )
    {
        
        if (indexPath.row == [arrayOfSelfActivity count] - 1 ) {
            ++index;
            [self getOwnersActivity];
        }
        
    }
    else{
        
        if (indexPath.row == [arrayOfFollowingActivity count] - 1 ) {
            ++followingIndex;
            [self getFollowingActivity];
            
        }
        
    }
}
                       
                       
                       
#pragma mark -FriendsCellDelegate
                       
-(void)cell:(FollowTableViewCell *)cell button:(UIButton *)button withObject:(NSDictionary *)object{
                           
    //UIButton *selectedButton = (UIButton *)sender;
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = object[@"user1_username"];
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
    
}
#pragma mark -SelfCellDelegate
                       
-(void)ownActivitycell:(YouTableViewCell *)cell button:(UIButton *)buttonN withObject:(NSDictionary *)userobject{
                           
                           
    //UIButton *selectedButton = (UIButton *)sender;
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = userobject[@"membername"];
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
    
}
                       
                       
-(void)cell:(FollowTableViewCell *)cell postbutton:(UIButton *)button ofpostType:(NSString *)posttype withpostid:(NSString *)id andUserName:(NSString *)name {
    InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
    newView.showListOfDataFor = @"ActivityProfile";
    //newView.dataForListView = dataForListView;
    newView.movetoRowNumber = 0;
    newView.postId = id;
    newView.activityUser = name;
    newView.postType = posttype;
    newView.controllerType = @"ActivityProfile";
    newView.navigationBarTitle = name; //self.navigationItem.title;
    [self.navigationController pushViewController:newView animated:YES];
}
                       
                       
-(void)selfCell:(YouTableViewCell *)cell postbutton:(UIButton *)button ofpostType:(NSString *)posttype withpostid:(NSString *)id andUserName:(NSString *)name {
    InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
    newView.showListOfDataFor = @"ActivityProfile";
    //newView.dataForListView = dataForListView;
    newView.movetoRowNumber = 0;
    newView.postId = id;
    newView.activityUser = name;
    newView.postType = posttype;
    newView.controllerType = @"ActivityProfile";
    newView.navigationBarTitle = name; //self.navigationItem.title;
    [self.navigationController pushViewController:newView animated:YES];
}
                       
                       
-(void)updateFollowButtonTitle:(NSInteger )row and:(id)sender andFollowStatus:(NSString *)followstatus{
                           
    UIButton *reeceivedButton = (UIButton *)sender;
    
    //  if follow status is 0 --->    "Requested"
    //  if follow status is 1 --->    "Following"
    //  if follow status is nil --->  "Follow"
    
    if ([followstatus  isEqualToString:@"0"]) {
        [reeceivedButton setImage:[UIImage imageNamed:imageForRequestedButton] forState:UIControlStateNormal];
    }
    else if ([followstatus  isEqualToString:@"1"]) {
        [reeceivedButton setImage:[UIImage imageNamed:imageForFollowingButton] forState:UIControlStateNormal];
    }
    else {
        [reeceivedButton setImage:[UIImage imageNamed:imageForFollowButton] forState:UIControlStateNormal];
    }
    
    [reeceivedButton addTarget:self
                        action:@selector(FollowButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
}
                       
                       
-(void)FollowButtonAction:(id)sender {
                           
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [self.selfActivityTable indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    
    //  if follow status is 0 --->    "Requested"
    //  if follow status is 1 --->    "Following"
    //  if follow status is nil --->  "Follow"
    
    
    NSString *memberPrivateAccountState = flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"memberIsPrivate"]);
    
    NSString *followStatus = flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"followRequestStatus"]);
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([followStatus isEqualToString:@"1"]) {
            [self unfollowRequest:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"])];
            [selectedButton setImage:[UIImage imageNamed:imageForFollowButton] forState:UIControlStateNormal];
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"]) andNewStatus:@"2"];
            arrayOfSelfActivity[selectedCellForLike.row][@"followRequestStatus"] = @"2";
        }
        else if ([followStatus isEqualToString:@"0"])  {
            [self unfollowRequest:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"])];
            [selectedButton setImage:[UIImage imageNamed:imageForFollowButton] forState:UIControlStateNormal];
            arrayOfSelfActivity[selectedCellForLike.row][@"followRequestStatus"] = @"2";
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"]) andNewStatus:@"2"];
        }
        else {
            [self followRequest:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"])];
            [selectedButton setImage:[UIImage imageNamed:imageForRequestedButton] forState:UIControlStateNormal];
            arrayOfSelfActivity[selectedCellForLike.row][@"followRequestStatus"] = @"0";
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"]) andNewStatus:@"0"];
        }
    }
    //actions for when the account is public.
    else {
        if ([followStatus isEqualToString:@"1"])  {
            [self unfollowRequest:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"])];
            [selectedButton setImage:[UIImage imageNamed:imageForFollowButton] forState:UIControlStateNormal];
            arrayOfSelfActivity[selectedCellForLike.row][@"followRequestStatus"] = @"2";
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"]) andNewStatus:@"2"];
        }
        else {
            [self followRequest:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"])];
            [selectedButton setImage:[UIImage imageNamed:imageForFollowingButton] forState:UIControlStateNormal];
            arrayOfSelfActivity[selectedCellForLike.row][@"followRequestStatus"] = @"1";
            [self sendNewFollowStatusThroughNotification:flStrForObj(arrayOfSelfActivity[selectedCellForLike.row][@"membername"]) andNewStatus:@"1"];
        }
    }
}
                       
-(void)followRequest :(NSString *)usernameToFollow {
    NSDictionary *requestDict = @{muserNameTofollow     : flStrForObj(usernameToFollow),
                                  mauthToken            :[Helper userToken],
                                  };
    [WebServiceHandler follow:requestDict andDelegate:self];
}
                       
-(void)unfollowRequest:(NSString *)usernameToUnfollow {
    NSDictionary *requestDict = @{muserNameToUnFollow     : flStrForObj(usernameToUnfollow),
                                  mauthToken            :[Helper userToken],
                                  };
    [WebServiceHandler unFollow:requestDict andDelegate:self];
}
                       
-(void)sendNewFollowStatusThroughNotification:(NSString *)userNamer andNewStatus:(NSString *)newFollowStatus {
    NSDictionary *newFollowDict = @{@"newFollowStatus"     :flStrForObj(newFollowStatus),
                                    @"userName"            :flStrForObj(userNamer),
                                    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedFollowStatus" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"newUpdatedFollowData"]];
}
                       
-(void)updateFollwoStatus:(NSNotification *)noti {
    if (!_classIsAppearing) {
        //check the postId and Its Index In array.
        NSString *userNamer = flStrForObj(noti.object[@"newUpdatedFollowData"][@"userName"]);
        NSString *foolowStatusRespectToUser = noti.object[@"newUpdatedFollowData"][@"newFollowStatus"];
        
        for (int i=0; i <arrayOfSelfActivity.count;i++) {
            if ([flStrForObj(arrayOfSelfActivity[i][@"membername"]) isEqualToString:userNamer]) {
                arrayOfSelfActivity[i][@"followRequestStatus"] = foolowStatusRespectToUser;
                NSIndexPath* rowToReloadAtIndexPath;
                NSArray* rowsToReload;
                if(numberOfPrivateRequests >0)
                {
                    rowToReloadAtIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
                     rowsToReload = [NSArray arrayWithObjects:rowToReloadAtIndexPath, nil];
                }
                else {
                    rowToReloadAtIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    rowsToReload = [NSArray arrayWithObjects:rowToReloadAtIndexPath, nil];
                }
                [self.selfActivityTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}
                       
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag == 200){
        if(indexPath.section ==0 && indexPath.row == 0 && tableView.numberOfSections > 1) {
            
            [self performSegueWithIdentifier:@"activityToPrivateRequestsSegue" sender:nil];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
                       
                       
-(void)getAllActivities {
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(backgroundQueue, ^{
        
        [self getOwnersActivity];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getFollowingActivity];
        });
    });
}
                       
#pragma mark - WebService
                       
                       /*
                        * Method to Request Following Activities
                        *
                        */
                       
-(void)getFollowingActivity{
                          
    NSDictionary *requestDict = @{
                                  mauthToken      :[Helper userToken],
                                  moffset         :flStrForObj([NSNumber numberWithInteger:followingIndex*10]),
                                  mlimit          :flStrForObj([NSNumber numberWithInteger:10])
                                  };
    
    [WebServiceHandler followingActivities:requestDict andDelegate:self];
    
}
                      /*
                       * Method to Request Own Activities
                       *
                       */
-(void)getOwnersActivity {
    NSDictionary *requestDict = @{
                                  mauthToken      :flStrForObj([Helper userToken]),
                                  moffset         :flStrForObj([NSNumber numberWithInteger:index*10]),
                                  mlimit          :flStrForObj([NSNumber numberWithInteger:10])
                                  };
    
    [WebServiceHandler ownActivities:requestDict andDelegate:self];
}
                       
- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
                           
    [avForSelfActivity stopAnimating];
    [avForFollowingActivity stopAnimating];
    
    
   
    
    if (error) {
        
        [refreshControlForFollowing endRefreshing];
        [refreshControl endRefreshing];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        
        self.followingActivityTable.backgroundView = [self showErrorMessage:[error localizedDescription]];
        self.selfActivityTable.backgroundView = [self showErrorMessage:[error localizedDescription]];
        
        return;
    }
    
    
    NSDictionary *responseDict = (NSDictionary*)response;
    
    if (requestType == RequestTypefollowingActivity ) {
         self.followingActivityTable.backgroundView = nil;
        [refreshControlForFollowing endRefreshing];
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                NSLog(@"Response From Following Activity:%@",responseDict);
                temp =responseDict[@"data"];//[0][@"data"];
                
                if(followingIndex == 0)
                {
                    [arrayOfFollowingActivity removeAllObjects];
                }
                
                for(int i= 0;i<temp.count;i++){
                    if(![flStrForObj(temp[i][@"notificationType"]) isEqualToString:@""])
                        [arrayOfFollowingActivity addObject:temp[i]];
                }
                
                if(arrayOfFollowingActivity.count == 0) {
                    [self viewWhenNodataAvailabeleForFollowingActivity];
                    //                    self.followingActivityTable.backgroundView = [self showErrorMessage:@"No Data To Show"];
                }
                else {
                    self.followingActivityTable.backgroundView =nil;
                }
                
                [self.followingActivityTable reloadData];
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
    
    NSDictionary *responseDict1  = (NSDictionary*)response;
    
    if (requestType == RequestTypeOwnActivity ) {
        self.selfActivityTable.backgroundView =nil;
        [refreshControl endRefreshing];
        switch ([responseDict1[@"code"] integerValue]) {
            case 200: {
                //successs response.
                tempOwn =responseDict1[@"data"];
                
                if(index == 0)
                {
                    numberOfPrivateRequests = 0;
                    [arrayOfSelfActivity removeAllObjects];
                }
                
                for(int i = 0; i< tempOwn.count;i++) {
                    if(![flStrForObj(tempOwn[i][@"notificationType"]) isEqualToString:@""])
                    {
                        if([flStrForObj(tempOwn[i][@"notificationType"]) isEqualToString:@"4"])
                        {
                            // numberOfPrivateRequests ++;
                            //profilePictureForRequestedToFollow = flStrForObj(tempOwn[i][@"memberProfilePicUrl"]);
                        }
                        else {
                            [arrayOfSelfActivity addObject:tempOwn[i]];
                        }
                    }
                }
                
                NSString *tempoString =  flStrForObj(responseDict[@"followRequestCount"][0][@"followRequestCount"]);
                numberOfPrivateRequests = [tempoString integerValue];
                profilePictureForRequestedToFollow = flStrForObj(responseDict[@"followRequestCount"][0][@"memberProfilePicUrl"]);
                
//                NSString *tempoString = flStrForObj(responseDict[@"followRequestCount"]);
//                numberOfPrivateRequests = [tempoString integerValue];
//                profilePictureForRequestedToFollow = @"default";
                
                if(arrayOfSelfActivity.count == 0) {
                    [self viewWhenNodataAvailabeleForActivity];
                }
                else {
                    self.selfActivityTable.backgroundView =nil;
                }
                
                [self.selfActivityTable reloadData];
            }
                //failure responses.
                break;
            case 2021: {
                [self errorAlert:responseDict1[@"message"]];
            }
                break;
            default:
                break;
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
                       
                       
-(void)nameAction:(UIButton *)sender{
    NSLog(@"nameClicked");
}
                       
  -(UIView *)showErrorMessage:(NSString *)errorMessage {
      UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
      [noDataAvailableMessageView setCenter:self.view.center];
      UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200, 60)];
      message.textAlignment = NSTextAlignmentCenter;
      message.numberOfLines = 0;
      message.text = errorMessage;
      [noDataAvailableMessageView addSubview:message];
      
      return noDataAvailableMessageView;
}
-(void)viewWhenNodataAvailabeleForActivity {
    UIView *mainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImageView *imag = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -50,20,100,100)];
    imag.image = [UIImage imageNamed:@"activity_heart_symbol_icon"];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,130,self.view.frame.size.width-40,50)];
    titleLabel.text = @"Recent Activity on Your Posts";
    titleLabel.font = [UIFont fontWithName:RobotoBold size:16];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,180,self.view.frame.size.width-40,50)];
    messageLabel.text = @"When someone comments on or likes one of your photos or videos, you'll see it here.";
    messageLabel.font = [UIFont fontWithName:RobotoRegular size:13];
    messageLabel.numberOfLines =0;
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    
    [mainView addSubview:messageLabel];
    [mainView addSubview:titleLabel];
    [mainView addSubview:imag];
    // [self.view addSubview:mainView];
    
    self.selfActivityTable.backgroundView = mainView;
}
                       
-(void)viewWhenNodataAvailabeleForFollowingActivity {
    UIView *mainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImageView *imag = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -50,20,100,100)];
    imag.image = [UIImage imageNamed:@"activity_heart_symbol_icon"];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,130,self.view.frame.size.width-40,50)];
    titleLabel.text = @"Activity from people you follow";
    titleLabel.font = [UIFont fontWithName:RobotoBold size:16];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,180,self.view.frame.size.width-40,50)];
    messageLabel.text = @"When someone you follow comments on or likes a post, you'll see it here.";
    messageLabel.font = [UIFont fontWithName:RobotoRegular size:13];
    messageLabel.numberOfLines =0;
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton *followButton = [[UIButton alloc] initWithFrame:CGRectMake(20,230,self.view.frame.size.width - 40,40)];
    followButton.backgroundColor = [UIColor colorWithRed:91.0f/255.0f green:181.0f/255.0f blue:38.0/255.0f alpha:1.0f];

    followButton.layer.cornerRadius = 5;
    [followButton setTitle:@"Find people to follow" forState:UIControlStateNormal];
    [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [followButton.titleLabel setFont:[UIFont fontWithName:RobotoMedium size:15]];
    [followButton addTarget:self action:@selector(followButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [mainView addSubview:messageLabel];
    [mainView addSubview:titleLabel];
    [mainView addSubview:imag];
    [mainView addSubview:followButton];
    // [self.view addSubview:mainView];
    
    self.followingActivityTable.backgroundView = mainView;
}
                    
-(void)followButtonClicked:(id)sender  {
    PGDiscoverPeopleViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:mDiscoverPeopleVcSI];
    [self.navigationController pushViewController:postsVc animated:YES];
}
@end
