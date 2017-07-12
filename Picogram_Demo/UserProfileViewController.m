///
//  UserProfileViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/30/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UserProfileCollectionViewCell.h"
#import "PostedPhotosCollectionViewController.h"
#import "MapViewController.h"
#import "HomeViewCommentsViewController.h"
#import "LikeViewController.h"
#import "ShareViewXib.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "UIImageView+AFNetworking.h"
#import "DetailPostViewController.h"
#import "UIImageView+WebCache.h"
#import "HashTagViewController.h"
#import "UIImage+GIF.h"
#import "PGLogInViewController.h"
#import "TinderGenericUtility.h"
#import "EditProfileViewController.h"
#import "PostedPhotosCollectionViewController.h"
#import "FontDetailsClass.h"
#import "PhotosPostedByLocationViewController.h"
#import "ProgressIndicator.h"
#import "Helper.h"
#import "OptionsViewController.h"
#import "PGDiscoverPeopleViewController.h"
#import "SharingPostViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareVideo.h>
#import <FBSDKShareKit/FBSDKShareOpenGraphContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareVideoContent.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKShareKit/FBSDKShareAPI.h>
#import <FBSDKShareKit/FBSDKSharePhotoContent.h>
#import "InstaVIdeoTableViewController.h"
#import "InstaTableViewCellForProfileVc.h"
#import "InstaVideoTableViewCell.h"
#import "LikeCommentTableViewCell.h"
#import "PostDetailsTableViewCell.h"
#import "SVPullToRefresh.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "businessHelpViewController.h"
#import "WebViewForDetailsVc.h"

// Chat Start
#import "ShareViewXib.h"
#import "suggestionViewController.h"
#import "AppDelegate.h"
#import "PageContentViewController.h"
#import "ChatNavigationContollerClass.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import "CouchbaseEvents.h"
#import "MSReceive.h"
#import "ContacDataBase.h"
#import "MacroFile.h"
#import "UIImageView+AFNetworking.h"
#import "HomeScreenTabBarController.h"
// Chat End

@interface UserProfileViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,profileViewDelegate,UITableViewDelegate,UITableViewDataSource,shareViewDelegate,WebServiceHandlerDelegate,UIGestureRecognizerDelegate,SDWebImageManagerDelegate,UIActionSheetDelegate,MyTableViewCellDelegate,MFMailComposeViewControllerDelegate,MyTableViewCellDelegateForUserProfile> {
    UserProfileCollectionViewCell *collectionViewCell;
    ProfileViewXib *userProfileView;
    
    UIRefreshControl *refreshControl;
    BOOL isTableSelected;
    
    
    NSString *ProfilePicUrl;
    
    BOOL checkingOwnProfile;
    BOOL visitingFirstTime;
    BOOL businessType;
    
    UIActivityIndicatorView *avInNavBar;
    CGFloat heightOfTheRow;
    NSInteger pageNumber;
    UIButton *navNextButton;
    NSIndexPath *selectedCellIndexPathForActionSheet;
    
    NSMutableArray *userPostsData;
    
    bool neccessaryToshowFollowRequestMessage;
    UILabel *errorMessageLabelOutlet;
    
    NSString *memberPrivateAccountState;
    CLLocationManager *locationManager;
    NSString *longitude;
    NSString *lattitude;
    NSString *address;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL classIsAppearing;
    NSString *profileContact;
    // Chat Start
    ShareViewXib *shareNib;
    UIView *polygonView;
    // Chat End
}
@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    businessType = YES;
     [self customizingnavigationBar];
    [self customeError];
    [self roundedImage];
    [self hidingRemaingViewsExceptCollectionView];
    [self calculateCollectionViewHeight];
    [self tapGestureForWebsiteUrl];
    [self addingRefreshControl];
    
    [self gettingDetailsOfUser];
    [self requestForPosts];
    [self createNavLeftButton];
    
    [self creatingNotificationForUpdatingLikeDetails];
    [self creatingNotoificationsForOwnProfile];
    [self notificationForNumberOfPrivateRequests];
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
}

-(void)creatingNotoificationsForOwnProfile {
    if ([self.checkProfileOfUserNmae isEqualToString:[Helper userName]] || !self.checkingFriendsProfile) {
        
        //these notifications only for own profile.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfilePicUrl:) name:@"updateProfilePic" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bussinessProfileIsUpdated:) name:@"bussinessProfileUpdated" object:nil];
    }
}


-(void)contactBtn
{
    if (self.contactButtonOutlet.frame.size.width<1) {
        self.contactButtonWidthConstaraint.constant = self.EditProfileAndContactSuperView.frame.size.width/2;
        self.EditProfileLeadingConstraibnt.constant = 5;
    }
}

-(void)businessContactAction
{
    UIActionSheet *contactAction = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Get Directions",@"Call",@"Email", nil];
    contactAction.tag = 5000;
    [contactAction showInView:self.view];
}

-(void)notificationForNumberOfPrivateRequests {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTopPrivateRequestStatus:) name:@"updatePrivateRequstedPeopleNumber" object:nil];
}

-(void)updateTopPrivateRequestStatus:(NSNotification *)noti {
    [self removefollowmessageview];
}

-(void)notificationForDeleteApost {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePostFromNotification:) name:@"deletePost" object:nil];
}

-(void)deletePostFromNotification:(NSNotification *)noti {
    NSString *updatepostId = flStrForObj(noti.object[@"deletedPostDetails"][@"postId"]);
    for (int i=0; i <userPostsData.count;i++) {
        
        if ([flStrForObj(userPostsData[i][@"postId"]) isEqualToString:updatepostId])
        {
            
            NSInteger numberOfPosts = [self.numberOfPostsLabelOutlet.text integerValue];
            numberOfPosts--;
            if (numberOfPosts >=0) {
                self.numberOfPostsLabelOutlet.text = [NSString stringWithFormat:@"%ld",(long)numberOfPosts ];
            }
            else {
                self.numberOfPostsLabelOutlet.text = 0;
            }
            NSUInteger atSection = i;
            [self removeRelatedDataOfDeletePost:atSection];
            [_customTableView beginUpdates];
            [_customTableView deleteSections:[NSIndexSet indexSetWithIndex:selectedCellIndexPathForActionSheet.section] withRowAnimation:UITableViewRowAnimationNone];
            [_customTableView endUpdates];
            self.customTableView.contentSize = [self.customTableView sizeThatFits:CGSizeMake(CGRectGetWidth(self.customTableView.bounds), CGFLOAT_MAX)];
            [self remove:atSection];
            [self calculateCollectionViewHeight];
            break;
        }
    }
}

-(void)creatingNotificationForUpdatingLikeDetails {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetails:) name:@"updatePostDetails" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedCommentsdata:) name:@"passingUpdatedComments" object:nil];
}


-(void)updatedCommentsdata:(NSNotification *)noti {
    //check the postId and Its Index In array.
    
    if (!classIsAppearing) {
        NSString *updatepostId = flStrForObj(noti.object[@"newCommentsData"][@"data"][0][@"postId"]);
        NSString *commentUpdateFor = flStrForObj(noti.object[@"newCommentsData"][@"message"]);
        //Successfully posted users Comment
        for (int i=0; i <userPostsData.count;i++) {
            if ([flStrForObj(userPostsData[i][@"postId"]) isEqualToString:updatepostId])
            {
                
                //NSInteger updateCellNumber  = [noti.object[@"newCommentsData"][@"selectedCell"] integerValue];
                if ([commentUpdateFor isEqualToString:@"Successfully posted users Comment"]) {
                    //when new comment on post
                    NSMutableArray *newCommentData = noti.object[@"newCommentsData"][@"data"][0][@"commentData"];
                    NSMutableArray *oldCommentsData = [[NSMutableArray alloc] init];
                    oldCommentsData = userPostsData[i][@"commentData"];
                    [newCommentData addObjectsFromArray:oldCommentsData];
                    
                    [[userPostsData objectAtIndex:i] setObject:newCommentData forKey:@"commentData"];
                    NSString *newNumberOfComments = noti.object[@"newCommentsData"][@"data"][0][@"totalComments"];
                    
                    [[userPostsData objectAtIndex:i] setObject:newNumberOfComments forKey:@"totalComments"];
                    
                    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:3 inSection:i];
                    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,nil];
                    [self.customTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
                else {
                    //when delete comment on post
                    
                    
                    NSArray *deletedCommentData = noti.object[@"newCommentsData"][@"data"][0][@"commentData"];
                    NSMutableArray *previousCommentData = [[NSMutableArray alloc] init];
                    previousCommentData = userPostsData[i][@"commentData"];
                    
                    NSString *theCommentIdToremove = flStrForObj(deletedCommentData[0][@"commentId"]);
                    
                    for (int x=0;x<previousCommentData.count;x++) {
                        
                        NSString *commentIdFromOldData = flStrForObj(previousCommentData[x][@"commentId"]);
                        
                        if ([commentIdFromOldData isEqualToString:theCommentIdToremove]) {
                            [previousCommentData removeObjectAtIndex:x];
                            
                            [[userPostsData objectAtIndex:i] setObject:previousCommentData forKey:@"commentData"];
                            
                            NSString *newNumberOfComments = noti.object[@"newCommentsData"][@"data"][0][@"totalComments"];
                            
                            [[userPostsData objectAtIndex:i] setObject:newNumberOfComments forKey:@"totalComments"];
                            
                            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:3 inSection:i];
                            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,nil];
                            [self.customTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                            break;
                        }
                    }
                }
            }
        }
    }
}

-(void)updateDetails:(NSNotification *)noti {
    
    //check the postId and Its Index In array.
    
    if(!classIsAppearing) {
        NSString *updatepostId = flStrForObj(noti.object[@"profilePicUrl"][@"data"][0][@"postId"]);
        for (int i=0; i <userPostsData.count;i++) {
            if ([flStrForObj(userPostsData[i][@"postId"]) isEqualToString:updatepostId])
            {
                //  updating the new data and reloading particular section.(row is constant)
                // row 1 is likebutton and commentButton.
                //row 2 is caption and comments.
                
                if ([flStrForObj(noti.object[@"profilePicUrl"][@"message"]) isEqualToString:@"unliked the post"]) {
                    //notification for unlike a post
                    //so update like status to zero.
                    
                    [[userPostsData objectAtIndex:i] setObject:@"0" forKey:@"likeStatus"];
                }
                else {
                    [[userPostsData objectAtIndex:i] setObject:@"1" forKey:@"likeStatus"];
                }
                
                NSString *updatedNumberOfLikes = flStrForObj(noti.object[@"profilePicUrl"][@"data"][0][@"likes"]);
                [[userPostsData objectAtIndex:i] setObject:updatedNumberOfLikes forKey:@"likes"];
                userPostsData[i][@"likes"] = noti.object[@"profilePicUrl"][@"data"][0][@"likes"];
                
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:2 inSection:i];
                NSIndexPath* secondRowToreload  = [NSIndexPath indexPathForRow:3 inSection:i];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,secondRowToreload, nil];
                [self.customTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
                
                break;
            }
        }
    }
}


-(void)customeError
{
    errorMessageLabelOutlet = [[UILabel alloc]initWithFrame:CGRectMake(0, -80, [UIScreen mainScreen].bounds.size.width, 50)];
    errorMessageLabelOutlet.backgroundColor = [UIColor colorWithRed:108/255.0f green:187/255.0f blue:79/255.0f alpha:1.0];
    errorMessageLabelOutlet.textColor = [UIColor whiteColor];
    errorMessageLabelOutlet.textAlignment = NSTextAlignmentCenter;
    [errorMessageLabelOutlet setHidden:YES];
    [self.view addSubview:errorMessageLabelOutlet];
}

-(void)bussinessProfileIsUpdated:(NSNotification *)noti {
    
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:userDetailForBussiness];
    NSDictionary *userData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    
    NSString *bussinessStatus = [Helper bussinessAccountStatus];
    if ([bussinessStatus isEqualToString:@"1"]) {
         self.contactButtonWidthConstaraint.constant = self.EditProfileAndContactSuperView.frame.size.width/2;
        self.EditProfileLeadingConstraibnt.constant = 5;
        
        //only oif the user active bussiness account then only we need to show bussiness details otherwise we need to  normal details only.
        
        _userNameLabelOutlet.text =flStrForObj(userData[@"businessName"]);
        _biodataLabelOutlet.text = flStrForObj(userData[@"aboutBusiness"]);
        
        
        [self changeTheTopcontentViewHeight];
    }
    else {
        self.contactButtonWidthConstaraint.constant = 0;
        
        
        _biodataLabelOutlet.text = flStrForObj(noti.object[@"profilePicUrl"][@"data"][@"bio"]);
        _userNameLabelOutlet.text =flStrForObj(userData[@"fullName"]);
        
        [self changeTheTopcontentViewHeight];
    }
}



-(void)updateProfilePicUrl:(NSNotification *)noti {
    
    
    _webSiteUrlLabelOutlet.text = flStrForObj(noti.object[@"profilePicUrl"][@"data"][@"website"]);
    
    NSString *bussinessStatus = [Helper bussinessAccountStatus];
    if ([bussinessStatus isEqualToString:@"1"]) {
        _userNameLabelOutlet.text =flStrForObj(noti.object[@"profilePicUrl"][@"data"][@"businessName"]);
        _biodataLabelOutlet.text = flStrForObj(noti.object[@"profilePicUrl"][@"data"][@"aboutBusiness"]);
    }
    else
    { _biodataLabelOutlet.text = flStrForObj(noti.object[@"profilePicUrl"][@"data"][@"bio"]);
    _userNameLabelOutlet.text =flStrForObj(noti.object[@"profilePicUrl"][@"data"][@"fullName"]);
    }
    
    
    self.navigationItem.title = flStrForObj(noti.object[@"profilePicUrl"][@"data"][@"username"]);
    
    ProfilePicUrl = flStrForObj(noti.object[@"profilePicUrl"][@"data"][@"profilePicUrl"]);
    if ([ProfilePicUrl isEqualToString:@"defaultUrl"]) {
        _profilePhotoOutlet.image = [UIImage imageNamed:@"defaultpp.png"];
    }
    else {
        [_profilePhotoOutlet sd_setImageWithURL:[NSURL URLWithString:ProfilePicUrl] placeholderImage:[UIImage imageNamed:@"defaultpp"]];
    }
    
    [self changeTheTopcontentViewHeight];
}

-(void)sendNewFollowStatusThroughNotification:(NSString *)userName andNewStatus:(NSString *)newFollowStatus {
    
    
    
    NSDictionary *newFollowDict = @{@"newFollowStatus"     :flStrForObj(newFollowStatus),
                                    @"userName"            :flStrForObj(userName),
                                    };
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedFollowStatus" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"newUpdatedFollowData"]];
}

-(void)updateFollwoStatus:(NSNotification *)noti {
    //check the postId and Its Index In array.
    NSString *userName = flStrForObj(noti.object[@"newUpdatedFollowData"][@"userName"]);
    NSString *foolowStatusRespectToUser = noti.object[@"newUpdatedFollowData"][@"newFollowStatus"];
    
    
    if ([self.navigationItem.title isEqualToString:userName]) {
        // userfollowingstatus : null (no follow request) ---- >(Title:Follow)
        // userfollowingstatus : 0 (requested to follow) ---- >(REQUESTED)
        //userfollowingstatus : 1 (accepted and follwoing) ---- >(Title:Following)
        
        
        
        if ([foolowStatusRespectToUser isEqualToString:@"0"]) {
            [self.editProfileButtonOutlet  setTitle:@" REQUESTED" forState:UIControlStateNormal];
             [self.editProfileButtonOutlet  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            self.editProfileButtonOutlet .backgroundColor= requstedButtonBackGroundColor;
            [self.editProfileButtonOutlet setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            self.editProfileButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
        }
        else if ([foolowStatusRespectToUser isEqualToString:@"1"]) {
            [self.editProfileButtonOutlet  setTitle:@" Following" forState:UIControlStateNormal];
             [self.editProfileButtonOutlet setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
            _editProfileButtonOutlet.backgroundColor = followingButtonBackGroundColor;
            _editProfileButtonOutlet.layer.borderColor = [UIColor clearColor].CGColor;
        }
        else
        {
            [self.editProfileButtonOutlet  setTitle:@" Follow" forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
             [self.editProfileButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            self.editProfileButtonOutlet .backgroundColor=followButtonBackGroundColor;
            self.editProfileButtonOutlet .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
        }
    }
}

//-(void)updatedCommentsdata:(NSNotification *)noti {
//    NSInteger updateCellNumber  = [noti.object[@"newCommentsData"][@"selectedCell"] integerValue];
//    NSString *updatedComment = flStrForObj(noti.object[@"newCommentsData"][@"data"][0][@"Posts"][@"properties"][@"commenTs"]);
//    [[responseData objectAtIndex:updateCellNumber] setObject:updatedComment forKey:@"comments"];
//    [_customTableView reloadSections:[NSIndexSet indexSetWithIndex:updateCellNumber] witpo hRowAnimation:UITableViewRowAnimationNone];
//}

-(void)viewDidAppear:(BOOL)animated {
    
    // Chat Start
    NSString *valueToSave =@"0";
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"TabSellected"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = (UIScrollView *)view;
            NSString *tabSellected = [[NSUserDefaults standardUserDefaults]
                                      stringForKey:@"TabSellected"];
            
            if([tabSellected isEqualToString:@"0"])
            {
                // scrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, self.view.frame.size.height);
                scrollView.scrollEnabled = YES;
            }else{
                scrollView.scrollEnabled = NO;
                // scrollView.contentSize = CGSizeZero;
            }
        }
    }
    
    
    // Chat End
    
    //not sure working or not.(image cahing)
    [self createNavLeftButton];
}

-(void)viewWillDisappear:(BOOL)animated {
    classIsAppearing = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    navNextButton.enabled  = YES;
    classIsAppearing = YES;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"postKey"]) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"postKey"];
        ProgressIndicator *pi = [ProgressIndicator sharedInstance];
        [pi showMessage:@"Posting.." On:self.view];
        [NSTimer scheduledTimerWithTimeInterval:10.5 target:self selector:@selector(hideProgress) userInfo:nil repeats:NO];
    }
    
    
    [self gettingDetailsOfUser];
    
    NSArray* cells = self.customTableView.visibleCells;
    for (InstaTableViewCellForProfileVc *cell in cells) {
        if([cell isKindOfClass:[InstaTableViewCellForProfileVc class]])
        {
            [cell.videoView resume];
        }
    }
}

