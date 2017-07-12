//
//  DiscoverPeopleViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGDiscoverPeopleViewController.h"
#import "PGDiscoverPeopleTableViewCell.h"
#import "DiscoverTableViewPostedImagesCell.h"
#import "postedImagesCollectionViewCell.h"
#import "ConnectToFaceBookViewController.h"
#import "TopTableViewCell.h"
#import "FontDetailsClass.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "UserProfileViewController.h"
#import "ListOfPostsViewController.h"
#import "Helper.h"

@interface PGDiscoverPeopleViewController () <WebServiceHandlerDelegate>{
    NSArray *title;
    NSArray *subTitle;
    NSArray *images;
    
    
    NSString *titleForFb;
    NSString *subtitleForFb;
    NSString *imageForFb;
    
    NSString *titleForContacts;
    NSString *subTitleForContacts;
    NSString *imageForContcts;
    
    
    postedImagesCollectionViewCell *collectionViewCell;
    
    NSMutableArray *arrayOfFollowingStaus;
    NSMutableArray *respDeatils;
    NSIndexPath *rowAt;
    BOOL chnageColorOfSubTitle;
    UIActivityIndicatorView *avForCollectionView;
    NSInteger offsetForMorePosts;
    
    UIRefreshControl *refreshControl;
    BOOL neccessaryToRemoveOldPostsData;
}
@property bool classIsAppearing;
@end

@implementation PGDiscoverPeopleViewController

#pragma mark
#pragma mark - viewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self navBarCustomization];
    [self createNavLeftButton];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    subTitle =[NSArray arrayWithObjects:@"to follow your friends",@"to follow your friends",nil];
    images = [NSArray arrayWithObjects:@"discovery_people_facebook_icon",@"discovery_people_contact_icon",nil];
    
    [self requestForDiscoverPeopleApi:0];
    arrayOfFollowingStaus = [[NSMutableArray alloc] init];
    respDeatils = [[NSMutableArray alloc] init];
    offsetForMorePosts = 0;
    [self addingRefreshControl];
    neccessaryToRemoveOldPostsData = NO;
    [self addingActivityIndicatorToCollectionViewBackGround];
    
    [self updateFollowStatus];
    [self creatingNotificationForUpdatingTitleFb];
    [self creatingNotificationForUpdatingTitleContacts];
}

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



-(void)creatingNotificationForUpdatingTitleFb {
    NSInteger numberOfFaceBookFriendsInPicogram = [[[NSUserDefaults standardUserDefaults]
                                                    stringForKey:numberOfFbFriendFoundInPicogram] integerValue];
    NSString *numberofFbFriends = [NSString stringWithFormat:@"%ld",numberOfFaceBookFriendsInPicogram];
    if (numberOfFaceBookFriendsInPicogram > 0) {
        titleForFb = @"Connected Facebook";
        subtitleForFb = [numberofFbFriends stringByAppendingString:@" Contacts"];
        imageForFb = @"discover_people_facebook_icon_whenavailable";
    }
    else {
        titleForFb = @"Connect to Facebook";
        subtitleForFb = @"to follow your friends";
        imageForFb = @"discover_people_facebook_icon_off";
    }
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitleForFb:) name:@"updateFaceBookSectionTitle" object:nil];
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
        imageForContcts = @"discover_people_facebook_icon_off";
    }
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.discoverTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
}

-(void)updateTitleForFb:(NSNotification *)noti {
    
    NSString *numberOfContcts = flStrForObj(noti.object[@"numberOfContactsSynced"][@"numberOfContacts"]);
    
    NSInteger numberOfFaceBookFriendsInPicogram = [numberOfContcts integerValue];
    
    if (numberOfFaceBookFriendsInPicogram > 0) {
        titleForFb = @"Connected Facebook";
        subtitleForFb = [numberOfContcts stringByAppendingString:@" Contacts"];
        imageForFb = @"discover_people_facebook_icon_whenavailable";
    }
    else {
        titleForFb = @"Connect to Facebook";
        subtitleForFb = @"to follow your friends";
        imageForFb = @"discover_people_facebook_icon_off";
    }
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.discoverTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
}