-(void)hideProgress
{
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
}

-(void)requestForPosts {
    if (self.checkingFriendsProfile && self.checkProfileOfUserNmae) {
        self.navigationController.navigationItem.hidesBackButton =  YES;
        
        
        // Requesting For member posts Api.(to get the details of another user)(passing "token" and respective memberusername as parameter)
        NSDictionary *requestDict = @{
                                      mauthToken :[Helper userToken],
                                      mmemberName :self.checkProfileOfUserNmae,
                                      };
        [WebServiceHandler getMemberPosts:requestDict andDelegate:self];
        
        if ([self.checkProfileOfUserNmae isEqualToString:[Helper userName]]) {
            checkingOwnProfile =  YES;
            [self.editProfileButtonOutlet  setTitle:@"EDIT PROFILE" forState:UIControlStateNormal];
        }
        else {
            checkingOwnProfile =  NO;
        }
    }
    else {
        
       
        [self gettingDetailsOfUser];
        // Requesting For Post Api.(passing "token" as parameter)
        NSDictionary *requestDict = @{
                                      mauthToken :[Helper userToken],
                                      mlimit:@"20"
                                      };
        [WebServiceHandler getUserFriendsDetails:requestDict andDelegate:self];
        //        [WebServiceHandler getUserPosts:requestDict andDelegate:self];
        [self.editProfileButtonOutlet  setTitle:@"EDIT PROFILE" forState:UIControlStateNormal];
        checkingOwnProfile = YES;
    }
}


-(void)tapGestureForWebsiteUrl {
    UITapGestureRecognizer *labelrecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(websitelabelTapped:)];
    labelrecog.numberOfTapsRequired = 1;
    [self.webSiteUrlLabelOutlet addGestureRecognizer:labelrecog];
    self.webSiteUrlLabelOutlet.userInteractionEnabled = YES;
}

/*-----------------------------------------------*/
#pragma mark -
#pragma mark - viewDidLoad method definations.
/*-----------------------------------------------*/

-(void)customizingnavigationBar {
    
   self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
    [self createActivityViewInNavbar];
}

-(void)roundedImage {
    //profilePhoto changing into circular.
    [self.view layoutIfNeeded];
    self.profilePhotoOutlet.layer.cornerRadius = self.profilePhotoOutlet.frame.size.width / 2;
    self.profilePhotoOutlet.clipsToBounds = YES;
}

-(void)gettingDetailsOfUser {
    if(self.checkingFriendsProfile) {
        self.navigationItem.title = self.checkProfileOfUserNmae;
    } else {
        self.navigationItem.title = [Helper userName];
    }
}

-(void)hidingRemaingViewsExceptCollectionView {
    self.collectionViewButtonOutlet.selected=YES;
    isTableSelected = NO;
    self.collectionView.hidden = NO;
    self.customTableView.hidden = YES;
}


/*-----------------------------------------------*/
#pragma mark -
#pragma mark - creatingNavBarButtons.
/*-----------------------------------------------*/

- (void)createNavSettingButton {
    navNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    if (checkingOwnProfile) {
        
        // it will show settings button.
        [navNextButton setImage:[UIImage imageNamed:@"edit_profile_setting_icon_off"]
                       forState:UIControlStateNormal];
        [navNextButton setImage:[UIImage imageNamed:@"edit_profile_setting_icon_on"]
                       forState:UIControlStateSelected];
        [navNextButton addTarget:self action:@selector(SettingButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
        
        [self notificationForDeleteApost];
    }
    else {
        
        // it will show options to block the user ... etc.
        [navNextButton setImage:[UIImage imageNamed:@"home_option_icon_off"]
                       forState:UIControlStateNormal];
        [navNextButton setImage:[UIImage imageNamed:@"home_option_icon_on"]
                       forState:UIControlStateSelected];
        [navNextButton addTarget:self action:@selector(optionsButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    [navNextButton setTitleColor:[UIColor grayColor]
                        forState:UIControlStateHighlighted];
    [navNextButton setFrame:CGRectMake(-10,17,45,45)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navNextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)optionsButtonAction:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Block User" otherButtonTitles:nil,nil];
   // @"Hide Your Story",@"Copy Profile URL",@"Share this Profile",@"Send Message",@"Turn on Post Notifications"
    
    //           UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:@"Share to Facebook",@"Share to Messenger",@"Tweet",@"Copy Share URL",@"Turn on Post Notifications",nil];
    actionSheet.tag = 10;
    [actionSheet showInView:self.view];
}

-(void)addingRefreshControl {
    refreshControl = [[UIRefreshControl alloc]init];
    [self.scrollView addSubview:refreshControl];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshData:(id)sender {
    [self requestForPosts];
}


//method for creating activityview in  navigation bar right.
- (void)createActivityViewInNavbar {
    avInNavBar = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [avInNavBar setFrame:CGRectMake(0,0,50,30)];
    [self.view addSubview:avInNavBar];
    avInNavBar.tag  = 1;
    [avInNavBar startAnimating];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:avInNavBar];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}


- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)SettingButtonAction:(UIButton *)sender {
    navNextButton.enabled  = NO;
    [self performSegueWithIdentifier:@"settingButtonToOptionsSegue" sender:nil];
}

/**
 *  this method calling from xib so give the editProfileButton action here.
 */

-(void)editProfileButtonClicked {
    NSLog(@"edit profile button clicked");
}

/*-----------------------------------------------------*/
#pragma mark -
#pragma mark - collectionView Delegates and DataSource.
/*-----------------------------------------------------*/

/**
 *  declaring numberOfSectionsInCollectionView
 *
 *  @param collectionView declaring numberOfSectionsInCollectionView in collection view.
 *
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
    return userPostsData.count;
}

/**
 *  implementation of collection view cell
 *  @param collectionView collectionView has only image view
 *  @return implemented cell will return.
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.checkingFriendsProfile && self.checkProfileOfUserNmae) {
        collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCellIndentifier" forIndexPath:indexPath];
        
        
        [collectionViewCell.postedImagesOutlet sd_setImageWithURL:[NSURL URLWithString:userPostsData[indexPath.row][@"thumbnailImageUrl"]]];
        
        
        //        [collectionViewCell.postedImagesOutlet sd_setImageWithURL:[NSURL URLWithString:[arrayOfThumbNailUrls objectAtIndex:indexPath.row]]];
        
        collectionViewCell.layer.borderWidth=1.0f;
        collectionViewCell.layer.borderColor=[[UIColor whiteColor] CGColor];
        collectionViewCell.contentView.backgroundColor =[UIColor clearColor];
    }
    else {
        collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCellIndentifier" forIndexPath:indexPath];
        
        [collectionViewCell.postedImagesOutlet sd_setImageWithURL:[NSURL URLWithString:userPostsData[indexPath.row][@"thumbnailImageUrl"]]];
        
        collectionViewCell.layer.borderWidth=1.0f;
        collectionViewCell.layer.borderColor=[[UIColor whiteColor] CGColor];
        collectionViewCell.contentView.backgroundColor =[UIColor clearColor];
    }
    return collectionViewCell;
}

- (void)calculateCollectionViewHeight {
    if (isTableSelected) {
        //self.collectionViewHeight.constant = arrayOfMainUrls.count * (CGRectGetHeight(tableViewCell.frame) + 56);
        
        self.collectionViewHeight.constant = self.customTableView.contentSize.height;
        if (  self.collectionViewHeight.constant < self.view.frame.size.width) {
            self.collectionViewHeight.constant = self.view.frame.size.height - self.topContentViewHeightConstr.constant;
        }
    }
    else {
        if (collectionViewCell) {
            self.collectionViewHeight.constant = self.collectionView.contentSize.height;
            if (self.collectionViewHeight.constant < self.view.frame.size.width) {
                self.collectionViewHeight.constant =  self.view.frame.size.height - self.topContentViewHeightConstr.constant;
            }
        }
    }
    [self.view layoutIfNeeded];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.view.frame)/3,CGRectGetWidth(self.view.frame)/3);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *singlePostDetails  = userPostsData;
    
    InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
    newView.showListOfDataFor = @"ListViewForPostFromProfile";
    newView.dataFromExplore = singlePostDetails[indexPath.item];
    newView.movetoRowNumber   = 0;
    newView.navigationBarTitle =@"Photo";
    newView.profilePicForPostFromProfile =flStrForObj(ProfilePicUrl);
    newView.UserNameForPostFromProfile = self.navigationItem.title;
    [self.navigationController pushViewController:newView animated:YES];
}

/*-----------------------------------------------------*/
#pragma mark -
#pragma mark - UITableViewDataSource and delegates.
/*-----------------------------------------------------*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return userPostsData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
//-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return heightOfTheRow;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{  return 56;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // creating custom header view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 56)];
    view.backgroundColor = [UIColor whiteColor];
    
    /* Create custom view to display section header... */
    //creating user name label
    
    
    UILabel *UserNamelabel = [[UILabel alloc] init];
    if (self.checkingFriendsProfile && self.checkProfileOfUserNmae) {
        UserNamelabel.text =self.checkProfileOfUserNmae;
    }
    else {
        UserNamelabel.text =[Helper userName];;
    }
    
    [UserNamelabel setFont:[UIFont fontWithName:RobotoMedium size:15]];
    UserNamelabel.textColor =[UIColor colorWithRed:0.1568 green:0.1568 blue:0.1568 alpha:1.0];
    
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *placeName = userPostsData[section][@"place"];
    if ([placeName isEqualToString:@"null"] ||[placeName isEqualToString:@"[object Object]"]) {
        placeName = @"";
        locationButton.enabled = NO;
    }
    
    [locationButton.titleLabel setFont:[UIFont fontWithName:RobotoLight  size:12]];
    locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [locationButton addTarget:self
                       action:@selector(locationButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    [locationButton setTitle:placeName forState:UIControlStateNormal];
    [locationButton setTitleColor: [UIColor blackColor] forState:
     UIControlStateNormal];
    
    //creating  total  header  as button
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [headerButton addTarget:self
                     action:@selector(headerButtonClicked)
           forControlEvents:UIControlEventTouchUpInside];
    headerButton.backgroundColor =  [UIColor whiteColor];
    
    //creating user image on tableView Header
    UIImageView *UserImageView =[[UIImageView alloc] init];
    
    //updating profilepicture of the post user.
    
    if ([ProfilePicUrl isEqualToString:@"defaultUrl"]) {
        UserImageView.image = [UIImage imageNamed:@"defaultpp.png"];
    }
    else {
        [UserImageView sd_setImageWithURL:[NSURL URLWithString:ProfilePicUrl] placeholderImage:[UIImage imageNamed:@"defaultpp"]];
    }
    
    
    if ([placeName isEqualToString:@""]) {
        UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 100, 18);
    }
    else {
        UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 100, 18);
    }
    
    locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 100, 18);
    //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
    //UserNamelabel.frame=CGRectMake(60, 20, 100, 15);
    
    
    UIImageView *locationImageView = [[UIImageView alloc] init];
    //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
    //if there is no place then usernamelabel will come in middle
    if ([placeName isEqualToString:@""]) {
        UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 100, 18);
        locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 0);
    }
    else {
        UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 100, 18);
        
        CGSize stringSize = [locationButton.titleLabel.text sizeWithAttributes:
                             @{NSFontAttributeName: [UIFont fontWithName:RobotoRegular size:12]}];
        //[locationButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoRegular size:12]];
        
        CGFloat width = stringSize.width;
        if (width > self.view.frame.size.width -100) {
            locationButton.frame = CGRectMake(60, 30, self.view.frame.size.width - 120, 18);
            locationImageView.frame = CGRectMake(locationButton.frame.size.width + 60, 34, 8, 10);
        }
        else {
            locationButton.frame = CGRectMake(60, 30,width +30, 18);
            
            locationImageView.frame = CGRectMake(locationButton.frame.size.width + 30, 34, 8, 10);
        }
        
        locationImageView.image = [UIImage imageNamed:@"home_next_arrow_icon_off"];
        
        
        //        CGFloat width = stringSize.width;
        //
        //        //[locationButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoRegular size:12]];
        //
        //        // locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 18);
        //        locationButton.frame = CGRectMake(60, 30,width +30, 18);
        //
        //        locationImageView.frame = CGRectMake(locationButton.frame.size.width + 30, 34, 8, 10);
        //        locationImageView.image = [UIImage imageNamed:@"home_next_arrow_icon_off"];
    }
    
    [self.view layoutIfNeeded];
    UserImageView.frame = CGRectMake(10,8,40,40);
    UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
    UserImageView.clipsToBounds = YES;
    
    headerButton.frame = CGRectMake(0, 1, tableView.frame.size.width,56);
    
    // adding  headerButton,UserImageView,timeLabel,UserNamelabel to the customized tableView  Section Header.
    [view addSubview:headerButton];
    [view addSubview:UserImageView];
    [view addSubview:UserNamelabel];
    [view addSubview:locationButton];
    [view addSubview:locationImageView];
    return view;
}

-(void)locationButtonClicked:(id)sender {
    UIButton *selectedLoaction = (UIButton *)sender;
    PhotosPostedByLocationViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"photosPostedByLoactionVCStoryBoardId"];
    postsVc.navtitle = selectedLoaction.titleLabel.text;
    [self.navigationController pushViewController:postsVc animated:YES];
}

- (void)headerButtonClicked {
    NSLog(@"header selected");
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row ==0) {
        
        InstaTableViewCellForProfileVc *cell = (InstaTableViewCellForProfileVc *)[tableView dequeueReusableCellWithIdentifier:@"InstaVideoTableViewCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        NSString *urlString;
        if (userPostsData[indexPath.row][@"mainUrl"])
            urlString = userPostsData[indexPath.section][@"mainUrl"];
        else
            urlString = userPostsData[indexPath.section][@"properties"][@"mainUrl"];
        cell.url = urlString;
        
        
        //        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        //
        //        dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([flStrForObj(userPostsData[indexPath.section][@"postsType"]) isEqualToString:@"0"]) {
                [cell.videoView setHidden:YES];
                cell.postType = @"0";
                [cell.imageViewOutlet setHidden:NO];
                [cell setUrl:urlString];
                if (userPostsData[indexPath.row][@"thumbnailImageUrl"])
                    [cell setPlaceHolderUrl:userPostsData[indexPath.row][@"thumbnailImageUrl"]];
                else
                    [cell setPlaceHolderUrl:userPostsData[indexPath.row][@"properties"][@"thumbnailImageUrl"]];
                [cell loadImageForCell];
                
                
            }
            else {
                cell.videoView = [cell videoView];
                cell.postType = @"1";
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [cell loadVideoForCellFromLinkwithUrl:urlString];
                    
                    if(indexPath.section != 0)
                    {
                        [cell.videoView pause];
                    }
                });
                [cell.videoView mute];
                [cell.videoView setHidden:NO];
                [cell.imageViewOutlet setHidden:YES];
            }
        });
        
        
        if (![userPostsData[indexPath.section][@"usersTaggedInPosts"]  containsString:@"undefined"])  {
            
            if ([flStrForObj(userPostsData[indexPath.section][@"postsType"]) isEqualToString:@"1"]) {
                cell.showTagsButtonOutlet.hidden = YES;
            }
            else {
                cell.showTagsButtonOutlet.hidden = NO;
            }
        }
        else {
            cell.showTagsButtonOutlet.hidden = YES;
        }
        
        [self removeTagsOnPhotos:cell.imageViewOutlet];
        
        return cell;
    }
    else if (indexPath.row ==1){
 
        
        static NSString *CellIdentifier = @"Cell";
        float  w = [[UIScreen mainScreen]bounds].size.width;
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        for (UIView *view in cell.subviews) {
            if ([view isKindOfClass:[UILabel class]]||[view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
        
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [buyButton addTarget:self
                      action:@selector(buyButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
        buyButton.backgroundColor =[UIColor clearColor];
        buyButton.tag = 10000 + indexPath.section ;
        
        UIImageView *arrowImage = [[UIImageView alloc]init];
        
        UILabel *showNow = [[UILabel alloc]init];
        UIView *line = [[UIView alloc] init];
        line.backgroundColor =[UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0];
        
         [Helper setToLabel:showNow Text:@"Shop Now" WithFont:RobotoRegular FSize:16 Color:[UIColor colorWithRed:46/255.0f green:144/255.0f blue:235/255.0f alpha:1.0f]];
        
        
        arrowImage.image = [UIImage imageNamed:@"shopnow.png"];
        
        
        UILabel *priceLbl = [[UILabel alloc]init];
        priceLbl.textColor = [UIColor colorWithRed:46/255.0f green:144/255.0f blue:235/255.0f alpha:1.0f];
        
        NSString *chkCurrency = flStrForObj(userPostsData[indexPath.section][@"currency"]);
        NSString *priceWithtype;
        if (chkCurrency.length) {
            if ([userPostsData[indexPath.section][@"currency"] isEqualToString:@"INR"]) {
                priceWithtype = [NSString stringWithFormat:@"\u20B9 %@",userPostsData[indexPath.section][@"price"]];
            }else
            {
                priceWithtype = [NSString stringWithFormat:@"$ %@",userPostsData[indexPath.section][@"price"]];
            }
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"shopnow.png"];
            attachment.bounds = CGRectMake(0, 0, attachment.image.size.width/2, attachment.image.size.height/2);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",priceWithtype]];
            //        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",_dataArray[indexPath.section][@"price"]]];
            [myString appendAttributedString:attachmentString];
            //        NSMutableAttributedString *myString1= [[NSMutableAttributedString alloc] initWithString:_subcategory];
            //        [myString appendAttributedString:myString1];
            priceLbl.textAlignment = NSTextAlignmentRight;
            priceLbl.attributedText = myString;
            [priceLbl sizeToFit];
            
        }
        
        NSString *isbusiness = flStrForObj(userPostsData[indexPath.section][@"productName"]);
        if ([isbusiness isEqualToString:@"product"])
        {
            showNow.frame = CGRectMake(10, 0,100, 40);
            buyButton.frame = CGRectMake(0, 0, w, 40);
            line.frame = CGRectMake(10, 39, w-20,0.5);
            //arrowImage.frame = CGRectMake(w-15, 20-6.5f, 15/2, 25/2);
            priceLbl.frame = CGRectMake(CGRectGetMaxX(showNow.frame), 0,w-CGRectGetMaxX(showNow.frame)-10, 40);
            [cell addSubview:arrowImage];
            // [arrowImage bringSubviewToFront:buyButton];
        }
        else
        {
            showNow.frame = CGRectMake(10, 0, w-10, 0);
            buyButton.frame = CGRectMake(0, 0, w, 0);
            line.frame = CGRectMake(0, 39, w, 0);
            priceLbl.frame = CGRectMake(CGRectGetMaxX(showNow.frame), 0, 0, 0);
            //arrowImage.frame = CGRectMake(0, 0, 0, 0);
            
        }
        
        showNow.backgroundColor = [UIColor clearColor];
        [cell addSubview:line];
        [cell addSubview:showNow];
        [cell addSubview:buyButton];
        [cell addSubview:priceLbl];
        
        cell.backgroundColor = [UIColor whiteColor];
        
        return cell;
    }
   else if (indexPath.row ==2){
        
        LikeCommentTableViewCell *cell = (LikeCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LikeCommentTableViewCell"];
        
        if ([userPostsData[indexPath.section][@"likeStatus"]integerValue] == 0) {
            cell.likeButtonOutlet.selected = NO;
        }
        else {
            cell.likeButtonOutlet.selected = YES;
        }
        
        
        if ([[Helper userName] isEqualToString: flStrForObj(userPostsData[indexPath.section][@"postedByUserName"])])
        {
            cell.moreButtonOutlet.tag = 1000 + indexPath.section;
        }
        else
        {
            cell.moreButtonOutlet.tag = 2000 + indexPath.section;
        }
        cell.likeButtonOutlet.tag = indexPath.section;
        cell.commentButtonOutlet.tag = indexPath.section;
        
        return cell;
    }
    else {
        
        PostDetailsTableViewCell *cell = (PostDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PostDetailsTableViewCell"];
        
        
        [cell customizingCaption:userPostsData and:indexPath.section andFrame:self.view.frame];
        [cell showcomments:userPostsData and:indexPath.section andframe:self.view.frame];
        [cell showinNumberOfLikes:[userPostsData[indexPath.section][@"likes"] integerValue]];
        
        cell.postedTimeLabelOutlet.text = [Helper convertEpochToNormalTime:userPostsData[indexPath.section][@"postedOn"]];
        
        
        //handinlg hashtags and usernames.
        [self handlingHashTags:cell];
        [self handlinguserName:cell];
        
        cell.numberOfLikesButtonOutlet.tag = indexPath.section;
        cell.viewAllCommentsButtonOutlet.tag = indexPath.section;
        
        return cell;
    }
    
}


-(void)removeTagsOnPhotos:(UIImageView *)sender{
    
    UIView *view = (UIView *)sender;
    
    for (UIButton *eachButton in view.subviews) {
        [UIView transitionWithView:view
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eachButton removeFromSuperview];
                            [self.view layoutIfNeeded];
                        }
                        completion:NULL];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==0)
        //        return _tableViewOutlet.frame.size.height/2+20;
        return self.view.frame.size.width;
    else if (indexPath.row == 1)
    {
        NSString *isbusiness = flStrForObj(userPostsData[indexPath.section][@"productName"]);
        if ([isbusiness isEqualToString:@"product"])
            return 40;
        else
            return 0;
    }
    else if (indexPath.row ==2)
    {
        return 45;
    }
    else

    {
        PostDetailsTableViewCell *cell = (PostDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PostDetailsTableViewCell"];
        
        UILabel*captionlbl=[[UILabel alloc]initWithFrame:cell.captionLabelOutlet.bounds];
        captionlbl.font=cell.captionLabelOutlet.font;
        
        
        UILabel *firstCommentlbl=[[UILabel alloc]initWithFrame:cell.firstCommentLabel.bounds];
        firstCommentlbl.font=cell.firstCommentLabel.font;
        
        
        
        UILabel *secondCommentlbl=[[UILabel alloc]initWithFrame:cell.secondCommentLabelOutlet.bounds];
        secondCommentlbl.font=cell.secondCommentLabelOutlet.font;
        
        
        //alloting text for labels.
        NSString *postedUser = flStrForObj(userPostsData[indexPath.section][@"postedByUserName"]);
        NSString *caption = flStrForObj(userPostsData[indexPath.section][@"postCaption"]);
        NSString *commentWithUserName =  [postedUser stringByAppendingFormat:@"  %@",caption];
        
        NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        commentWithUserName = [commentWithUserName stringByTrimmingCharactersInSet:ws];
       
        NSInteger numberOfLikes = [userPostsData[indexPath.section][@"likes"] integerValue];
        
        firstCommentlbl.text = @"";
        secondCommentlbl.text = @"";
        
        if ([caption isEqualToString:@"null"]) {
            captionlbl.text = @"";
        }
        else {
            captionlbl.text = commentWithUserName;
        }
        
        CGRect frame=captionlbl.frame;
        frame.size.width=self.view.frame.size.width - 20;
        captionlbl.frame=frame;
        
        NSArray *response = userPostsData[indexPath.section][@"commentData"];
        
        if (response.count == 1) {
            NSString *commentedUser1 = flStrForObj(response[0][@"commentedByUser"]);
            NSString *commentedText1 = flStrForObj(response[0][@"commentBody"]);
            
            NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
            
            postcommentWithUserName1 = [postcommentWithUserName1 stringByTrimmingCharactersInSet:ws];
            
            firstCommentlbl.text = postcommentWithUserName1;
        }
        else if (response.count >1) {
            
            NSString *commentedUser1 = flStrForObj(response[0][@"commentedByUser"]);
            NSString *commentedText1 = flStrForObj(response[0][@"commentBody"]);
            
            NSString *commentedUser2 = flStrForObj(response[1][@"commentedByUser"]);
            NSString *commentedText2 =  flStrForObj(response[1][@"commentBody"]);
            
            
            NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
            
            postcommentWithUserName1 = [postcommentWithUserName1 stringByTrimmingCharactersInSet:ws];
            
            NSString *postcommentWithUserName2 = [commentedUser2 stringByAppendingFormat:@"  %@",commentedText2];
            
            postcommentWithUserName2 = [postcommentWithUserName2 stringByTrimmingCharactersInSet:ws];
            
            firstCommentlbl.text =postcommentWithUserName1;
            secondCommentlbl.text = postcommentWithUserName2;
        }
        
        
        CGRect firstCommentlblframe=firstCommentlbl.frame;
        firstCommentlblframe.size.width=self.view.frame.size.width - 20;
        firstCommentlbl.frame=firstCommentlblframe;
        
        CGRect secondCommentlblframe=secondCommentlbl.frame;
        secondCommentlblframe.size.width=self.view.frame.size.width -20;
        secondCommentlbl.frame=secondCommentlblframe;
        
        
        CGFloat heightOfCaption;
        CGFloat heightOfFirstComment;
        CGFloat heightOfSecondComment;
        CGFloat heightOfViewAllCommentsButton;
        CGFloat heightOfLikesNumberView;
        
        
        //claculating the height of text and if the text is empty directly making the respective label or button height as zero otherwise calculating height of text by using measureHieightLabel method.
        //+5 ids for spacing for the labels.
        
        if ([captionlbl.text  isEqualToString:@""]) {
            heightOfCaption = 0;
        }
        else {
            heightOfCaption = [Helper measureHieightLabel:captionlbl] +5;
        }
        
        if ([firstCommentlbl.text isEqualToString:@""]) {
            heightOfFirstComment = 0;
        }
        else {
            heightOfFirstComment = [Helper measureHieightLabel:firstCommentlbl]+5;
        }
        
        if ([secondCommentlbl.text isEqualToString:@""]) {
            heightOfSecondComment = 0;
        }
        else {
            heightOfSecondComment = [Helper measureHieightLabel:secondCommentlbl]+5;
        }
        
   
        
        if (heightOfFirstComment > 0 && heightOfSecondComment > 0) {
            heightOfViewAllCommentsButton = 25;
        }
        else {
            heightOfViewAllCommentsButton = 0;
        }
        
        if (numberOfLikes > 0) {
            heightOfLikesNumberView = 25;
        }
        else {
            heightOfLikesNumberView = 0;
        }
        
        // 20 --- > for posted time label height.
        CGFloat totalHeightOfRow =  heightOfCaption + heightOfFirstComment +heightOfSecondComment  + heightOfViewAllCommentsButton + heightOfLikesNumberView + 30;
        
        return  totalHeightOfRow;
    }
}


/*---------------------------------------*/
#pragma
#pragma mark - Button Actions
/*---------------------------------------*/


// Chat Start





-(void)cancelButtonClicked {
    [shareNib removeFromSuperview];
}

-(void)customeErrorlocalPush:(NSDictionary *)detail
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    polygonView = [[UIView alloc] initWithFrame: CGRectMake ( 0,-80, self.view.frame.size.width, 80)];
    polygonView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    
    //    polygonView.backgroundColor = [UIColor darkGrayColor];
    
    [window addSubview:polygonView];
    
    [window bringSubviewToFront:polygonView];
    
    
    [UIView animateWithDuration:0.75f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         polygonView.frame = CGRectMake ( 0, 0, self.view.frame.size.width, 80);
                         
                         [polygonView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
    
    UIButton *gotoChat = [[UIButton alloc]initWithFrame: CGRectMake(0, 0,self.view.frame.size.width, 50)];
    [gotoChat addTarget:self action:@selector(gotoChatList) forControlEvents:UIControlEventTouchUpInside];
    [gotoChat setTitle:@"" forState:UIControlStateNormal];
    gotoChat.backgroundColor = [UIColor clearColor];
    [polygonView addSubview:gotoChat];
    
    UIImageView *groupImage = [[UIImageView alloc]initWithFrame: CGRectMake(5, 20, 30, 30)];
    groupImage.layer.cornerRadius = groupImage.frame.size.width / 2;
    
    NSURL *imageUrl =[NSURL URLWithString:detail[@"GroupImage"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
    UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
    groupImage.image = placeholderImage;
    
    groupImage.clipsToBounds = YES;
    [polygonView setNeedsLayout];
    
    [groupImage setImageWithURLRequest:request
                      placeholderImage:placeholderImage
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   
                                   groupImage.image = image;
                                   groupImage.layer.cornerRadius = groupImage.frame.size.width / 2;
                                   groupImage.clipsToBounds = YES;
                                   
                               } failure:nil];
    
    
    [polygonView addSubview:groupImage];
    
    NSString * groupMember = [NSString stringWithFormat:@"Sent To %@",detail[@"GroupMembers"]];
    
    UILabel *sendTo = [[UILabel alloc]initWithFrame: CGRectMake(groupImage.frame.size.width + 10, 10, polygonView.frame.size.width - 50, 45)];
    sendTo.text =groupMember;
    sendTo.textColor = [UIColor blackColor];
    [polygonView addSubview:sendTo];
    [window bringSubviewToFront:sendTo];
    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(aTimeHide) userInfo:nil repeats:NO];
    NSLog(@"%@",aTimer);
    //add code to customize, e.g. polygonView.backgroundColor = [UIColor blackColor];
    
    
}

-(void)aTimeHide
{
    
    
    [UIView animateWithDuration:0.75 animations:^{
        polygonView.frame = CGRectMake ( 0,-80, self.view.frame.size.width, 80);
        
        [polygonView layoutIfNeeded];
    }completion:^(BOOL finished) {
        [polygonView removeFromSuperview];
    }];
    
    
}

-(void)gotoChatList{
    
    [UIView animateWithDuration:0.75 animations:^{
        polygonView.frame = CGRectMake ( 0,-80, self.view.frame.size.width, 80);
        
        [polygonView layoutIfNeeded];
    }completion:^(BOOL finished) {
        [polygonView removeFromSuperview];
    }];
    
    ChatNavigationContollerClass *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
    
    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

-(void)sendButtonClicked:(NSDictionary *)detail
{
    [shareNib removeFromSuperview];
    
    [self customeErrorlocalPush:detail];
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

// Chat End

- (IBAction)sendPostButtonAction:(id)sender {
    
    UIButton *likeButton = (UIButton *)sender;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
    self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
    
    //    NSInteger num = [sender integerValue];
    NSLog(@"%@",[userPostsData objectAtIndex:likeButton.tag]);
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    shareNib = [[ShareViewXib alloc] init];
    shareNib.delegate = self;
    shareNib.friendesListShow =self.friendesList;
    shareNib.friendesPost = [userPostsData objectAtIndex:likeButton.tag];
    [shareNib showViewWithContacts:window];
}

- (IBAction)likeButtonAction:(id)sender {
    UIButton *likeButton = (UIButton *)sender;
    
    // adding animation for selected button
    [self animateButton:likeButton];
    
    if(likeButton.selected) {
        likeButton.selected = NO;
        [[userPostsData objectAtIndex:likeButton.tag] setObject:@"0" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [userPostsData[likeButton.tag][@"likes"] integerValue];
        newNumberOfLikes --;
        [[userPostsData objectAtIndex:likeButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        [self reloadRowToShowNewNumberOfLikes:likeButton.tag];
        [self unlikeAPost:flStrForObj(userPostsData[likeButton.tag][@"postId"]) postType:flStrForObj(userPostsData[likeButton.tag][@"postsType"])];
    }
    else  {
        likeButton.selected = YES;
        [[userPostsData objectAtIndex:likeButton.tag] setObject:@"1" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [userPostsData[likeButton.tag][@"likes"] integerValue];
        newNumberOfLikes ++;
        [[userPostsData objectAtIndex:likeButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        [self reloadRowToShowNewNumberOfLikes:likeButton.tag];
        [self likeAPost:flStrForObj(userPostsData[likeButton.tag][@"postId"]) postType:flStrForObj(userPostsData[likeButton.tag][@"postsType"])];
    }
}

- (IBAction)commentButtonAction:(id)sender {
    
    UIButton *commentButton = (UIButton *)sender;
    
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId =  flStrForObj(userPostsData[commentButton.tag][@"postId"]);
    newView.postCaption =  flStrForObj(userPostsData[commentButton.tag][@"postCaption"]);
    newView.postType = flStrForObj(userPostsData[commentButton.tag][@"postsType"]);
    newView.imageUrlOfPostedUser =  flStrForObj(userPostsData[commentButton.tag][@"profilePicUrl"]);
    newView.selectedCellIs =commentButton.tag;
    newView.userNameOfPostedUser = flStrForObj(userPostsData[commentButton.tag][@"postedByUserName"]);
    //newView.commentingOnPostFrom = @"ToHomeScreen";
    [self.navigationController pushViewController:newView animated:YES];
}

- (IBAction)numberOfLikesButtonAction:(id)sender {
    UIButton *listOflikes = (UIButton *)sender;
    LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
    newView.navigationTitle = @"Likers";
    newView.postId =  flStrForObj(userPostsData[listOflikes.tag][@"postId"]);
    newView.postType = flStrForObj(userPostsData[listOflikes.tag][@"postsType"]);
    [self.navigationController pushViewController:newView animated:YES];
}

- (IBAction)moreButtonAction:(id)sender {
    UIButton *moreButton = (UIButton *)sender;
    
     selectedCellIndexPathForActionSheet = [self.customTableView indexPathForCell:(UITableViewCell *) [[sender superview] superview]];
    
    NSInteger tag = [sender tag];
    UIActionSheet *sheet;
    if(!(tag < 2000)){
        
        sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Report",@"Share to Facebook", @"Copy Share URL", nil];
        [sheet setTag:moreButton.tag];
        
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Delete",@"Copy Share URL", @"Share", nil];
        [sheet setTag:moreButton.tag];
        
    }
    [sheet showInView:self.view];
}

- (IBAction)viewAllCommentButtonAction:(id)sender {
    
    UIButton *allCommentButton = (UIButton *)sender;
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId =  flStrForObj(userPostsData[allCommentButton.tag][@"postId"]);
    newView.postCaption =  flStrForObj(userPostsData[allCommentButton.tag][@"postCaption"]);
    newView.postType = flStrForObj(userPostsData[allCommentButton.tag][@"postsType"]);
    newView.imageUrlOfPostedUser =  flStrForObj(userPostsData[allCommentButton.tag][@"profilePicUrl"]);
    newView.selectedCellIs =allCommentButton.tag;
    newView.userNameOfPostedUser = flStrForObj(userPostsData[allCommentButton.tag][@"postedByUserName"]);
    //newView.commentingOnPostFrom = @"ToHomeScreen";
    [self.navigationController pushViewController:newView animated:YES];
    
}

- (IBAction)listOfLikesButtonAction:(id)sender {
    UIButton *listOflikes = (UIButton *)sender;
    LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
    newView.navigationTitle = @"Likers";
    newView.postId =  flStrForObj(userPostsData[listOflikes.tag][@"postId"]);
    newView.postType = flStrForObj(userPostsData[listOflikes.tag][@"postsType"]);
    [self.navigationController pushViewController:newView animated:YES];
}

- (IBAction)viewAllCommentsButtonAction:(id)sender {
    UIButton *allCommentButton = (UIButton *)sender;
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId =  flStrForObj(userPostsData[allCommentButton.tag][@"postId"]);
    newView.postCaption =  flStrForObj(userPostsData[allCommentButton.tag][@"postCaption"]);
    newView.postType = flStrForObj(userPostsData[allCommentButton.tag][@"postsType"]);
    newView.imageUrlOfPostedUser =  flStrForObj(userPostsData[allCommentButton.tag][@"profilePicUrl"]);
    newView.selectedCellIs =allCommentButton.tag;
    newView.userNameOfPostedUser = flStrForObj(userPostsData[allCommentButton.tag][@"postedByUserName"]);
    //newView.commentingOnPostFrom = @"ToHomeScreen";
    [self.navigationController pushViewController:newView animated:YES];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSInteger tag = popup.tag;
    if (tag == 5000) {
        switch (buttonIndex) {
            case 0:
                [self getDirection];
                break;
            case 1:[self call];
                break;
            case 2:[self showMailPanel];
                break;
            default:
                break;
        }
    }
    else if(!(tag < 2000)){
        
        switch (buttonIndex) {
            case 0:
                [self reportPost:tag%2000];
                break;
            case 1:
                [self shareToFacebook:tag%2000];
                break;
            case 2:
                [self copyShareURL:tag%2000];
                break;
            case 3:
                // [self turnOnPostNotifications:tag%2000];
                break;
            default:
                break;
        }
    }
    else if (tag == 10)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, I'm sure", nil];
        alert.tag = 10;
        [alert show];
    }
    else
    {
        
        if (buttonIndex == 0)
        {
            [self deletePost:tag%1000];
        }
        else if (buttonIndex == 1){
            [self copyShareURL:tag%1000];
        }
        else if (buttonIndex == 2) {
            [self sharePost:tag%1000];
        }
    }
}


-(void)getDirection
{
    
    //GoogleMaps
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:@"comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic"]];
        
    }
    else
    {
        //Apple Maps
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com://"]])
        { [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://maps.apple.com/maps?center=40.765819,-73.975866&zoom=14&views=traffic"]];
            
        }
        else {
            NSLog(@"Can't access any Maps");
        }
        
    }
}

/*---------------------------------------*/
#pragma
#pragma mark - Reloading TableView
/*---------------------------------------*/

-(void)animateButton:(UIButton *)likeButton {
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[likeButton layer] addAnimation:ani forKey:@"zoom"];
}

-(void)reloadRowToShowNewNumberOfLikes:(NSInteger )reloadRowAtSection {
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:3 inSection:reloadRowAtSection];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.customTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InstaVideoTableViewCell *cell1 = (InstaVideoTableViewCell *)cell;
    if(![cell1 isKindOfClass:[InstaVideoTableViewCell class]])
    {
        return;
    }
    [cell1.videoView pause];
}

-(void)call
{
    NSString *num;
    if (checkingOwnProfile)
        num = [[NSUserDefaults standardUserDefaults]valueForKey:@"ProfileContact"];
    else
        num = flStrForObj(profileContact);
    NSString *phoneNumber = [@"tel://" stringByAppendingString:num];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

/**
 *  @brief used for checking the visibility of the cell
 *
 *  @param cell        current cell
 *  @param aScrollView table view's scroll view
 */
- (void)checkVisibilityOfCell:(InstaVideoTableViewCell *)cell inScrollView:(UIScrollView *)aScrollView {
    CGRect cellRect = [aScrollView convertRect:cell.frame toView:aScrollView.superview];
    if(![cell isKindOfClass:[InstaVideoTableViewCell class]])
    {
        return;
    }
    if (CGRectContainsRect(aScrollView.frame, cellRect))
        [cell notifyCompletelyVisible];
    else
        [cell notifyNotCompletelyVisible];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    NSArray* cells = self.customTableView.visibleCells;
    
    NSUInteger cellCount = [cells count];
    if (cellCount == 0)
        return;
    
    // Check the visibility of the first cell
    InstaVideoTableViewCell *cell = [cells firstObject];
    [self checkVisibilityOfCell:cell inScrollView:aScrollView];
    if (cellCount == 1)
        return;
    
    // Check the visibility of the last cell
    cell = [cells lastObject];
    [self checkVisibilityOfCell:[cells lastObject] inScrollView:aScrollView];
    if (cellCount == 2)
        return;
    
    // All of the rest of the cells are visible: Loop through the 2nd through n-1 cells
    for (NSUInteger i = 1; i < cellCount - 1; i++){
        cell = [cells objectAtIndex:i];
        if(![[cells objectAtIndex:i] isKindOfClass:[InstaVideoTableViewCell class]])
        {
            return;
        }
        [[cells objectAtIndex:i] notifyCompletelyVisible];
    }
}

- (void)stopAnimation {
    __weak UserProfileViewController *weakSelf = self;
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.customTableView.pullToRefreshView stopAnimating];
        [weakSelf.customTableView.infiniteScrollingView stopAnimating];
    });
}



-(void)showMailPanel{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        
        [mailCont setSubject:@"Contact Regarding Business "];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"support@3embed.com"]];
        [mailCont setMessageBody:@" " isHTML:NO];
        mailCont.navigationBar.tintColor = [UIColor blackColor];
       // [mailCont.navigationBar setBackgroundImage:[UIImage imageNamed:@"signup_navigation_bar.png"] forBarMetrics:UIBarMetricsDefault];
        [mailCont.navigationBar setBackgroundColor:[UIColor whiteColor]];
        mailCont.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        [self presentViewController:mailCont animated:YES completion:^{
        }];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
/*-----------------------------------------------------------------------------*/
#pragma
#pragma mark - REQUESTING SERVICES .
/*------------------------------------------------------------------------------*/


-(void)likeAPost:(NSString *)postId postType:(NSString *)postType {
    NSDictionary *requestDict;
    
    // 1 is for video and 0 is for photo.
    
    if ([flStrForObj(postType) isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj([Helper userToken]),
                        mpostid:postId,
                        mLabel:@"Video"
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj([Helper userToken]),
                        mpostid:postId,
                        mLabel:@"Photo"
                        };
    }
    
    [WebServiceHandler likeAPost:requestDict andDelegate:self];
}

-(void)unlikeAPost:(NSString *)postId postType:(NSString *)postType {
    NSDictionary *requestDict;
    if ([flStrForObj(postType) isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj([Helper userToken]),
                        mpostid:postId,
                        mLabel:@"Video",
                        mUserName:[Helper userName]
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj([Helper userToken]),
                        mpostid:postId,
                        mLabel:@"Photo",
                        mUserName:[Helper userName]
                        };
    }
    [WebServiceHandler unlikeAPost:requestDict andDelegate:self];
}


/*-----------------------------------------------------------------------------*/
#pragma
#pragma mark - Tap Delegates
/*------------------------------------------------------------------------------*/


- (void)delegateFordoubLeTapCell:(InstaVideoTableViewCell *)cell {
    
    UIView *view = cell.videoView;
    
    
    
    //    for (UIButton *eachButton in view.subviews) {
    //        [UIView transitionWithView:view
    //                          duration:0.1
    //                           options:UIViewAnimationOptionTransitionCrossDissolve
    //                        animations:^{
    //                            [eachButton removeFromSuperview];
    //                            [self.view layoutIfNeeded];
    //                        }
    //                        completion:NULL];
    //    }
    
    
    UIImageView *animateImage = cell.popUpImageViewOutlet;
    
    NSIndexPath *indexPath = [self.customTableView indexPathForCell:(UITableViewCell *)[[animateImage superview] superview]];
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section];
    
    LikeCommentTableViewCell *selectedCell = [self.customTableView cellForRowAtIndexPath:indexPath];
    
    UIButton *selectedButton = selectedCell.likeButtonOutlet;
    
    //animating the like button.
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
    
    //checking if the post is already liked or not .if it is already liked no need to perform anything otherwise we need to perform like action.
    
    NSString *likeStatus =  [NSString stringWithFormat:@"%@", userPostsData[indexPath.section][@"likeStatus"]];
    if ([likeStatus  isEqualToString:@"0"]) {
        
        selectedButton.selected = YES;
        [[userPostsData objectAtIndex:selectedButton.tag] setObject:@"1" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [userPostsData[selectedButton.tag][@"likes"] integerValue];
        newNumberOfLikes ++;
        [[userPostsData objectAtIndex:selectedButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        [self reloadRowToShowNewNumberOfLikes:selectedButton.tag];
        [self likeAPost:flStrForObj(userPostsData[selectedButton.tag][@"postId"]) postType:flStrForObj(userPostsData[selectedButton.tag][@"postsType"])];
    }
    
    animateImage.hidden = NO;
    animateImage.alpha = 0;
    
    [[view superview] bringSubviewToFront:animateImage];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        animateImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
        animateImage.alpha = 1.0;
    }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              animateImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                                  animateImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                  animateImage.alpha = 0.0;
                                              }
                                                               completion:^(BOOL finished) {
                                                                   animateImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                   
                                                                   [[view superview] sendSubviewToBack:animateImage];
                                                               }];
                                          }];
                     }];
}