-(void)updateFollowStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollwoStatus:) name:@"updatedFollowStatus" object:nil];
}

-(void)updateFollwoStatus:(NSNotification *)noti {
    //check the postId and Its Index In array.
    
    if (!_classIsAppearing) {
        NSString *userName = flStrForObj(noti.object[@"newUpdatedFollowData"][@"userName"]);
        NSString *foolowStatusRespectToUser = noti.object[@"newUpdatedFollowData"][@"newFollowStatus"];
        
        if ([foolowStatusRespectToUser isEqualToString:@"2"]) {
            foolowStatusRespectToUser = @"0";
        }
        else if ([foolowStatusRespectToUser isEqualToString:@"0"]) {
            foolowStatusRespectToUser = @"2";
        }
        
        for (int i=0; i <respDeatils.count;i++) {
            if ([flStrForObj(respDeatils[i][@"postedByUserName"]) isEqualToString:userName]) {
                arrayOfFollowingStaus[i] = foolowStatusRespectToUser;
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:1];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                [self.discoverTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}

-(void)sendNewFollowStatusThroughNotification:(NSString *)userName andNewStatus:(NSString *)newFollowStatus {
    
    
    
    NSDictionary *newFollowDict = @{@"newFollowStatus"     :flStrForObj(newFollowStatus),
                                    @"userName"            :flStrForObj(userName),
                                    };
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedFollowStatus" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"newUpdatedFollowData"]];
}

-(void)viewWillDisappear:(BOOL)animated {
      _classIsAppearing = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    _classIsAppearing = YES;
}

-(void)navBarCustomization {
    //navigationbar title
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title =@"Discover People";
}



-(void )requestForDiscoverPeopleApi:(NSInteger)numb{
    //passing parameters(faceBookids list and token)
    NSDictionary *requestDict = @{
                                  mauthToken      :[Helper userToken],
                                  moffset:flStrForObj([NSNumber numberWithInteger:numb*10]),
                                  mlimit:flStrForObj([NSNumber numberWithInteger:10]),
                                  };
    //requesting the service and passing parametrs.
    [WebServiceHandler discoverPeople:requestDict andDelegate:self];
}




/*---------------------------------------------------------*/
#pragma mark - Pull To refresh
/*---------------------------------------------------------*/
-(void)addingRefreshControl {
    refreshControl = [[UIRefreshControl alloc]init];
    [self.discoverTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshData:(id)sender {
    neccessaryToRemoveOldPostsData = YES;
    [self requestForDiscoverPeopleApi:0];
}

#pragma mark
#pragma mark - table view delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return  [title count];
    }
    else {
        return  respDeatils.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        return 50;
    }
    else {
       NSString *memberPrivateAccountState = flStrForObj(respDeatils[indexPath.row][@"privateProfile"]);
       NSMutableArray   *postDetails = respDeatils[indexPath.row][@"postData"];
        
        if ([memberPrivateAccountState isEqualToString:@"1"]) {
            return 90;
        }
        else {
            if(postDetails.count ==0 ) {
                return 90;
                // 60 for first section and 50 for 2nd section(no need to show rectangular images just we need to show no posts available message.)
            }
            else {
                return 60 + self.view.frame.size.width/3;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    rowAt =indexPath;
    if (indexPath.section == 0) {
        static NSString *simpleTableIdentifier = @"Cell";
        PGDiscoverPeopleTableViewCell *cell;
        if (cell == nil) {
            cell = (PGDiscoverPeopleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        }
        
        if (indexPath.row == 0) {
            cell.TitleLabelOutlet.text = titleForFb ;
            cell.subTitleLabelOutlet.text =subtitleForFb;
            cell.imageViewOutlet.image =[UIImage imageNamed:imageForFb];
            
            if ([subtitleForFb isEqualToString:@"to follow your friends"]) {
                cell.subTitleLabelOutlet.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
            }
            else {
                cell.subTitleLabelOutlet.textColor = [UIColor colorWithRed:0.2157 green:0.5137 blue:0.8157 alpha:1.0];
            }
        }
        else {
            cell.TitleLabelOutlet.text = titleForContacts;
            cell.subTitleLabelOutlet.text = subTitleForContacts;
            cell.imageViewOutlet.image =[UIImage imageNamed:imageForContcts];
            
            
            if ([subTitleForContacts isEqualToString:@"to follow your friends"]) {
                cell.subTitleLabelOutlet.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
            }
            else {
                cell.subTitleLabelOutlet.textColor = [UIColor colorWithRed:0.2157 green:0.5137 blue:0.8157 alpha:1.0];
            }
        }
        return cell;
    }
    else {
        static NSString *simpleTableIdentifier = @"PostedImagecell";
        DiscoverTableViewPostedImagesCell *PostedImagecell;
        if (PostedImagecell == nil) {
            PostedImagecell = (DiscoverTableViewPostedImagesCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        }
        
        
        PostedImagecell.contentView.backgroundColor = [UIColor whiteColor];
        PostedImagecell.userNameLabelOutlet.text = flStrForObj(respDeatils[indexPath.row][@"postedByUserName"]);
        PostedImagecell.labelUnderUserNameOutelt.text = flStrForObj(respDeatils[indexPath.row][@"postedByUserFullName"]);
        
        [PostedImagecell layoutIfNeeded];
        PostedImagecell.followButtonOutlet .layer.cornerRadius = 5;
        PostedImagecell.followButtonOutlet .layer.borderWidth = 1;
        PostedImagecell.followButtonOutlet.layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
        
        [self updateFollowButtonTitle:indexPath.row and:PostedImagecell.followButtonOutlet];
        
        if(([arrayOfFollowingStaus[indexPath.row]  isEqualToString:@"0"])) {
            PostedImagecell.followButtonTrailingConstraint.constant = 5;
            PostedImagecell.widthConstraintFollowButtonOutlet.constant = 60;
        }
        else {
            PostedImagecell.followButtonTrailingConstraint.constant = - 40;
            PostedImagecell.widthConstraintFollowButtonOutlet.constant = 105;
        }
        
        
        PostedImagecell.hideButtonOutlet.tag = 63000 + indexPath.row;
        [PostedImagecell.hideButtonOutlet addTarget:self action:@selector(hideButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [PostedImagecell.profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:flStrForObj(respDeatils[indexPath.row][@"profilePicUrl"]]) placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
         
         NSMutableArray   *postDetails = respDeatils[indexPath.row][@"postData"];
         NSString *memberPrivateAccountState = flStrForObj(respDeatils[indexPath.row][@"privateProfile"]);
         
         
         if ([memberPrivateAccountState isEqualToString:@"1"]) {
             //private account no need to show posts.
             PostedImagecell.viewWhenNoPostsAvailable.hidden = NO;
             PostedImagecell.messageWhenNoPostsAvailableLabelOutlet.text = @"This account is private. Follow to see photos.";
             //PostedImagecell.viewWhenNoPostsAvailable.backgroundColor = followingButtonBackGroundColor;
         }
         else {
             PostedImagecell.messageWhenNoPostsAvailableLabelOutlet.text = @"No Photos Or Videos.";
             
             if(postDetails.count == 0 ) {
                 //show view for no photos or videos message.
                 PostedImagecell.viewWhenNoPostsAvailable.hidden = NO;
                 PostedImagecell.viewWhenNoPostsAvailable.backgroundColor =[UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0];
                 
              
                 // 60 for first section and 30 for 2nd section(no need to show rectangular images just we need to show no posts available message.)
             }
             else {
                 PostedImagecell.viewWhenNoPostsAvailable.hidden = YES;
                 
             }
         }
         
         
         if(postDetails.count == 1) {
             if(flStrForObj(respDeatils[indexPath.row][@"postData"][0][@"thumbnailImageUrl"])) {
                 [PostedImagecell.postedImage1  sd_setImageWithURL:[NSURL URLWithString:flStrForObj(respDeatils[indexPath.row][@"postData"][0][@"thumbnailImageUrl"])]  placeholderImage:[UIImage imageNamed:@""]];
             }
             PostedImagecell.postedImage2.image = nil;
             PostedImagecell.postedImage3.image = nil;
         }
         else if (postDetails.count  == 2) {
             if(flStrForObj(respDeatils[indexPath.row][@"postData"][0][@"thumbnailImageUrl"])) {
                 [PostedImagecell.postedImage1  sd_setImageWithURL:[NSURL URLWithString:flStrForObj(respDeatils[indexPath.row][@"postData"][0][@"thumbnailImageUrl"])]  placeholderImage:[UIImage imageNamed:@""]];
             }
             if(flStrForObj(respDeatils[indexPath.row][@"postData"][1][@"thumbnailImageUrl"])) {
                 [PostedImagecell.postedImage2  sd_setImageWithURL:[NSURL URLWithString:flStrForObj(respDeatils[indexPath.row][@"postData"][1][@"thumbnailImageUrl"])]  placeholderImage:[UIImage imageNamed:@""]];
             }
             PostedImagecell.postedImage3.image = nil;
         }
         else if (postDetails.count  > 2) {
             if(flStrForObj(respDeatils[indexPath.row][@"postData"][0][@"thumbnailImageUrl"])) {
                 [PostedImagecell.postedImage1  sd_setImageWithURL:[NSURL URLWithString:flStrForObj(respDeatils[indexPath.row][@"postData"][0][@"thumbnailImageUrl"])]  placeholderImage:[UIImage imageNamed:@""]];
             }
             if(flStrForObj(respDeatils[indexPath.row][@"postData"][1][@"thumbnailImageUrl"])) {
                 [PostedImagecell.postedImage2  sd_setImageWithURL:[NSURL URLWithString:flStrForObj(respDeatils[indexPath.row][@"postData"][1][@"thumbnailImageUrl"])]  placeholderImage:[UIImage imageNamed:@""]];
             }
             if(flStrForObj(respDeatils[indexPath.row][@"postData"][2][@"thumbnailImageUrl"])) {
                 [PostedImagecell.postedImage3  sd_setImageWithURL:[NSURL URLWithString:flStrForObj(respDeatils[indexPath.row][@"postData"][2][@"thumbnailImageUrl"])]  placeholderImage:[UIImage imageNamed:@""]];
             }
         }
         
         PostedImagecell.buttonForPostedImage1.tag = 1500 + indexPath.row;
         PostedImagecell.buttonForPostedImage2.tag = 2000 + indexPath.row;
         PostedImagecell.buttonForPostedImage3.tag = 2500 + indexPath.row;
         [PostedImagecell.buttonForPostedImage1 addTarget:self
                                                   action:@selector(buttonActionFor1stImage:)
                                         forControlEvents:UIControlEventTouchUpInside];
         [PostedImagecell.buttonForPostedImage2 addTarget:self
                                                   action:@selector(buttonActionFor2ndImage:)
                                         forControlEvents:UIControlEventTouchUpInside];
         [PostedImagecell.buttonForPostedImage3 addTarget:self
                                                   action:@selector(buttonActionFor3rdImage:)
                                         forControlEvents:UIControlEventTouchUpInside];
         [PostedImagecell layoutIfNeeded];
         PostedImagecell.profileImageViewOutlet.layer.cornerRadius = PostedImagecell.profileImageViewOutlet.frame.size.height/2;
         PostedImagecell.profileImageViewOutlet.clipsToBounds = YES;
         
         
         
         PostedImagecell.hideButtonOutlet.layer.cornerRadius = 5;
         PostedImagecell.hideButtonOutlet.layer.borderWidth = 1;
         
         PostedImagecell.hideButtonOutlet.layer.borderColor = [UIColor colorWithRed:0.6781 green:0.6781 blue:0.6781 alpha:1.0].CGColor;
         return PostedImagecell;
         }
}
         
-(void)buttonActionFor3rdImage:(id)sender {
    //    NSIndexPath *indexPath = [self.discoverTableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview]];
    //    NSLog( @"clicked row at %ld",(long)indexPath.row);
    //    [self requestForPostsInListView:indexPath.row and:2];
}
         
-(void)buttonActionFor2ndImage:(id)sender {
    //    NSIndexPath *indexPath = [self.discoverTableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview]];
    //    NSLog( @"clicked row at %ld",(long)indexPath.row);
    //    [self requestForPostsInListView:indexPath.row and:1];
}
         
-(void)buttonActionFor1stImage:(id)sender {
    //    NSIndexPath *indexPath = [self.discoverTableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview]];
    //    NSLog( @"clicked row at %ld",(long)indexPath.row);
    //    [self requestForPostsInListView:indexPath.row and:0];
}
         
-(void)updateFollowButtonTitle :(NSInteger )row and:(id)sender {
             
             
    UIButton *reeceivedButton = (UIButton *)sender;
    [reeceivedButton setTitleColor:[UIColor whiteColor]
                        forState:UIControlStateHighlighted];
    
    // for temp  -- FollowingStaus --> 0 follow
    //           -- FollowingStaus --> 1 following
    //           -- FollowingStaus --> 2 requested
    
    if(([arrayOfFollowingStaus[row]  isEqualToString:@"1"])) {
        [reeceivedButton  setTitle:@"FOLLOWING" forState:UIControlStateNormal];
        [reeceivedButton  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        reeceivedButton.backgroundColor =[UIColor colorWithRed:0.4 green:0.7412 blue:0.1804 alpha:1.0];
        reeceivedButton.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    }
    else if(([arrayOfFollowingStaus[row]  isEqualToString:@"0"])) {
        [reeceivedButton  setTitle:@"FOLLOW" forState:UIControlStateNormal];
        [reeceivedButton  setTitleColor:followButtonTextColor forState:UIControlStateNormal];
        reeceivedButton.backgroundColor = [UIColor whiteColor];
        reeceivedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    }
    else {
        [reeceivedButton  setTitle:@"REQUESTED" forState:UIControlStateNormal];
        
        [reeceivedButton  setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
        reeceivedButton.backgroundColor = [UIColor colorWithRed:0.7804 green:0.7804 blue:0.7804 alpha:1.0];
        reeceivedButton .layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    
    
    reeceivedButton.tag = 1000 + row;
    [reeceivedButton addTarget:self
                        action:@selector(FollowButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
}
         
         
         
-(void)requestForPostsInListView:(NSInteger )selectedindex  and:(NSInteger )gotoPost{
    ListOfPostsViewController  *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"listViewVcStoryBoardId"];
    newView.ListViewdata = respDeatils[selectedindex];
    newView.listViewForPostsOf = @"listViewForDiscoverPeople";
    newView.navTitle = flStrForObj(respDeatils[selectedindex][@"postedByUserName"]);
    //move to first post bcoz user clicking on first button so we need to jump to first post.
    NSInteger gotoPostNumber = gotoPost;
    newView.movetoRowNumber = gotoPostNumber;
    [self.navigationController pushViewController:newView animated:YES];
}
         
-(void)hideButtonAction:(id)sender {
    NSIndexPath *indexPath = [self.discoverTableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview]];
    NSUInteger row = [indexPath row];
    
    // requesting hide particular user from suggestions.
    NSDictionary *requestDict = @{mmembername     : flStrForObj(respDeatils[row][@"postedByUserName"]),
                                  mauthToken            :[Helper userToken],
                                  };
    [WebServiceHandler hideFromDiscovery:requestDict andDelegate:self];
    
    [respDeatils removeObjectAtIndex:row];
    [arrayOfFollowingStaus removeObjectAtIndex:row];
    [_discoverTableView beginUpdates];
    [_discoverTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationTop];
    [_discoverTableView endUpdates];
}
         

         
-(void)FollowButtonAction:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;

    NSIndexPath *selectedCellForLike = [_discoverTableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview ]];
    
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    NSString *memberPrivateAccountState = flStrForObj(respDeatils[selectedCellForLike.row][@"privateProfile"]);
    
    
    DiscoverTableViewPostedImagesCell *selectedCell = [self.discoverTableView cellForRowAtIndexPath:selectedCellForLike];
    
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([selectedButton.titleLabel.text isEqualToString:@"FOLLOW"]) {
            arrayOfFollowingStaus[selectedCellForLike.row] = @"2";
            selectedButton.backgroundColor = requstedButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor clearColor].CGColor;
             [selectedButton  setTitle:@"REQUESTED" forState:UIControlStateNormal];
            [selectedButton setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            [UIView animateWithDuration:0.1 animations:^ {
            selectedCell.followButtonTrailingConstraint.constant = - 40;
            selectedCell.widthConstraintFollowButtonOutlet.constant = 105;
            }];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(respDeatils[selectedButton.tag%1000][@"postedByUserName"]) andNewStatus:@"0"];
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :respDeatils[selectedCellForLike.row][@"postedByUserName"],
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
        else if ([selectedButton.titleLabel.text isEqualToString:@"FOLLOWING"])  {
            selectedButton.backgroundColor = followButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
              [selectedButton  setTitle:@"FOLLOW" forState:UIControlStateNormal];
            [UIView animateWithDuration:0.1 animations:^ {
                selectedCell.followButtonTrailingConstraint.constant = 5;
                selectedCell.widthConstraintFollowButtonOutlet.constant = 60;
            }];
            
            arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
             [self sendNewFollowStatusThroughNotification:flStrForObj(respDeatils[selectedButton.tag%1000][@"postedByUserName"]) andNewStatus:@"2"];
            
            //passing parameters.    muserNameToUnFollow
            NSDictionary *requestDict = @{muserNameToUnFollow     : respDeatils[selectedCellForLike.row][@"postedByUserName"],
                                          mauthToken            :[Helper userToken],
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
        else {
            // cancel request for follow.
            [selectedButton  setTitle:@"FOLLOW" forState:UIControlStateNormal];
            selectedButton.backgroundColor = followButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            [UIView animateWithDuration:0.1 animations:^ {
                selectedCell.followButtonTrailingConstraint.constant = 5;
                selectedCell.widthConstraintFollowButtonOutlet.constant = 60;
            }];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(respDeatils[selectedButton.tag%1000][@"postedByUserName"]) andNewStatus:@"2"];
            arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
            NSDictionary *requestDict = @{muserNameToUnFollow     : respDeatils[selectedCellForLike.row][@"postedByUserName"],
                                          mauthToken            :[Helper userToken],
                                          };
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
    }
    
    //actions for when the account is public.
    else {
        if ([selectedButton.titleLabel.text isEqualToString:@"FOLLOWING"]) {
            arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
            [selectedButton  setTitle:@"FOLLOW" forState:UIControlStateNormal];
            [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            selectedButton.backgroundColor = followButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            [UIView animateWithDuration:0.1 animations:^ {
                selectedCell.followButtonTrailingConstraint.constant = 5;
                selectedCell.widthConstraintFollowButtonOutlet.constant = 60;
            }];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(respDeatils[selectedButton.tag%1000][@"postedByUserName"]) andNewStatus:@"2"];
            
            //passing parameters.    muserNameToUnFollow
            NSDictionary *requestDict = @{muserNameToUnFollow   : respDeatils[selectedCellForLike.row][@"postedByUserName"],
                                          mauthToken            :[Helper userToken],
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
        else {
            arrayOfFollowingStaus[selectedCellForLike.row] = @"1";
            [selectedButton  setTitle:@"FOLLOWING" forState:UIControlStateNormal];
            [selectedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            selectedButton.backgroundColor = followingButtonBackGroundColor;
            selectedButton.layer.borderColor = [UIColor clearColor].CGColor;
            [selectedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [UIView animateWithDuration:0.1 animations:^ {
                selectedCell.followButtonTrailingConstraint.constant = -40;
                selectedCell.widthConstraintFollowButtonOutlet.constant = 105;
            }];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(respDeatils[selectedButton.tag%1000][@"postedByUserName"]) andNewStatus:@"1"];
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :respDeatils[selectedCellForLike.row][@"postedByUserName"],
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
    }
}
         
         
#pragma mark
#pragma mark - navigation bar next button
         
- (void)createNavRightButton {
    UIButton *navDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navDoneButton setTitle:@"Done"
                   forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor blackColor]
                        forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor blackColor]
                        forState:UIControlStateHighlighted];
    navDoneButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:13];
    [navDoneButton setFrame:CGRectMake(0,0,50,30)];
    [navDoneButton addTarget:self action:@selector(DoneButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navDoneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}
         
- (void)DoneButtonAction:(UIButton *)sender {
    // [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
         
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
             
    if (indexPath.section == 1) {
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        newView.checkProfileOfUserNmae = flStrForObj(respDeatils[indexPath.row][@"postedByUserName"]);
        newView.checkingFriendsProfile = YES;
        [self.navigationController pushViewController:newView animated:YES];
    }
    else {
        if (indexPath.section == 0 && indexPath.row == 0) {
            ConnectToFaceBookViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"connectToFaceBookFriendsStoryBoardId"];
            postsVc.syncingContactsOf = @"faceBook";
            [self.navigationController pushViewController:postsVc animated:YES];
        }
        if (indexPath.section == 0 && indexPath.row == 1) {
            ConnectToFaceBookViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"connectToFaceBookFriendsStoryBoardId"];
            postsVc.syncingContactsOf = @"phoneBook";
            [self.navigationController pushViewController:postsVc animated:YES];
        }
    }
}
         
#pragma mark
#pragma mark - collection view delegates
         
        /**
         *  declaring numberOfSectionsInCollectionView
         *  @param collectionView declaring numberOfSectionsInCollectionView in collection view.
         *  @return number of sctions in collection view here it is 1.
         */
         
         - (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
             return 1;
         }
         
        /**
         *  declaring numberOfItemsInSection
         *  @param collectionView declaring numberOfItemsInSection in collection view.
         *  @param section    here only one section.
         *  @return number of items in collection view here it is 100.
         */
         
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
             NSMutableArray   *postedData = respDeatils[rowAt.row][@"postData"];
             return postedData.count;
}
         
        /**
         *  implementation of collection view cell
         *  @param collectionView collectionView has only image view
         *  @return implemented cell will return.
         */
         
         - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
             static NSString *reuseIdentifier = @"discoverPeopleCollectionViewCell";
             collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
             //  collectionViewCell.postedImageViewOutlet.image = [UIImage imageNamed:@"instagr.am3_.jpg"];
             [ collectionViewCell.postedImageViewOutlet  sd_setImageWithURL:[NSURL URLWithString:flStrForObj(respDeatils[rowAt.row][@"postData"][indexPath.item][@"thumbnailImageUrl"])]  placeholderImage:[UIImage imageNamed:@""]];
             return collectionViewCell;
         }
         
         -(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
             
         }
         
         - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
             return CGSizeMake(CGRectGetWidth(self.view.frame)/3,CGRectGetWidth(self.view.frame)/3);
         }
         
         /*-------------------------------------------------------*/
#pragma mark - Webservice Handler
#pragma mark - WebServiceDelegate
         /*------------------------------------------------------*/
         
- (void) didFinishLoadingRequest:(RequestType )requestType withResponse:(id)response error:(NSError*)error {
             // handling response.
       [avForCollectionView stopAnimating];
             if (error) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:[error localizedDescription]
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil,nil];
                 [alert show];
                 self.discoverTableView.backgroundView = nil;
                 [avForCollectionView stopAnimating];
                 [self showingMessageForCollectionViewBackground:[error localizedDescription]];
                 return;
             }
             
             NSDictionary *responseDict = (NSDictionary*)response;
             if (requestType == RequestTypeDiscoverPeople ) {
                 
                 [refreshControl endRefreshing];
                 
                 switch ([responseDict[@"code"] integerValue]) {
                     case 200: {
                         //successs response.
                         NSArray *newData = responseDict[@"discoverData"];
                         
                         if(neccessaryToRemoveOldPostsData) {
                             neccessaryToRemoveOldPostsData = NO;
                             [respDeatils removeAllObjects];
                             [arrayOfFollowingStaus removeAllObjects];
                             [respDeatils addObjectsFromArray:newData];
                             
                             if(respDeatils.count) {
                                 for(int i = 0; i< newData.count;i++) {
                                     NSString *followingstatus = flStrForObj(respDeatils[i][@"followsFlag"]);
                                     [arrayOfFollowingStaus addObject:followingstatus];
                                 }
                                 title = [NSArray arrayWithObjects:@"Connect to Facebook",@"Connect to Contacts", nil];
                                 [self.discoverTableView reloadData];
                             }
                             else {
                                 [self.discoverTableView reloadData];
                                 [self backGrounViewWithImageAndTitle:@"None Of Your Friends Are Using Picogram"];
                             }
                         }
                         else {
                             [respDeatils addObjectsFromArray:newData];
                             if(respDeatils.count) {
                                 for(int i = 0; i< newData.count;i++) {
                                     NSString *followingstatus = flStrForObj(respDeatils[i][@"followsFlag"]);
                                     [arrayOfFollowingStaus addObject:followingstatus];
                                 }
                                 title = [NSArray arrayWithObjects:@"Connect to Facebook",@"Connect to Contacts", nil];
                                 [self.discoverTableView reloadData];
                             }
                             else {
                                 title = [NSArray arrayWithObjects:@"Connect to Facebook",@"Connect to Contacts", nil];
                                 [self.discoverTableView reloadData];
                                 [self backGrounViewWithImageAndTitle:@"None Of Your Friends Are Using Picogram"];
                             }
                         }
                     }
                         break;
                     case 2021: {
                         [self errorAlert:responseDict[@"message"]];
                     }
                         break;
                     case 2022: {
                         [self errorAlert:responseDict[@"message"]];
                         
                     }
                         break;
                     case 2023: {
                         [self errorAlert:responseDict[@"message"]];
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
                     case 91222: {
                         [avForCollectionView stopAnimating];
                         UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                         [noDataAvailableMessageView setCenter:self.view.center];
                         UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200, 40)];
                         message.textAlignment = NSTextAlignmentCenter;
                         message.text = responseDict[@"message"];
                         [noDataAvailableMessageView addSubview:message];
                         self.discoverTableView.backgroundColor = [UIColor clearColor];
                         self.discoverTableView.backgroundView = noDataAvailableMessageView;
                     }
                         break;
                     default:
                         break;
                 }
             }
         }
         
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // UITableView only moves in one direction, y axis
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    //NSInteger result = maximumOffset - currentOffset;
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0) {
        [self requestForMoreData:++offsetForMorePosts];
    }
}
         
         
-(void)requestForMoreData:(NSInteger )pageNumber {
    if(respDeatils.count %10 == 0) {
        pageNumber++;
        [self requestForDiscoverPeopleApi:pageNumber];
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
         
-(UIView *)showingMessageForCollectionViewBackground:(NSString *)textmessage {
    UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [noDataAvailableMessageView setCenter:self.view.center];
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200,100)];
    message.numberOfLines =0;
    message.textAlignment = NSTextAlignmentCenter;
    message.text = textmessage;
    [noDataAvailableMessageView addSubview:message];
    self.discoverTableView.backgroundColor = [UIColor whiteColor];
    self.discoverTableView.backgroundView = noDataAvailableMessageView;
    return noDataAvailableMessageView;
}
         
-(void)addingActivityIndicatorToCollectionViewBackGround {
    avForCollectionView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    avForCollectionView.frame =CGRectMake(self.view.frame.size.width/2 -12.5, self.view.frame.size.height/2 -12.5, 25,25);
    avForCollectionView.tag  = 1;
    [self.discoverTableView addSubview:avForCollectionView];
    [avForCollectionView startAnimating];
}
         
-(void)backGrounViewWithImageAndTitle:(NSString *)mesage{
             
    UIView *viewWhenNoPosts = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImageView *image =[[UIImageView alloc] init];
    image.image = [UIImage imageNamed:@"ip5"];
    image.frame =  CGRectMake(self.view.frame.size.width/2 - 45, self.view.frame.size.height/2 - 45, 90, 90);
    [viewWhenNoPosts addSubview:image];
    
    UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
    labelForNoPostsMessage.text = mesage;
    labelForNoPostsMessage.textColor = [UIColor whiteColor];
    labelForNoPostsMessage.numberOfLines =0;
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    labelForNoPostsMessage.frame = CGRectMake(0, CGRectGetMaxY(image.frame) + 10, self.view.frame.size.width, 60);
    [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoRegular size:15]];
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    [viewWhenNoPosts addSubview:labelForNoPostsMessage];
//    self.discoverTableView.backgroundColor = backGroundColor;
    self.discoverTableView.backgroundView = viewWhenNoPosts;
}
         
@end