/*---------------------------------------*/
#pragma
#pragma mark - Button Actions
/*---------------------------------------*/



- (IBAction)showTagsButtonAction:(id)sender {
    
    NSIndexPath *selectedButtontToShowTags = [self.customTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    // Get the subviews of the view
    NSArray *subviewsfff =  [[sender superview] subviews];
    
    UIView *view = (UIView *) subviewsfff[2];
    
    NSArray *namesOfTaggedPeople = [userPostsData[selectedButtontToShowTags.section][@"usersTaggedInPosts"] componentsSeparatedByString:@","];
    NSArray *positionsOfNames = [userPostsData[selectedButtontToShowTags.section][@"taggedUserCoordinates"] componentsSeparatedByString:@",,"];
    
    
    // if there is no one tagged then from response by defaultly we are getting undefined so handling that.
    if ([namesOfTaggedPeople[0]  isEqualToString:@"undefined"]) {
        namesOfTaggedPeople = nil;
        positionsOfNames = nil;
    }
    
    if (!view.subviews.count) {
        for( int i = 0; i < namesOfTaggedPeople.count; i++ ) {
            UIButton *customButton;
            customButton = [UIButton buttonWithType: UIButtonTypeCustom];
            [customButton setBackgroundColor: [UIColor clearColor]];
            [customButton setTitleColor:[UIColor blackColor] forState:
             UIControlStateHighlighted];
            //sets background image for normal state
            [customButton setBackgroundImage:[UIImage imageNamed:
                                              @"tag_people_tittle_btn"]
                                    forState:UIControlStateNormal];
            
            [customButton setBackgroundImage:[UIImage imageNamed:@"tag_people_tittle_btn"] forState:UIControlStateHighlighted];
            
            [customButton setTitle:[namesOfTaggedPeople objectAtIndex:i] forState:UIControlStateNormal];
            
            CGPoint fromPoint = CGPointFromString([positionsOfNames objectAtIndex:i]);
            
            CGSize stringsize = [customButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoMedium size:13]];
            [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
            //checking the poistion is going out of imaege  or not.
            //if button poistion is out of image then need to alifgn properly.
            if (fromPoint.x + customButton.frame.size.width > view.frame.size.width || fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
                NSLog(@"custom button is out of view");
                if (fromPoint.x + customButton.frame.size.width > view.frame.size.width) {
                    NSLog(@"custom button is out of view along horizontal");
                    [customButton setFrame:CGRectMake(fromPoint.x - ((fromPoint.x + customButton.frame.size.width) - view.frame.size.width),fromPoint.y, stringsize.width + 50, 35)];
                }
                else {
                    NSLog(@"custom button is aligned properly along horizontal");
                }
                
                if( fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
                    NSLog(@"custom button is out of view along vertical");
                    //[customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
                    
                    [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y - ((fromPoint.y + customButton.frame.size.height) - view.frame.size.height), stringsize.width + 50, 35)];
                }
                else {
                    NSLog(@"custom button is aligned properly along vertical");
                }
                
                if (fromPoint.x + customButton.frame.size.width > view.frame.size.width && fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
                    [customButton setFrame:CGRectMake(fromPoint.x - ((fromPoint.x + customButton.frame.size.width) - view.frame.size.width),fromPoint.y - ((fromPoint.y + customButton.frame.size.height) - view.frame.size.height), stringsize.width + 50, 35)];
                    
                    NSLog(@"custom button is out of view along both horizontal and vertical");
                }
            }
            else {
                [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
            }
            [customButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 0.0f, 0.0f, 0.0f)];
            customButton.tag = 12345 + i;
            [customButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [UIView transitionWithView:view
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [view addSubview:customButton];
                                [view bringSubviewToFront:customButton];
                                [self.view layoutIfNeeded];
                            }
                            completion:NULL];
        }
    }
    else {
        for (UIButton *eachButton in view.subviews) {
            [UIView transitionWithView:view
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [eachButton removeFromSuperview];
                                [self.view layoutIfNeeded];
                            }
                            completion:NULL];
        }
    }
}

//- (IBAction)showTagsButtonAction:(id)sender {
//    
//    NSIndexPath *selectedButtontToShowTags = [self.customTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
//    
//    // Get the subviews of the view
//    NSArray *subviewsfff =  [[sender superview] subviews];
//    
//    UIView *view = (UIView *) subviewsfff[3];
//    
//    NSArray *namesOfTaggedPeople = [userPostsData[selectedButtontToShowTags.section][@"usersTaggedInPosts"] componentsSeparatedByString:@","];
//    NSArray *positionsOfNames = [userPostsData[selectedButtontToShowTags.section][@"taggedUserCoordinates"] componentsSeparatedByString:@",,"];
//    
//    
//    // if there is no one tagged then from response by defaultly we are getting undefined so handling that.
//    if ([namesOfTaggedPeople[0]  isEqualToString:@"undefined"]) {
//        namesOfTaggedPeople = nil;
//        positionsOfNames = nil;
//    }
//    
//    if (!view.subviews.count) {
//        for( int i = 0; i < namesOfTaggedPeople.count; i++ ) {
//            UIButton *customButton;
//            customButton = [UIButton buttonWithType: UIButtonTypeCustom];
//            [customButton setBackgroundColor: [UIColor clearColor]];
//            [customButton setTitleColor:[UIColor blackColor] forState:
//             UIControlStateHighlighted];
//            //sets background image for normal state
//            [customButton setBackgroundImage:[UIImage imageNamed:
//                                              @"tag_people_tittle_btn"]
//                                    forState:UIControlStateNormal];
//            
//            [customButton setBackgroundImage:[UIImage imageNamed:@"tag_people_tittle_btn"] forState:UIControlStateHighlighted];
//            
//            [customButton setTitle:[namesOfTaggedPeople objectAtIndex:i] forState:UIControlStateNormal];
//            
//            CGPoint fromPoint = CGPointFromString([positionsOfNames objectAtIndex:i]);
//            
//            CGSize stringsize = [customButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoMedium size:13]];
//            [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
//            //checking the poistion is going out of imaege  or not.
//            //if button poistion is out of image then need to alifgn properly.
//            if (fromPoint.x + customButton.frame.size.width > view.frame.size.width || fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
//                NSLog(@"custom button is out of view");
//                if (fromPoint.x + customButton.frame.size.width > view.frame.size.width) {
//                    NSLog(@"custom button is out of view along horizontal");
//                    [customButton setFrame:CGRectMake(fromPoint.x - ((fromPoint.x + customButton.frame.size.width) - view.frame.size.width),fromPoint.y, stringsize.width + 50, 35)];
//                }
//                else {
//                    NSLog(@"custom button is aligned properly along horizontal");
//                }
//                
//                if( fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
//                    NSLog(@"custom button is out of view along vertical");
//                    //[customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
//                    
//                    [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y - ((fromPoint.y + customButton.frame.size.height) - view.frame.size.height), stringsize.width + 50, 35)];
//                }
//                else {
//                    NSLog(@"custom button is aligned properly along vertical");
//                }
//                
//                if (fromPoint.x + customButton.frame.size.width > view.frame.size.width && fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
//                    [customButton setFrame:CGRectMake(fromPoint.x - ((fromPoint.x + customButton.frame.size.width) - view.frame.size.width),fromPoint.y - ((fromPoint.y + customButton.frame.size.height) - view.frame.size.height), stringsize.width + 50, 35)];
//                    
//                    NSLog(@"custom button is out of view along both horizontal and vertical");
//                }
//            }
//            else {
//                [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
//            }
//            [customButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 0.0f, 0.0f, 0.0f)];
//            customButton.tag = 12345 + i;
//            [customButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [UIView transitionWithView:view
//                              duration:0.2
//                               options:UIViewAnimationOptionTransitionCrossDissolve
//                            animations:^{
//                                [view addSubview:customButton];
//                                [view bringSubviewToFront:customButton];
//                                [self.view layoutIfNeeded];
//                            }
//                            completion:NULL];
//        }
//    }
//    else {
//        for (UIButton *eachButton in view.subviews) {
//            [UIView transitionWithView:view
//                              duration:0.2
//                               options:UIViewAnimationOptionTransitionCrossDissolve
//                            animations:^{
//                                [eachButton removeFromSuperview];
//                                [self.view layoutIfNeeded];
//                            }
//                            completion:NULL];
//        }
//    }
//}

- (void)delegateForSingleTapCell:(InstaVideoTableViewCell *)cell {
    NSIndexPath *indexPath = [self.customTableView indexPathForCell:cell];
    
    InstaVideoTableViewCell *selectedCell = [self.customTableView cellForRowAtIndexPath:indexPath];
    [self showTagsButtonAction:selectedCell.showTagsButtonOutlet];
}

/*---------------------------------------*/
#pragma
#pragma mark - Button Actions
/*---------------------------------------*/




-(void)likePostFromDoubleTap:(id)sender {
    
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [self.customTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    //animating the like button.
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
    
    //checking if the post is already liked or not .if it is already liked no need to perform anything otherwise we need to perform like action.
    
    NSString *likeStatus =  [NSString stringWithFormat:@"%@", userPostsData[selectedCellForLike.section][@"likeStatus"]];
    if ([likeStatus  isEqualToString:@"0"]) {
        
        selectedButton.selected = YES;
        [[userPostsData objectAtIndex:selectedButton.tag] setObject:@"1" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [userPostsData[selectedButton.tag][@"likes"] integerValue];
        newNumberOfLikes ++;
        [[userPostsData objectAtIndex:selectedButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        [self reloadRowToShowNewNumberOfLikes:selectedButton.tag];
        [self likeAPost:flStrForObj(userPostsData[selectedButton.tag][@"postId"]) postType:flStrForObj(userPostsData[selectedButton.tag][@"postsType"])];
    }
}



/*-----------------------------------------------------------------------------*/
#pragma
#pragma mark - Handling Hashtags,URL and UserNames.
/*------------------------------------------------------------------------------*/

-(void)handlingHashTags:(id)sender {
    
    PostDetailsTableViewCell *receivedCell = (PostDetailsTableViewCell *)sender;
    // Attach a block to be called when the user taps a hashtag.
    
    receivedCell.captionLabelOutlet.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self openPostsByHashtag:string];
    };
    receivedCell.firstCommentLabel.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self openPostsByHashtag:string];
    };
    receivedCell.secondCommentLabelOutlet.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self openPostsByHashtag:string];
    };
}

-(void)handlinguserName:(id)sender {
    
    PostDetailsTableViewCell *receivedCell = (PostDetailsTableViewCell *)sender;
    // Attach a block to be called when the user taps a user handle.
    
    receivedCell.captionLabelOutlet.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        
        if ([string isEqualToString:@"@"]) {
            
        }
        else{
            UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
            
            //removing @ from string.
            NSString *stringWithoutspecialCharacter = [string
                                                       stringByReplacingOccurrencesOfString:@"@" withString:@""];
            newView.checkProfileOfUserNmae = stringWithoutspecialCharacter;
            newView.checkingFriendsProfile = YES;
            [self.navigationController pushViewController:newView animated:YES];
        }
    };
}

-(void)openPostsByHashtag:(NSString *)string {
    if ([string isEqualToString:@"#"]) {
        
    }
    else{
        HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
        newView.navTittle = string;
        [self.navigationController pushViewController:newView animated:YES];
    }
}



/**
 *  these all are button actions of tableView like,comment and share buttons.
 */

-(void)likeAPost:(NSInteger )selectedIndex {
    
    if ([userPostsData[selectedIndex][@"postsType"] isEqualToString:@"1"]) {
        NSString *postId = flStrForObj(userPostsData[selectedIndex][@"postId"]);
        NSDictionary *requestDict = @{
                                      mauthToken:flStrForObj([Helper userToken]),
                                      mpostid:postId,
                                      mLabel:@"Video"
                                      };
        [WebServiceHandler likeAPost:requestDict andDelegate:self];
    }
    else {
        NSString *postId = flStrForObj(userPostsData[selectedIndex][@"postId"]);
        NSDictionary *requestDict = @{
                                      mauthToken:flStrForObj([Helper userToken]),
                                      mpostid:postId,
                                      mLabel:@"Photo"
                                      };
        [WebServiceHandler likeAPost:requestDict andDelegate:self];
    }
    
    
}

-(void)unlikeAPost:(NSInteger )selectedIndex
{
    
    
    if ([userPostsData[selectedIndex][@"postsType"] isEqualToString:@"1"]) {
        NSString *postId = flStrForObj(userPostsData[selectedIndex][@"postId"]);
        NSString *username = flStrForObj([Helper userName]);
        NSDictionary *requestDict = @{
                                      mauthToken:flStrForObj([Helper userToken]),
                                      mpostid:postId,
                                      mLabel:@"Video",
                                      mUserName:username
                                      };
        [WebServiceHandler unlikeAPost:requestDict andDelegate:self];
    }
    else {
        NSString *postId = flStrForObj(userPostsData[selectedIndex][@"postId"]);
        NSString *username = flStrForObj([Helper userName]);
        NSDictionary *requestDict = @{
                                      mauthToken:flStrForObj([Helper userToken]),
                                      mpostid:postId,
                                      mLabel:@"Photo",
                                      mUserName:username
                                      };
        [WebServiceHandler unlikeAPost:requestDict andDelegate:self];
    }
}




-(void)moreButtnAction:(id)sender {
   
    
    if (checkingOwnProfile) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit",@"Share",nil];
        [actionSheet showInView:self.view];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:@"Share to Facebook",@"Share to Messenger",@"Tweet",@"Copy Share URL",@"Turn on Post Notifications",nil];
        [actionSheet showInView:self.view];
    }
}

///*--------------------------------------*/
//#pragma mark
//#pragma mark -  action sheet
///*--------------------------------------*/
//
//
//
////uiaction sheet
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
//
//    NSLog( @" before deleting  tableview content size :%f",self.customTableView.contentSize.height);
//
//    NSInteger tag = actionSheet.tag;
//
//    if(!(tag < 2000)){
//
//        switch (buttonIndex) {
//            case 0:
//                [self reportPost:tag%2000];
//                break;
//            case 1:
//                [self shareToFacebook:tag%2000];
//                break;
//            case 2:
//                [self copyShareURL:tag%2000];
//
//                break;
//                //            case 3:
//                //                [self turnOnPostNotifications:tag%2000];
//                //
//                //                break;
//            default:
//                break;
//        }
//    }
//    else
//    {
//
//        if (buttonIndex == 0)
//        {
//            // [self deletePost:tag%1000];
//            UIAlertView *alertForDeleteConfirmation =[[UIAlertView alloc] initWithTitle:@"" message:@"Confirm To Delete" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
//            [alertForDeleteConfirmation show];
//            alertForDeleteConfirmation.tag = 26;
//        }
//        else if (buttonIndex == 1){
//            [self copyShareURL:tag%1000];
//
//        }
//        else if (buttonIndex == 2) {
//
//             [self sharePost:tag%1000];
//        }
//        else if (buttonIndex == 3)
//        {
//            //            UIAlertView *alertForDeleteConfirmation =[[UIAlertView alloc] initWithTitle:@"" message:@"Confirm To Delete" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
//            //            [alertForDeleteConfirmation show];
//            //            alertForDeleteConfirmation.tag = 26;
//
//        }
//    }
//
//
//}



//uiaction sheet
/*- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
 NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
 
 NSLog( @" before deleting  tableview content size :%f",self.customTableView.contentSize.height);
 
 if  ([buttonTitle isEqualToString:@"Edit"]) {
 }
 if ([buttonTitle isEqualToString:@"Share"]) {
 }
 if ([buttonTitle isEqualToString:@"Cancel"]) {
 }
 if ([buttonTitle isEqualToString:@"Delete"]) {
 UIAlertView *alertForDeleteConfirmation =[[UIAlertView alloc] initWithTitle:@"" message:@"Confirm To Delete" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
 [alertForDeleteConfirmation show];
 alertForDeleteConfirmation.tag = 26;
 }
 }
 */


-(void)showingProgressindicator {
    //showing progress indicator and requesting for posts.
    ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];  [HomePI showPIOnView:self.view withMessage:@"Deleting.."];
}

-(void)remove:(NSInteger )i {
    [self.collectionView performBatchUpdates:^{
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:i inSection:0];
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    } completion:^(BOOL finished) {
        
    }];
}







/*---------------------------------*/
#pragma mark -
#pragma mark - Button Actions.
/*---------------------------------*/

/**
 *  collectionView button action(ThumbNail Photos).
 *  @param sender it will open collection view.
 */
- (IBAction)collectionViewButtonAction:(id)sender {
    isTableSelected = NO;
    self.collectionView.hidden = NO;
    self.customTableView.hidden = YES;
    self.collectionViewButtonOutlet.selected=YES;
    self.tableViewButtonOutlet.selected=NO;
    [self calculateCollectionViewHeight];
}

/**
 *  tableView button action(MainURL Photos).
 *  @param sender it will open table view.
 */
- (IBAction)tableViewButtonAction:(id)sender {
    isTableSelected = YES;
    self.collectionView.hidden = YES;
    self.customTableView.hidden = NO;
    self.tableViewButtonOutlet.selected=YES;
    self.collectionViewButtonOutlet.selected=NO;
    [self calculateCollectionViewHeight];
}
- (IBAction)mapButtonAction:(id)sender {
    //Opening mapViewController.
    [self performSegueWithIdentifier:@"mapButonSegue" sender:nil];
}

- (IBAction)followingButtonAction:(id)sender {
    if (self.checkProfileOfUserNmae) {
        //Opening LikeViewController With navigation title as FOLLOWERS.
        LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
        newView.navigationTitle = @"FOLLOWING";
        newView.getdetailsDetailsOfUserName = self.checkProfileOfUserNmae;
        [self.navigationController pushViewController:newView animated:YES];    }
    else {
        //Opening LikeViewController With navigation title as FOLLOWING.
        LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
        newView.navigationTitle = @"FOLLOWING";
        [self.navigationController pushViewController:newView animated:YES];
    }
}

- (IBAction)followersButtonAction:(id)sender {
    if (self.checkProfileOfUserNmae) {
        
        
        
        
        //Opening LikeViewController With navigation title as FOLLOWERS.
        LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
        newView.navigationTitle = @"FOLLOWERS";
        newView.getdetailsDetailsOfUserName = self.checkProfileOfUserNmae;
        [self.navigationController pushViewController:newView animated:YES];
    }
    else {
        //Opening LikeViewController With navigation title as FOLLOWERS.
        LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
        newView.navigationTitle = @"FOLLOWERS";
        [self.navigationController pushViewController:newView animated:YES];
    }
}

- (IBAction)editProfileButtonAction:(id)sender {
    //if user checking his own profile then we need to show edit profile button otherwise follow/following relation.
    if (checkingOwnProfile) {
        //Opening editProfileViewController.
        [self performSegueWithIdentifier:@"editProfileSegue" sender:nil];
    }
    else {
        [self followButtonClicked];
    }
}

- (void)buyButtonClicked :(id)sender {
    UIButton *selectedHeaderButton = (UIButton *)sender;
    NSInteger selectedIndex = selectedHeaderButton.tag % 10000;
    NSString *buyUrl =  flStrForObj(userPostsData[selectedIndex][@"productUrl"]);
    WebViewForDetailsVc *webView = [[WebViewForDetailsVc alloc]init];
    webView.category = flStrForObj(userPostsData[selectedIndex][@"category"]);
    webView.subcategory = flStrForObj(userPostsData[selectedIndex][@"subCategory"]);
    webView.weburl = buyUrl;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webView animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
}


-(void)followButtonClicked
{
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    
    // adding animation for selected button
    
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.1];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.9]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[_editProfileButtonOutlet layer] addAnimation:ani forKey:@"zoom"];
    
    
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([_editProfileButtonOutlet.titleLabel.text isEqualToString:@" Follow"]) {
            [self.editProfileButtonOutlet  setTitle:@" REQUESTED" forState:UIControlStateNormal];
            [self sendNewFollowStatusThroughNotification:flStrForObj(self.checkProfileOfUserNmae) andNewStatus:@"0"];
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            self.editProfileButtonOutlet.backgroundColor =requstedButtonBackGroundColor;
            self.editProfileButtonOutlet .layer.borderColor = [UIColor whiteColor].CGColor;
            
            NSDictionary *requestDict = @{muserNameTofollow     :self.checkProfileOfUserNmae,
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          mdeviceToken          :[Helper deviceToken]
                                          };
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
        else if ([_editProfileButtonOutlet.titleLabel.text isEqualToString:@" Following"])  {
            [self showUnFollowAlert:_profilePhotoOutlet.image and:_userNameLabelOutlet.text];
        }
        else {
            // cancel request for follow.
            [self.editProfileButtonOutlet  setTitle:@" Follow" forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            [self sendNewFollowStatusThroughNotification:flStrForObj(self.checkProfileOfUserNmae) andNewStatus:@"2"];
            self.editProfileButtonOutlet.backgroundColor = followButtonBackGroundColor;
            NSDictionary *requestDict = @{muserNameToUnFollow     : self.checkProfileOfUserNmae ,
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
            self.editProfileButtonOutlet .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
    }
    
    //actions for when the account is public.
    else {
        if ([_editProfileButtonOutlet.titleLabel.text isEqualToString:@" Following"]) {
            [self showUnFollowAlert:_profilePhotoOutlet.image and:_userNameLabelOutlet.text];
        }
        else {
            
            [self.editProfileButtonOutlet  setTitle:@" Following" forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];            _editProfileButtonOutlet.layer.cornerRadius = 5;
            _editProfileButtonOutlet.layer.borderWidth = 1;
             self.editProfileButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
            [self sendNewFollowStatusThroughNotification:flStrForObj(self.checkProfileOfUserNmae) andNewStatus:@"1"];
            _editProfileButtonOutlet.backgroundColor = followingButtonBackGroundColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :self.checkProfileOfUserNmae,
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          mdeviceToken          :[Helper deviceToken]
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
    }
}

- (IBAction)postedPhotosButtonAction:(id)sender {
    //Opening postedPhotosViewController.
    [self performSegueWithIdentifier:@"postedPhotoSegue" sender:nil];
}

- (IBAction)postsButtonAction:(id)sender {
    if (self.collectionViewHeight.constant > 100) {
        [self.scrollView setContentOffset:CGPointMake(0,_topContentViewHeightConstr.constant + 50
                                                      ) animated:YES];
    }
}

-(void)websitelabelTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Open Safari?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    alert.tag = 100;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 26) {
        if(buttonIndex == 0)//cancel pressed
        {
            if (alertView.tag == 1001)
            {
                //This will open ios devices location settings
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
            }
            else if (alertView.tag == 2001)
            {
                //This will opne particular app location settings
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
        
        else if(buttonIndex == 1)//confirm delete  pressed.
        {
            NSUInteger row = [selectedCellIndexPathForActionSheet section];
            //deleting a post.
            NSDictionary *requestDict = @{
                                          mauthToken :flStrForObj([Helper userToken]),
                                          mpostid:userPostsData[row][@"postId"]
                                          };
            [WebServiceHandler deletePost:requestDict andDelegate:self];
            NSLog(@"%@",requestDict);
            [self showingProgressindicator];
        }
    }
    else if (alertView.tag ==10) {
        if(buttonIndex == 1)//confirm delete  pressed.
        {
            UIAlertView *all = [[UIAlertView alloc] initWithTitle:nil message:@"User Blocked" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [all show];
        }
    }
    else if (alertView.tag == 100) {
        if(buttonIndex == 0)//no button pressed
        {
            
        }
        else if(buttonIndex == 1)//yes button pressed.
        {
            if (alertView.tag == 100)
            {
                NSString *urlstr = [@"http://"    stringByAppendingString:self.webSiteUrlLabelOutlet.text];
                NSURL *url = [NSURL URLWithString:urlstr];
                if (![[UIApplication sharedApplication] openURL:url]) {
                    NSLog(@"%@%@",@"Failed to open url:",[url description]);
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"Looking it is not a valid url" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [al show];
                }
            }
        }
    }
}

/*-------------------------------------*/
#pragma mark
#pragma mark - topcontentViewHeight.
/*------------------------------------*/

-(void)changeTheTopcontentViewHeight {
    
    CGFloat heightOfTopViewWithOutLabels = _topContentViewHeightConstr.constant - _heightOfLabelsView.constant;
    
    //if the label is empty then height will be zero but defaultly the height of text method returning 13 as label height size so before only we need to check if the label is empty or not.
    
    if ([_userNameLabelOutlet.text isEqualToString:@""]) {
        _userNameLabelHeightConstr.constant = 0;
    }
    else {
        _userNameLabelHeightConstr.constant = [Helper heightOfText:_userNameLabelOutlet] + 2;
    }
    
    
    if ([_biodataLabelOutlet.text isEqualToString:@""]) {
        _biodatalabelHeightConstr.constant = 0;
    }
    else {
        _biodatalabelHeightConstr.constant = [Helper heightOfText:_biodataLabelOutlet] + 2;
    }
    
    if ([_webSiteUrlLabelOutlet.text isEqualToString:@""]) {
        _websiteLabelHeightConstr.constant = 0;
    }
    else {
        _websiteLabelHeightConstr.constant = [Helper heightOfText:_webSiteUrlLabelOutlet] +2;
    }
    
    
    CGFloat newHeightOfLabelsView = _biodatalabelHeightConstr.constant + _userNameLabelHeightConstr.constant +   _websiteLabelHeightConstr.constant ;
    _heightOfLabelsView.constant = newHeightOfLabelsView;
    _topContentViewHeightConstr.constant = heightOfTopViewWithOutLabels + newHeightOfLabelsView;
}



/*------------------------------------*/
#pragma mark
#pragma mark - navigation bar back button
/*------------------------------------*/

- (void)createNavLeftButton {
    UIView *leftBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
    //checking if user checking his own profile or not.
    if (!self.checkingFriendsProfile) {
        //For DiscoverPeople
        UIButton  *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [navCancelButton setImage:[UIImage imageNamed:@"edit_profile_add_user_icon_off"]
                         forState:UIControlStateNormal];
        [navCancelButton setImage:[UIImage imageNamed:@"edit_profile_add_user_icon_on"]
                         forState:UIControlStateSelected];
        [navCancelButton addTarget:self
                            action:@selector(discoverPeopleButtonAction)
                  forControlEvents:UIControlEventTouchUpInside];
        [navCancelButton setFrame:CGRectMake(-10.0f,-5.0f,40,40)];
        
        [leftBarButtonItems addSubview:navCancelButton];
        
        NSString *bussinessStatus = [Helper bussinessAccountStatus];
        if ([bussinessStatus isEqualToString:@"2"] ||[bussinessStatus isEqualToString:@"4"]  ) {
            if (![Helper isPrivateAccount]) {
                
                UIButton *bussinessBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
                [bussinessBtn setTitle: @"+BIZ" forState:UIControlStateNormal];
                [Helper setButton:bussinessBtn Text: @"+BIZ" WithFont:LatoReg FSize:15 TitleColor:[UIColor blackColor] ShadowColor:nil];
                
                [bussinessBtn addTarget:self action:@selector(BussinessButton:) forControlEvents:UIControlEventTouchUpInside];
                [bussinessBtn setFrame:CGRectMake(20,-5.0f, 40, 40)];
                [leftBarButtonItems addSubview:bussinessBtn];
            }
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButtonItems];
        
    }
    else {
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
}

-(void)BussinessButton:(id)sender
{
    //    businessHelpViewController *businessVC = [[businessHelpViewController alloc] init];
    //    [self presentViewController:businessVC animated:YES completion:nil];
    
    businessHelpViewController *businessVC = [[businessHelpViewController alloc] init];
    businessVC.fromController = @"profile";
    // self.hidesBottomBarWhenPushed = YES;
    
    
    [UIView transitionWithView:self.view.window
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        self.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:businessVC animated:NO];
                        [businessVC.navigationController setNavigationBarHidden:YES];
                        self.hidesBottomBarWhenPushed=NO;
                    }
                    completion:NULL];
    
    
}

-(void)discoverPeopleButtonAction {
    PGDiscoverPeopleViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"discoverPeopleStoryBoardId"];
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) updateMemberDetails:(NSDictionary *)profiledetails{
        //getting follow/following/requestforfollow status.
    
    self.numberOfPostsLabelOutlet.text = [NSString stringWithFormat:@"%@",profiledetails[@"totalPosts"]];
    self.numberOfFollowersLabelOutlet.text = [NSString stringWithFormat:@"%@",profiledetails[@"followers"]];
    self.numberOfFollowingLabelOutlet.text =  [NSString stringWithFormat:@"%@",profiledetails[@"following"]];
    
    if(checkingOwnProfile)
    {
        if ([flStrForObj(profiledetails[@"websiteUrl"]) length]) {
            [[NSUserDefaults standardUserDefaults]setValue:flStrForObj(profiledetails[@"websiteUrl"]) forKey:@"ProfileWebUrl"];
        }
        if ([flStrForObj(profiledetails[@"phoneNumber"]) length]) {
            [[NSUserDefaults standardUserDefaults]setObject:flStrForObj(profiledetails[@"phoneNumber"]) forKey:@"ProfileContact"];
        }
        if ([flStrForObj(profiledetails[@"email"]) length]) {
            [[NSUserDefaults standardUserDefaults]setObject:flStrForObj(profiledetails[@"email"]) forKey:@"ProfileEmail"];
        }
        if ([flStrForObj(profiledetails[@"bio"]) length]) {
            [[NSUserDefaults standardUserDefaults]setObject:flStrForObj(profiledetails[@"bio"]) forKey:@"Profilebio"];
        }
        
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
    
    
    
    //if user checking his own profile then edit profile button we need to display otherwise based on status we need to show follow or following title.
    
    if ([flStrForObj(profiledetails[@"memberFollowRequestStatus"]) isEqualToString:@"0"] && !checkingOwnProfile) {
        
        _messageLabelForFollowRequest.text  = [self.checkProfileOfUserNmae stringByAppendingString:@" wants to follow you"];
        
        _followRequestMessageHeightConstraint.constant = 0;
        [UIView animateWithDuration:0.1 animations:^ {
            _followRequestMessageHeightConstraint.constant = 50;
        }];
    }
    
    NSString *userfollowingstatus =  [NSString stringWithFormat:@"%@",profiledetails[@"userFollowRequestStatus"]];
    
    if (checkingOwnProfile)     {
        [self.editProfileButtonOutlet  setTitle:@"EDIT PROFILE" forState:UIControlStateNormal];
    }
    else {
        
        // userfollowingstatus : null (no follow request) ---- >(Title:Follow)
        // userfollowingstatus : 0 (requested to follow) ---- >(REQUESTED)
        //userfollowingstatus : 1 (accepted and follwoing) ---- >(Title:Following)
        
        
        
        self.followersButtonOutlet.enabled = NO;
        self.followingButtonOutlet.enabled = NO;
        self.photosOfYouButtonOutlet.enabled = NO;
        self.mapButtonOutlet.enabled = NO;
        
        
        if ([userfollowingstatus isEqualToString:@"0"]) {
            [self.editProfileButtonOutlet  setTitle:@" REQUESTED" forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            self.editProfileButtonOutlet .backgroundColor= requstedButtonBackGroundColor;
            self.editProfileButtonOutlet .layer.borderColor = [UIColor clearColor].CGColor;
            
        }
        else if ([userfollowingstatus isEqualToString:@"1"]) {
            [self.editProfileButtonOutlet  setTitle:@" Following" forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
            _editProfileButtonOutlet.backgroundColor = followingButtonBackGroundColor;
            _editProfileButtonOutlet.layer.borderColor = [UIColor clearColor].CGColor;
            
            
            
            
            if ([self.numberOfFollowersLabelOutlet.text isEqualToString:@"0"]) {
                self.followersButtonOutlet.enabled = NO;
                
            }
            else{
                self.followersButtonOutlet.enabled = YES;
                
            }
            
            if ([self.numberOfFollowingLabelOutlet.text isEqualToString:@"0"]) {
                self.followingButtonOutlet.enabled = NO;
            }
            else {
                self.followingButtonOutlet.enabled = YES;
            }
            self.photosOfYouButtonOutlet.enabled = YES;
            self.mapButtonOutlet.enabled = YES;
        }
        else
        {
            [self.editProfileButtonOutlet  setTitle:@" Follow" forState:UIControlStateNormal];
            [self.editProfileButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            
            [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
            
            self.editProfileButtonOutlet .backgroundColor= followButtonBackGroundColor;
            self.editProfileButtonOutlet .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            
            
            if (![memberPrivateAccountState isEqualToString:@"1"]) {
                
                //public account
                
                if ([self.numberOfFollowersLabelOutlet.text isEqualToString:@"0"]) {
                    self.followersButtonOutlet.enabled = NO;
                    
                }
                else{
                    self.followersButtonOutlet.enabled = YES;
                    
                }
                
                if ([self.numberOfFollowingLabelOutlet.text isEqualToString:@"0"]) {
                    self.followingButtonOutlet.enabled = NO;
                }
                else {
                    self.followingButtonOutlet.enabled = YES;
                    
                }
                
                self.photosOfYouButtonOutlet.enabled = YES;
                self.mapButtonOutlet.enabled = YES;
            }
        }
        
        _editProfileButtonOutlet.layer.cornerRadius = 5;
        _editProfileButtonOutlet.layer.borderWidth = 1;
    }
    _webSiteUrlLabelOutlet.text = flStrForObj(profiledetails[@"websiteUrl"]);
    
    NSString *bussinessStatus = flStrForObj(profiledetails[@"businessProfile"]);
    //[Helper bussinessAccountStatus];
    if ([bussinessStatus isEqualToString:@"1"]) {
        _userNameLabelOutlet.text =flStrForObj(profiledetails[@"businessName"]);
        _biodataLabelOutlet.text = flStrForObj(profiledetails[@"aboutBusiness"]);
        profileContact = flStrForObj(profiledetails[@"phoneNumber"]);
        [self contactBtn];
    }
    else
    { _biodataLabelOutlet.text = flStrForObj(profiledetails[@"bio"]);
        _userNameLabelOutlet.text =flStrForObj(profiledetails[@"fullName"]);
        self.contactButtonWidthConstaraint.constant = 0;
    }

    self.privateAccountState = flStrForObj(profiledetails[@"private"]);
    
    
    ProfilePicUrl = flStrForObj(profiledetails[@"profilePicUrl"]);
    if ([ProfilePicUrl isEqualToString:@"defaultUrl"]) {
        _profilePhotoOutlet.image = [UIImage imageNamed:@"defaultpp.png"];
    }
    else {
        [_profilePhotoOutlet sd_setImageWithURL:[NSURL URLWithString:ProfilePicUrl] placeholderImage:[UIImage imageNamed:@"defaultpp"]];
    }
    
    [self changeTheTopcontentViewHeight];
}

-(void)removeRelatedDataOfDeletePost:(NSInteger )atSection {
    
    [userPostsData removeObjectAtIndex:atSection];
}

-(void)reportOption:(NSString*)postId andUserName:(NSString *)posteUser{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"It's Spam" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSDictionary *requestDict = @{mauthToken :[Helper userToken],
                                      mpostid :postId,
                                      @"reasonFlag":@"0",
                                       @"membername":flStrForObj(posteUser)
                                      };
        [self reportRequest:requestDict];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"It's inappropriate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSDictionary *requestDict = @{mauthToken :[Helper userToken],
                                      mpostid :postId,
                                      @"reasonFlag":@"1",
                                       @"membername":flStrForObj(posteUser)
                                      };
        [self reportRequest:requestDict];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // OK button tapped.
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

-(void)reportRequest:(NSDictionary *)dic
{
    [WebServiceHandler sendreportPost:dic andDelegate:self];
}

-(void)reportPost:(NSInteger)selectedSection{
    NSDictionary *dic = userPostsData[selectedSection];
    NSString *postId = flStrForObj([dic objectForKey:@"postId"] );
    NSString *postedUser = flStrForObj([dic objectForKey:@"postedByUserName"]);
    [self reportOption:postId andUserName:postedUser];
    
    
}


/*-----------------------------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*----------------------------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
    [avInNavBar stopAnimating];
    [self createNavSettingButton];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        
        if (self.customTableView.numberOfSections >0) {
            self.noPhotosAvailableLabel.hidden = NO;
            self.noPhotosAvailableLabel.text = [error localizedDescription];
            self.actiVityViewIndicator.hidden = YES;
            self.collectionViewHeight.constant = 100;
        }
        return;
    }
    
    //storing the response from server to dictonary.
    NSDictionary *responseDict = (NSDictionary*)response;
    //checking the request type and handling respective response code.
    if (requestType == RequestTypeLikeAPost) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePostDetails" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"profilePicUrl"]];
            }
                break;
            case 9584: {
                NSDictionary *likeDictonaty = responseDict[@"likeResponse"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePostDetails" object:[NSDictionary dictionaryWithObject:likeDictonaty forKey:@"profilePicUrl"]];
            }
                break;
            default:
                break;
        }
    }
    if (requestType == RequestTypeaccceptFollowRequest) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePrivateRequstedPeopleNumber" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"statusForRequst"]];
    }
    
    if (requestType == RequestTypemakeUserProfileDetails) {
        [self updateDetailsOfUser:response];
    }
    else if (requestType == RequestTypereportPost)
    {
        if ([responseDict[@"code"]integerValue] == 200) {
            [Helper showAlertWithTitle:@"Thanks for reporting this post" Message:@"Your feedback is important in helping us keep the Picogram community safe."];
        }
    }
    else if (requestType == RequestTypeUnlikeAPost) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePostDetails" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"profilePicUrl"]];
            }
                break;
            default:
                break;
        }
    }
    else if (requestType == RequestTypeDeletePost) {
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deletePost" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"deletedPostDetails"]];
                
            }
                break;
            case 90114: {
                
            }
                break;
            default:
                break;
        }
    }
    
    if (requestType == RequestTypemakePostRequest ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                NSArray * responsedataOfMemberDetails =  response[@"data"];
                if (responsedataOfMemberDetails.count >0){
                    
                    userPostsData =  response[@"memberPostsData"];
                    [userPostsData setValue:flStrForObj(self.navigationItem.title) forKey:@"postedByUserName"];
                    
                    [self.customTableView reloadData];
                    [self.collectionView reloadData];
                    
                    self.editProfileButtonOutlet.enabled = YES;
                    [self calculateCollectionViewHeight];
                    
                    self.mainActivityViewController.hidden = YES;
                    self.mainTableAndCollectionViewSuperView.hidden= NO;
                    
                }
                else {
                    [self messageWhenNoPostsAvaliable];
                    self.collectionViewHeight.constant = 100;
                }
                
                
                [self updateMemberDetails:response[@"memberProfileData"][0]];
                
            }
                break;
                //failure response.
            case 1971: {
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
            case 19010: {
                [self messageWhenNoPostsAvaliable];
                self.collectionViewHeight.constant = 100;
            }
            default:
                break;
        }
    }
    
    //user own details request.
    if (requestType == RequestTypeUserProfileDetails) {
        
        [refreshControl endRefreshing];
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                NSArray * responsedataOfMemberDetails =  response[@"memberPostsData"];
                
                ProfilePicUrl = flStrForObj(response[@"memberProfileData"][0][@"profilePicUrl"]);
                
                if (responsedataOfMemberDetails.count >0) {
                    userPostsData =  response[@"memberPostsData"];
                    
                    [userPostsData setValue:flStrForObj(self.navigationItem.title) forKey:@"postedByUserName"];
                    
                    [self.customTableView reloadData];
                    [self.collectionView reloadData];
                    
                    self.editProfileButtonOutlet.enabled = YES;
                    [self calculateCollectionViewHeight];
                    
                    self.mainActivityViewController.hidden = YES;
                    self.mainTableAndCollectionViewSuperView.hidden= NO;
                    
                }
                else {
                    [self messageWhenNoPostsAvaliable];
                    self.collectionViewHeight.constant = 100;
                }
                
                
                [self updateMemberDetails:response[@"memberProfileData"][0]];
                
                
                
                
                if ([self.numberOfFollowingLabelOutlet.text isEqualToString:@"0"]) {
                    self.followingButtonOutlet.enabled = NO;
                }
                else {
                    self.followingButtonOutlet.enabled = YES;
                }
                
                if ([self.numberOfFollowersLabelOutlet.text isEqualToString:@"0"]) {
                    self.followersButtonOutlet.enabled = NO;
                }
                else {
                    self.followersButtonOutlet.enabled = YES;
                }
            }
                break;
        }
    }
    
    if (requestType == RequestTypemakeMemberPosts) {
        
        [refreshControl endRefreshing];
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                NSArray * responsedataOfMemberDetails =  response[@"memberPostsData"];
                if (responsedataOfMemberDetails.count >0){
                    
                    //if the member private status is 0 then no need to check posts can show to all  and
                    //if the member private status is 1 then we need to check followflag is 1 then we need to show the data.
                    //if follow flag is 0 then  no need to show data.
                    
                    memberPrivateAccountState  =  flStrForObj(response[@"memberProfileData"][0][@"privateMember"]);
                    
                    self.privateAccountState = flStrForObj(response[@"memberProfileData"][0][@"privateUser"]);
                    
                    if ([flStrForObj(memberPrivateAccountState) isEqualToString:@"1"]) {
                        
                        NSLog(@"member account is private ");
                        
                        if([flStrForObj(response[@"memberProfileData"][0][@"userFollowRequestStatus"]) isEqualToString:@"1"] || checkingOwnProfile) {
                            
                            userPostsData =  response[@"memberPostsData"];
                            [userPostsData setValue:flStrForObj(self.navigationItem.title) forKey:@"postedByUserName"];
                            [self.customTableView reloadData];
                            [self.collectionView reloadData];
                            
                            self.editProfileButtonOutlet.enabled = YES;
                            [self calculateCollectionViewHeight];
                            
                            self.mainActivityViewController.hidden = YES;
                            self.mainTableAndCollectionViewSuperView.hidden= NO;
                            
                            [self updateMemberDetails:response[@"memberProfileData"][0]];
                        }
                        else {
                            [self updateMemberDetails:response[@"memberProfileData"][0]];
                            //no need to show posts.
                            [self showingMessageForPrivateAccount];
                        }
                    }
                    else {
                        NSLog(@"member account is public ");
                        userPostsData =  response[@"memberPostsData"];
                        [userPostsData setValue:flStrForObj(self.navigationItem.title) forKey:@"postedByUserName"];
                        [self.customTableView reloadData];
                        [self.collectionView reloadData];
                        self.editProfileButtonOutlet.enabled = YES;
                        [self calculateCollectionViewHeight];
                        self.mainActivityViewController.hidden = YES;
                        self.mainTableAndCollectionViewSuperView.hidden= NO;
                    }
                }
                else {
                    
                    memberPrivateAccountState  =  flStrForObj(response[@"memberProfileData"][0][@"privateMember"]);
                    
                    self.privateAccountState = flStrForObj(response[@"memberProfileData"][0][@"privateUser"]);
                    
                    if ([flStrForObj(memberPrivateAccountState) isEqualToString:@"1"]) {
                          [self showingMessageForPrivateAccount];
                    }
                    else {
                         [self messageWhenNoPostsAvaliable];
                    }
                    self.collectionViewHeight.constant = 100;
                }
                [self updateMemberDetails:response[@"memberProfileData"][0]];
                break;
            }
            case 1800: {
                NSLog(@"user not found");
                _webSiteUrlLabelOutlet.text = @"";
                _biodataLabelOutlet.text =@"";
                _userNameLabelOutlet.text = @"";
                [self changeTheTopcontentViewHeight];
                self.numberOfPostsLabelOutlet.text = @"-";
                self.numberOfFollowersLabelOutlet.text =@"-";
                self.numberOfFollowingLabelOutlet.text = @"-";
                [self.editProfileButtonOutlet setTitle:@"No User Found" forState:UIControlStateNormal];
                [self.editProfileButtonOutlet setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                self.followersButtonOutlet.enabled = NO;
                self.followingButtonOutlet.enabled = NO;
                self.editProfileButtonOutlet.enabled = NO;
                self.collectionViewHeight.constant = 100;
                self.mapButtonOutlet.enabled = NO;
                self.tableViewButtonOutlet.enabled = NO;
                self.collectionViewButtonOutlet.enabled = NO;
                self.postedPhotosButtonOutlet.enabled = NO;
                self.photosOfYouButtonOutlet.enabled = NO;
                self.actiVityViewIndicator.hidden = YES;
            }
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

-(void)dealloc {
    self.collectionView.delegate =nil;
    self.collectionView.dataSource = nil;
    self.customTableView.delegate =  nil;
    self.customTableView.dataSource = nil;
    [self clearImageCache];
}

-(void)updateDetailsOfUser:(id)response {
    self.numberOfFollowingLabelOutlet.text = flStrForObj(response[@"data"][1][0][@"followingCount"]);
    self.numberOfFollowersLabelOutlet.text = flStrForObj(response[@"data"][2][0][@"followerCount"]);
    
    if ([self.numberOfFollowersLabelOutlet.text isEqualToString:@"0"]) {
        self.followersButtonOutlet.enabled = NO;
        
    }
    else{
        self.followersButtonOutlet.enabled = YES;
    }
    
    if ([self.numberOfFollowingLabelOutlet.text isEqualToString:@"0"]) {
        self.followingButtonOutlet.enabled = NO;
    }
    else {
        self.followingButtonOutlet.enabled = YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"editProfileSegue"]) {
        
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        EditProfileViewController *controller = (EditProfileViewController *)navController.topViewController;
        controller.necessarytocallEditProfile = YES;
        controller.pushingVcFrom = @"ProfileScreen";
        controller.profilepic = _profilePhotoOutlet.image;
    }
    if ([segue.identifier isEqualToString:@"mapButonSegue"]) {
        MapViewController     *mapvc = [segue destinationViewController];
        mapvc.checkingPhotoMapOf =   self.navigationItem.title;
        mapvc.postDetails = userPostsData;
    }
    if ([segue.identifier isEqualToString:@"settingButtonToOptionsSegue"]) {
        OptionsViewController *optionsVc  = [segue destinationViewController];
        optionsVc.token = flStrForObj([Helper userToken]);
        optionsVc.privateAccountState = self.privateAccountState;
        optionsVc.delegate=self;
    }
    
    if ([segue.identifier isEqualToString:@"postedPhotoSegue"]) {
        
        if (self.checkingFriendsProfile && self.checkProfileOfUserNmae) {
            PostedPhotosCollectionViewController *vc = [segue destinationViewController];
            vc.getDetailsOfUser = flStrForObj(self.checkProfileOfUserNmae);
        }
        else {
            PostedPhotosCollectionViewController *vc =  [segue destinationViewController];
            vc.getDetailsOfUser = self.navigationItem.title;
            NSLog(@"name:%@",vc.getDetailsOfUser);
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self clearImageCache];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [self clearImageCache];
}
-(void)clearImageCache{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}

/*-----------------------------------------------------*/
#pragma mark -
#pragma mark - CustomActionSheet
/*----------------------------------------------------*/
- (void)showUnFollowAlert:(UIImage *)profieImage and:(NSString *)profileName {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    CGFloat margin = 8.0F;
    UIView *customView;
    customView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0F, 80)];
    
    UIImageView *UserImageView =[[UIImageView alloc] init];
    UserImageView.image = profieImage;
    UserImageView.frame = CGRectMake(customView.frame.size.width/2-20,10,40,40);
    [self.view layoutIfNeeded];
    UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
    UserImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    UserImageView.layer.borderWidth = 2.0;
    UserImageView.layer.masksToBounds = YES;
    //    customView.backgroundColor = [UIColor colorWithRed:0.9753 green:0.9753 blue:0.9753 alpha:1.0];
    customView.backgroundColor =[UIColor clearColor];
    //creating user name label
    UILabel *UserNamelabel = [[UILabel alloc] init];
    NSString *BoldText = [self.navigationItem.title stringByAppendingString:@"?"];
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
    
    UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { [self unfollowAction];}];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    [alertController addAction:somethingAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)unfollowAction {
    NSLog(@"unfollow clicked");
    
    [self.editProfileButtonOutlet  setTitle:@" Follow" forState:UIControlStateNormal];
   [self.editProfileButtonOutlet setTitleColor:followButtonTextColor forState:UIControlStateNormal];
    [self sendNewFollowStatusThroughNotification:flStrForObj(self.checkProfileOfUserNmae) andNewStatus:@"2"];
    [self.editProfileButtonOutlet setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
    [self.view layoutIfNeeded];
    _editProfileButtonOutlet.layer.cornerRadius = 5;
    _editProfileButtonOutlet.layer.borderWidth = 1;
    self.editProfileButtonOutlet .backgroundColor= followButtonBackGroundColor;
    self.editProfileButtonOutlet .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    
    //passing parameters.
    NSDictionary *requestDict = @{muserNameToUnFollow     : self.checkProfileOfUserNmae ,
                                  mauthToken            :flStrForObj([Helper userToken]),
                                  };
    //requesting the service and passing parametrs.
    [WebServiceHandler unFollow:requestDict andDelegate:self];
}

-(void)showCommentsOnPost:(NSInteger )section tableviewcell:(id)sender{
    UserProfileViewTableViewCell  *receivedCell = (UserProfileViewTableViewCell *)sender;
    
    NSArray *response =  [flStrForObj(userPostsData[section][@"comments"]) componentsSeparatedByString:@"^^"];
    NSMutableArray *arrayOffCommentedUserNames = [[NSMutableArray alloc]init];
    NSMutableArray * arrayOfComments = [[NSMutableArray alloc]init];
    for(int i=0;i <response.count-1;i++) {
        NSString* temp = [response objectAtIndex:i+1];
        NSString * userNam = [temp componentsSeparatedByString:@"$$"][0];
        NSString * commen = [temp componentsSeparatedByString:@"$$"][1];
        [arrayOffCommentedUserNames addObject:userNam];
        [arrayOfComments addObject:commen];
    }
    
    if (arrayOfComments.count == 0) {
        receivedCell.commentLabelOne.text = @"";
        receivedCell.commentLabelTwo.text = @"";
    }
    else if (arrayOfComments.count == 1) {
        NSString *commentedUser1 = flStrForObj(arrayOffCommentedUserNames[0]);
        NSString *commentedText1 = flStrForObj(arrayOfComments[0]);
        NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
        
        NSMutableAttributedString * attributtedPostComment1 = [[NSMutableAttributedString alloc] initWithString:postcommentWithUserName1];
        [attributtedPostComment1 addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                                        range:NSMakeRange(0,commentedUser1.length)];
        [attributtedPostComment1 addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:RobotoMedium size:14]
                                        range:NSMakeRange(0, commentedUser1.length)];
        [receivedCell.commentLabelOne setAttributedText:attributtedPostComment1];
        receivedCell.commentLabelTwo.text = @"";
    }
    else {
        
        NSString *commentedUser1 = flStrForObj(arrayOffCommentedUserNames[arrayOffCommentedUserNames.count-1]);
        NSString *commentedText1 = flStrForObj(arrayOfComments[arrayOfComments.count-1]);
        NSString *commentedUser2 = flStrForObj(arrayOffCommentedUserNames[arrayOffCommentedUserNames.count -2]);
        NSString *commentedText2 = flStrForObj(arrayOfComments[arrayOfComments.count-2]);
        
        
        NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
        NSString *postcommentWithUserName2 = [commentedUser2 stringByAppendingFormat:@"  %@",commentedText2];
        NSMutableAttributedString * attributtedPostComment1 = [[NSMutableAttributedString alloc] initWithString:postcommentWithUserName1];
        NSMutableAttributedString * attributtedPostComment2 = [[NSMutableAttributedString alloc] initWithString:postcommentWithUserName2];
        [attributtedPostComment1 addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                                        range:NSMakeRange(0,commentedUser1.length)];
        [attributtedPostComment1 addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:RobotoMedium size:14]
                                        range:NSMakeRange(0, commentedUser1.length)];
        [attributtedPostComment2 addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                                        range:NSMakeRange(0,commentedUser2.length)];
        [attributtedPostComment2 addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:RobotoMedium size:14]
                                        range:NSMakeRange(0, commentedUser2.length)];
        [receivedCell.commentLabelOne setAttributedText:attributtedPostComment1];
        [receivedCell.commentLabelTwo setAttributedText:attributtedPostComment2];
    }
}

- (void)buttonClicked:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = selectedButton.titleLabel.text;
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
}


-(void)arrangeDataInCommonArrayForMemberPosts:(NSMutableArray *)dataFromServerSide {
    
    if(dataFromServerSide.count == 0)
    {
        self.noPhotosAvailableLabel.hidden = NO;
        self.actiVityViewIndicator.hidden = YES;
        self.collectionViewHeight.constant = 100;
    }
    else
    {
        userPostsData =[[NSMutableArray alloc] init];
        for (int i = 0 ; i != dataFromServerSide.count ; i++) {
            [userPostsData addObject: @{
                                        @"postId" : flStrForObj(dataFromServerSide[i][@"postId"]),
                                        @"postsType" : flStrForObj(dataFromServerSide[i][@"postsType"]),
                                        @"likeStatus": flStrForObj(dataFromServerSide[i][@"likedByUser"]),
                                        @"mainUrl":  flStrForObj(dataFromServerSide[i][@"postMainURl"]),
                                        @"numberOfLikes":flStrForObj(dataFromServerSide[i][@"likes"]),
                                        @"postCaption": flStrForObj(dataFromServerSide[i][@"postCaption"]),
                                        @"profilePicUrl":flStrForObj(dataFromServerSide[i][@"profilePicUrl"]),
                                        @"postedByUserName": flStrForObj(self.checkProfileOfUserNmae),
                                        @"place": flStrForObj(dataFromServerSide[i][@"place"]),
                                        @"comments":flStrForObj(dataFromServerSide[i][@"comments"]),
                                        @"postedOn": flStrForObj(dataFromServerSide[i][@"postedOn"]),
                                        @"hashtags":flStrForObj(dataFromServerSide[i][@"hashtags"]),
                                        @"usersTagged":flStrForObj(dataFromServerSide[i][@"usersTagged"]),
                                        @"thumbnailImageUrl":flStrForObj(dataFromServerSide[i][@"thumbnailImageUrl"]),
                                        @"longitude":flStrForObj(dataFromServerSide[i][@"latitude"]),
                                        @"latitude":flStrForObj(dataFromServerSide[i][@"longitude"]),
                                        }];
        }
        self.editProfileButtonOutlet.enabled = YES;
        [self calculateCollectionViewHeight];
        
        [self.customTableView reloadData];
        [self.collectionView reloadData];
        
        self.mainActivityViewController.hidden = YES;
        self.mainTableAndCollectionViewSuperView.hidden= NO;
    }
}

-(void)arrangeDataInCommonArrayForUserOwnPosts:(NSMutableArray *)dataFromServerSide {
    
    userPostsData =[[NSMutableArray alloc] init];
    for (int i = 0 ; i != dataFromServerSide.count ; i++) {
        [userPostsData addObject: @{
                                    @"postId" : flStrForObj(dataFromServerSide[i][@"postsId"]),
                                    @"postsType" : flStrForObj(dataFromServerSide[i][@"poststype"]),
                                    @"likeStatus": flStrForObj(dataFromServerSide[i][@"likedByUser"]),
                                    @"mainUrl":  flStrForObj(dataFromServerSide[i][@"mainUrl"]),
                                    @"numberOfLikes":flStrForObj(dataFromServerSide[i][@"likes"]),
                                    @"postCaption": flStrForObj(dataFromServerSide[i][@"caption"]),
                                    @"profilePicUrl":flStrForObj(dataFromServerSide[i][@"profilePicUrl"]),
                                    @"postedByUserName": flStrForObj([Helper userName]),
                                    @"place": flStrForObj(dataFromServerSide[i][@"place"]),
                                    @"comments":flStrForObj(dataFromServerSide[i][@"comments"]),
                                    @"postedOn":flStrForObj(dataFromServerSide[i][@"postedOn"]),
                                    @"hashtags":flStrForObj(dataFromServerSide[i][@"hashtags"]),
                                    @"usersTagged":flStrForObj(dataFromServerSide[i][@"usersTagged"]),
                                    @"thumbnailImageUrl":flStrForObj(dataFromServerSide[i][@"thumbnailImageUrl"]),
                                    @"postLikedBy":flStrForObj(dataFromServerSide[i][@"postLikedBy"]),
                                    @"longitude":flStrForObj(dataFromServerSide[i][@"latitude"]),
                                    @"latitude":flStrForObj(dataFromServerSide[i][@"longitude"]),
                                    }];
    }
    self.mainActivityViewController.hidden = YES;
    self.mainTableAndCollectionViewSuperView.hidden= NO;
    [self calculateCollectionViewHeight];
    
    [self.customTableView reloadData];
    [self.collectionView reloadData];
}

-(void)replaceObjectAt:(NSInteger )replaceAt numberofLikes:(NSString * )newnumberOfLikes likeStatus:(NSString *)newLikesStatus {
    [userPostsData setObject:@{
                               @"postId" : flStrForObj(userPostsData[replaceAt][@"postId"]),
                               @"postsType" : flStrForObj(userPostsData[replaceAt][@"postsType"]),
                               @"likeStatus": flStrForObj(newLikesStatus),
                               @"mainUrl":  flStrForObj(userPostsData[replaceAt][@"mainUrl"]),
                               @"numberOfLikes":flStrForObj(newnumberOfLikes),
                               @"postCaption": flStrForObj(userPostsData[replaceAt][@"numberOfLikes"]),
                               @"profilePicUrl":flStrForObj(userPostsData[replaceAt][@"profilePicUrl"]),
                               @"postedByuserName": flStrForObj(userPostsData[replaceAt][@"postedByuserName"]),
                               @"place": flStrForObj(userPostsData[replaceAt][@"place"]),
                               @"comments":flStrForObj(userPostsData[replaceAt][@"comments"]),
                               @"postedOn":flStrForObj(userPostsData[replaceAt][@"postedOn"]),
                               @"hashtags":flStrForObj(userPostsData[replaceAt][@"hashtags"]),
                               @"usersTagged":flStrForObj(userPostsData[replaceAt][@"usersTagged"]),
                               @"thumbnailImageUrl":flStrForObj(userPostsData[replaceAt][@"thumbnailImageUrl"]),
                               @"postLikedBy":flStrForObj(userPostsData[replaceAt][@"postLikedBy"]),
                               @"longitude":flStrForObj(userPostsData[replaceAt][@"latitude"]),
                               @"latitude":flStrForObj(userPostsData[replaceAt][@"longitude"])
                               } atIndexedSubscript:replaceAt];
}

-(void)replaceDataForCommentAtIndex:(NSNotification *)noti {
    
    NSInteger updateCellNumber  = [noti.object[@"newCommentsData"][@"selectedCell"] integerValue];
    NSString *updatedComment = flStrForObj(noti.object[@"newCommentsData"][@"data"][0][@"Posts"][@"properties"][@"commenTs"]);
    [userPostsData setObject:@{
                               @"postId" : flStrForObj(userPostsData[updateCellNumber][@"postId"]),
                               @"postsType" : flStrForObj(userPostsData[updateCellNumber][@"postsType"]),
                               @"likeStatus":  flStrForObj(userPostsData[updateCellNumber][@"likeStatus"]),
                               @"mainUrl":  flStrForObj(userPostsData[updateCellNumber][@"mainUrl"]),
                               @"numberOfLikes": flStrForObj(userPostsData[updateCellNumber][@"numberOfLikes"]),
                               @"postCaption": flStrForObj(userPostsData[updateCellNumber][@"numberOfLikes"]),
                               @"profilePicUrl":flStrForObj(userPostsData[updateCellNumber][@"profilePicUrl"]),
                               @"postedByuserName": flStrForObj(userPostsData[updateCellNumber][@"postedByuserName"]),
                               @"place": flStrForObj(userPostsData[updateCellNumber][@"place"]),
                               @"comments":flStrForObj(updatedComment),
                               @"postedOn":flStrForObj(userPostsData[updateCellNumber][@"postedOn"]),
                               @"hashtags":flStrForObj(userPostsData[updateCellNumber][@"hashtags"]),
                               @"usersTagged":flStrForObj(userPostsData[updateCellNumber][@"usersTagged"]),
                               @"thumbnailImageUrl":flStrForObj(userPostsData[updateCellNumber][@"thumbnailImageUrl"]),
                               @"postLikedBy":flStrForObj(userPostsData[updateCellNumber][@"postLikedBy"])
                               } atIndexedSubscript:updateCellNumber];
    
    [_customTableView reloadSections:[NSIndexSet indexSetWithIndex:updateCellNumber] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)sendPrivateStatusToUserProfileVc:(NSString *)newPrivateSt
{
    _privateAccountState = newPrivateSt;
}


- (IBAction)acceptButtonAction:(id)sender {
    [self requestForAcceptFollowOrDeny:@"1"];
    [self removefollowmessageview];
}

- (IBAction)rejectButtonAction:(id)sender {
    [self requestForAcceptFollowOrDeny:@"0"];
    [self removefollowmessageview];
}

-(void)removefollowmessageview {
    _followRequestMessageHeightConstraint.constant = 50;
    [UIView animateWithDuration:0.1 animations:^ {
        _followRequestMessageHeightConstraint.constant = 0;
    }];
}

-(void)requestForAcceptFollowOrDeny:(NSString *)followAction {
    
    //   action  --->   0 : reject,
    //   action  ----> 1 : accept]
    
    NSDictionary *requestDict = @{
                                  mauthToken :flStrForObj([Helper userToken]),
                                  mmembername:_checkProfileOfUserNmae,
                                  mfollowAction:followAction
                                  };
    [WebServiceHandler accceptFollowRequest:requestDict andDelegate:self];
}



-(void)shareToFacebook:(NSInteger )selectedSection {
    NSLog(@"SHAREtO FB of index :%ld ",(long)selectedSection);
    
    NSDictionary *dic = userPostsData[selectedSection];
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showMessage:@"Posting.." On:self.view];
    
    if ([flStrForObj([dic objectForKey:@"postsType"] )isEqualToString:@"0"]) {
        // NSString *mediaLink = [self getWebLinkForFeed:feed];
        
        NSString *caption = NSLocalizedString(@"Checkout this cool app",nil);
        
        // NSString *description;
        
        NSString *picturelink = [Helper getWebLinkForFeed:userPostsData[selectedSection]]; //responseData[selectedSection][@"mainUrl"];
        
        //NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:picturelink]];
        
        NSMutableDictionary *params1 = [NSMutableDictionary dictionaryWithCapacity:3L];
        
        //[params1 setObject:videoData forKey:@"video.mov"];
        [params1 setObject:[NSURL URLWithString:picturelink] forKey:@"link"];
        [params1 setObject:NSLocalizedString(@"Created from Picogram.",nil) forKey:@"title"];
        [params1 setObject:caption forKey:@"description"];
        
        
        [self makeFBPostWithParams:params1];
    }
    else{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock = ^(NSURL *newURL, NSError *error) {
            if (error)
            {
                NSLog( @"Error writing image with metadata to Photo Library: %@", error );
            }
            else
            {
                NSLog(@"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
                
                FBSDKShareVideo* video = [FBSDKShareVideo videoWithVideoURL:newURL];
                
                FBSDKShareVideoContent* content = [[FBSDKShareVideoContent alloc] init];
                content.video = video;
                [FBSDKShareAPI shareWithContent:content delegate:nil];
            }
        };
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Downloading Started");
            NSString *urlToDownload = userPostsData[selectedSection][@"mainUrl"];
            NSURL  *url = [NSURL URLWithString:urlToDownload];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
                
                
                
                
                //saving is done on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:filePath atomically:YES];
                    NSLog(@"File Saved !");
                    
                    
                    NSURL *videoURL = [NSURL URLWithString:filePath];
                    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL])
                    {
                        [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:videoWriteCompletionBlock];
                    }
                    
                    
                });
            }
            
        });
        
        
    }
    
}


/**
 *  NPost the media with its description on facebook
 *
 *  @param params mediatype,caption,mediaLink
 */

- (void) makeFBPostWithParams:(NSDictionary*)params
{
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:params[@"link"]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
            sharePhoto.caption = params[@"title"]; //@"Test Caption";
            sharePhoto.image = image;//[UIImage imageNamed:@"BGI.jpg"];
            FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
            content.photos = @[sharePhoto];
            
            [FBSDKShareAPI shareWithContent:content delegate:nil];
        });
        
    }
    else{
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
       
        
        
        
        [login logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           NSLog(@"Process error");
                                       } else if (result.isCancelled)
                                       {
                                           NSLog(@"Cancelled");
                                       }
                                       else
                                       {
                                           NSLog(@"Logged in");
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
                                               sharePhoto.caption = params[@"title"]; //@"Test Caption";
                                               sharePhoto.image = image;//[UIImage imageNamed:@"BGI.jpg"];
                                               
                                               
                                               FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
                                               content.photos = @[sharePhoto];
                                               
                                               [FBSDKShareAPI shareWithContent:content delegate:nil];
                                           });
                                       }
                                   }];
        
    }
    
}




#pragma mark - MoreActions


-(void)copyShareURL:(NSInteger )selectedSection {
    [errorMessageLabelOutlet setHidden:NO];
    [self showingErrorAlertfromTop:@"Link copied to clipboard."];
    NSLog(@"copyShareURL of index :%ld ",(long)selectedSection);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *copymainurl = userPostsData[selectedSection][@"mainUrl"];
    pasteboard.string = copymainurl;
}

-(void)turnOnPostNotifications:(NSInteger )selectedSection {
    NSLog(@"turnOnPostNotifications of index :%ld ",(long)selectedSection);
    
    
}

- (void)paste {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = pasteboard.string;
    NSLog(@"%@",string);
}

-(void)deletePost:(NSInteger)selectedSection{
    // NSDictionary *dic = _dataArray[selectedSection];
    UIAlertView *alertForDeleteConfirmation =[[UIAlertView alloc] initWithTitle:@"Confirm To Delete" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alertForDeleteConfirmation show];
    alertForDeleteConfirmation.tag = 26;
    
    NSLog(@"Deleting post");
}

-(void)sharePost:(NSInteger)selectedSection{
    
    SharingPostViewController *postshare = [self.storyboard instantiateViewControllerWithIdentifier:@"sharingPost"];
    postshare.postDetailsDic = userPostsData[selectedSection];
    [self.navigationController pushViewController:postshare animated:YES];
}

#pragma mark-Error Alert
-(void)showingErrorAlertfromTop:(NSString *)message {
    [errorMessageLabelOutlet setHidden:NO];
    
    [errorMessageLabelOutlet setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    [self.view layoutIfNeeded];
    errorMessageLabelOutlet.text = message;
    
    /**
     *  changing the error message view position if user enter  wrong number
     */
    
    [UIView animateWithDuration:0.4 animations:
     ^ {
         
         [self.view layoutIfNeeded];
     }];
    
    int duration = 2; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:
         ^ {
             [errorMessageLabelOutlet setFrame:CGRectMake(0, -100, [UIScreen mainScreen].bounds.size.width, 100)];
             [errorMessageLabelOutlet setHidden:YES];
             [self.view layoutIfNeeded];
         }];
    });
}

-(void)showingMessageForPrivateAccount {
    
    self.mainTableAndCollectionViewSuperView.hidden = YES;
    self.mainActivityViewController.hidden = NO;
    self.noPhotosAvailableImageViewOutlet.image = [UIImage imageNamed:@"edit_profile_two_lock_icon"];
    self.noPhotosAvailableLabel.text = @"This Account is Private. Follow to see their photos and videos.";
    self.noPhotosAvailableLabel.textAlignment = NSTextAlignmentCenter;
    self.noPhotosAvailableLabel.numberOfLines = 0;
    self.noPhotosAvailableLabel.hidden = NO;
    self.noPhotosAvailableImageViewOutlet.hidden = NO;
    self.actiVityViewIndicator.hidden = YES;
}

-(void)messageWhenNoPostsAvaliable {
    self.noPhotosAvailableLabel.textAlignment = NSTextAlignmentCenter;
    self.noPhotosAvailableLabel.numberOfLines = 0;
    self.noPhotosAvailableLabel.hidden = NO;
    self.noPhotosAvailableImageViewOutlet.hidden = NO;
    self.actiVityViewIndicator.hidden = YES;
}

- (IBAction)contactButtonAction:(id)sender {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Get Direction" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self getDirection];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self call];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showMailPanel];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // OK button tapped.
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}


-(void)showAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled!"
                                                        message:@"Please enable Location Based Services for better results! We promise to keep your location private"
                                                       delegate:self
                                              cancelButtonTitle:@"Settings"
                                              otherButtonTitles:@"Cancel", nil];
    
    
    //TODO if user has not given permission to device
    if (![CLLocationManager locationServicesEnabled])
    {
        alertView.tag = 1001;
    }
    //TODO if user has not given permission to particular app
    else
    {
        alertView.tag = 2001;
    }
    
    [alertView show];
    
    return;
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        lattitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        NSLog(@"edges:%@ & %@",longitude,lattitude);
        //currentLatitude = currentLocation.coordinate.latitude;
        // currentLongitude = currentLocation.coordinate.longitude;
        
        [[NSUserDefaults standardUserDefaults]setObject:longitude forKey:@"longitude"];
        [[NSUserDefaults standardUserDefaults]setObject:lattitude forKey:@"lattitude"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
             if (error == nil && [placemarks count] > 0) {
                 placemark = [placemarks lastObject];
                 address = placemark.subLocality;
                 NSLog(@"user location %@",address);
  
             }
             else
             {
                 NSLog(@"%@", error.debugDescription);
             }
         } ];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
}

-(void)openProfileOfUsername:(NSString *)selectedUserName {
    if ([selectedUserName isEqualToString:@""]) {
        
    }
    else{
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        newView.checkingFriendsProfile = YES;
        newView.checkProfileOfUserNmae = selectedUserName;
        [self.navigationController pushViewController:newView animated:YES];
    }
}

- (IBAction)captionUserNameButtonAction:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
}


- (IBAction)firstCommentUserNameButtonAction:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
}

- (IBAction)secondCommentUserNameButtonAction:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
}
@end
